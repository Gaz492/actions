#!/bin/bash

set -e

if [[ -z "$GITHUB_WORKSPACE" ]]; then
  echo "Set the GITHUB_WORKSPACE env variable."
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Set the GITHUB_REPOSITORY env variable."
  exit 1
fi

root_path="/go/src/github.com/$GITHUB_REPOSITORY"
release_path="$GITHUB_WORKSPACE/.release"
repo_name="$(echo $GITHUB_REPOSITORY | cut -d '/' -f2)"
targets=${@-"darwin/amd64 darwin/386 linux/amd64 linux/386 windows/amd64 windows/386"}

echo "----> Setting up Go repository"
mkdir -p $release_path
mkdir -p $root_path
cp -a $GITHUB_WORKSPACE/* $root_path/
cd $root_path

echo "----> Getting Go Packages"
go get

for target in $targets; do
  echo "----> Building project for: $target"
  platform_split=(${targets//\// })
  GOOS=${platform_split[0]}
  GOARCH=${platform_split[1]}
  output_name="${release_path}/${repo_name}_${GOOS}_${GOARCH}"
  if [ $GOOS = "windows" ]; then
    output+='.exe'
  fi
  env GOOS=$GOOS GOARCH=$GOARCH go build -o $output_name $package
#   GOOS=$os
#   GOARCH=$arch CGO_ENABLED=0 go get && go build -i -o $output
done

echo "----> Build is complete. List of files at $release_path:"
cd $release_path
ls -al
