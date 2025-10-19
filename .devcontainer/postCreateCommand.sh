#! /bin/bash

set -ex

echo "Print OS and Tool Versions"

lsb_release -a
git --version

pwsh --version
az version

echo "INSTALLING PROJECT DEPENDENCIES"


echo "postCreateCommand.sh finished!"
