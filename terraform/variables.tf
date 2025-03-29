variable "credentials" {
  description = "My Credentials"
  default     = "google-credentials.json"
  #ex: if you have a directory where this file is called keys with your service account json file
  #saved there as my-creds.json you could use default = "./keys/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "sg-resi-carpark"
}

variable "location" {
  description = "Project Location"
  default     = "us-central1"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "sg_carpark_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "carpark-availability-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}