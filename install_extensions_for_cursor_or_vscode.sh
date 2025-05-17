#!/bin/bash

# Exit on error but don't kill the script for background process failures
set -e

# Array to hold extension names and their status
declare -A extension_status

# Determine which editor command to use (cursor or code)
if command -v cursor &> /dev/null; then
  EDITOR_CMD="cursor"
elif command -v code &> /dev/null; then
  EDITOR_CMD="code"
else
  echo "Error: Neither Cursor nor VS Code is installed or available in PATH"
  exit 1
fi

echo "Using ${EDITOR_CMD} to install extensions... (this might take a while like 5 minutes!!!! - the extensions marketplace is sloooooooooow)"

# Function to install an extension and track its status
install_extension() {
  local name=$1
  local ext_id=$2
  echo "Installing ${name}..."
  ${EDITOR_CMD} --install-extension ${ext_id} && extension_status["${name}"]="success" || extension_status["${name}"]="failed"
}

# Start all installations in parallel
install_extension "pyright" "ms-pyright.pyright" &
install_extension "ruff" "charliermarsh.ruff" &
install_extension "jupyter" "ms-toolsai.jupyter" &
install_extension "python indent" "kevinrose.vsc-python-indent" &
install_extension "code spell checker" "streetsidesoftware.code-spell-checker" &
install_extension "git graph" "mhutchie.git-graph" &
install_extension "gitlens" "eamodio.gitlens" &
install_extension "live share" "ms-vsliveshare.vsliveshare" &
install_extension "postgres" "ckolkman.vscode-postgres" &
install_extension "rainbow csv" "mechatroner.rainbow-csv" &
install_extension "git rename" "ambooth.git-rename" &
install_extension "git tree compare" "letmaik.git-tree-compare" &

# Store all background PIDs
pids=( $(jobs -p) )

# Wait for all background processes to finish
echo "Waiting for all extensions to finish installing..."
wait

# Check results
failed=0
for name in "${!extension_status[@]}"; do
  if [ "${extension_status[$name]}" = "failed" ]; then
    echo "❌ Failed to install: $name"
    failed=1
  else
    echo "✅ Successfully installed: $name"
  fi
done

if [ $failed -eq 0 ]; then
  echo "🎉 All extensions installed successfully!"
else
  echo "⚠️ Some extensions failed to install. Please check the logs above."
  exit 1
fi


