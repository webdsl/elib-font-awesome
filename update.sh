#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o noclobber
set -o nounset
#set -o xtrace

FA_VERSION=6.1.1
FA_NAME=fontawesome-free-${FA_VERSION}-web
FA_URL=https://use.fontawesome.com/releases/v${FA_VERSION}/${FA_NAME}.zip
ASSET_DIR=stylesheets/fontawesome
METADATA_DIR=metadata

################
# REQUIREMENTS #
################
# The following packages:
# - python-yq
# - unzip
# - wget

# Get the script directory
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Extract the following files from Fontawesome into this directory:
# - webfonts/
# - css/all.min.css
# - metadata/icons.yml
echo "Downloading: ${FA_URL}"
tmp_dir=$(mktemp -d)
trap "rm -rf $tmp_dir" 0 2 3 15
wget -q -O "${tmp_dir}/fontawesome.zip" "${FA_URL}"
echo "Unpacking: ${FA_NAME}.zip"
unzip -q "${tmp_dir}/fontawesome.zip" -d "${tmp_dir}/fontawesome/"
echo "Copying: webfonts/ to ${ASSET_DIR}/webfonts/"
rm -r "${dir}/${ASSET_DIR}/webfonts/" 2> /dev/null || true
mkdir -p "${dir}/${ASSET_DIR}/webfonts/"
cp -r "${tmp_dir}/fontawesome/${FA_NAME}/webfonts/" "${dir}/${ASSET_DIR}/webfonts/"
echo "Copying: css/all.min.css to ${ASSET_DIR}/css/all.min.css"
rm -r "${dir}/${ASSET_DIR}/css/" 2> /dev/null || true
mkdir -p "${dir}/${ASSET_DIR}/css/"
cp "${tmp_dir}/fontawesome/${FA_NAME}/css/all.min.css" "${dir}/${ASSET_DIR}/css/"
echo "Copying: metadata/icons.yml to ${ASSET_DIR}/metadata/"
rm -r "${dir}/${ASSET_DIR}/metadata/" 2> /dev/null || true
mkdir -p "${dir}/${ASSET_DIR}/metadata/"
cp "${tmp_dir}/fontawesome/${FA_NAME}/metadata/icons.yml" "${dir}/${ASSET_DIR}/metadata/"

# Overwrite icons.app header
echo "Generating: icons.app"
set +o noclobber        # Allow overwriting files
cat > "${dir}/icons.app" << EOF
////////////////////////////////////////////
// This file is generated. DO NOT MODIFY! //
////////////////////////////////////////////
// See this repo's README.md for more info.

module elib/elib-fontawesome/icons

section Icons

htmlwrapper{
EOF
set -o noclobber        # Disallow overwriting files

# Append icons.app content
cat "${dir}/${ASSET_DIR}/metadata/icons.yml" | yq -r 'to_entries | map(. |
    .key as $key |
    ((.key / "-") | map((.[:1] | ascii_upcase) + .[1:]) | join("")) as $name |
    .value.styles[] | . as $style |
    .[:1] as $letter |
    "  fa\($letter)\($name) i[class=\"fa-\($style) fa-\($key)\"]") |
    .[]' >> "${dir}/icons.app"

# Append icons.app footer
cat >> "${dir}/icons.app" << EOF
}
EOF
echo "Done!"
