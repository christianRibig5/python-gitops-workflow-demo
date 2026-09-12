#!/bin/bash
set -e

cd "$(dirname "$0")"
source .venv/bin/activate
ansible-playbook -i inventory.ini playbook.yml