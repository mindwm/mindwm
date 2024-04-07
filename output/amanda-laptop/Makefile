create:
	k3d cluster create amanda-laptop --servers 1 --agents 1 --port 9080:80@loadbalancer --port 9443:443@loadbalancer --api-port 6443 --k3s-arg "traefik@server:0"
delete:
	k3d cluster delete amanda-laptop
argo_admin:
	kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}'  |base64 -d;echo
argocd:
	helm repo add argocd https://argoproj.github.io/argo-helm && helm repo update && helm upgrade --install --namespace argocd --create-namespace argocd argocd/argo-cd --wait
