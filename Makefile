CLUSTER_NAME := mindwm
OUTPUT_DIR := output
create:
	k3d cluster create $(CLUSTER_NAME) --servers 1 --agents 1 --port 9080:80@loadbalancer --port 9443:443@loadbalancer --api-port 6443 --k3s-arg "traefik@server:0"
delete:
	k3d cluster delete $(CLUSTER_NAME)
argocd: create
	helm upgrade --install --namespace argocd --create-namespace argocd argo/argo-cd --wait
regenerate-files:
	nix run .#regenerate-files
	test -d $(OUTPUT_DIR) && git rm -rf $(OUTPUT_DIR) || :
	nix run .#regenerate-files
	git add -A $(OUTPUT_DIR)
	git commit --amend $(OUTPUT_DIR) --no-edit
