let KubernetesNamespaceSchema = import "./namespace.yaml" in
let KubernetesNamespace = fun namespace_name => KubernetesNamespaceSchema & {
  metadata.name | force = namespace_name
} in
{
	make = KubernetesNamespace
}
