.PHONY: reset install startat help

default: install

install:
	ansible-playbook site.yml -i inventory/my-cluster/hosts.ini

uninstall:
	ansible-playbook reset.yml -i inventory/my-cluster/hosts.ini

startat:
	@if [ -z "$(task)" ]; then \
		echo "Error: You must specify a parameter for --start-at-task"; \
		exit 1; \
	fi
	ansible-playbook site.yml -i inventory/my-cluster/hosts.ini --start-at-task="$(task)"

pull-pki:
	scp -r 10.20.183.57:/root/.kube/config ~/.kube/config
	chmod 600 ~/.kube/config
	sed -i "s/localhost:9443/10.20.183.57:6443/" ~/.kube/config

vpn: pull-pki
	kubevpn disconnect 0 || echo
	# kubevpn connect --image registry.local:5000/naison/kubevpn:v2.9.1
	kubevpn connect

help:
	@echo "Usage:"
	@echo "  make                 # Run the install playbook (default)"
	@echo "  make uninstall           # Run the reset playbook"
	@echo "  make install         # Run the install playbook"
	@echo "  make startat task="xxx"   # Run the install playbook starting at a specific task"
