# Project Notes - Learning in Public

## Kestra Plugins

### Load​From​Gcs

```type: "io.kestra.plugin.gcp.bigquery.LoadFromGcs"```

The LoadFromGcs plugin enables direct import of data from Google Cloud Storage (GCS) into a BigQuery table. It's particularly useful for analyzing and extracting insights from static data files stored in GCS. The plugin supports multiple file formats, including Avro, JSON, Parquet, ORC, and CSV.

```
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
