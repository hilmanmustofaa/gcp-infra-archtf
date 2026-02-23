# Contributing to gcp-infra-archtf

We welcome contributions to improve and extend our Terraform modules for Google Cloud Platform (GCP). Whether it's fixing bugs, improving documentation, or adding new features, your help is greatly appreciated!

## How to Contribute

### 1. Fork the Repository

Create a fork of this repository and clone it locally.

```sh
git clone https://github.com/hilmanmustofaa/gcp-infra-archtf.git
cd gcp-infra-archtf
```

### 2. Create a Feature Branch

Work on your contributions in a dedicated branch.

```sh
git checkout -b feature/my-new-feature
```

### 3. Follow Code Standards

- Use Terraform best practices.
- Keep variable naming consistent.
- Ensure backward compatibility when making changes.
- All resources **must** include FinOps labels (`env`, `project`, `owner`).

### 4. Test Your Changes

Run the full quality check suite before submitting your PR.

```sh
# Using Taskfile (recommended)
task check

# Or individual checks
task fmt
task validate
task lint
task security
task test
```

### 5. Generate Documentation

If you modified variables, outputs, or module structure, regenerate the README:

```sh
task docs
```

This runs `tools/tfdoc.py` against each module to update the README tables.

### 6. Submit a Pull Request (PR)

Push your changes and open a PR to the `main` branch.

```sh
git push origin feature/my-new-feature
```

Then, create a PR in [GitHub](https://github.com/hilmanmustofaa/gcp-infra-archtf/pulls) and provide a clear description of your changes.

### 7. Review & Approval

A maintainer will review your PR. Ensure you:

- Address any feedback promptly.
- Keep PRs small and focused.
- Add documentation updates if necessary.
- All CI checks pass (validate, lint, security scan, tests).

## Reporting Issues

If you find bugs or issues, create a [GitHub Issue](https://github.com/hilmanmustofaa/gcp-infra-archtf/issues) with:

- A clear description.
- Steps to reproduce the issue.
- Expected behavior and actual results.

## Documentation Standards

We use a custom tool `tfdoc.py` to generate README tables. You can use special annotations in your code to enrich the documentation:

- `# tfdoc:file:description <text>`: Set a custom description for the file in the Files table.
- `# tfdoc:output:consumers <text>`: Specify which modules or systems consume this output.
- `# tfdoc:variable:source <text>`: Specify the origin of this variable (e.g., another module or a global config).

Place these annotations directly above the resource/variable/output definition or at the top of the file.

### Example

```hcl
# tfdoc:output:consumers GKE clusters, VPC Peering
output "id" {
  description = "The ID of the network."
  value       = google_compute_network.network.id
}
```

## License

This project is licensed under the Apache License 2.0 — see [LICENSE](./LICENSE) for details.
