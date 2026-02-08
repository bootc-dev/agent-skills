# Basic development workflows
# Run `just --list` to see available targets.

# Python scripts to check
python_scripts := "diff-quiz/scripts/quiztool perform-forge-review/scripts/reviewtool split-commits/scripts/git-split-commits"

# Run basic syntax checks on all scripts
check:
    #!/bin/bash
    set -euo pipefail
    echo "Checking Python syntax..."
    for script in {{python_scripts}}; do
        python3 -m py_compile "$script" && echo "  ✓ $script"
    done
    echo "All checks passed."
