#!/bin/bash
# shellcheck source=/dev/null
# @name: create-release.sh
# @description: Create a new release based on the commits since the last tag
# @author: @tomcdj71
# @author_name: Thomas Chauveau
# @project: MediaEase
# @license: MIT
# @copyright: 2024 Thomas Chauveau

# Setup environment variables
DEBUG=${DEBUG:-false}
REPO_NAME=${REPO_NAME:-$(basename "$(git remote get-url origin)" .git)}
REPO_OWNER=${REPO_OWNER:-$(git remote get-url origin | cut -d/ -f4)}
GITHUB_REF=${GITHUB_REF:-$(git rev-parse --abbrev-ref HEAD)}
if [[ -z "$DEVELOP_BRANCH" ]]; then
  printf "Please set the following environment variables: GITHUB_TOKEN, REPO_OWNER, REPO_NAME, DEVELOP_BRANCH\n" >&2
  exit 1
fi

# Log a message
# @param level: the log level
# @param message: the log message
# @return the log
log() {
  local level=$1
  local message=$2
  local line function_name

  line=$(caller | awk '{print $1}')
  function_name=$(caller | awk '{print $2}')

  echo "::${level} file=$0 line=$line function=$function_name::${message}" >&2
}

# Get the commits since the last tag
# @param last_tag: the last tag
# @return the commits
get_commits(){
  local last_tag=$1
  local commits
  commits=$(git log "$last_tag"..HEAD --pretty=format:"%h %s")
  echo "$commits"
}

# Fetch the last tag from the remote
# @return the last tag or v0.1.0 if no tags are found
get_last_tag() {
  local tag
  tag=$(git describe --tags "$(git rev-list --tags --max-count=1)" 2>/dev/null)
  if [ -z "$tag" ]; then
    log "notice" "No tags found. Defaulting to v0.1.0" "get_last_tag"
    echo "v0.1.0"
  else
    log "notice" "Last tag: $tag" "get_last_tag"
    echo "$tag"
  fi
}

# Get the prerelease identifier
# @return the prerelease identifier
function get_prerelease_suffix() {
  if [[ -n "$PRERELEASE_IDENTIFIER" ]]; then
    echo "$PRERELEASE_IDENTIFIER"
    return
  fi

  # Set default values for repo and file if not provided
  local prerelease_repo="${PRERELEASE_REPO:-$REPO_OWNER/$REPO_NAME}"
  local file_path="${PRERELEASE_FILE:-prerelease_identifier.txt}"
  local url="https://raw.githubusercontent.com/${prerelease_repo}/main/${file_path}"
  local silent_flag=""

  [[ $DEBUG == "true" ]] || silent_flag="-s"
  local prerelease_identifier
  prerelease_identifier=$(curl "$silent_flag" "$url")

  # Provide a default identifier if curl fails or the file is empty
  if [[ -z "$prerelease_identifier" ]]; then
    prerelease_identifier="beta"
  fi

  echo "$prerelease_identifier"
}



