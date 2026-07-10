#!/usr/bin/env bash
# Counts the TOTAL number of commits authored by a GitHub user across every
# repository they own or contribute to (public + private, via the auth token).
#
# Method: for each accessible repo, hit the commits API filtered by author with
# per_page=1 and read the Link header's "last" page number — that page number
# equals the commit count. Sum across all repos.
#
# Usage: GH_TOKEN=<pat> bash scripts/count-commits.sh <login>

login="${1:?usage: count-commits.sh <login>}"

repos=$(gh api --paginate \
  "user/repos?affiliation=owner,collaborator,organization_member&per_page=100" \
  --jq '.[].full_name' | sort -u)

total=0
while read -r r; do
  [ -z "$r" ] && continue
  link=$(gh api -i "repos/$r/commits?author=$login&per_page=1" 2>/dev/null \
          | tr -d '\r' | grep -i '^link:')
  n=$(printf '%s' "$link" | grep -oE 'page=[0-9]+>; rel="last"' | grep -oE '[0-9]+' | head -1)
  if [ -z "$n" ]; then
    # No "last" link means 0 or 1 commit: count the returned array length.
    n=$(gh api "repos/$r/commits?author=$login&per_page=1" 2>/dev/null \
          | jq 'if type=="array" then length else 0 end')
  fi
  total=$((total + ${n:-0}))
done <<< "$repos"

echo "$total"
