provider "google" {
  project     = "finanz-dashboard"
  region      = "europe-west3"
}

resource "google_storage_bucket" "function_bucket" {
  name          = "finanz-dashboard-functions-bucket"
  location      = "EU"
  storage_class = "STANDARD"
}

resource "google_cloudfunctions_function" "finanz_dashboard_function" {
  name        = "finanz-dashboard-function"
  runtime     = "python310"
  region      = "europe-west3"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = "function-source.zip"
  entry_point = "main"

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.function_bucket.name
  }
}

resource "google_bigquery_dataset" "finanz_dashboard_dataset" {
  dataset_id  = "finanz_dashboard"
  project     = "finanz-dashboard"
  location    = "EU"
}

resource "google_bigquery_table" "finanz_dashboard_table" {
  dataset_id = google_bigquery_dataset.finanz_dashboard_dataset.dataset_id
  table_id   = "market_data"
  project    = "finanz-dashboard"

  schema = <<EOF
[
  {"name": "symbol", "type": "STRING", "mode": "REQUIRED"},
  {"name": "price", "type": "FLOAT", "mode": "REQUIRED"},
  {"name": "timestamp", "type": "TIMESTAMP", "mode": "REQUIRED"}
]
EOF
}
