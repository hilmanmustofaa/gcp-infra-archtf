# GKE Cluster Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module provisions a Google Kubernetes Engine (GKE) cluster with rich configurability: private clusters, network & pod security policies, optional Autopilot/TPU/Alpha features, addon toggles (HPA, HTTP LB, Cloud Run, Istio), custom IP allocation, master-authorized networks, maintenance windows, and workload logging.

# Feature
- **Cluster Modes**: Standard, Autopilot, Kubernetes Alpha, TPU  
- **Private Cluster**: private nodes & endpoint configuration  
- **Security**: built-in network policy (Calico), pod security policy, master-authorized networks  
- **Addons**: horizontal pod autoscaling, HTTP load balancing, Cloud Run integration, Istio mutual-TLS  
- **IPAM**: VPC secondary range support for pods & services  
- **Maintenance**: daily maintenance window scheduling  
- **Logging**: control plane & optional workload logging  
- **Lifecycle Controls**: remove default node pool, ignore churn on SSH keys & labels
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [cluster_secondary_range_name](variables.tf#L32) | The name of the secondary range for pod IPs. | <code>string</code> | ✓ |  |
| [database_encryption](variables.tf#L132) | Application-layer Secrets Encryption settings. REQUIRED: Cloud KMS key must be provided for hardened clusters. | <code title="object&#40;&#123;&#10;  state    &#61; string&#10;  key_name &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> | ✓ |  |
| [default_labels](variables.tf#L37) | Default labels to apply to the cluster. Must include 'env', 'project', and 'owner' for FinOps governance. | <code>map&#40;string&#41;</code> | ✓ |  |
| [name](variables.tf#L202) | The name of the cluster. | <code>string</code> | ✓ |  |
| [network](variables.tf#L207) | The VPC network to host the cluster in. | <code>string</code> | ✓ |  |
| [node_service_account](variables.tf#L224) | REQUIRED: Custom service account for GKE node pools. Default compute SA is not permitted. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L235) | The project ID to host the cluster in. | <code>string</code> | ✓ |  |
| [services_secondary_range_name](variables.tf#L246) | The name of the secondary range for service IPs. | <code>string</code> | ✓ |  |
| [subnetwork](variables.tf#L251) | The subnetwork to host the cluster in. | <code>string</code> | ✓ |  |
| [backup_plans](variables.tf#L1) | Map of backup plans keyed by name. | <code title="map&#40;object&#40;&#123;&#10;  region                            &#61; string&#10;  schedule                          &#61; string&#10;  labels                            &#61; map&#40;string&#41;&#10;  retention_policy_days             &#61; number&#10;  retention_policy_delete_lock_days &#61; optional&#40;number&#41;&#10;  retention_policy_lock             &#61; optional&#40;bool&#41;&#10;  include_volume_data               &#61; bool&#10;  include_secrets                   &#61; bool&#10;  encryption_key                    &#61; optional&#40;string&#41;&#10;  namespaces                        &#61; optional&#40;list&#40;string&#41;&#41;&#10;  applications                      &#61; optional&#40;map&#40;list&#40;string&#41;&#41;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [certificate_authority_fqdns](variables.tf#L19) | List of FQDNs for certificate authority configuration. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [certificate_authority_secret_uri](variables.tf#L25) | Secret URI for the certificate authority in GCP Secret Manager. | <code>string</code> |  | <code>null</code> |
| [default_max_pods_per_node](variables.tf#L51) | The default maximum number of pods per node in this cluster. | <code>number</code> |  | <code>110</code> |
| [description](variables.tf#L57) | The description of the cluster. | <code>string</code> |  | <code>&#34;&#34;</code> |
| [enable_addons](variables.tf#L63) | Addons configuration. | <code title="object&#40;&#123;&#10;  horizontal_pod_autoscaling  &#61; optional&#40;bool, true&#41;&#10;  http_load_balancing         &#61; optional&#40;bool, true&#41;&#10;  network_policy              &#61; optional&#40;bool, false&#41;&#10;  cloudrun                    &#61; optional&#40;bool, false&#41;&#10;  cloudrun_load_balancer_type &#61; optional&#40;string, &#34;EXTERNAL&#34;&#41;&#10;  istio &#61; optional&#40;object&#40;&#123;&#10;    enable_tls &#61; optional&#40;bool, false&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>&#123;&#125;</code> |
| [enable_backup_agent](variables.tf#L78) | Enable the GKE Backup Agent. | <code>bool</code> |  | <code>false</code> |
| [enable_kubernetes_alpha](variables.tf#L84) | Enable Kubernetes Alpha features. | <code>bool</code> |  | <code>false</code> |
| [enable_legacy_abac](variables.tf#L90) | Enable legacy ABAC authentication. | <code>bool</code> |  | <code>false</code> |
| [enable_private_endpoint](variables.tf#L96) | Enable private endpoint. | <code>bool</code> |  | <code>false</code> |
| [enable_private_nodes](variables.tf#L102) | Enable private nodes. | <code>bool</code> |  | <code>true</code> |
| [enable_private_registry](variables.tf#L108) | Enable private registry access for the cluster. | <code>bool</code> |  | <code>false</code> |
| [enable_shielded_nodes](variables.tf#L114) | Enable Shielded Nodes features on all nodes. | <code>bool</code> |  | <code>true</code> |
| [enable_tpu](variables.tf#L120) | Enable Cloud TPU resources. | <code>bool</code> |  | <code>false</code> |
| [enable_workload_logs](variables.tf#L126) | Enable workload logging. | <code>bool</code> |  | <code>true</code> |
| [gateway_api_channel](variables.tf#L146) | Channel to use for Gateway API support. | <code>string</code> |  | <code>null</code> |
| [join_separator](variables.tf#L152) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [location](variables.tf#L158) | The location (region or zone) to host the cluster in. | <code>string</code> |  | <code>null</code> |
| [maintenance_window_start_time](variables.tf#L164) | Time window specified for daily maintenance operations. | <code>string</code> |  | <code>null</code> |
| [master_authorized_networks](variables.tf#L170) | List of authorized CIDR blocks to access GKE control plane. | <code title="list&#40;object&#40;&#123;&#10;  cidr_block   &#61; string&#10;  display_name &#61; string&#10;&#125;&#41;&#41;">list&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code title="&#91;&#10;  &#123;&#10;    cidr_block   &#61; &#34;10.0.0.0&#47;8&#34;&#10;    display_name &#61; &#34;internal-only&#34;&#10;  &#125;&#10;&#93;">&#91;&#8230;&#93;</code> |
| [master_ipv4_cidr_block](variables.tf#L184) | IP range for the master network. | <code>string</code> |  | <code>&#34;172.16.0.0&#47;28&#34;</code> |
| [min_master_version](variables.tf#L190) | The minimum version of the master. | <code>string</code> |  | <code>null</code> |
| [monitoring_components](variables.tf#L196) | Monitoring components to enable. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#34;SYSTEM_COMPONENTS&#34;&#93;</code> |
| [node_locations](variables.tf#L218) | The list of zones in which the cluster's nodes are located. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [release_channel](variables.tf#L240) | GKE release channel to use (e.g. RAPID, REGULAR, STABLE). | <code>string</code> |  | <code>&#34;REGULAR&#34;</code> |
| [resource_prefix](variables.tf#L212) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |
| [upgrade_notifications](variables.tf#L256) | Pub/Sub notification config for GKE upgrades. | <code title="object&#40;&#123;&#10;  topic_id &#61; optional&#40;string&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [workload_pool](variables.tf#L264) | The Workload Identity Pool to associate with the cluster. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [backup_plan_ids](outputs.tf#L1) | List of backup plan resource IDs. |  |
| [ca_certificate](outputs.tf#L6) | Cluster ca certificate (base64 encoded). | ✓ |
| [certificate_authority_config](outputs.tf#L12) | Certificate authority configuration. | ✓ |
| [cluster_id](outputs.tf#L21) | Cluster ID. |  |
| [cluster_location](outputs.tf#L26) | Cluster location. |  |
| [cluster_name](outputs.tf#L31) | Cluster name. |  |
| [cluster_self_link](outputs.tf#L36) | Cluster self-link URL. |  |
| [endpoint](outputs.tf#L41) | Cluster endpoint. | ✓ |
| [horizontal_pod_autoscaling_enabled](outputs.tf#L47) | Whether horizontal pod autoscaling is enabled. |  |
| [http_load_balancing_enabled](outputs.tf#L52) | Whether http load balancing is enabled. |  |
| [master_authorized_networks_config](outputs.tf#L57) | Master authorized networks configuration. |  |
| [master_version](outputs.tf#L62) | Current master kubernetes version. |  |
| [network_policy_enabled](outputs.tf#L67) | Whether network policy (Calico) is enabled. |  |
| [node_pools_names](outputs.tf#L72) | List of node pools names. |  |
| [peering_name](outputs.tf#L77) | The name of the peering between this cluster and the Google owned VPC. |  |
| [private_cluster_config](outputs.tf#L82) | Private cluster configuration. | ✓ |
| [pubsub_notification_topic](outputs.tf#L88) | Pub/Sub topic for upgrade notifications if created. |  |
<!-- END TFDOC -->
# Example Usage
```hcl
module "gke_cluster" {
  source    = "./modules/gcp/container/gke-cluster"
  project_id = "my-project"
  name       = "prod-cluster"
  location   = "us-central1"
  network    = "vpc-main"
  subnetwork = "subnet-us"
  node_locations = ["us-central1-a","us-central1-b"]
  cluster_secondary_range_name  = "pods-range"
  services_secondary_range_name = "svc-range"

  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = "172.16.0.0/28"

  enable_addons = {
    horizontal_pod_autoscaling = true
    http_load_balancing        = true
    network_policy             = true
    cloudrun                   = false
    istio                      = false
  }

  master_authorized_networks = [
    { cidr_block = "10.0.0.0/8", display_name = "vpn" }
  ]
  maintenance_window_start_time = "03:00"
  enable_workload_logs          = true
}
