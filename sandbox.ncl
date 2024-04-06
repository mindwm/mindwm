let make_helm_release = (import "./helm.ncl").make in
let make_k8s_ns = (import "./k8s/namespace.ncl").make in
{
  env = {
    serializer = "argocd",

    resources = {
 	istio_system_ns = make_k8s_ns "istio-system",
  	istio = make_helm_release istio_system_ns "istio" "chart" "4.1.0" {
		foo = "bar"
  	}
    }
  },

  test = std.record.map (
       fun s x => std.serialize 'Yaml (x.serialize)
    ) env.resources

}
