#!/bin/bash

# Retrieve the application name from the environment variable
last_tag="$LAST_TAG"

# Version calculation logic
# Enable case-insensitive matching
shopt -s nocasematch

# Determine the current version from the last tag
if [[ $last_tag =~ ^[0-9a-f]{5,40}$ ]]; then
  PREFIX="${APP_NAME}-v"
  MAJOR=0
  MINOR=0
  PATCH=0
else
  PREFIX=$(echo $last_tag | grep -oE '^[^-]+-v')
  VERSION=$(echo $last_tag | sed -e "s/^$PREFIX//")
  MAJOR=$(echo $VERSION | cut -d '.' -f 1)
  MINOR=$(echo $VERSION | cut -d '.' -f 2)
  PATCH=$(echo $VERSION | cut -d '.' -f 3)
fi

# Initialize version increment variables
MAJOR_INC=0
MINOR_INC=0
PATCH_INC=0

# Analyze commits for version bump indicators
COMMIT_IDS=$(git log $last_tag..HEAD --pretty=format:"%H" -- $APP_PATH $CORE_PATH)
for COMMIT_ID in $COMMIT_IDS; do
  if git diff --name-only $COMMIT_ID^! | grep -q -E "$APP_PATH|$CORE_PATH"; then
    COMMIT_MSG=$(git log -1 --pretty=format:"%B" $COMMIT_ID)
    # Check for semantic commit types
    if echo "$COMMIT_MSG" | grep -q "BREAKING CHANGE" || echo "$COMMIT_MSG" | grep -qE "\w+\([^)]+\)!:|\w+!:"; then
      MAJOR_INC=1
      break # Major version increment is the highest, stop further analysis
    elif echo "$COMMIT_MSG" | grep -qE '^(feat)'; then
      MINOR_INC=1
    elif echo "$COMMIT_MSG" | grep -qE '^(fix)'; then
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

if [[ "$NEXT_VERSION" == "$last_tag" ]]; then
  echo "VERSION_CHANGED=false" >> $GITHUB_ENV
  echo "VERSION_CHANGED=false"
else
  echo "VERSION_CHANGED=true" >> $GITHUB_ENV
  echo "VERSION_CHANGED=true"
fi

# Disable case-insensitive matching after use
shopt -u nocasematch
