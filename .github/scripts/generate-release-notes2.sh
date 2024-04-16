#!/bin/bash

# Define repository details
REPO_URL="https://github.com/ochadwick-westminster/deployment-test"

# Fetch the encoded commits information from the environment variable
encoded_commits=$(echo "$COMMITS")

#Decode the Base64 encoded commits
commits=$(echo "$encoded_commits" | base64 --decode)

echo "Generating release notes..."
TODAYS_DATE=$(date +%Y-%m-%d) # Gets the current date in the format YYYY-MM-DD
RELEASE_NOTES="## $NEXT_VERSION ($TODAYS_DATE)"
FIXES=""
OTHERS=""
FEATURES=""

# Enable case-insensitive matching
shopt -s nocasematch

echo "Processing commits:"
while IFS= read -r commit; do
  echo "======"
  if [[ -z "$commit" ]]; then
    echo "Commit empty"
    continue
  fi

  # Extract commit hash, which is the first part before a space
  commit_hash=$(echo $commit | awk '{print $1}')
  echo "Commit hash: $commit_hash"
  echo "---"

  # Extract commit title, which is the second part before a space
  commit_title=$(echo "$commit" | cut -d ' ' -f2-)
  echo "Commit title: $commit_title"
  echo "---"

  # Get the full commit message
  full_message=$(git show -s --format=%B $commit_hash)
  echo "Commit body: $full_message"
  echo "---"

  # Determine if it is a breaking change by looking for '!' or 'BREAKING CHANGE' in footer
  breaking_change=false
  if echo "$full_message" | grep -q "BREAKING CHANGE" || echo "$commit_title" | grep -qE "\w+\([^)]+\)!:|\w+!:"; then
      breaking_change=true
  fi
  echo "Breaking change: $breaking_change"
  echo "---"

  # Formatting based on presence of scope
  if echo "$commit_message" | grep -q "):"; then
      echo "Change contains ):"
  
      # Commit with scope
      scope=$(echo "$commit_message" | sed -n 's/.*(\([^)]*\)).*/\1/p')
      echo "scope: $scope"
      description=$(echo "$commit_message" | sed 's/[^:]*:(.*)//')
      echo "description: $description"
      formatted_message="**$scope:** $description$breaking_change"
      echo "formatted_message: $formatted_message"
      echo "---"
  else
      echo "Change does not contain ):"
      # Commit without scope
      description=$(echo "$commit_message" | sed 's/[^:]*: //')
      echo "description: $description"
      formatted_message="$description$breaking_change"
      echo "formatted_message: $formatted_message"
      echo "---"
  fi

  # Link the commit hash
  formatted_message+=" ([${commit_hash}]($REPO_URL/commit/$commit_hash))"

  # Output the formatted message
  echo "$formatted_message"

  FIX=""
  OTHER=""
  FEATURE=""
  
  if [[ "$commit_title" =~ ^feat ]]; then
    FEATURES+="- $formatted_message\n"
  elif [[ "$commit_title" =~ ^fix ]]; then
    FIXES+="- $formatted_message\n"
  else
    OTHERS+="- $formatted_message\n"
  fi
done < <(echo "$commits" | sed '/^$/d')

# Disable case-insensitive matching after use
shopt -u nocasematch

if [[ $FEATURES ]]; then
  RELEASE_NOTES+="\n\n### :rocket: Features\n$FEATURES"
fi
if [[ $FIXES ]]; then
  RELEASE_NOTES+="\n\n### :adhesive_bandage: Fixes\n$FIXES"
fi
if [[ $OTHERS ]]; then
  RELEASE_NOTES+="\n\n### :wrench: Others\n$OTHERS"
fi

echo "Release notes:"
echo -e "$RELEASE_NOTES"

# Save the release notes to a markdown file
echo -e "$RELEASE_NOTES" > release_notes.md
