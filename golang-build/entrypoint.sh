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
  os="$(echo $target | cut -d '/' -f1)"
  arch="$(echo $target | cut -d '/' -f2)"
  output="${release_path}/${repo_name}_${os}_${arch}"
  if [ $os = "windows" ]; then
    output+='.exe'
  fi

  echo "----> Building project for: $target"
  env GOOS=$os GOARCH=$arch go build -o $output
done

echo "----> Build is complete. List of files at $release_path:"
cd $release_path
ls -al
