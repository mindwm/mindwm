{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.fenix.url = "github:nix-community/fenix";
  inputs.organist.url = "github:nickel-lang/organist";
  inputs.argocd = {
     type = "github";
     owner = "argoproj";
     repo = "argo-cd";
     dir = "manifests/crds";
     flake = false;
  };

  nixConfig = {
    extra-substituters = ["https://organist.cachix.org" "https://nix-community.cachix.org"];
    extra-trusted-public-keys = ["organist.cachix.org-1:GB9gOx3rbGl7YEh6DwOscD1+E/Gc5ZCnzqwObNH2Faw=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };


  outputs = {organist, ...} @ inputs:
    organist.flake.outputsFromNickel ./. inputs {};
 in
    {
      templates.default = {
        path = ./templates/default;
        description = "A devshell using nickel.";
        welcomeText = ''
          You have just created an _Organist_-powered development shell.

          - Enter the environment with `nix develop`
          - Tweak it by modifying `project.ncl`

          _Hint_: To be able to leverage the Nickel language server for instant feedback on your configuration, run `nix run .#regenerate-lockfile` first.
        '';
      };
    };

}
