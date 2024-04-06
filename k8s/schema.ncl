
{
  KubernetesNamespace = std.contract.from_predicate( fun x => std.string.is_match("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$") x ),
  KubernetesResourceName = std.contract.from_predicate( fun x => std.string.is_match("^[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?$") x ),
}
