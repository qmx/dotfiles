{ pkgs, ... }:

let
  nginxConf = pkgs.writeText "nginx.conf" ''
    worker_processes auto;
    error_log /dev/stderr;
    pid /tmp/nginx.pid;

    events {
      worker_connections 1024;
    }

    http {
      access_log /dev/stdout;

      server {
        listen 80;

        # Static cache first, fallback to ncps
        location / {
          root /data/static;
          try_files $uri @ncps;
        }

        location ~ \.narinfo$ {
          root /data/static;
          try_files $uri @ncps;
        }

        location /nar/ {
          root /data/static;
          try_files $uri @ncps;
          sendfile on;
          tcp_nopush on;
          directio 4m;
        }

        location @ncps {
          proxy_pass http://127.0.0.1:8081;
          proxy_buffering off;
          proxy_request_buffering off;
        }
      }
    }
  '';

  deployScript = pkgs.writeShellScript "deploy.sh" ''
    set -euo pipefail

    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    SECRETS_FILE="''${1:-$HOME/.config/nix/secrets/secrets.json.age}"
    TARGET="ark"
    REMOTE_DIR="\$HOME/dev/syno-docker/nix-cache"

    if [ ! -f "$SECRETS_FILE" ]; then
      echo "Error: Secrets file not found: $SECRETS_FILE"
      echo "Usage: $0 [path/to/secrets.json.age]"
      exit 1
    fi

    echo "Rendering docker-compose.yml with secrets..."

    # Decrypt secrets and render template
    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT

    ${pkgs.age}/bin/age --decrypt \
      -i ~/.config/age/keys.txt \
      -o "$TMPDIR/secrets.json" \
      "$SECRETS_FILE"

    ${pkgs.minijinja}/bin/minijinja-cli \
      --autoescape none \
      "$SCRIPT_DIR/docker-compose.yml.j2" \
      "$TMPDIR/secrets.json" \
      -o "$TMPDIR/docker-compose.yml"

    echo "Deploying to $TARGET..."

    # Create directories and clean old configs
    ssh $TARGET "mkdir -p $REMOTE_DIR/config $REMOTE_DIR/tailscale /volume1/nix-cache/{static,ncps} && rm -f $REMOTE_DIR/config/nginx.conf $REMOTE_DIR/docker-compose.yml"

    # Copy configs
    scp -O "$SCRIPT_DIR/nginx.conf" "$TARGET:$REMOTE_DIR/config/"
    scp -O "$TMPDIR/docker-compose.yml" "$TARGET:$REMOTE_DIR/"

    echo "Restarting containers..."
    ssh $TARGET "bash -l -c 'cd $REMOTE_DIR && docker-compose up -d'"

    echo "Done! Check status with: ssh ark 'docker-compose -f $REMOTE_DIR/docker-compose.yml ps'"
  '';

in
pkgs.runCommand "ark-nixcache" { } ''
  mkdir -p $out
  cp ${nginxConf} $out/nginx.conf
  cp ${deployScript} $out/deploy.sh
  chmod +x $out/deploy.sh
''
