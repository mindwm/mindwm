let k8s_schema = import "./schema.ncl" in
let k8s_ns_model = import "./namespace.yaml" in
{
  KubernetesNamespaceSchema = {
  	name
	   | k8s_schema.KubernetesNamespace
	   ,
	serialize
	   | Dyn
	   | optional
  },
  make : k8s_schema.KubernetesNamespace -> KubernetesNamespaceSchema = fun namespace => KubernetesNamespaceSchema & {
  	name | force = namespace,
	serialize | force = {
		"namespace/%{namespace}/ns.yml" = {
			content = std.serialize 'Yaml k8s_ns_model
		}
	}
  } | KubernetesNamespaceSchema

}
