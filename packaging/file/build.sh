#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
version=0.1.0
dist=$root/dist
work=$dist/stack-$version
common=$root/packaging/common

if [ ! -x "$dist/bin/app" ]; then
  mkdir -p "$dist/bin"
  docker run --rm \
    -v "$root/apps/go:/src:ro" \
    -v "$dist/bin:/out" \
    -w /src \
    golang:1.22-alpine \
    sh -c 'CGO_ENABLED=0 go build -o /out/app .'
fi

rm -rf "$work"
mkdir -p \
  "$work/payload/app-go/bin" \
  "$work/payload/app-go/config" \
  "$work/payload/app-python/config" \
  "$work/payload/app-frontend" \
  "$work/payload/units"

cp "$dist/bin/app" "$work/payload/app-go/bin/app"
chmod 0755 "$work/payload/app-go/bin/app"
cp "$common/app-go.env.example" "$work/payload/app-go/config/config.env.example"
cp "$root/apps/python/app.py" "$work/payload/app-python/app.py"
cp "$common/app-python.env.example" "$work/payload/app-python/config/config.env.example"
cp "$root/apps/frontend/index.html" "$work/payload/app-frontend/index.html"
cp "$root/apps/frontend/nginx.conf" "$work/payload/app-frontend/nginx.conf"
cp "$common/"*.service "$work/payload/units/"
cp "$root/packaging/file/stack-ctl" "$work/stack-ctl"
chmod 0755 "$work/stack-ctl"

tar -C "$dist" -czf "$dist/stack-$version.tar.gz" "stack-$version"
echo "archive $dist/stack-$version.tar.gz"
