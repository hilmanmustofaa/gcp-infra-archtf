# GKE Autopilot Cluster Module

This module manages GKE Autopilot clusters.
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [cluster_secondary_range_name](variables.tf#L1) | The name of the secondary range for pod IPs. | <code>string</code> | ✓ |  |
| [location](variables.tf#L45) | The location (region or zone) to host the cluster in. | <code>string</code> | ✓ |  |
| [name](variables.tf#L82) | The name of the cluster. | <code>string</code> | ✓ |  |
| [network](variables.tf#L93) | The VPC network to host the cluster in. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L110) | The project ID to host the cluster in. | <code>string</code> | ✓ |  |
| [services_secondary_range_name](variables.tf#L121) | The name of the secondary range for service IPs. | <code>string</code> | ✓ |  |
| [subnetwork](variables.tf#L126) | The subnetwork to host the cluster in. | <code>string</code> | ✓ |  |
| [database_encryption](variables.tf#L36) | Application-layer Secrets Encryption settings. The key_name is the name of the KMS key to use. | <code title="object&#40;&#123;&#10;  state    &#61; string&#10;  key_name &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [default_labels](variables.tf#L6) | Default labels to apply to the cluster. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [description](variables.tf#L12) | The description of the cluster. | <code>string</code> |  | <code>&#34;&#34;</code> |
| [enable_private_endpoint](variables.tf#L18) | Enable private endpoint. | <code>bool</code> |  | <code>false</code> |
| [enable_private_nodes](variables.tf#L24) | Enable private nodes. | <code>bool</code> |  | <code>true</code> |
| [gateway_api_channel](variables.tf#L30) | Channel to use for Gateway API support. | <code>string</code> |  | <code>null</code> |
| [join_separator](variables.tf#L87) | Separator to use when joining prefix to resource names. | <code>string</code> |  | <code>&#34;-&#34;</code> |
| [maintenance_window_start_time](variables.tf#L50) | Time window specified for daily maintenance operations. | <code>string</code> |  | <code>null</code> |
| [master_authorized_networks](variables.tf#L56) | List of authorized CIDR blocks to access GKE control plane. | <code title="list&#40;object&#40;&#123;&#10;  cidr_block   &#61; string&#10;  display_name &#61; string&#10;&#125;&#41;&#41;">list&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code title="&#91;&#10;  &#123;&#10;    cidr_block   &#61; &#34;10.0.0.0&#47;8&#34;&#10;    display_name &#61; &#34;internal-only&#34;&#10;  &#125;&#10;&#93;">&#91;&#8230;&#93;</code> |
| [master_ipv4_cidr_block](variables.tf#L70) | IP range for the master network. | <code>string</code> |  | <code>&#34;172.16.0.0&#47;28&#34;</code> |
| [min_master_version](variables.tf#L76) | The minimum version of the master. | <code>string</code> |  | <code>null</code> |
| [node_service_account](variables.tf#L104) | The service account to be used by the nodes. If not provided, the default compute service account will be used (not recommended). | <code>string</code> |  | <code>null</code> |
| [release_channel](variables.tf#L115) | GKE release channel to use (e.g. RAPID, REGULAR, STABLE). | <code>string</code> |  | <code>&#34;REGULAR&#34;</code> |
| [resource_prefix](variables.tf#L98) | Prefix to be added to resource names. | <code>string</code> |  | <code>null</code> |
| [workload_pool](variables.tf#L131) | The Workload Identity Pool to associate with the cluster. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [ca_certificate](outputs.tf#L1) | The cluster CA certificate (base64 encoded). | ✓ |
| [endpoint](outputs.tf#L7) | The IP address of the cluster master. |  |
| [id](outputs.tf#L12) | The unique identifier of the cluster. |  |
| [location](outputs.tf#L17) | The location of the cluster. |  |
| [master_version](outputs.tf#L22) | The current version of the master. |  |
| [name](outputs.tf#L27) | The name of the cluster. |  |
| [self_link](outputs.tf#L32) | The server-defined URL for the cluster. |  |
<!-- END TFDOC -->
