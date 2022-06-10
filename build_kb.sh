#!/usr/bin/env bash
# This script is designed to build the keybase client on an arm64 linux target

# Set shell operating params
set -Eeuo pipefail
#set -x # Uncomment for debug

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
MAIN_DIR="$(dirname "$SCRIPT_DIR")"

# Install dependencies
sudo apt update
sudo apt install git golang docker fuse gconf-service patch libxss-dev npm build-essential libgtk2.0-dev -y

# Clone the repos
cd "$MAIN_DIR"
git clone https://github.com/keybase/client.git
git clone https://github.com/keybase/kbfs.git
CLIENT_DIR="$MAIN_DIR/client"
BUILD_DIR="$MAIN_DIR/keybase_build"

# Install new version of yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn -y

# Enter the client dir and try to build
cd "$CLIENT_DIR"
export KEYBASE_BUILD_ARM_ONLY=1
"$CLIENT_DIR"/packaging/linux/build_binaries.sh prerelease "$BUILD_DIR"
FINAL_DIR="$BUILD_DIR/binaries/arm64/opt/keybase"
if [[ ! -f "$FINAL_DIR/post_install.sh" ]]; then
  echo "Build failed post install script not found; exiting."
  exit
else
  cd "$FINAL_DIR"
  ./post_install.sh
fi

