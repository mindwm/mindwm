let KubernetesNamespaceSchema = import "./namespace.yaml" in
let KubernetesNamespace = fun namespace_name => KubernetesNamespaceSchema & {
  metadata.namespace = namespace_name
} in
{
	make = KubernetesNamespace
}
