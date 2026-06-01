{
  den.aspects.llama-cpp.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.llama-cpp-server;
    in
    {
      options.services.llama-cpp-server = {
        enable = lib.mkEnableOption "llama.cpp server with ROCm support";

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.llama-cpp-rocm;
          description = "llama.cpp package to use";
        };

        rocmOverrideGfx = lib.mkOption {
          type = lib.types.str;
          default = "10.3.0";
          description = "ROCm GFX override for GPU compatibility";
        };

        models = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                hfRepo = lib.mkOption {
                  type = lib.types.str;
                  description = "HuggingFace repository (e.g., 'Qwen/Qwen2.5-Coder-7B-Instruct-GGUF')";
                };
                hfFile = lib.mkOption {
                  type = lib.types.str;
                  description = "Model file in the repo (e.g., 'qwen2.5-coder-7b-instruct-q4_k_m.gguf')";
                };
                port = lib.mkOption {
                  type = lib.types.port;
                  default = 11434;
                  description = "Port for the server";
                };
                ctxSize = lib.mkOption {
                  type = lib.types.int;
                  default = 32768;
                  description = "Context size";
                };
                nGpuLayers = lib.mkOption {
                  type = lib.types.int;
                  default = 99;
                  description = "Number of layers to offload to GPU (-ngl)";
                };
                extraArgs = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                  description = "Additional llama-server arguments";
                };
              };
            }
          );
          default = { };
          description = "Models to serve";
        };

        stateDir = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/llama-cpp";
          description = "Directory for downloaded models";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          nixpkgs.config.rocmSupport = true;

          users.users.llama-cpp = {
            group = "llama-cpp";
            home = cfg.stateDir;
            isSystemUser = true;
          };

          users.groups.llama-cpp = { };

          systemd.tmpfiles.rules = [
            "d ${cfg.stateDir} 0755 llama-cpp llama-cpp -"
            "d ${cfg.stateDir}/models 0755 llama-cpp llama-cpp -"
          ];

          systemd.services = lib.mapAttrs' (name: model: {
            name = "llama-cpp-${name}";
            value = {
              description = "llama.cpp server for ${name}";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                Type = "simple";
                User = "llama-cpp";
                Group = "llama-cpp";

                ExecStart = lib.concatStringsSep " " (
                  [
                    "${cfg.package}/bin/llama-server"
                    "-hf"
                    "${model.hfRepo}:${model.hfFile}"
                    "--port"
                    (toString model.port)
                    "-c"
                    (toString model.ctxSize)
                    "-ngl"
                    (toString model.nGpuLayers)
                  ]
                  ++ model.extraArgs
                );

                Restart = "always";
                RestartSec = 10;

                Environment = [
                  "HSA_OVERRIDE_GFX_VERSION=${cfg.rocmOverrideGfx}"
                  "PATH=/run/current-system/sw/bin"
                ];

                CacheDirectory = "llama-cpp";
                CacheDirectoryMode = "0755";
              };
            };
          }) cfg.models;
        })

        {
          services.llama-cpp-server = {
            enable = true;
            rocmOverrideGfx = "10.3.0";

            models."qwen2.5-coder" = {
              hfRepo = "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF";
              hfFile = "qwen2.5-coder-7b-instruct-q4_k_m.gguf";
              port = 11434;
              ctxSize = 32768;
              nGpuLayers = 99;
              extraArgs = [
                "-fa"
                "0"
              ];
            };
          };
        }
      ];
    };
}
