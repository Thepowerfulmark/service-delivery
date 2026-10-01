#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)
version=0.1.0
dist=$root/dist
common=$root/packaging/common

rm -rf "$dist"
mkdir -p "$dist/bin" "$dist/stage"

echo "build go binary"
docker run --rm \
  -v "$root/apps/go:/src:ro" \
  -v "$dist/bin:/out" \
  -w /src \
  golang:1.22-alpine \
  sh -c 'CGO_ENABLED=0 go build -o /out/app .'

stage_deb() {
  pkg=$1
  stage=$dist/stage/$pkg
  rm -rf "$stage"
  mkdir -p "$stage/DEBIAN"

  case "$pkg" in
    app-go)
      mkdir -p "$stage/opt/app-go/bin" "$stage/opt/app-go/config" "$stage/lib/systemd/system"
      cp "$dist/bin/app" "$stage/opt/app-go/bin/app"
      chmod 0755 "$stage/opt/app-go/bin/app"
      cp "$common/app-go.env.example" "$stage/opt/app-go/config/config.env.example"
      cp "$common/app-go.service" "$stage/lib/systemd/system/app-go.service"
      cp "$root/packaging/apt/postinst-go" "$stage/DEBIAN/postinst"
      desc="Sample Go HTTP service"
      arch=amd64
      depends=
      ;;
    app-python)
      mkdir -p "$stage/opt/app-python/config" "$stage/lib/systemd/system"
      cp "$root/apps/python/app.py" "$stage/opt/app-python/app.py"
      cp "$common/app-python.env.example" "$stage/opt/app-python/config/config.env.example"
      cp "$common/app-python.service" "$stage/lib/systemd/system/app-python.service"
      cp "$root/packaging/apt/postinst-python" "$stage/DEBIAN/postinst"
      desc="Sample Python HTTP service"
      arch=all
      depends="python3"
      ;;
    app-frontend)
      mkdir -p "$stage/opt/app-frontend" "$stage/lib/systemd/system"
      cp "$root/apps/frontend/index.html" "$stage/opt/app-frontend/index.html"
      cp "$root/apps/frontend/nginx.conf" "$stage/opt/app-frontend/nginx.conf"
      cp "$common/app-frontend.service" "$stage/lib/systemd/system/app-frontend.service"
      cp "$root/packaging/apt/postinst-frontend" "$stage/DEBIAN/postinst"
      desc="Sample static frontend"
      arch=all
      depends="nginx"
      ;;
  esac

  chmod 0755 "$stage/DEBIAN/postinst"
  {
    echo "Package: $pkg"
    echo "Version: $version"
    echo "Section: misc"
    echo "Priority: optional"
    echo "Architecture: $arch"
    echo "Maintainer: Template <template@example.com>"
    if [ -n "$depends" ]; then
      echo "Depends: $depends"
    fi
    echo "Description: $desc"
    echo " Replace the files under /opt/$pkg with your own build."
  } > "$stage/DEBIAN/control"

  if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb --root-owner-group --build "$stage" "$dist/${pkg}_${version}_${arch}.deb"
  else
    docker run --rm -v "$dist:/dist" debian:bookworm-slim \
      dpkg-deb --root-owner-group --build "/dist/stage/$pkg" "/dist/${pkg}_${version}_${arch}.deb"
  fi
}

stage_deb app-go
stage_deb app-python
stage_deb app-frontend
echo "packages in $dist"
