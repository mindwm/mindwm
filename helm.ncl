let k8s_schema = import "./k8s/namespace.ncl" in
let env_config = import "./env_config.ncl" in
let HelmReleaseName = std.contract.from_predicate(
  # https://github.com/helm/helm/blob/9a5eb70320c1c1b7b6f1c5a6f0f5420cb1c934a0/pkg/chartutil/validate_name.go#L55-L78
  let maxReleaseNameLen = "53" in
  fun value => std.string.is_match("^[a-z0-9][-a-z0-9]{0,%{maxReleaseNameLen}}$") value
) in
let HelmReleaseVersion = std.contract.from_predicate(
  fun value => std.string.is_match("^v\\d+\\.\\d+\\.\\d+$") value
) in
let HelmChartVersion = HelmReleaseVersion in
let HelmChartName = std.contract.from_predicate(
  fun value => std.string.is_match("^[a-zA-Z0-9]+(?:[-.][a-zA-Z0-9]+)*$") value
) in
{
  HelmReleaseOptionsSchema = {
    create_namespace
        | Bool
        | default = true
  },

  HelmChartSchema = {
    name
       | HelmChartName
       ,
    repoUrl
       | String
       ,
    version
       | HelmChartVersion
  },

  HelmReleaseSchema = {
    name
	| HelmReleaseName
	,
    chart
        | HelmChartSchema
        ,
    options
        | HelmReleaseOptionsSchema
	| optional
	| default = { create_namespace = true }
        ,
    values
        | Dyn
        ,
    serialize
    	| Dyn
	| optional
	| default = import "./k8s/namespace.ncl"
        ,
    driver
        | String
        | optional
	| default = "argocd"

  },

  make : k8s_schema.KubernetesNamespaceSchema -> HelmReleaseName -> HelmChartSchema -> Dyn -> HelmReleaseSchema = fun ns release_name _chart helm_values =>
    HelmReleaseSchema &
  	{
		name | force = release_name,
		chart = _chart,
		values | force = helm_values,
		driver | force = "argocd",
		serialize | force = {
		  "%{ns.name}/helm_%{name}.yml" = {
			content = (std.serialize 'Yaml ((import "./_argocd/helm.yml") & {

				metadata.name | force = name,
				spec.destination.namespace | force = ns.name,
			 	spec.source.chart | force = _chart.name,
			 	spec.source.helm.releaseName | force = release_name,
				spec.source.helm.valuesObject | force = helm_values,
				spec.syncPolicy.syncOptions | force = [
				   "CreateNamespace=" ++ std.to_string HelmReleaseOptionsSchema.create_namespace
				]

			}))
		  }
		}
  	} | HelmReleaseSchema

}
