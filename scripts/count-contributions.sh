#!/usr/bin/env bash
# Prints the total number of contributions shown on a user's GitHub profile
# graph over the last year (commits + PRs + issues + reviews). This reads the
# public contributions endpoint, which includes private contributions when the
# user has enabled "Include private contributions on my profile" — so it matches
# the "N contributions in the last year" figure on the profile exactly.
#
# No auth needed. Usage: bash scripts/count-contributions.sh <login>

login="${1:?usage: count-contributions.sh <login>}"

html=$(curl -sSL "https://github.com/users/${login}/contributions")

# Each active day renders a tooltip like ">12 contributions on ...". Sum them.
printf '%s' "$html" \
  | grep -oE '>[0-9]+ contribution' \
  | grep -oE '[0-9]+' \
  | awk '{s+=$1} END{print s+0}'
