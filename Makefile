SKAFFOLD_VERSION=0.32.0
CST_VERSION=1.8.0

setup: .resize microk8s helm skaffold gitconfig ssh

.resize: 
	sh resize-volume.sh
	touch .resize
	
microk8s:
	sudo snap install kubectl --classic
	sudo snap install microk8s --classic
	microk8s.status --wait-ready
	microk8s.enable registry
	microk8s.config > $(HOME)/.kube/config 
	
helm:
	sudo snap install helm --classic
	helm init

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
	@read -p "  What is your name? " name && git config --global user.name "$${name}"
	@read -p "  What is your email? " email && git config --global user.email "$${email}"
	@echo ""