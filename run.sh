#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

if ! command -v pip &> /dev/null ; then
	sudo apt update
	sudo apt install -y python-pip
fi

if ! ( command -v ansible &> /dev/null && [[ "$(ansible --version | head -1 | awk '{print $2}')" == "2.5.0" ]] ); then
	echo pip install --user -r requirements.txt
fi

echo "Starting Ansible"
echo "Note: Ansible will need root access, expect a sudo prompt"
ansible-playbook \
	"setup.yml" \
	-i "HOSTS" \
	--ask-become-pass \
	--connection=local \
	--module-path ./ansible_modules

