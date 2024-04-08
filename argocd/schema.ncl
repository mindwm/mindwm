let KubernetesSchema = import "../k8s/schema.ncl" in
let KubernetesNamespaceSchema = (import "../k8s/namespace.ncl").KubernetesNamespaceSchema in
let util = import "../util.ncl" in
let defaults = {
  namespace = "argocd",
  server = "http://kubernetes.default.svc"
} in
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
    IgnoreDifference = {
      group
        | String
        ,
      kind
        | String
        ,
      name
        | KubernetesSchema.KubernetesResourceName
        ,
      jsonPointers
        | Array String
    },
    Application = {
      name
       | KubernetesSchema.KubernetesResourceName
       ,
      namespace
       | KubernetesNamespaceSchema
       | default = { name = defaults.namespace }
       ,
      destination = {
	server
          | util.UrlSchema
          | default = defaults.server
      },

      source
       | ArgoCdSchemas.Source
       ,
      ignore
       | Array ArgoCdSchemas.IgnoreDifference
       | optional
       ,
      serialize
       | Dyn
       | optional
    },
  },

}
