CLUSTER_NAME := mindwm
create:
	k3d cluster create $(CLUSTER_NAME) --servers 1 --agents 1 --port 9080:80@loadbalancer --port 9443:443@loadbalancer --api-port 6443 --k3s-arg "traefik@server:0"
delete:
	k3d cluster delete $(CLUSTER_NAME)
argocd: create
	helm upgrade --install --namespace argocd --create-namespace argocd argo/argo-cd --wait
regenerate-files:
	nix run .#regenerate-files
