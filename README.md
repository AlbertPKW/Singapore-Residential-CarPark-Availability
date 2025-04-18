# Singapore Residential Carpark Analytics - Data Engineering Project

## Problem Description

### Problem Statement

Singapore, as a densely populated urban city-state, faces significant challenges with limited parking infrastructure serving a large vehicle population. Residents and visitors alike struggle with:

1. **Parking uncertainty**: Difficulty finding available parking spaces in residential areas, particularly during peak hours
2. **Inefficient time management**: Time wasted circling neighborhoods looking for parking
3. **Regional disparity**: Uneven distribution of parking resources across different regions of Singapore
4. **Lack of real-time insights**: Limited access to current parking availability data to inform decision-making
5. **Planning challenges**: Inadequate historical data for urban planners to optimize infrastructure development

### Solution
This project empowers Singapore residents with data-driven insights to reduce parking-related stress, save time, and optimize their daily commutes. 
Additionally, it provides valuable information for urban planners and policy makers to better allocate resources and develop future infrastructure based on actual usage patterns.

![Dashboard](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/Singapore_Residential_Carpark_Analytics%20(2).jpg)


The project provides the following key features:

* Creates a centralized data pipeline that transforms raw parking data into actionable insights
* Provides comprehensive analytics on carpark capacity by region and vehicle type
* Visualizes occupancy patterns by time of day and day of week, enabling users to identify optimal parking times
* Tracks daily availability trends to reveal patterns and anomalies
* Maps availability by subzones to help users locate areas with higher parking probability
* Delivers both real-time and historical views to support immediate decisions and long-term planning


## Dataset

