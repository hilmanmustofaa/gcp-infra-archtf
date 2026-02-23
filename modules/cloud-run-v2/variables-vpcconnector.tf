variable "vpc_connector_create" {
  description = "Populate this to create a Serverless VPC Access connector."
  type = object({
    ip_cidr_range = optional(string)
    machine_type  = optional(string)
    name          = optional(string)
    network       = optional(string)
    instances = optional(object({
      max = optional(number)
      min = optional(number)
      }), {}
    )
    throughput = optional(object({
      max = optional(number)
      min = optional(number)
      }), {}
    )
    subnet = optional(object({
      name       = optional(string)
      project_id = optional(string)
    }), {})
  })
  default = null
}
