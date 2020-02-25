SKAFFOLD_VERSION=0.33.0
CST_VERSION=1.8.0
K8S_VERSION=1.15/stable

all: setup k8s install

setup: .resize iptables profile
install: helm skaffold gitconfig ssh c9

.resize:
	sh resize-volume.sh
	touch .resize

c9:
	@cp c9-project.settings ~/environment/.c9/project.settings
	
profile:
	@-which rvm && rvm implode --force
	@sudo cp profile.sh /etc/profile.d/lead-workspace.sh
	
k8s:
	curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
	chmod +x kubectl
	sudo mv ./kubectl /usr/bin/kubectl
	curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-linux-amd64
	chmod +x kind
	sudo mv ./kind /usr/local/bin
	bash create-cluster.sh
	chown -R ubuntu:ubuntu ~ubuntu/.kube
	kind export kubeconfig
	echo "alias k=kubectl" >> /home/ubuntu/.bashrc
	kubectl apply -f rbac.yaml
	
iptables:
	sudo iptables -P FORWARD ACCEPT
	
reset:
	sudo systemctl stop kind-control-plane
	kind delete cluster
	bash create-cluster.sh
	kind export kubeconfig
	kubectl apply -f rbac.yaml
	helm init

helm:
	curl -LO https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz
	tar -zxvf helm-v2.16.1-linux-amd64.tar.gz
	sudo mv linux-amd64/helm /usr/bin/helm
	helm init
	cp -a helm-starters/* $(HOME)/.helm/starters/

skaffold:
	@curl -fsLo skaffold https://github.com/GoogleCloudPlatform/skaffold/releases/download/v${SKAFFOLD_VERSION}/skaffold-linux-amd64 && \
	  sudo install skaffold /usr/bin/ && \
	  rm skaffold

	@curl -fsLo container-structure-test https://storage.googleapis.com/container-structure-test/v${CST_VERSION}/container-structure-test-linux-amd64 && \
	  sudo install container-structure-test /usr/bin/ && \
	  rm container-structure-test

	skaffold config set --global default-repo localhost:5000

ssh:
	@test -f ~/.ssh/id_rsa.pub || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q

	@echo ""
	@echo "Register a new SSH key with GitHub by navigating to https://github.com/settings/ssh/new and pasting in:"
	@echo ""
	@cat ~/.ssh/id_rsa.pub
	@echo ""

gitconfig:
	@curl -LO https://github.com/github/hub/releases/download/v2.13.0/hub-linux-amd64-2.13.0.tgz
	@tar -zxvf hub-linux-amd64-2.13.0.tgz
	@sudo mv hub-linux-amd64-2.13.0/bin/hub /usr/bin/hub
	@echo ""
	@echo "Setting up Git"
	@read -p "  What is your full name? " name && git config --global user.name "$${name}"
	@read -p "  What is your email address? " email && git config --global user.email "$${email}"
	@echo ""

.PHONY: setup
