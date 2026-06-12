mock_provider "google" {}

variables {
  project_id = "dummy-project"
}

# Missing FinOps label keys => fail.
run "missing_finops_labels" {
  command = plan

  variables {
    default_labels = { env = "test" } # missing project + owner
    topics         = {}
  }

  expect_failures = [var.default_labels]
}

# dead_letter_topic without max_delivery_attempts => fail.
run "incomplete_dead_letter" {
  command = plan

  variables {
    default_labels = { env = "test", project = "demo", owner = "platform" }
    topics = {
      t = { name = "t" }
    }
    subscriptions = {
      s = {
        name              = "s"
        topic             = "t"
        dead_letter_topic = "projects/dummy-project/topics/dlq"
        # max_delivery_attempts intentionally omitted
      }
    }
  }

  expect_failures = [var.subscriptions]
}
