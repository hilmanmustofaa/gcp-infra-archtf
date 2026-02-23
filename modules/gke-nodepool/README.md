# GKE Node Pool Module

<!-- BEGIN TOC -->
- [Description](#description)
- [Feature](#feature)
- [Variables](#variables)
- [Outputs](#outputs)
- [Example Usage](#example-usage)
<!-- END TOC -->

# Description
This module creates one or more GKE node pools attached to an existing GKE cluster. It supports both fixed-size and autoscaled pools, custom machine types, disks, taints, accelerators (GPUs), shielded instances, sandbox configs, kubelet tuning, and lifecycle/upgrade controls.

# Feature
- **Autoscaling & Fixed Size**: support for `initial_node_count` or HPA-style autoscaling  
- **Custom Disks**: boot disk size/type, local SSDs, encrypted disks  
- **Security**: shielded instances, sandbox (gVisor), workload metadata server  
- **Accelerators**: GPU support with optional partition sizing  
- **Node Tuning**: taints, labels, tags, metadata, kubelet config, linux sysctls  
- **Upgrade Controls**: auto-repair, auto-upgrade, surge/unavailable, blue/green rollout  
- **Network**: pod CIDR ranges, private nodes, custom placement policies  
- **Lifecycle**: `create_before_destroy`, `ignore_changes` for count fields, custom timeouts
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [cluster_name](variables.tf#L19) | The name of the GKE cluster. | <code>string</code> | ✓ |  |
| [location](variables.tf#L125) | Location/region of the GKE cluster. | <code>string</code> | ✓ |  |
| [machine_type](variables.tf#L130) | The machine type to use for nodes. | <code>string</code> | ✓ |  |
| [name](variables.tf#L156) | Name of the node pool. | <code>string</code> | ✓ |  |
| [node_count](variables.tf#L184) | Initial and current node counts. | <code title="object&#40;&#123;&#10;  initial &#61; number&#10;  current &#61; number&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> | ✓ |  |
| [project_id](variables.tf#L226) | The GCP project ID. | <code>string</code> | ✓ |  |
| [service_account_email](variables.tf#L255) | Service account email to use for nodes. | <code>string</code> | ✓ |  |
| [autoscaling](variables.tf#L1) | Autoscaling settings. | <code title="object&#40;&#123;&#10;  min_node_count       &#61; number&#10;  max_node_count       &#61; number&#10;  total_min_node_count &#61; optional&#40;number&#41;&#10;  total_max_node_count &#61; optional&#40;number&#41;&#10;  location_policy      &#61; optional&#40;string&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [boot_disk_kms_key](variables.tf#L13) | KMS key for boot disk encryption. | <code>string</code> |  | <code>null</code> |
| [default_labels](variables.tf#L24) | Default labels to apply to node pool nodes. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [disk_size](variables.tf#L30) | Disk size in GB for each node. | <code>number</code> |  | <code>100</code> |
| [disk_type](variables.tf#L36) | Disk type to use (pd-standard, pd-ssd, etc). | <code>string</code> |  | <code>&#34;pd-standard&#34;</code> |
| [enable_confidential_nodes](variables.tf#L42) | Whether to enable Confidential VMs in the node pool. | <code>bool</code> |  | <code>false</code> |
| [ephemeral_ssd_count](variables.tf#L48) | Number of ephemeral SSDs (ephemeral_storage_config). | <code>number</code> |  | <code>null</code> |
| [gcfs](variables.tf#L54) | Enable GCFS for COS_CONTAINERD. | <code>bool</code> |  | <code>false</code> |
| [guest_accelerator](variables.tf#L60) | GPU configuration block. | <code title="object&#40;&#123;&#10;  type               &#61; string&#10;  count              &#61; number&#10;  gpu_partition_size &#61; optional&#40;string&#41;&#10;  gpu_driver &#61; optional&#40;object&#40;&#123;&#10;    version                    &#61; string&#10;    partition_size             &#61; optional&#40;string&#41;&#10;    max_shared_clients_per_gpu &#61; optional&#40;number&#41;&#10;  &#125;&#41;&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [gvnic](variables.tf#L75) | Enable GVNIC. | <code>bool</code> |  | <code>false</code> |
| [image_type](variables.tf#L81) | Image type to use for nodes (COS_CONTAINERD, UBUNTU, etc). | <code>string</code> |  | <code>null</code> |
| [join_separator](variables.tf#L167) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [kubelet_config](variables.tf#L87) | Kubelet-level config options. | <code title="object&#40;&#123;&#10;  cpu_manager_policy   &#61; string&#10;  cpu_cfs_quota        &#61; bool&#10;  cpu_cfs_quota_period &#61; string&#10;  pod_pids_limit       &#61; number&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [labels](variables.tf#L98) | Resource labels assigned to nodes. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [linux_node_config](variables.tf#L104) | Linux-specific node settings. | <code title="object&#40;&#123;&#10;  sysctls     &#61; map&#40;string&#41;&#10;  cgroup_mode &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [local_nvme_ssd_count](variables.tf#L113) | Number of local NVMe SSDs to attach. | <code>number</code> |  | <code>0</code> |
| [local_ssd_count](variables.tf#L119) | Number of local SSDs to attach. | <code>number</code> |  | <code>0</code> |
| [management](variables.tf#L135) | Management options (auto_repair, auto_upgrade). | <code title="object&#40;&#123;&#10;  auto_repair  &#61; bool&#10;  auto_upgrade &#61; bool&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [metadata](variables.tf#L144) | Metadata key/value pairs assigned to each instance. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [min_cpu_platform](variables.tf#L150) | Minimum CPU platform. | <code>string</code> |  | <code>null</code> |
| [network_config](variables.tf#L173) | Pod range network configuration. | <code title="object&#40;&#123;&#10;  create_pod_range     &#61; bool&#10;  enable_private_nodes &#61; bool&#10;  pod_ipv4_cidr_block  &#61; optional&#40;string&#41;&#10;  pod_range            &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [node_locations](variables.tf#L192) | List of zones where the node pool will be deployed. Leave empty to use cluster default. | <code>list&#40;string&#41;</code> |  | <code>null</code> |
| [node_version](variables.tf#L198) | GKE node version. | <code>string</code> |  | <code>null</code> |
| [oauth_scopes](variables.tf#L204) | List of OAuth scopes to be used for node VMs. | <code>list&#40;string&#41;</code> |  | <code>null</code> |
| [placement_policy](variables.tf#L210) | Node placement policy config. | <code title="object&#40;&#123;&#10;  type         &#61; string&#10;  policy_name  &#61; optional&#40;string&#41;&#10;  tpu_topology &#61; optional&#40;string&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [preemptible](variables.tf#L220) | Use preemptible VMs. | <code>bool</code> |  | <code>false</code> |
| [queued_provisioning](variables.tf#L231) | Enable queued provisioning. | <code>bool</code> |  | <code>false</code> |
| [reservation_affinity](variables.tf#L237) | Reservation affinity config. | <code title="object&#40;&#123;&#10;  consume_reservation_type &#61; string&#10;  key                      &#61; string&#10;  values                   &#61; list&#40;string&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [resource_prefix](variables.tf#L161) | Optional prefix to prepend to node pool name. | <code>string</code> |  | <code>null</code> |
| [sandbox_config](variables.tf#L247) | Gvisor sandbox configuration. | <code title="object&#40;&#123;&#10;  sandbox_type &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [shielded_instance_config](variables.tf#L260) | Shielded instance config. | <code title="object&#40;&#123;&#10;  enable_secure_boot          &#61; bool&#10;  enable_integrity_monitoring &#61; bool&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [spot](variables.tf#L269) | Use Spot VMs instead of preemptible. | <code>bool</code> |  | <code>null</code> |
| [tags](variables.tf#L275) | Network tags applied to nodes. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [taints](variables.tf#L281) | Taints to apply to nodes. | <code title="map&#40;object&#40;&#123;&#10;  value  &#61; string&#10;  effect &#61; string&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [timeouts](variables.tf#L290) | Timeout settings for create/update/delete. | <code>map&#40;string&#41;</code> |  | <code title="&#123;&#10;  create &#61; &#34;45m&#34;&#10;  update &#61; &#34;45m&#34;&#10;  delete &#61; &#34;45m&#34;&#10;&#125;">&#123;&#8230;&#125;</code> |
| [upgrade_settings](variables.tf#L300) | Node pool upgrade settings. | <code title="object&#40;&#123;&#10;  max_surge               &#61; number&#10;  max_unavailable         &#61; number&#10;  strategy                &#61; string&#10;  node_pool_soak_duration &#61; string&#10;  batch_percentage        &#61; number&#10;  batch_soak_duration     &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [workload_metadata_config](variables.tf#L313) | Workload metadata config mode. | <code>string</code> |  | <code>&#34;GKE_METADATA&#34;</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [node_pool_id](outputs.tf#L1) | ID of the GKE node pool. |  |
| [node_pool_name](outputs.tf#L6) | Name of the GKE node pool. |  |
| [node_pool_version](outputs.tf#L11) | Kubernetes version of the node pool. |  |
<!-- END TFDOC -->
# Example Usage
```hcl
module "gke_nodepool" {
  source             = "./modules/gcp/container/gke-nodepool"
  project_id         = "my-project"
  cluster_name       = "prod-cluster"
  location           = "us-central1-a"
  name               = "worker-pool"
  node_version       = "1.24.5-gke.100"
  node_count = {
    initial = 3
  }
  autoscaling = {
    min_node_count = 3
    max_node_count = 10
  }
  machine_type     = "e2-standard-4"
  disk_size        = 100
  image_type       = "COS_CONTAINERD"
  local_ssd_count  = 1
  service_account_email = "my-sa@my-project.iam.gserviceaccount.com"
  tags             = ["web-server", "gpu"]
  labels           = { env = "prod", role = "web" }
  taints           = { gpu = { value = "true", effect = "NO_SCHEDULE" } }
  guest_accelerator = {
    type  = "nvidia-tesla-t4"
    count = 1
  }
  shielded_instance_config = {
    enable_secure_boot          = true
    enable_integrity_monitoring = true
  }
  upgrade_settings = {
    max_surge       = { fixed = 1 }
    max_unavailable = { percent = 10 }
    blue_green_settings = {
      node_pool_soak_duration = "10m"
      standard_rollout_policy = {
        batch_percentage    = 20
        batch_soak_duration = "5m"
      }
    }
  }
  timeouts = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
