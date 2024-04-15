# Fetch the encoded commits information from the environment variable
encoded_commits=$(echo "$COMMITS")

#Decode the Base64 encoded commits
commits=$(echo "$encoded_commits" | base64 --decode)

echo "Generating release notes..."
RELEASE_NOTES="## Release Notes - $NEXT_VERSION"
FIXES=""
OTHERS=""
FEATURES=""

# Enable case-insensitive matching
shopt -s nocasematch

while IFS= read -r commit; do
  echo "Processing commits:"
  if [[ -z "$commit" ]]; then
    echo "Commit empty"
    continue
  fi

  # Extract commit hash, which is the first part before a space
  commit_hash=$(echo $commit | awk '{print $1}')

  # Extract commit title, which is the second part before a space
  commit_title=$(echo "$commit" | cut -d ' ' -f 2-)

  # Get the full commit message
  full_message=$(git show -s --format=%B $commit_hash)

  commit_message="$commit_title"
  if [[ "$full_message" =~ BREAKING[[:space:]]CHANGE: ]] || [[ "$commit_title" =~ ^[a-z]+!: ]]; then
    commit_message+=$' (BREAKING CHANGE)'
  fi
  echo "Commit message for release note: $commit_message"
  
  if [[ "$commit_title" =~ ^feat ]]; then    
    FEATURES+="- $(echo $commit_message | cut -d ' ' -f2-)\n"
  elif [[ "$commit_title" =~ ^fix ]]; then
    FIXES+="- $(echo $commit_message | cut -d ' ' -f2-)\n"
  else
    OTHERS+="- $commit_message\n"
  fi
done < <(echo "$commits" | sed '/^$/d')

# Disable case-insensitive matching after use
shopt -u nocasematch

if [[ $FEATURES ]]; then
  RELEASE_NOTES+="\n\n### Features\n$FEATURES"
fi
if [[ $FIXES ]]; then
  RELEASE_NOTES+="\n\n### Fixes\n$FIXES"
fi
if [[ $OTHERS ]]; then
  RELEASE_NOTES+="\n\n### Others\n$OTHERS"
fi

echo "Release notes:"
echo -e "$RELEASE_NOTES"

# Save the release notes to a markdown file
echo -e "$RELEASE_NOTES" > release_notes.md