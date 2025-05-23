# Project Notes - Learning in Public

## Kestra Plugins

### Load​From​Gcs

```type: "io.kestra.plugin.gcp.bigquery.LoadFromGcs"```

The LoadFromGcs plugin enables direct import of data from Google Cloud Storage (GCS) into a BigQuery table. It's particularly useful for analyzing and extracting insights from static data files stored in GCS. The plugin supports multiple file formats, including Avro, JSON, Parquet, ORC, and CSV.

```
tasks:
  - id: load_table
    type: io.kestra.plugin.gcp.bigquery.LoadFromGcs
    from:
      - "{{render(vars.gcs_file)}}"
    destinationTable: "{{kv('GCP_PROJECT_ID')}}.{{kv('GCP_DATASET')}}.hdb_carpark_info"
    ignoreUnknownValues: true
    format: CSV
    csvOptions:
      fieldDelimiter: ","
      encoding: UTF-8
      allowJaggedRows: true
      skipLeadingRows: 1
    createDisposition: CREATE_IF_NEEDED   
    writeDisposition: WRITE_TRUNCATE
    schema:
      fields:
        - name: car_park_no
          type: STRING
          description: Carpark Alpha-numeric Code
        - name: address
          type: STRING
          description: Carpark Address
        ...
```

* **allowJaggedRows**: Specifies whether BigQuery should allow rows with missing trailing optional columns. If set to true, missing trailing columns are treated as null. If false (default), such rows are considered bad records, and too many will cause the job to fail.
* **createDisposition**: This paramenter defines whether the job is allowed to create tables. ```CREATE_IF_NEEDED``` create table if it does not exist and pass through when table exist, while ```CREATE_NEVER``` will not create table in any circumstance.
* **writeDisposition**: Determines how to handle existing tables when writing query results. ```WRITE_TRUNCATE``` replaces all existing rows, while ```WRITE_APPEND``` adds results to the current table data.


### ​Download

```type: "io.kestra.plugin.core.http.Download"```

Retrieve a file from an HTTP server. This task establishes a connection to an HTTP server and transfers the file into Kestra’s internal storage.

```
tasks:
  - id: get_zipfile
    type: io.kestra.plugin.core.http.Download
    uri: https://gist.github.com/samuelyeewl/246258d00910390b0859f864645c00c8/archive/ab82ef3ac41da254ae1cbea4ecf77352d9ad3018.zip
```


### ​Archive​Decompress

```type: "io.kestra.plugin.compress.ArchiveDecompress"```

Decompress an archive file.

```
tasks:
  - id: unzip
    type: io.kestra.plugin.compress.ArchiveDecompress
    algorithm: ZIP
    from: "{{ outputs.get_zipfile.uri }}"
```


### Python Script

```type: "io.kestra.plugin.scripts.python.script"```

Execute a Python script.

```
tasks:
  - id: process_json
    type: io.kestra.plugin.scripts.python.Script
    containerImage: ghcr.io/kestra-io/pydata:latest
    env:
      CREDENTIALS__PROJECT_ID: "{{kv('GCP_PROJECT_ID')}}"
      CREDENTIALS__PRIVATE_KEY: "{{kv('GCP_CREDS')['private_key']}}"
    outputFiles:
      - "*.json"
    script: |
    
      import json

      with open("{{render(vars.data)}}") as f:
          data = json.load(f)
      with open("{{vars.features_file}}", "w") as out:
          for feature in data['features']:
              out.write(json.dumps(feature) + '\n')
```

* **beforeCommands**: A list of commands that will run before the commands, allowing to set up the environment e.g. pip install -r requirements.txt.
* **containerImage**: The task runner container image, only used if the task runner is container-based.


### Delete​Table

```type: "io.kestra.plugin.gcp.bigquery.DeleteTable"```

Delete a BigQuery table or a BigQuery partition

```
tasks:
  - id: delete_ext_table
    type: io.kestra.plugin.gcp.bigquery.DeleteTable
    projectId: "{{kv('GCP_PROJECT_ID')}}"
    dataset: "{{kv('GCP_DATASET')}}"
    table: "{{render(vars.del_table)}}_ext"
```


### Subflow

```type: "io.kestra.plugin.core.flow.Subflow"```

Subflows provide a modular approach to reusing workflow logic, allowing one flow to invoke another flow similarly to how functions are called in programming languages. When a parent flow is restarted, any subflows that were previously executed will also be restarted.

