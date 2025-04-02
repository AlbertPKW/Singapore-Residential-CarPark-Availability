import dlt
from dlt.sources.helpers import requests
from typing import Dict, Any, Iterator, List
from pydantic import BaseModel
from datetime import datetime

# Define Pydantic models for the nested API response structure
class CarparkInfoItem(BaseModel):
    total_lots: str
    lot_type: str
    lots_available: str

class CarparkData(BaseModel):
    carpark_info: List[CarparkInfoItem]
    carpark_number: str
    update_datetime: str

class CarparkItem(BaseModel):
    timestamp: str
    carpark_data: List[CarparkData]

class ApiResponse(BaseModel):
    items: List[CarparkItem]

# Define the output model for the flattened data
class CarparkInfo(BaseModel):
    carpark_number: str
    lot_type: str
    timestamp: datetime
    total_lots: int
    lots_available: int
    update_datetime: datetime

@dlt.resource(
    name="carpark_availability",
    write_disposition="append",
    primary_key=["carpark_number", "lot_type"],
    columns=CarparkInfo
)
def carpark_data_resource(date_time_slot) -> Iterator[Dict[str, Any]]:
    
    url = "https://api.data.gov.sg/v1/transport/carpark-availability"
    params={"date_time": date_time_slot}

    # Get data from the API
    response = requests.get(url, params=params)

    # Parse the response with Pydantic
    api_data = ApiResponse.parse_obj(response.json())

    # Flatten the data using Pydantic models
    for item in api_data.items:
        timestamp = item.timestamp
        for carpark in item.carpark_data:
            carpark_number = carpark.carpark_number
            update_datetime = carpark.update_datetime

            for info in carpark.carpark_info:
                # Create and yield a CarparkInfo object
                # Pydantic will handle the type conversions
                carpark_record = CarparkInfo(
                    carpark_number=carpark_number,
                    lot_type=info.lot_type,
                    timestamp=timestamp,
                    total_lots=int(info.total_lots),
                    lots_available=int(info.lots_available),
                    update_datetime=update_datetime
                )

                # Convert to dict for yielding
                yield carpark_record.dict()

# Create a pipeline
pipeline = dlt.pipeline(
    pipeline_name="carpark_data_pipeline",  # Name of your pipeline
    destination="filesystem",               # filesystem, bigquery
    dataset_name="carpark_data"             # change to sg_carpark_dataset
)

date_time = "2025-03-20T20:05:00+08:00"

# Run the pipeline with your resource
load_info = pipeline.run(carpark_data_resource(date_time), loader_file_format="parquet") # loader_file_format="parquet"

# Print information about the load
print(load_info)