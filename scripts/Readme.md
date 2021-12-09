# pod-golly-wiki scripts

Contains scripts for the private wiki docker pod.
Some scripts are called by Ansible, some scripts
are called by the Makefile.


# Template Scripts

These scripts are used to perform actions involving the Jinja templates.

## `apply_templates.py`

Render Jinja templates. Variable values come from environment variables.
This should be used with the `environment` file in the repo root.

## `clean_templates.py`

Cleans all rendered Jinja templates. Does not require environment variables.

This script is destructive! Be careful!


# Utilities

### `executioner.py`

This provides a utility function to display captured stdout
output as it is printed to the screen, rather than having to
wait until the command is finished to see the output.
