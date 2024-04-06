let make_helm_release = (import "../helm.ncl").make in
let HelmChartSchema = (import "../helm.ncl").HelmChartSchema in
let make_k8s_ns = (import "../k8s/namespace.ncl").make in
let env_config = import "./env_config.ncl" in
{
  env | not_exported = {
    natsUserRoot = {
      name = "root",
      password = "r00tpass"
    },


    nats_chart = {
      name = "nats",
      repoUrl = "https://nats-io.github.io/k8s/helm/charts/",
      version = "1.1.10"
    } | HelmChartSchema,

    argocd_chart = {
      name = "argo-cd",
      repoUrl = "https://argoproj.github.io/argo-helm",
      version = "3.35.4"
    } | HelmChartSchema,

    argocd = make_helm_release (make_k8s_ns "argocd") "argocd" argocd_chart {},

    resources = {

	nats_ns = make_k8s_ns "nats",

  	nats = make_helm_release nats_ns "nats" nats_chart  {
	   config = {
	     jetstream.enabled = true,
	     cluster."merge".name =  "nats-cluster",
	     "merge".accounts.root = {
	 	jetstream = "enable",
                users = [
		  natsUserRoot
                ]
 	     },
	     "merge".accounts."$SYS" = {
                users = [
		  {
		    "user" = "sys",
                    "password" = "pass"
                  }
                ]
             }
	   },
           service.ports.cluster.enabled = true,
           service."merge".spec.type = "NodePort"

  	}

    }
  },

  files = std.record.map (
       fun s x => x.serialize
  ) env.resources |> std.record.map_values (fun x => std.record.to_array x)
    |> std.record.values
     |> std.array.flatten |> std.array.map(fun x => std.record.update "field" ("output/" ++ env_config.name ++ "/argocd/" ++ x.field) x)
       |> std.record.from_array &
   {
	"output/%{env_config.name}/Makefile" = {
		content = m%"
create:
	k3d cluster create %{env_config.name} --servers 1 --agents 1 --port 9080:80@loadbalancer --port 9443:443@loadbalancer --api-port 6443 --k3s-arg "traefik@server:0"
delete:
	k3d cluster delete %{env_config.name}
argo_admin:
       kubectl get secret -n %{env.argocd.namespace.name} argocd-initial-admin-secret -o jsonpath='{.data.password}'  |base64 -d;echo
argocd:
	%{env.argocd.helm_string} --wait
	"%
	},
	"output/%{env_config.name}/argo_application.yaml " = {
	  content = std.serialize 'Yaml (
  	    (import "../argocd_application.yml") &
              {
                metadata.name | force = "%{env_config.name}",
                metadata.namespace | force = "%{env.argocd.namespace.name}",
		spec.source | force = {
		  directory = {
 		     jsonnet: {},
                     recurse: true
                  },
	 	  repoURL = "%{env_config.gitRepo}",
	 	  path = "output/%{env_config.name}/argocd"
		},
		spec.syncPolicy.automated | force = {}
 	      }
	    )
	}
   }


}
