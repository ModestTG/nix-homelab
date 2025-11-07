let
  # List of machine public keys
  kaladesh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpFEFYX8tYCEDdVTfKewl9zQoq3X3aQ+52DRTJdOL1x";
  dominaria = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElkoT9GhRczgqRRpdC4gfw/z1eShyqto4AKQnk3nka6";
  systems = [
    kaladesh
    dominaria
  ];
in
{
  # Create keys using `nix run github:ryantm/agenix -- -e <secretName>.age` from this folder
  # this file is not imported into the nix config
  "cf-dns-api-token.age".publicKeys = systems;
}
