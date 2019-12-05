#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

if ! command -v pip &> /dev/null ; then
	echo "pip is not installed"
	read -p "Press any key to start install " -n1 -s
	echo ""
	echo "Root access needed"
	sudo apt update
	sudo apt install -y python-pip
fi

if ! ( command -v ansible &> /dev/null && [[ "$(ansible --version | head -1 | awk '{print $2}')" == "2.9.0" ]] ); then
	pip install --user -r requirements.txt
fi

echo "Starting Ansible"
echo "Note: Ansible will need root access, expect a sudo prompt"
echo ""

if [[ ! -f "$HOME/.ansible_is_init" ]]; then
	echo "Before continuing, please confirm your hostname."
	while :; do
		echo "Hostname is currently: $(hostname)"
		read -p "Is this correct? (y/N) " yn
		case $yn in
			[Yy]* ) break;;
			* )
				read -p "Please update hostname and press any key to continue... " -n1 -s
				echo ""
			;;
		esac
	done

	echo ""

	ansible-playbook \
		"setup.yml" \
		-i "HOSTS" \
		--tag=init \
		--ask-become-pass \
		--connection=local \
		--module-path ./ansible_modules
	while :; do
		echo "Setup requires that SpiderOak One is setup and ready."
		echo "A share set to ~/shared must exists to continue."
		read -p "When setup, press any key to continue... " -n1 -s
		echo ""
		if [[ -d "$HOME/shared" ]]; then
			break;
		fi
		echo "$HOME/shared/ does not exists"
		echo ""
	done
	touch "$HOME/.ansible_is_init"
fi

tags=""
if [[ ! -z "${WIP:-}" ]]; then
	tags="--tags=wip"
fi

ansible-playbook \
	"setup.yml" $tags \
	-i "HOSTS" \
	--ask-become-pass \
	--connection=local \
	--module-path ./ansible_modules

