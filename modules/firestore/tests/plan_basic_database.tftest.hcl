run "plan_basic_database" {
  command = plan

  variables {
    project_id = "test-project"

    database = {
      name        = "test-db"
      location_id = "us-central1"
      type        = "FIRESTORE_NATIVE"
    }

    documents = {
      "doc-1" = {
        collection  = "users"
        document_id = "user-1"
        fields = {
          name = { stringValue = "John Doe" }
          age  = { integerValue = 30 }
        }
      }
    }
  }

  # Verify Database
  assert {
    condition     = google_firestore_database.firestore_database[0].name == "test-db"
    error_message = "Database name incorrect"
  }

  assert {
    condition     = google_firestore_database.firestore_database[0].location_id == "us-central1"
    error_message = "Location ID incorrect"
  }

  assert {
    condition     = google_firestore_database.firestore_database[0].type == "FIRESTORE_NATIVE"
    error_message = "Database type incorrect"
  }

  # Verify Document
  assert {
    condition     = google_firestore_document.firestore_documents["doc-1"].collection == "users"
    error_message = "Document collection incorrect"
  }

  assert {
    condition     = google_firestore_document.firestore_documents["doc-1"].document_id == "user-1"
    error_message = "Document ID incorrect"
  }
}
