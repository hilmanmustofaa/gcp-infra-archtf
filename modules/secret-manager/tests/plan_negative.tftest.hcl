# ============================================================================
# Plan Test: secret-manager validation negatives
# ============================================================================

mock_provider "google" {}

variables {
  project_id = "dummy-project"

  default_labels = {
    env     = "test"
    project = "demo"
    owner   = "platform"
  }
}

# Neither automatic nor user-managed replication => fail.
run "replication_none" {
  command = plan

  variables {
    secrets = {
      bad = {
        secret_id   = "x"
        replication = {}
      }
    }
  }

  expect_failures = [var.secrets]
}

# Both automatic and user-managed replication => fail.
run "replication_both" {
  command = plan

  variables {
    secrets = {
      bad = {
        secret_id = "x"
        replication = {
          automatic             = true
          user_managed_replicas = [{ location = "asia-southeast2" }]
        }
      }
    }
  }

  expect_failures = [var.secrets]
}

# Rotation without topics => fail.
run "rotation_without_topics" {
  command = plan

  variables {
    secrets = {
      bad = {
        secret_id   = "x"
        replication = { automatic = true }
        rotation    = { rotation_period = "7776000s" }
        topics      = []
      }
    }
  }

  expect_failures = [var.secrets]
}

# ttl and expire_time both set => fail.
run "ttl_and_expire" {
  command = plan

  variables {
    secrets = {
      bad = {
        secret_id   = "x"
        replication = { automatic = true }
        ttl         = "3600s"
        expire_time = "2026-12-31T00:00:00Z"
      }
    }
  }

  expect_failures = [var.secrets]
}
