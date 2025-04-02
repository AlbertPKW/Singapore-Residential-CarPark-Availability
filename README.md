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

* [Carpark Availability API](https://data.gov.sg/datasets?resultId=d_ca933a644e55d34fe21f28b8052fac63&coverage=&page=1) from Data.gov.sg: Provides parking availability data of HDB Residential estates in Singapore which is updated every minute.
* [HDB Information Dataset](https://data.gov.sg/datasets/d_23f946fa557947f93a8043bbef41dd09/view): Information about HDB carparks such as car park type, car park location (in SVY21), type of parking system, etc.
* [Singapore Subzones GeoJSON file](https://gist.github.com/samuelyeewl/246258d00910390b0859f864645c00c8): GeoJSON file of Singapore subzones boundaries based on Singapore Master Plan 2019

## Tools

The following tools were incorporated to create the batch data pipeline:

* **Data Ingestion**: [Carpark Availability API](https://data.gov.sg/datasets?resultId=d_ca933a644e55d34fe21f28b8052fac63&coverage=&page=1)
* **Infrastructure as Code**: Terraform
* **Workflow Orchestration**: Kestra
* **Data Lake**: Google Cloud Storage
* **Data Warehouse**: Google BigQuery
* **Data Transformation**: dbt
* **Reporting**: Google Data Studio
