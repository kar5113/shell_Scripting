# Copilot Instructions for AI Coding Agents

## Project Overview
This repository contains a collection of Bash shell scripts for DevOps practice and automation. The scripts are organized by topic and use-case, with a subfolder (`shell-roboshop/`) for more complex provisioning tasks.

## Key Components
- Top-level scripts (e.g., `env_var.sh`, `functions.sh`, `variables.sh`) demonstrate basic to intermediate shell scripting concepts.
- `shell-roboshop/roboshop.sh` automates AWS EC2 instance creation and Route53 DNS record management for a set of service names passed as arguments.

## Patterns and Conventions
- Scripts use Bash (`#!/bin/bash`) and expect to be run in a Unix-like environment (macOS, Linux).
- Arguments are passed to scripts using `$@` and should be quoted in loops for safety: `for instance in "$@"; do ...`.
- AWS CLI is used for cloud automation; credentials and permissions must be configured externally.
- DNS and instance metadata are dynamically constructed based on input arguments and environment variables at the top of each script.
- Use double quotes around variables in test statements (e.g., `[ "$var" == "value" ]`) to avoid errors with empty or special values.

## Developer Workflows
- No build or test automation is present; scripts are run directly from the shell.
- For `roboshop.sh`, ensure AWS CLI is installed and configured, and that you have permissions to create EC2 instances and modify Route53 records.
- Debugging is typically done by adding `set -x` at the top of scripts or echoing variable values.

## Integration Points
- AWS CLI: Used for provisioning and DNS management. Scripts assume the CLI is available in the environment.
- Route53: DNS records are managed via CLI commands embedded in scripts.

## Examples
- To create a frontend and backend instance with DNS records:
  ```sh
  bash shell-roboshop/roboshop.sh frontend backend
  ```
- To experiment with variables or functions, run the corresponding script directly:
  ```sh
  bash variables.sh
  bash functions.sh
  ```

## File Reference
- `shell-roboshop/roboshop.sh`: Main automation script for cloud provisioning.
- Top-level `.sh` files: Practice scripts for various shell features.

## Project-Specific Notes
- No CI/CD, linting, or test frameworks are present.
- No README.md or prior agent instructions were found; this file serves as the primary onboarding guide for AI agents.
