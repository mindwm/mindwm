let KubernetesSchema = import "../k8s/schema.ncl" in
let KubernetesNamespaceSchema = (import "../k8s/namespace.ncl").KubernetesNamespaceSchema in
let default_namespace = "argocd" in
let default_project = "default" in
let default_server = "https://kubernetes.default.svc" in
let ArgoCdSchemas = (import "./schema.ncl").ArgoCdSchemas in
{
  make_app : KubernetesSchema.KubernetesResourceName -> ArgoCdSchemas.Source -> ArgoCdSchemas.IgnoreDifference -> ArgoCdSchemas.Application =
    fun app_name app_source => ArgoCdSchemas.Application & {
      name = app_name,
      namespace = ArgoCdSchemas.Application.namespace,
      source = app_source,
      serialize = {
        "argocd/%{namespace.name}/%{name}.yml" = {
          content = std.serialize 'Yaml
  	  ((import "./argocd_application.yml") & {
      	    metadata.name | force = name,
  	    metadata.namespace | force = namespace.name,
              spec.destination | force = ArgoCdSchemas.Application.destination,
  	    spec.source = {
  	      path | force = source.path,
                repoURL | force = source.repo,
                targetRevision | force = source.branch
              }
            })

        }
      }
    } | ArgoCdSchemas.Application
}
