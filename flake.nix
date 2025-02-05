{
  description = "Bitte Cells";
  inputs = {
    std.url = "github:divnix/std";
    n2c.url = "github:nlewo/nix2container";
    data-merge.url = "github:divnix/data-merge";
    cicero.url = "github:input-output-hk/cicero";
    # Cardano Stack Inputs
    cardano-iohk-nix.url = "github:input-output-hk/iohk-nix";
    cardano-node.url = "github:input-output-hk/cardano-node/flake-improvements";
    cardano-db-sync.url = "github:input-output-hk/cardano-db-sync/12.0.1-flake-improvements";
    cardano-wallet.url = "github:input-output-hk/cardano-wallet";
  };

  outputs = {
    std,
    cicero,
    nixpkgs,
    ...
  } @ inputs:
    (std.grow {
      inherit inputs;
      as-nix-cli-epiphyte = false;
      systems = ["x86_64-linux"];
      cellsFrom = ./cells;
      # debug = ["cells" "cardano" "healthChecks"];
      organelles = [
        (std.runnables "healthChecks")
        (std.runnables "entrypoints")
        # just repo automation; std - just integration pending
        (std.runnables "justTasks")
        (std.installables "oci-images")
        (std.installables "packages")
        (std.functions "library")
        (std.data "constants")
        (std.functions "nomadJob")
        (std.functions "nomadTask")
        (std.functions "devshellProfiles")
        (std.functions "nixosProfiles")
        (std.functions "hydrationProfiles")
      ];
    })
    // {
      ciceroActions =
        cicero.lib.callActionsWithExtraArgs rec {
          inherit (cicero.lib) std;
          inherit (nixpkgs) lib;
          actionLib = import "${cicero}/action-lib.nix" {inherit std lib;};
        }
        cicero/actions;
    };
}