* [Carpark Availability API](https://data.gov.sg/datasets?resultId=d_ca933a644e55d34fe21f28b8052fac63&coverage=&page=1) from Data.gov.sg: Provides parking availability data of HDB Residential estates in Singapore which is updated every minute. For quick evaluation, the workflow for this dataset is schedule to run every 3 hours and it is recommended to trigger backfill for not more than 5-7 days.
* [HDB Information Dataset](https://data.gov.sg/datasets/d_23f946fa557947f93a8043bbef41dd09/view): Information about HDB carparks such as car park type, car park location (in SVY21), type of parking system, etc. This dataset is not updated frequently, hence the workflow for this dataset is scheduled to run monthly.
* [Singapore Subzones GeoJSON file](https://gist.github.com/samuelyeewl/246258d00910390b0859f864645c00c8): GeoJSON file of Singapore subzones boundaries based on Singapore Master Plan 2019. This file is updated on every 5 years. Nevertheless the workflow for this dataset is scheduled to run monthly.

## Tools

The following tools were incorporated to create the batch data pipeline:

* **Data Ingestion**: [Carpark Availability API](https://data.gov.sg/datasets?resultId=d_ca933a644e55d34fe21f28b8052fac63&coverage=&page=1)
* **Infrastructure as Code**: Terraform
* **Containerization**: Docker and Postgres
* **Workflow Orchestration**: Kestra
* **Data Lake**: Google Cloud Storage
* **Data Warehouse**: Google BigQuery
* **Data Transformation**: dbt
* **Reporting**: Google Data Studio

## Architecture

![Architecture](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/DE%20Diagram%20(2).jpeg)

### Steps to Reproduce

### Local Installation
  * [Terraform](https://developer.hashicorp.com/terraform/install)
  * Docker Desktop
 
### Cloud setup
  * Navigate to [Google Cloud Console](https://console.cloud.google.com/) and create a new project. Copy the Project ID for Terraform configuration later.
    
  * Create a service account in Google Cloud IAM with the following roles
    * BigQuery Admin
    * Storage Admin
    * Storage Object Admin
      
  * Create the service account key and download as JSON file. Rename the JSON file as ```google-credentials.json``` and place it in the Terraform file as shown in the image
    
    ![project structure](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/project_structure.jpg)


### Setup Infrastructure with Terraform

After Terraform is installed, make the following changes to the file ```terraform\variables.tf```:
  * Change the project name to match your GCP project name
  ![project_id](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/project_id.jpg)
  * (optional) Change the bucket name, which have to be a unique value
  * (optional) Change the Big Query dataset name
  * (optional) Change the location based on nearest location 

Perform the following in the terminal to provision the cloud infrastructure
```
cd terraform
terraform init
terraform plan -var="project=sg-resi-carpark"
terraform apply -var="project=sg-resi-carpark"

cd ..

```

### Data Ingestion (Part 1)

Make sure Docker Desktop is opened before running the following commands

```
cd data_ingest
docker compose up
```

Go to Kestra UI at the web address ```localhost:9080``` and import the workflows from ```data_ingest\kestra_workflows```
![import_workflows](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/import_workflows.jpg)

<ins>**01_gcp_kv Workflow**</ins>

Open the ```01_gcp_kv``` workflow by clicking on Edit Workflow. The purpose of this workflow is to populate the KV Store for the infrastructure created in Terraform. Check that the values in this workflow matched what is created by Terraform.

Excecute ```01_gcp_kv``` workflow, open the KV store after run is completed to check the values. 

For security reasons (in case credentials are accidentally pushed to Github), please click on ```New Key-Value``` button to create the ```GCP_CREDS``` key manually by copying and pasting the entire content of ```google-credentials.json``` in value field. Namespace is sg_carpark and change the Type to JSON.

The KV store should contain the following Key-Value pairs before proceeding with the subsequent workflows.

![kv_store](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/KV_Store_2.jpg)

<ins>**02_gcp_carparkinfo_scheduled Workflow**</ins>

For quick evaluation, execute this workflow manually and check that ```HDBCarparkInformation.csv``` is in GCS bucket and ```hdb_carpark_info``` table is in BigQuery.
Alternatively, you can trigger a backfill for the previous month as the workflow is scheduled to run on monthly basis.

![HDB_CSV](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/HDB_csv.jpg)

![HDB_BigQuery](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/HDB_BQ.jpg)

<ins>**03_gcp_subzones_scheduled Workflow**</ins>

For quick evaluation, execute this workflow manually and check that ```sg_boundaries.json``` is in the same bucket and ```subzones``` table is in BigQuery.
Alternatively, you can trigger a backfill for the previous month as the workflow is scheduled to run on monthly basis. 

![GeoJSON_file](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/Subzones_Bucket.jpg)

![GeoJSON_BigQuery](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/subzone_BQ.jpg)

<ins>**04_gcp_carpark Workflow**</ins>

Execute this workflow manually to create the BigQuery table ```carpark_availability_data``` by selecting values for a recent date and time. 

![workflow_manual](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/dbt_manual.jpg)

Follow the instructions below to setup and test the dbt project. Once dbt project is setup and working, proceed to <ins>04_gcp_carpark_scheduled Workflow</ins> in Data Ingestion (Part 2) to backfill data for a date range.

![carpark_parquet](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/carpark_parquet_2.jpg)

![carpark_BigQuery](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/avail_BQ_2.jpg)

### dbt setup

Sign up for a free account at [dbt homepage](https://www.getdbt.com/) and create a new project.

Fork this repository and enter Repo by copying Git repo link from Github.
Choose BigQuery as the data warehouse.

* Upload the service account key json file in the create from file option. This will fill out most fields related to the production credentials.
* Scroll down to the end of the page and set up the development credentials.
* Click on Test Connection > Next.

![dbt_setting](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/dbt_settings.jpg)

Navigate to Account > Projects to specify the project subdirectory which is ```dbt_analytics```.

At the left sidebar, click on Develop and Cloud IDE. After the git repository is populate in Cloud IDE, create a new branch.
Run ```dbt build``` to check results.

![dbt_build](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/dbt_build.jpg)

Check the lineage is the same as the image

![dbt_lineage](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/dbt_lineage.jpg)

In the dbt core model ```availability_subzones.sql```, the ```availability_subzones``` table is partitioned by ```Date``` field as it is a Time-unit column and this field is used as date range control in the dashboard to filter by date. The table is also clustered by ```Region``` field as this field is used as a filter in the dashboard.

### Data Ingestion (Part 2)

<ins>**04_gcp_carpark_scheduled Workflow**</ins>

After dbt is set up and working, go back to Kestra and open ```04_gcp_carpark_scheduled Workflow```. This is the main workflow of the project that will perform the following tasks:

 * Upload carpark availability as parquet files in same bucket
 * Create/update ```carpark_availability_data``` table in BigQuery
 * Trigger the sub workflow ```05_gcp_dbt```

It is scheduled to run every 3 hours and trigger backfill for not more that 5-days. Click on Trigger tab and enable backfill. Click on Backfill executions button

![backfill_1](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/backfill_1.jpg)

In the pop-up window, select the start date and end date for backfill. Optionally, enter the backfill labels. Once done, click on Execute button.
    
![backfill_2](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/backfill_2.jpg)

The same GCS bucket will be populated with parquet files of carpark availability data and ```carpark_availability_data``` in BigQuery will updated with more data after each run is completed.

In this workflow, the ```carpark_availability_data``` table is partitioned by ```Date``` field and clustered by ```carpark_number``` and ```lot_type``` fields as numerous queries in dbt perform aggregation against these columns. 

In addition, the subflow ```05_gcp_dbt``` will generate numerous Staging/Dimension tables and Fact Table in BigQuery.

![dim_fact](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/images/dimensions_fact_2.jpg)

### Data Reporting with Data Studio

Open the [dashboard](https://lookerstudio.google.com/reporting/d7937c79-de8d-4694-875b-e800abc4b159/page/5tLFF) for insights.

### Learning in Public

[Notes for topics learnt during project](https://github.com/AlbertPKW/Singapore-Residential-CarPark-Availability/blob/main/README.md)