```
tasks:
  - id: call_subflow
    type: io.kestra.plugin.core.flow.Subflow
    description: This task triggers the flow `05_gcp_dbt` without inputs.
    namespace: "{{ flow.namespace}}"
    flowId: 05_gcp_dbt
    wait: true
    transmitFailed: true
```

* **wait**: Whether to wait for the subflow execution to finish before continuing the current execution.
* **transmitFailed**: Whether to fail the current execution if the subflow execution fails or is killed. Note that this option works only if wait is set to true.


## JQ

JQ is a lightweight command-line utility designed specifically for processing JSON data. 

```data: "{{ outputs.unzip.files | jq('.[] | select(. | endswith(\"master_plan_boundaries.json\")) | .') | first }}"```

The purpose of this expression is to locate the specific JSON file named "master_plan_boundaries.json" from all the files that were extracted from the zip archive, without needing to know its exact path within the archive structure. This value is then stored in the ```data``` variable, which is used later in the workflow, specifically in the Python script that processes the JSON data.

1. ```outputs.unzip.files``` - This references the list of files that were extracted by the "unzip" task. After decompression, Kestra makes the list of files available through this variable.

2. ```| jq('.[] | select(. | endswith(\"master_plan_boundaries.json\")) | .')``` - This applies a jq filter to process the file list:
    * ```.[]``` - Iterates through each item in the array of files
    * ```select(. | endswith(\"master_plan_boundaries.json\"))``` - Filters to only include files that end with "master_plan_boundaries.json"
    * The final ```.``` in the jq expression outputs the matching file paths

3. ```| first``` - Takes only the first matching file from the results (in case there are multiple matches)


## dbt

### dbt-date

```packages.yml```
```
packages:
  - package: godatadriven/dbt_date
    version: 0.11.0
```

```dbt-date``` is an extension package for dbt to handle common date logic and calendar functionality.

```dates.sql```
```{{ dbt_date.get_date_dimension("2023-01-01", "2025-12-31") }}```


## BigQuery for geospatial analytics

[ST_GEOGPOINT](https://cloud.google.com/bigquery/docs/reference/standard-sql/geography_functions#st_geogpoint) creates a GEOGRAPHY point using specified longitude and latitude in degrees

```ST_GEOGPOINT(longitude, latitude)```

z.geometry are polygons for subzones in Singapore. c.geometry are centroids of carparks in Singapore.

[ST_CONTAINS](https://cloud.google.com/bigquery/docs/reference/standard-sql/geography_functions#st_contains) Returns TRUE if all points of carparks(c.geometry) are within subzones(z.geometry) and their interiors overlap; otherwise, returns FALSE.

```
SELECT *
FROM availability_source 
LEFT JOIN carpark_dim c
    ON availability_source.carpark_number = c.car_park_no
INNER JOIN subzones_dim as z
    ON (ST_CONTAINS(z.geometry,c.geometry))
```


## Sources
* [Kestra blog: Robust data pipelines for BigQuery and Google Cloud](https://kestra.io/blogs/2022-11-19-create-data-pipeline-bigquery-google-cloud)
* [​Kestra Plugin: Load​From​Gcs](https://kestra.io/plugins/plugin-graalvm/bigquery/io.kestra.plugin.gcp.bigquery.loadfromgcs)
* [​Kestra Plugin: Download](https://kestra.io/plugins/core/http/io.kestra.plugin.core.http.download)
* [​Kestra Plugin: Archive​Decompress](https://kestra.io/plugins/plugin-compress/io.kestra.plugin.compress.archivedecompress)
* [​Kestra Plugin: Python Script](https://kestra.io/plugins/tasks/io.kestra.plugin.scripts.python.script)
* [​Kestra Plugin: Delete​Table](https://kestra.io/plugins/plugin-graalvm/bigquery/io.kestra.plugin.gcp.bigquery.deletetable)
* [​Kestra Plugin: Subflow](https://kestra.io/plugins/core/flow/io.kestra.plugin.core.flow.subflow)
* [dbt-date](https://hub.getdbt.com/godatadriven/dbt_date/latest/)
* [Using GeoJSON in BigQuery for geospatial analytics](https://cloud.google.com/blog/topics/developers-practitioners/using-geojson-bigquery-geospatial-analytics)
