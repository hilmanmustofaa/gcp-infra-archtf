# Cloud SQL Instance Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module provisions one or more Google Cloud SQL database instances, together with any databases, users, and optional root passwords. It supports advanced configuration—including backup, maintenance windows, high-availability settings, disk encryption, networking, and insights.

# Feature
- Create Cloud SQL instances (MySQL, PostgreSQL, SQL Server) with flexible settings (tier, disk, collation, flags).  
- Automatically generate strong random passwords when desired.  
- Provision multiple databases and users per instance.  
- Configure IP settings, private networking, and authorized networks.  
- Manage backup, point-in-time recovery, and maintenance windows.  
- Integrate Active Directory, insights, and database flags.  
- Ignores drift on selected mutable fields to minimize unnecessary updates.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [sql_database_instances](variables.tf#L26) | Map of Cloud SQL instance configurations. | <code title="map&#40;object&#40;&#123;&#10;  name                 &#61; string&#10;  region               &#61; string&#10;  database_version     &#61; string&#10;  master_instance_name &#61; optional&#40;string&#41;&#10;  project              &#61; string&#10;  root_password        &#61; optional&#40;string&#41;&#10;  encryption_key_name  &#61; optional&#40;string&#41;&#10;  deletion_protection  &#61; optional&#40;bool, true&#41;&#10;  settings &#61; object&#40;&#123;&#10;    tier                        &#61; string&#10;    activation_policy           &#61; optional&#40;string&#41;&#10;    availability_type           &#61; optional&#40;string&#41;&#10;    collation                   &#61; optional&#40;string&#41;&#10;    disk_autoresize             &#61; optional&#40;bool&#41;&#10;    disk_size                   &#61; optional&#40;number&#41;&#10;    disk_type                   &#61; optional&#40;string&#41;&#10;    pricing_plan                &#61; optional&#40;string&#41;&#10;    deletion_protection_enabled &#61; optional&#40;bool&#41;&#10;    user_labels                 &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;    database_flags &#61; list&#40;object&#40;&#123;&#10;      name  &#61; string&#10;      value &#61; string&#10;    &#125;&#41;&#41;&#10;    active_directory_config &#61; list&#40;object&#40;&#123;&#10;      domain &#61; string&#10;    &#125;&#41;&#41;&#10;    backup_configuration &#61; object&#40;&#123;&#10;      enabled                        &#61; bool&#10;      binary_log_enabled             &#61; optional&#40;bool&#41;&#10;      start_time                     &#61; optional&#40;string&#41;&#10;      point_in_time_recovery_enabled &#61; optional&#40;bool&#41;&#10;      location                       &#61; optional&#40;string&#41;&#10;      transaction_log_retention_days &#61; optional&#40;number&#41;&#10;      backup_retention_settings &#61; object&#40;&#123;&#10;        retained_backups &#61; number&#10;        retention_unit   &#61; string&#10;      &#125;&#41;&#10;    &#125;&#41;&#10;    ip_configuration &#61; object&#40;&#123;&#10;      ipv4_enabled       &#61; bool&#10;      private_network    &#61; optional&#40;string&#41;&#10;      allocated_ip_range &#61; optional&#40;string&#41;&#10;      authorized_networks &#61; map&#40;object&#40;&#123;&#10;        expiration_time &#61; optional&#40;string&#41;&#10;        name            &#61; string&#10;        value           &#61; string&#10;      &#125;&#41;&#41;&#10;    &#125;&#41;&#10;    location_preference &#61; map&#40;object&#40;&#123;&#10;      follow_gae_application &#61; optional&#40;bool&#41;&#10;      zone                   &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#41;&#10;    maintenance_window &#61; map&#40;object&#40;&#123;&#10;      day          &#61; number&#10;      hour         &#61; number&#10;      update_track &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#41;&#10;    insights_config &#61; map&#40;object&#40;&#123;&#10;      query_insights_enabled  &#61; bool&#10;      query_string_length     &#61; optional&#40;number&#41;&#10;      record_application_tags &#61; optional&#40;bool&#41;&#10;      record_client_address   &#61; optional&#40;bool&#41;&#10;    &#125;&#41;&#41;&#10;  &#125;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> | ✓ |  |
| [default_labels](variables.tf#L1) | Default labels to be applied to all resources. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [join_separator](variables.tf#L7) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [network_lookup](variables.tf#L13) | Map of VPC network name → network object (must contain 'id' for private network use). | <code>map&#40;any&#41;</code> |  | <code>&#123;&#125;</code> |
| [resource_prefix](variables.tf#L19) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |
| [sql_databases](variables.tf#L96) | Map of Cloud SQL database configurations. | <code title="map&#40;object&#40;&#123;&#10;  name      &#61; string&#10;  instance  &#61; string&#10;  charset   &#61; optional&#40;string&#41;&#10;  collation &#61; optional&#40;string&#41;&#10;  project   &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [sql_users](variables.tf#L108) | Map of Cloud SQL user configurations. | <code title="map&#40;object&#40;&#123;&#10;  name            &#61; string&#10;  instance        &#61; string&#10;  password        &#61; optional&#40;string&#41;&#10;  type            &#61; optional&#40;string&#41;&#10;  deletion_policy &#61; optional&#40;string&#41;&#10;  host            &#61; optional&#40;string&#41;&#10;  project         &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [databases](outputs.tf#L1) | The created Cloud SQL databases. |  |
| [instances](outputs.tf#L6) | The created Cloud SQL instances. | ✓ |
| [users](outputs.tf#L12) | The created Cloud SQL users. | ✓ |
<!-- END TFDOC -->
# Example Usage

```hcl
module "cloudsql" {
  source             = "git::ssh://git@gitlab.com/your-org/terraform-modules-multicloud.git//modules/gcp/database/cloudsql-instance?ref=v1.0.0"

  resource_prefix    = "demo"
  join_separator     = "-"
  default_labels     = { env = "dev" }

  network_lookup = {
    default = { id = "projects/my-project/global/networks/default" }
  }

  sql_database_instances = {
    example = {
      name              = "example-instance"
      region            = "us-central1"
      database_version  = "MYSQL_8_0"
      project           = "my-project"
      root_password     = "override-or-null-to-generate"
      deletion_protection = false
      settings = {
        tier               = "db-f1-micro"
        disk_size          = 10
        disk_type          = "PD_SSD"
        disk_autoresize    = true
        user_labels        = { app = "demo" }
        database_flags     = [
          { name = "slow_query_log", value = "on" }
        ]
        ip_configuration = {
          ipv4_enabled       = true
          private_network    = null
          authorized_networks = {
            office = {
              name  = "office-net"
              value = "203.0.113.0/24"
            }
          }
        }
        backup_configuration = {
          enabled                        = true
          binary_log_enabled             = true
          start_time                     = "03:00"
          point_in_time_recovery_enabled = true
          location                       = "us"
          transaction_log_retention_days = 7
          backup_retention_settings = {
            retained_backups = 7
            retention_unit   = "COUNT"
          }
        }
      }
    }
  }

  sql_databases = {
    app_db = {
      name     = "app_database"
      instance = "example"
      project  = "my-project"
    }
  }

  sql_users = {
    app_user = {
      name     = "app_user"
      instance = "example"
      password = null   # will generate a strong random password
      type     = "NORMAL_USER"
      host     = "%"
      project  = "my-project"
    }
  }
}
