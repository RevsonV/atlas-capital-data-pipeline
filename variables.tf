# variables.tf

variable "project_id" {
  description = "O ID do projeto GCP para implantar recursos."
  type        = string
}

variable "region" {
  description = "A região padrão do GCP para recursos (datasets, buckets, etc)."
  type        = string
  default     = "us-central1"
}

variable "bq_location" {
  description = "A localização do BigQuery para os datasets (ex: US, EU)."
  type        = string
  default     = "US"
}