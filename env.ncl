let make_helm_release = (import "./helm.ncl").make in
let make_k8s_ns = (import "./k8s/namespace.ncl").make in
{
  env | not_exported = {
    serializer = "argocd",

    resources = {
 	istio_system_ns = make_k8s_ns "istio-system",
  	istio = make_helm_release istio_system_ns "istio" "chart" "4.1.0" {
		foo = "bar"
  	}
    }
  },

  #_files = std.record.map (
  #     fun s x => x.serialize
  #  ) env.resources, #|> std.record.map_values (fun x => std.record.to_array x) |> std.record.values |> std.array.flatten |> std.record.from_array
  #files = ( std.record.map_values (fun x => std.record.to_array x) _files |> std.record.values |> std.array.flatten |> std.record.from_array)

  files = std.record.map (
       fun s x => x.serialize
  ) env.resources |> std.record.map_values (fun x => std.record.to_array x) |> std.record.values |> std.array.flatten |> std.record.from_array


}
