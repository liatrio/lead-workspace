SKAFFOLD_VERSION=0.33.0
CST_VERSION=1.8.0

setup: .resize iptables profile microk8s helm skaffold gitconfig ssh c9

.resize:
	sh resize-volume.sh
	touch .resize

c9:
	@cp c9-project.settings ~/environment/.c9/project.settings
	
profile:
	@-which rvm && rvm implode --force
	@sudo cp profile.sh /etc/profile.d/lead-workspace.sh
	
	
microk8s:
	sudo snap install kubectl --classic
	sudo snap install microk8s --classic
	microk8s.status --wait-ready
	microk8s.enable registry
	microk8s.enable dns
	microk8s.config -l > $(HOME)/.kube/config
	
iptables:
	sudo iptables -P FORWARD ACCEPT
	
reset:
	microk8s.disable registry || echo "ok"
	microk8s.disable dns || echo "ok"
	microk8s.reset
	microk8s.stop
	microk8s.start
	microk8s.status --wait-ready
	microk8s.enable registry
	microk8s.enable dns
	helm init

helm:
	sudo snap install helm --classic
	helm init
	cp -a helm-starters/* $(HOME)/.helm/starters/

skaffold:
	@curl -fsLo skaffold https://github.com/GoogleCloudPlatform/skaffold/releases/download/v${SKAFFOLD_VERSION}/skaffold-linux-amd64 && \
	  sudo install skaffold /usr/bin/ && \
	  rm skaffold

	@curl -fsLo container-structure-test https://storage.googleapis.com/container-structure-test/v${CST_VERSION}/container-structure-test-linux-amd64 && \
	  sudo install container-structure-test /usr/bin/ && \
	  rm container-structure-test

	skaffold config set --global default-repo localhost:32000

ssh:
	@test -f ~/.ssh/id_rsa.pub || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q

	@echo ""
	@echo "Register a new SSH key with GitHub by navigating to https://github.com/settings/ssh/new and pasting in:"
	@echo ""
	@cat ~/.ssh/id_rsa.pub
	@echo ""

gitconfig:
	@echo ""
	@echo "Setting up Git"
	@read -p "  What is your full name? " name && git config --global user.name "$${name}"
	@read -p "  What is your email address? " email && git config --global user.email "$${email}"
	@echo ""
