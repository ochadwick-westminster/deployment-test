#!/bin/bash

# Fetch the encoded commits information from the environment variable
encoded_commits=$(echo "$COMMITS")
encoded_authors=$(echo "$AUTHORS")

#Decode
commits=$(echo "$encoded_commits" | base64 --decode)
authors=$(echo "$encoded_authors" | base64 --decode)

echo "Generating release notes..."
TODAYS_DATE=$(date +%Y-%m-%d) # Gets the current date in the format YYYY-MM-DD
RELEASE_NOTES="## $NEXT_VERSION ($TODAYS_DATE)"
FEATURES=""
FIXES=""
STYLES=""
REFACTORS=""
PERFS=""
BUILDS=""
CIS=""
REVERTS=""
CONTRIBUTORS=""

# Enable case-insensitive matching
shopt -s nocasematch

while IFS= read -r commit; do
  echo "======"
  if [[ -z "$commit" ]]; then
    echo "Commit empty"
    continue
  fi

  # Extract commit hash, which is the first part before a space
  commit_hash=$(echo $commit | awk '{print $1}')

  # Extract commit title, which is the second part before a space
  commit_title=$(echo "$commit" | cut -d ' ' -f2-)
  echo "commit_title: $commit_title"

  # Get the full commit message
  full_message=$(git show -s --format=%B $commit_hash)

  # Determine if it is a breaking change by looking for '!' or 'BREAKING CHANGE' in footer
  breaking_change=false
  if echo "$full_message" | grep -q "BREAKING CHANGE" || echo "$commit_title" | grep -qE "\w+\([^)]+\)!:|\w+!:"; then
      breaking_change=true
  fi
  echo "Breaking change: $breaking_change"
  echo "---"

  # Formatting commit message
  # Regular expression to check for a valid type at the start of the commit message
  if echo "$commit_title" | grep -qE '^(feat|fix)'; then
      if echo "$commit_title" | grep -qE "):"; then
          # Commit with scope
          scope=$(echo "$commit_title" | awk -F'[:()]' '{print $2}')
          description=$(echo "$commit_title" | sed 's/^[^:]*:[[:space:]]*//')
          formatted_message="**$scope:** $description"
      else
          echo "Change does not contain ):"
          # Commit without scope
          description=$(echo "$commit_title" | sed 's/[^:]*: //')
          formatted_message="$description"
      fi
      
      # Regular expression to check for a pull request number
      if ! echo "$commit_title" | grep -qE '\(#[0-9]+\)'; then
          formatted_message="$formatted_message ($commit_hash)"
      fi
      
      if [[ "$breaking_change" == true ]]; then
          formatted_message="$formatted_message **BREAKING CHANGE**"
      fi
      
      echo "formatted_message: $formatted_message"
  else
      echo "Invalid conventional commit type. Commit does not start with a recognized type."
  fi

  # Output the formatted message
  echo "$formatted_message"
  
  if [[ "$commit_title" =~ ^feat ]]; then
    FEATURES+="- $formatted_message\n"
  elif [[ "$commit_title" =~ ^fix ]]; then
    FIXES+="- $formatted_message\n"
  elif [[ "$commit_title" =~ ^style ]]; then
    STYLES+="- $formatted_message\n"
  elif [[ "$commit_title" =~ ^refactor ]]; then
    REFACTORS+="- $formatted_message\n"
  elif [[ "$commit_title" =~ ^perf ]]; then
    PERFS+="- $formatted_message\n"
  elif [[ "$commit_title" =~ ^build ]]; then
    BUILDS+="- $formatted_message\n"
  elif [[ "$commit_title" =~ ^ci ]]; then
    CIS+="- $formatted_message\n"
  elif [[ "$commit_title" =~ ^revert ]]; then
    REVERTS+="- $formatted_message\n"
  fi
done < <(echo "$commits" | sed '/^$/d')

# Disable case-insensitive matching after use
shopt -u nocasematch

while IFS= read -r author; do
  CONTRIBUTORS+="- $author\n"
done < <(echo "$authors" | sed '/^$/d')

if [[ $FEATURES ]]; then
  RELEASE_NOTES+="\n\n### :sparkles: Features\n$FEATURES"
fi
if [[ $FIXES ]]; then
  RELEASE_NOTES+="\n\n### :bug: Bug Fixes\n$FIXES"
fi
if [[ $STYLES ]]; then
  RELEASE_NOTES+="\n\n### :gem: Styles\n$STYLES"
fi
if [[ $REFACTORS ]]; then
  RELEASE_NOTES+="\n\n### :hammer: Code Refactoring\n$REFACTORS"
fi
if [[ $PERFS ]]; then
  RELEASE_NOTES+="\n\n### :rocket: Performance Improvements\n$PERFS"
fi
if [[ $BUILDS ]]; then
  RELEASE_NOTES+="\n\n### :package: Builds\n$BUILDS"
fi
if [[ $CIS ]]; then
  RELEASE_NOTES+="\n\n### :construction_worker: Continuous Integrations\n$CIS"
fi
if [[ $REVERTS ]]; then
  RELEASE_NOTES+="\n\n### :wastebasket: Reverts\n$REVERTS"
fi
if [[ $CONTRIBUTORS ]]; then
  RELEASE_NOTES+="\n\n### :heart: Thank You\n$CONTRIBUTORS"
fi

echo "Release notes:"
echo -e "$RELEASE_NOTES"

# Save the release notes to a markdown file
echo -e "$RELEASE_NOTES" > release_notes.md
