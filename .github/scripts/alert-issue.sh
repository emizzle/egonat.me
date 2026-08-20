#!/usr/bin/env bash
#
# Manage a single open "alert" issue identified by a label.
#
# Both monitors (uptime, link-check) share this, so the create / update / close
# logic lives in one place. The label - not the title - is the lookup key, so an
# issue that someone retitles by hand is still tracked.
#
# The deliberate omission is comments: `sync` edits the body in place rather than
# adding a comment, because an outage lasting a couple of days at hourly cadence
# would otherwise generate ~48 comments. Comments are reserved for the one state
# transition worth announcing, which `resolve` handles.
#
# Requires: gh, with GH_TOKEN and GH_REPO in the environment.

set -euo pipefail

ASSIGNEE="${ALERT_ASSIGNEE:-emizzle}"

usage() {
  cat >&2 <<'USAGE'
usage:
  alert-issue.sh find     <label>                       # -> "<number> <createdAt>" or nothing
  alert-issue.sh sync     <label> <title> <body-file>   # -> creates or updates, prints number
  alert-issue.sh resolve  <label> <comment-file>        # -> comments on and closes all matches
  alert-issue.sh epoch    <iso8601>                     # -> unix seconds
  alert-issue.sh duration <seconds>                     # -> "2d 6h 14m"
USAGE
  exit 64
}

# Colour and description for labels we create on demand. `gh issue create --label`
# fails outright on a label that does not exist yet, and neither of these existed
# in this repo before the monitors were added.
label_meta() {
  case "$1" in
    uptime)       echo "b60205 Automated uptime alert for egonat.me" ;;
    broken-links) echo "fbca04 Automated broken-link report for egonat.me" ;;
    *)            echo "ededed Automated alert" ;;
  esac
}

ensure_label() {
  local label="$1" color desc
  read -r color desc <<<"$(label_meta "$label")"
  gh label create "$label" --color "$color" --description "$desc" >/dev/null 2>&1 || true
}

# Oldest open issue carrying the label, as "<number> <createdAt>". Prints nothing
# when there is none, so callers can test with [ -z ... ].
cmd_find() {
  local label="$1"
  gh issue list --label "$label" --state open --json number,createdAt \
    --jq 'sort_by(.createdAt) | .[0] | select(.) | "\(.number) \(.createdAt)"'
}

cmd_sync() {
  local label="$1" title="$2" body_file="$3" existing number
  ensure_label "$label"
  existing="$(cmd_find "$label")"
  if [ -n "$existing" ]; then
    number="${existing%% *}"
    gh issue edit "$number" --title "$title" --body-file "$body_file" >/dev/null
  else
    # Fall back to an unassigned issue rather than failing outright if the
    # assignee cannot be set (e.g. the account loses access to the repo).
    number="$(gh issue create --title "$title" --body-file "$body_file" \
                --label "$label" --assignee "$ASSIGNEE" 2>/dev/null |
                grep -oE '[0-9]+$')" ||
    number="$(gh issue create --title "$title" --body-file "$body_file" \
                --label "$label" | grep -oE '[0-9]+$')"
  fi
  echo "$number"
}

# Close every open issue with the label, not just the first. Scheduled runs can be
# delayed and overlap, so duplicates are possible; recovery should clear all of them.
cmd_resolve() {
  local label="$1" comment_file="$2" numbers n
  numbers="$(gh issue list --label "$label" --state open --json number --jq '.[].number')"
  if [ -z "$numbers" ]; then
    echo "no open '$label' issues - nothing to resolve"
    return 0
  fi
  while read -r n; do
    [ -n "$n" ] || continue
    gh issue comment "$n" --body-file "$comment_file" >/dev/null
    gh issue close "$n" --reason completed >/dev/null
    echo "closed #$n"
  done <<<"$numbers"
}

# GNU date first, BSD date second, so the script is testable on macOS too.
cmd_epoch() {
  date -u -d "$1" +%s 2>/dev/null || date -u -j -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s
}

cmd_duration() {
  local s="$1" d h m out=""
  d=$(( s / 86400 )); h=$(( (s % 86400) / 3600 )); m=$(( (s % 3600) / 60 ))
  [ "$d" -gt 0 ] && out="${d}d "
  { [ "$d" -gt 0 ] || [ "$h" -gt 0 ]; } && out="${out}${h}h "
  echo "${out}${m}m"
}

[ $# -ge 1 ] || usage
sub="$1"; shift
case "$sub" in
  find)     [ $# -eq 1 ] || usage; cmd_find "$1" ;;
  sync)     [ $# -eq 3 ] || usage; cmd_sync "$1" "$2" "$3" ;;
  resolve)  [ $# -eq 2 ] || usage; cmd_resolve "$1" "$2" ;;
  epoch)    [ $# -eq 1 ] || usage; cmd_epoch "$1" ;;
  duration) [ $# -eq 1 ] || usage; cmd_duration "$1" ;;
  *)        usage ;;
esac
