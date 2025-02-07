{ buildGoModule, hasura-graphql-engine }:

buildGoModule rec {
  pname = "hasura";
  version = hasura-graphql-engine.version;

  src = hasura-graphql-engine.src;
  modRoot = "./cli";

  subPackages = [ "cmd/hasura" ];

  vendorSha256 = "1pkc9bh5s2vqnpkmnm91zaihh98b3drhiv4lcpi98rhln8r52b1k";

  doCheck = false;

  buildFlagsArray = [''-ldflags=
    -X github.com/hasura/graphql-engine/cli/version.BuildVersion=${version}
    -s
    -w
  ''];

  postInstall = ''
    mkdir -p $out/share/{bash-completion/completions,zsh/site-functions}

    export HOME=$PWD
    $out/bin/hasura completion bash > $out/share/bash-completion/completions/hasura
    $out/bin/hasura completion zsh > $out/share/zsh/site-functions/_hasura
  '';

  meta = {
    inherit (hasura-graphql-engine.meta) license homepage maintainers;
    description = "Hasura GraphQL Engine CLI";
  };
}
