#!/bin/sh
set -e

echo "📦 Generating .tflint.hcl into all modules..."

TFLINT_CONFIG_CONTENT=$(cat <<'EOF'
plugin "google" {
  enabled = true
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}
EOF
)

for MODULE in $(find modules -mindepth 1 -maxdepth 1 -type d); do
  echo "📍 Writing .tflint.hcl into $MODULE"
  echo "$TFLINT_CONFIG_CONTENT" > "$MODULE/.tflint.hcl"
done

echo "✅ Done."
