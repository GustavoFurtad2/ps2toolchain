#!/bin/bash
# toolchain.sh by Naomi Peori (naomi@peori.ca)

## Enter the ps2toolchain directory.
cd "$(dirname "$0")" || { echo "ERROR: Could not enter the ps2toolchain directory."; exit 1; }

## Create the build directory.
mkdir -p build || { echo "ERROR: Could not create the build directory."; exit 1; }

## Enter the build directory.
cd build || { echo "ERROR: Could not enter the build directory."; exit 1; }

## Fetch the depend scripts.
readarray -t DEPEND_SCRIPTS < <(ls ../depend/*.sh | sort)

## Run all the depend scripts.
for SCRIPT in ${DEPEND_SCRIPTS[@]}; do "$SCRIPT" || { echo "$SCRIPT: Failed."; exit 1; } done

## Check if repo is in a tag, to install this specfic PS2 Dev environment
if git describe --exact-match --tags $(git log -n1 --pretty='%h') >/dev/null 2>&1; then
  TAG=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))
  echo "Instaling specific version $TAG";
else
  echo "Installing latest environment status"
  TAG=""
fi

## Fetch the build scripts.
readarray -t BUILD_SCRIPTS < <(ls ../scripts/*.sh | sort)

## If specific steps were requested...
if [ "$1" ]; then

  ## Run the requested build scripts.
  for STEP in "$@"; do "${BUILD_SCRIPTS[$STEP-1]}" "$TAG" || { echo "${BUILD_SCRIPTS[$STEP-1]}: Failed."; exit 1; } done

else

  ## Run the all build scripts.
  for SCRIPT in ${BUILD_SCRIPTS[@]}; do "$SCRIPT" "$TAG" || { echo "$SCRIPT: Failed."; exit 1; } done

fi
