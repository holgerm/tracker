#!/bin/bash

# go up to porject base dir
cd ..

# Read the current version from pubspec.yaml
version=$(grep 'version:' pubspec.yaml | cut -d ' ' -f 2)

# Split the version into the semantic version and build number
semantic_version=$(echo $version | cut -d '+' -f 1)
build_number=$(echo $version | cut -d '+' -f 2)

# Increment the build number
new_build_number=$((build_number + 1))

# Write the new version back to pubspec.yaml
sed -i "s/version: $version/version: $semantic_version+$new_build_number/" pubspec.yaml