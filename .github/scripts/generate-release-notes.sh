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

  #commit_message="$commit_title"
  breaking_change_commit=false
  if [[ "$full_message" =~ BREAKING[[:space:]]CHANGE: ]] || [[ "$commit_title" =~ ^[a-z]+!: ]]; then
    #commit_message+=$' (BREAKING CHANGE)'
    breaking_change_commit=true
    echo "Commit contains breaking change"
  fi

  FIX=""
  OTHER=""
  FEATURE=""
  
  if [[ "$commit_title" =~ ^feat ]]; then
    if [[ "$breaking_change_commit" == true ]]; then
      FEATURE="- **$(echo $commit_title | cut -d ' ' -f2-)**\n"
    else
      FEATURE="- $(echo $commit_title | cut -d ' ' -f2-)\n"
    fi
    FEATURES+=$FEATURE
  elif [[ "$commit_title" =~ ^fix ]]; then
    FIXES+="- $(echo $commit_title | cut -d ' ' -f2-)\n"
  else
    OTHERS+="- $commit_title\n"
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
