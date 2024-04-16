#!/bin/bash

# Retrieve the application name from the environment variable
echo "env app name: $APP_NAME"
app_name="$APP_NAME"
echo "local app name: $app_name"

# Fetch tags to ensure we have the latest tag information
git fetch --tags

# Determine the last tag for the specific application
LAST_TAG=$(git tag --list | grep -i "^${APP_NAME}-v" | sort --version-sort --reverse | head -n 1)

if [ -z "$LAST_TAG" ]; then
  # If no tags are found, consider the first commit as the starting point
  LAST_TAG=$(git rev-list --max-parents=0 HEAD)
  echo "No version tag found, using initial commit as LAST_TAG."
fi

echo "LAST_TAG=$LAST_TAG" >> $GITHUB_ENV
echo "Last tag: $LAST_TAG"

# Determine changed files since the last tag in application and core directories
CHANGED_FILES_APP=$(git diff --name-only $LAST_TAG HEAD | grep -E "$APP_PATH" || true)
CHANGED_FILES_CORE=$(git diff --name-only $LAST_TAG HEAD | grep -E "$CORE_PATH" || true)

echo "Changed Files in $APP_NAME: $CHANGED_FILES_APP"
echo "Changed Files in Core: $CHANGED_FILES_CORE"

# Set environment variable to indicate if the app or core has changes
if [[ -z "$CHANGED_FILES_APP" && -z "$CHANGED_FILES_CORE" ]]; then
  echo "No relevant changes detected. Skipping release."
  echo "APP_AFFECTED=false" >> $GITHUB_ENV
  exit 0
else
  echo "Changes detected in $APP_NAME or Core application. Preparing release."
  echo "APP_AFFECTED=true" >> $GITHUB_ENV
fi