# Calculate the new version based on the commits since the last tag
# @param last_tag: the last tag
# @return the new version
calculate_new_version() {
  local last_tag=$1
  local prerelease_suffix
  prerelease_suffix=$(get_prerelease_suffix)
  local full_last_tag=$last_tag
  last_tag=${last_tag#v}
  last_tag=${last_tag%-"$prerelease_suffix"}

  IFS='.' read -r -a version_components <<< "$last_tag"
  local major=${version_components[0]}
  local minor=${version_components[1]}
  local patch=${version_components[2]}

  local has_feature_commit=false
  local has_breaking_commit=false
  local has_other_commit=false

  while IFS= read -r line; do
    if [[ "$line" =~ feat: ]]; then
      has_feature_commit=true
    elif [[ "$line" =~ breaking: ]]; then
      has_breaking_commit=true
    else
      has_other_commit=true
    fi
  done < <(get_commits "$full_last_tag")

  if [[ "$has_breaking_commit" == "true" ]]; then
    major=$((major + 1))
    minor=0
    patch=0
  elif [[ "$has_feature_commit" == "true" ]]; then
    minor=$((minor + 1))
    patch=0
  elif [[ "$has_other_commit" == "true" ]]; then
    patch=$((patch + 1))
  fi

  local new_version="v${major}.${minor}.${patch}"
  if [[ "$GITHUB_REF" == "refs/heads/$DEVELOP_BRANCH" ]]; then
    new_version="${new_version}-${prerelease_suffix}"
  fi

  log "notice" "Old version: $full_last_tag" "calculate_new_version"
  log "notice" "New version calculated: $new_version" "calculate_new_version"
  echo "$new_version"
}

# Is the current branch a prerelease branch?
# @return true or false
is_prerelease() {
  [[ "$GITHUB_REF" == "refs/heads/$DEVELOP_BRANCH" ]] && printf "true\n" || printf "false\n"
}

# Create a new tag
# @param new_version: the new version
# @return the new tag
create_tag() {
  local new_version=$1
  local quiet_flag=""
  if git rev-parse "$new_version" >/dev/null 2>&1; then
    log "error" "Tag $new_version already exists" "create_tag"
    printf "Tag %s already exists\n" "$new_version" >&2
    exit 1
  fi
  
  [[ $DEBUG != "true" ]] || quiet_flag="-q"
  
  git tag "$new_version"
  git push origin "$new_version" $quiet_flag
}

# Generate the changelog since the last tag
# @param last_tag: the last tag
# @return the changelog
generate_changelog() {
  local last_tag=$1

  # Define the changelog types
  declare -A changelog_types
  changelog_types["api"]="📡 API"
  changelog_types["assets"]="🍱 Assets"
  changelog_types["breaking"]="💥 Breaking Changes"
  changelog_types["build"]="🏗️ Build System & Dependencies"
  changelog_types["chore"]="🚀 Chores"
  changelog_types["ci"]="👷 Continuous Integration"
  changelog_types["conf"]="🔧 Configuration"
  changelog_types["docs"]="📝 Documentation"
  changelog_types["egg"]="🥚 Easter Eggs"
  changelog_types["feat"]="🎉 New Features"
  changelog_types["fix"]="🩹 Bug Fixes"
  changelog_types["hotfix"]="🚑 Hotfixes"
  changelog_types["intl"]="🌐 Internationalization"
  changelog_types["other"]="🤷 Other Changes"
  changelog_types["perf"]="⚡️ Performance Improvements"
  changelog_types["platform"]="🐧️ Linux"
  changelog_types["refactor"]="♻️ Refactors"
  changelog_types["revert"]="⏪️ Reverts"
  changelog_types["security"]="🔒 Security"
  changelog_types["style"]="💄 Code Style"
  changelog_types["test"]="✅ Tests"
  changelog_types["ui"]="🎨 UI/UX"

  # Initialize changelog string
  local changelog="# Changelog\n\n### This release contains the following changes:\n\n"

  # Get the list of commits since the last tag, with details
  local commits
  commits=$(git log "$last_tag"..HEAD --pretty=format:"%H %s %an")

  # Sort commits into sections based on their types
  declare -A sections
  while IFS= read -r commit; do
    local hash type desc author
    hash=$(echo "$commit" | awk '{print $1}')
    type=$(echo "$commit" | awk '{print $2}' | sed -n 's/^\([^:]*\):.*/\1/p')
    desc=$(echo "$commit" | sed -e "s/^[^ ]* $type: //g" -e "s/ [^ ]*$//g")
    author=$(echo "$commit" | awk '{print $NF}')
    partial_hash=${hash:0:7}
    sections[$type]+="- $desc ([$partial_hash](https://github.com/$REPO_OWNER/$REPO_NAME/commit/$hash) by @$author)\n"
  done <<< "$commits"

  # Append sections to the changelog
  for type in "${!changelog_types[@]}"; do
    if [[ -n "${sections[$type]}" ]]; then
      changelog+="### ${changelog_types[$type]}\n"
      changelog+="${sections[$type]}"
    fi
  done

  # Write the changelog to CHANGELOG.md
  echo -e "$changelog" > CHANGELOG.md
  # Debug print the changelog
  [[ $DEBUG == "true" ]] || log "notice" "Generated changelog:\n$changelog" "generate_changelog"
  [[ $DEBUG == "true" ]] || cat CHANGELOG.md
}

# Create a GitHub release
# @param new_version: the new version
# @param is_prerelease: is the release a prerelease?
# @return the GitHub release
create_github_release() {
  local new_version=$1
  local is_prerelease=$2
  local changelog_content changelog_body
  changelog_content=$(<CHANGELOG.md)

  # Escape newlines for JSON
  changelog_body=$(echo "$changelog_content" | jq -Rs .)

  log "notice" "Creating GitHub release $new_version" "create_github_release"
  local silent_flag=""
  [[ $DEBUG == "true" ]] || silent_flag="-s"
  curl "$silent_flag" -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type:application/json" \
    -X POST -d @- "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases" <<EOF
    {
      "tag_name": "${new_version}",
      "target_commitish": "main",
      "name": "${new_version}",
      "body": ${changelog_body},
      "draft": false,
      "prerelease": ${is_prerelease} 
    }
EOF
  [[ $DEBUG == "true" ]] || log "notice" "GitHub release created" "create_github_release"
}

create_release() {
  local last_tag new_version is_prerelease
  # Get the last tag
  if ! last_tag=$(get_last_tag); then
    log "error" "Failed to get the last tag" "create_release"
  fi

  # Calculate the new version
  if ! new_version=$(calculate_new_version "$last_tag"); then
    log "error" "Failed to calculate the new version" "create_release"
  fi

  # Is the new version a prerelease?
  is_prerelease=$(is_prerelease)
  if [[ "$is_prerelease" == "true" ]]; then
    log "warning" "Pre-release detected" "create_release"
  fi

  # Create the tag 
  if ! create_tag "$new_version"; then
    log "error" "Failed to create the tag $new_version" "create_release"
  fi

  # Generate the changelog
  if ! generate_changelog "$last_tag"; then
    log "error" "Failed to generate the changelog" "create_release"
    return 1
  fi

  # Create the GitHub release
  if ! create_github_release "$new_version" "$is_prerelease"; then
    log "error" "Failed to create the GitHub release" "create_release"
    return 1
  fi
}

# Main
set -e
set -o pipefail
if ! create_release; then
    log "error" "Release process failed" "create_release"
fi
log "notice" "Release process completed successfully" "create_release"
