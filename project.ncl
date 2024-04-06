let inputs = import "./nickel.lock.ncl" in
let organist = inputs.organist in
{
  shells = organist.shells.Bash,

  shells.build = {
    packages = {},
  },

  shells.dev = {
    packages.hello = organist.import_nix "nixpkgs#hello",
  },


  files = (import "./env-amanda-laptop/env.ncl").files &
  	(import "./mindwm-dev1/env.ncl").files

}
  | organist.OrganistExpression
