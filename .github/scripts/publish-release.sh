#!/bin/bash

# Make sure to stop the script if any step fails
set -e

# Variables
TAG_NAME=$NEXT_VERSION
RELEASE_NAME="${TAG_NAME} Release"
RELEASE_NOTES_FILE="release_notes.md"
ARTIFACT_PATH="publish/${TAG_NAME}.zip"

# Tag the repository with the new version
echo "Creating git tag for the release..."
git tag $TAG_NAME
git push origin $TAG_NAME

echo "Git tag $TAG_NAME pushed."

# Create GitHub Release
echo "Creating GitHub Release $RELEASE_NAME..."

# GitHub CLI to create a release
gh release create "$TAG_NAME" \
    --title "$RELEASE_NAME" \
    --notes-file "$RELEASE_NOTES_FILE" \
    --files "$ARTIFACT_PATH" \
    --target "$(git rev-parse --abbrev-ref HEAD)" \
    --draft false \
    --prerelease false

echo "GitHub Release $RELEASE_NAME created successfully."

# Additional steps could include notifications or further automation triggers.
