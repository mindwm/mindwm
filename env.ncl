let make_helm_release = (import "./helm.ncl").make in
let HelmChartSchema = (import "./helm.ncl").HelmChartSchema in
let make_k8s_ns = (import "./k8s/namespace.ncl").make in
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
  ) env.resources |> std.record.map_values (fun x => std.record.to_array x) |> std.record.values |> std.array.flatten |> std.record.from_array


}
