{ ... }:
{
  nix.settings = {
    substituters = [ "http://nix-cache" ];
    trusted-public-keys = [ "nix-cache:9IwJNosU74MY7LLLxTsHlDYGkDjTvvFhoNodxp6OpoQ=" ];
  };
}
