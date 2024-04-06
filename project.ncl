let inputs = import "./nickel.lock.ncl" in
let organist = inputs.organist in
let KubernetesNamespaceMake = (import "./k8s/namespace.ncl").make in
{
  shells = organist.shells.Bash,

  shells.build = {
    packages = {},
  },

  shells.dev = {
    packages.hello = organist.import_nix "nixpkgs#hello",
  },


  files = {
  	"clusters/metacoma-laptop/resources/test-namespace.yaml" = {
		content = std.serialize 'Yaml (KubernetesNamespaceMake "test")
	},
  	"clusters/metacoma-laptop/resources/foobar-namespace.yaml" = {
		content = std.serialize 'Yaml (KubernetesNamespaceMake "foobar")
	},
  }

}
  | organist.OrganistExpression
