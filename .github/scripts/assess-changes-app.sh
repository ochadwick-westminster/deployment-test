#!/bin/bash

# Retrieve the application name from the environment variable
app_name="$APP_NAME"

# Fetch tags to ensure we have the latest tag information
git fetch --tags

LAST_TAG=$(git tag --list | grep -i "^${app_name}" | sort --version-sort --reverse | head -n 1)
if [ -z "$LAST_TAG" ]; then
  LAST_TAG=$(git rev-list --max-parents=0 HEAD)
  echo "No version tag found, using initial commit as LAST_TAG."
fi
echo "LAST_TAG=$LAST_TAG" >> $GITHUB_ENV

# Determine changed files since the last tag in application and core directories
CHANGED_FILES_APP=$(git diff --name-only $LAST_TAG HEAD | grep -E "$APP_PATH" || true)
CHANGED_FILES_CORE=$(git diff --name-only $LAST_TAG HEAD | grep -E "$CORE_PATH" || true)

# Set environment variable to indicate if the app or core has changes
if [[ -z "$CHANGED_FILES_APP" && -z "$CHANGED_FILES_CORE" ]]; then
  echo "There are no changes detected to app."
  echo "APP_AFFECTED=false" >> $GITHUB_ENV
else
  echo "Changes detected in $APP_NAME or Core application. Preparing release."
  echo "APP_AFFECTED=true" >> $GITHUB_ENV
fi
