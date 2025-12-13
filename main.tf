# main.tf

# --------------------------
# 1. PROVIDER E CONFIGURAÇÃO
# --------------------------

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "local" {
    # Usando backend local para simplicidade inicial. 
    # Mude para "gcs" (Google Cloud Storage) em produção.
    path = "terraform.tfstate" 
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  # O Terraform usará as credenciais de autenticação que você já configurou 
  # localmente no seu terminal (gcloud auth application-default login)
}

# --------------------------
# 2. RECURSOS DO BIGQUERY
# --------------------------

# Dataset para a Camada BRUTA (Raw Layer)
# Aqui é onde os dados de origem (CSV, API, etc.) são carregados.
resource "google_bigquery_dataset" "raw_layer" {
  dataset_id = "raw_atlas_capital"
  project    = var.project_id
  location   = var.bq_location
  
  labels = {
    env  = "development"
    type = "raw"
  }
}

# Dataset para a Camada STAGING (Staging Layer)
# Modelos de limpeza e padronização (stg_...).
resource "google_bigquery_dataset" "staging_layer" {
  dataset_id = "stg_atlas_capital"
  project    = var.project_id
  location   = var.bq_location
  
  labels = {
    env  = "development"
    type = "staging"
  }
}

# Dataset para a Camada ANALÍTICA (Marts/Consumption Layer)
# Modelos finais prontos para BI (marts/dim/fct).
resource "google_bigquery_dataset" "marts_layer" {
  dataset_id = "marts_atlas_capital"
  project    = var.project_id
  location   = var.bq_location
  
  labels = {
    env  = "development"
    type = "marts"
  }
}