let KubernetesSchema = import "../k8s/schema.ncl" in
let KubernetesNamespaceSchema = (import "../k8s/namespace.ncl").KubernetesNamespaceSchema in
let default_namespace = "argocd" in
let default_project = "default" in
let default_server = "https://kubernetes.default.svc" in
let util = import "../util.ncl" in
{
  ArgoCdSchemas = {
    Source = {
      repo
        | util.UrlSchema
        ,
      path
        | String
	  ,
      branch
        | String
        | default = "main"
    },
    Application = {
      name
       | KubernetesSchema.KubernetesResourceName
       ,
      namespace
       | KubernetesNamespaceSchema
       | default = { name = default_namespace }
       ,
      destination = {
	server
          | util.UrlSchema
          | default = "https://kubernetes.default.svc"
      },

      source
       | ArgoCdSchemas.Source
       ,
      serialize
       | Dyn
       | optional
    }
  },
  make_app : KubernetesSchema.KubernetesResourceName -> ArgoCdSchemas.Source -> ArgoCdSchemas.Application = fun app_name app_source => ArgoCdSchemas.Application & {
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
