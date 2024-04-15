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

# Version calculation logic
# Enable case-insensitive matching
shopt -s nocasematch

# Determine the current version from the last tag
if [[ $LAST_TAG =~ ^[0-9a-f]{5,40}$ ]]; then
  PREFIX="${APP_NAME}-v"
  MAJOR=0
  MINOR=0
  PATCH=0
else
  PREFIX=$(echo $LAST_TAG | grep -oE '^[^-]+-v')
  VERSION=$(echo $LAST_TAG | sed -e "s/^$PREFIX//")
  MAJOR=$(echo $VERSION | cut -d '.' -f 1)
  MINOR=$(echo $VERSION | cut -d '.' -f 2)
  PATCH=$(echo $VERSION | cut -d '.' -f 3)
fi

# Initialize version increment variables
MAJOR_INC=0
MINOR_INC=0
PATCH_INC=0

# Analyze commits for version bump indicators
COMMIT_IDS=$(git log $LAST_TAG..HEAD --pretty=format:"%H" -- $APP_PATH $CORE_PATH)
for COMMIT_ID in $COMMIT_IDS; do
  if git diff --name-only $COMMIT_ID^! | grep -q -E "$APP_PATH|$CORE_PATH"; then
    COMMIT_MSG=$(git log -1 --pretty=format:"%B" $COMMIT_ID)
    # Check for semantic commit types
    if [[ "$COMMIT_MSG" =~ BREAKING[[:space:]]CHANGE: ]] || [[ "$COMMIT_MSG" =~ ^[a-z]+!: ]]; then
      MAJOR_INC=1
      break # Major version increment is the highest, stop further analysis
    elif [[ "$COMMIT_MSG" =~ ^feat: ]]; then
      MINOR_INC=1
    elif [[ "$COMMIT_MSG" =~ ^fix: ]]; then
      PATCH_INC=1
    fi
  fi
done

# Calculate next version based on increments
if [[ $MAJOR_INC -eq 1 ]]; then
  MAJOR=$(($MAJOR + 1))
  MINOR=0
  PATCH=0
elif [[ $MINOR_INC -eq 1 ]]; then
  MINOR=$(($MINOR + 1))
  PATCH=0
elif [[ $PATCH_INC -eq 1 ]]; then
  PATCH=$(($PATCH + 1))
fi

NEXT_VERSION="$PREFIX$MAJOR.$MINOR.$PATCH"
echo "Next version: $NEXT_VERSION"
echo "NEXT_VERSION=$NEXT_VERSION" >> $GITHUB_ENV

if [[ "$NEXT_VERSION" == "$LAST_TAG" ]]; then
  echo "VERSION_CHANGED=false" >> $GITHUB_ENV
  echo "VERSION_CHANGED=false"
else
  echo "VERSION_CHANGED=true" >> $GITHUB_ENV
  echo "VERSION_CHANGED=true"
fi

# Disable case-insensitive matching after use
shopt -u nocasematch
