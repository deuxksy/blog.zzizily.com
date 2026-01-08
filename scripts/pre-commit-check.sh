#!/usr/bin/env bash
set -euo pipefail

# Simple pre-commit check to detect common secret patterns in staged files.
# Install locally:
#   cp scripts/pre-commit-check.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit

STAGED_FILES=$(git diff --cached --name-only -z | xargs -0 -n1 || true)
if [ -z "${STAGED_FILES}" ]; then
  exit 0
fi

FAIL=0
PATTERN="AKIA|-----BEGIN|PRIVATE KEY|api_key|secret\s*=|SECRET_KEY|PASSWORD=|password\s*=|ssh-rsa|-----BEGIN RSA PRIVATE KEY-----"
for file in ${STAGED_FILES}; do
  if [ -f "${file}" ]; then
    if grep -I -nE "${PATTERN}" "${file}" >/dev/null 2>&1; then
      echo "Potential secret found in staged file: ${file}"
      grep -nE "${PATTERN}" "${file}" || true
      FAIL=1
    fi
  fi
done

if [ "${FAIL}" -ne 0 ]; then
  echo "\nCommit aborted: remove secrets from staged files or add safe files to .gitignore. See SECURITY.md for guidance."
  exit 1
fi

exit 0
