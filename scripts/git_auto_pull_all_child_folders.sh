#!/usr/bin/env bash

# ==============================================================================
# Script: generate_git_report.sh
# Description: Generates a Markdown report of git status for all folders in a directory
# Workflow per folder:
#   1. Check initial working tree status (git status)
#   2. If clean -> git pull; If modified/dirty -> git fetch
#   3. Re-check git status and compile the final report
# Usage: ./generate_git_report.sh [-d target_directory] [-o output_file.md] [--no-sync]
# ==============================================================================

set -euo pipefail

# Default configuration
TARGET_DIR="."
OUTPUT_FILE="GIT_STATUS_REPORT.md"
ENABLE_SYNC=true

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -d DIR       Target directory to scan (default: current directory)
  -o FILE      Output Markdown file path (default: GIT_STATUS_REPORT.md)
  --no-sync    Skip git pull / git fetch (run offline check only)
  -h, --help   Show this help message

Workflow per repository:
  1. Check initial working tree status.
  2. If clean -> Run 'git pull' to auto-update.
     If dirty -> Run 'git fetch' to update tracking refs safely.
  3. Re-examine git status & compile final Markdown report.

Examples:
  ./$(basename "$0")
  ./$(basename "$0") -d /path/to/projects -o my_report.md
  ./$(basename "$0") --no-sync
EOF
    exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d)
            TARGET_DIR="$2"
            shift 2
            ;;
        -o)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --no-sync)
            ENABLE_SYNC=false
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            ;;
    esac
done

# Validate target directory
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist." >&2
    exit 1
fi

TARGET_DIR_ABS=$(cd "$TARGET_DIR" && pwd)
REPORT_DATE=$(date "+%Y-%m-%d %H:%M:%S %z")

echo "🔍 Scanning directories in: $TARGET_DIR_ABS ..."
if [ "$ENABLE_SYNC" = true ]; then
    echo "⚡ Smart Sync Enabled: Clean repos will 'git pull', dirty repos will 'git fetch'."
else
    echo "🚫 Offline Mode (--no-sync): Skipping network pull/fetch."
fi

SUMMARY_ROWS=""
DETAILS_SECTIONS=""

total_dirs=0
total_repos=0
clean_repos=0
dirty_repos=0
non_git_dirs=0
pulled_repos=0
fetched_repos=0

# Iterate through subdirectories
for dir in "$TARGET_DIR_ABS"/*/; do
    [ -d "$dir" ] || continue
    
    dir_name=$(basename "$dir")
    
    # Skip hidden directories and 'tmp' directory
    if [[ "$dir_name" == .* ]] || [[ "$dir_name" == "tmp" ]]; then
        continue
    fi

    total_dirs=$((total_dirs + 1))

    # Check if directory is a git repo
    if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        total_repos=$((total_repos + 1))
        
        # ----------------------------------------------------------------------
        # STEP 1: Check initial working tree status (uncommitted changes)
        # ----------------------------------------------------------------------
        initial_status=$(git -C "$dir" status --porcelain 2>/dev/null || echo "")
        upstream=$(git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")
        
        sync_action="Skipped"

        # ----------------------------------------------------------------------
        # STEP 2: Sync Action (git pull if clean, git fetch if dirty)
        # ----------------------------------------------------------------------
        if [ "$ENABLE_SYNC" = true ] && [ -n "$upstream" ]; then
            if [ -z "$initial_status" ]; then
                echo "  📥 [$dir_name] Clean -> Running git pull..."
                if git -C "$dir" pull --quiet 2>/dev/null; then
                    sync_action="Git Pull ✅"
                    pulled_repos=$((pulled_repos + 1))
                else
                    echo "  ⚠️ [$dir_name] git pull failed, attempting git fetch..."
                    git -C "$dir" fetch --quiet --all 2>/dev/null || true
                    sync_action="Git Fetch (Pull Failed)"
                    fetched_repos=$((fetched_repos + 1))
                fi
            else
                echo "  🌐 [$dir_name] Modified/Dirty -> Running git fetch..."
                git -C "$dir" fetch --quiet --all 2>/dev/null || true
                sync_action="Git Fetch 🌐"
                fetched_repos=$((fetched_repos + 1))
            fi
        fi

        # ----------------------------------------------------------------------
        # STEP 3: Re-check status & build report data
        # ----------------------------------------------------------------------
        branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "")
        if [ -z "$branch" ]; then
            head_hash=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null || echo "")
            if [ -n "$head_hash" ]; then
                branch="Detached ($head_hash)"
            else
                branch="No Commits"
            fi
        fi

        last_commit=$(git -C "$dir" log -1 --format="%h - %s (%cr)" 2>/dev/null || echo "No commits")
        last_commit_escaped=$(echo "$last_commit" | sed 's/|/\\|/g')

        final_status=$(git -C "$dir" status --porcelain 2>/dev/null || echo "")
        
        if [ -z "$final_status" ]; then
            status_badge="🟢 Clean"
            clean_repos=$((clean_repos + 1))
            has_changes=false
        else
            status_badge="🔴 Modified"
            dirty_repos=$((dirty_repos + 1))
            has_changes=true
        fi

        modified_count=$(echo "$final_status" | grep -c -E "^( M|M | A|D | D| R| C)" || true)
        untracked_count=$(echo "$final_status" | grep -c -E "^\?\?" || true)
        staged_count=$(echo "$final_status" | grep -c -E "^[MADRC]" || true)
        stash_count=$(git -C "$dir" stash list 2>/dev/null | wc -l | tr -d ' ' || echo "0")

        # Remote sync status calculation
        sync_status="No Remote"
        if [ -n "$upstream" ]; then
            counts=$(git -C "$dir" rev-list --left-right --count HEAD...@{u} 2>/dev/null || echo "0 0")
            ahead=$(echo "$counts" | awk '{print $1}')
            behind=$(echo "$counts" | awk '{print $2}')
            
            if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
                sync_status="Up-to-date"
            elif [ "$ahead" -gt 0 ] && [ "$behind" -eq 0 ]; then
                sync_status="Ahead by $ahead"
            elif [ "$ahead" -eq 0 ] && [ "$behind" -gt 0 ]; then
                sync_status="Behind by $behind (pull needed)"
            else
                sync_status="Ahead $ahead / Behind $behind"
            fi
        fi

        # Append to summary table
        SUMMARY_ROWS="${SUMMARY_ROWS}| \`$dir_name\` | \`$branch\` | $status_badge | $sync_action | $sync_status | $last_commit_escaped |\n"

        # Append to detailed section if repository is modified or out-of-sync
        if [ "$has_changes" = true ] || [ "$sync_status" != "Up-to-date" -a "$sync_status" != "No Remote" ]; then
            DETAILS_SECTIONS="${DETAILS_SECTIONS}### 📁 \`$dir_name\`\n\n"
            DETAILS_SECTIONS="${DETAILS_SECTIONS}- **Branch:** \`$branch\`\n"
            DETAILS_SECTIONS="${DETAILS_SECTIONS}- **Sync Action Taken:** $sync_action\n"
            DETAILS_SECTIONS="${DETAILS_SECTIONS}- **Upstream:** \`${upstream:-None}\` ($sync_status)\n"
            DETAILS_SECTIONS="${DETAILS_SECTIONS}- **Last Commit:** $last_commit_escaped\n"
            if [ "$stash_count" -gt 0 ]; then
                DETAILS_SECTIONS="${DETAILS_SECTIONS}- **Stash Count:** $stash_count stash(es)\n"
            fi
            DETAILS_SECTIONS="${DETAILS_SECTIONS}\n**Working Tree Breakdown:**\n"
            DETAILS_SECTIONS="${DETAILS_SECTIONS}- Staged: **$staged_count** | Modified: **$modified_count** | Untracked: **$untracked_count**\n\n"
            
            if [ -n "$final_status" ]; then
                DETAILS_SECTIONS="${DETAILS_SECTIONS}<details>\n<summary><b>View changed files</b></summary>\n\n\`\`\`text\n"
                DETAILS_SECTIONS="${DETAILS_SECTIONS}${final_status}\n"
                DETAILS_SECTIONS="${DETAILS_SECTIONS}\`\`\`\n</details>\n\n"
            fi
            DETAILS_SECTIONS="${DETAILS_SECTIONS}---\n\n"
        fi

    else
        non_git_dirs=$((non_git_dirs + 1))
        SUMMARY_ROWS="${SUMMARY_ROWS}| \`$dir_name\` | N/A | ⚪ Non-Git Folder | N/A | N/A | N/A |\n"
    fi
done

SYNC_NOTE="> ⚡ **Smart Sync Active:** Đối với repo không có thay đổi (Clean), script tự động \`git pull\`. Đối với repo có thay đổi dở dang (Modified), script chạy \`git fetch\` để cập nhật remote tracking an toàn."
if [ "$ENABLE_SYNC" = false ]; then
    SYNC_NOTE="> 🚫 **Offline Mode:** Đã bỏ qua thao tác \`git pull\` / \`git fetch\` theo cờ \`--no-sync\`."
fi

# Write Markdown report
cat << EOF > "$OUTPUT_FILE"
# 📊 Git Repository Status Report

> 🕒 **Generated at:** \`$REPORT_DATE\`  
> 📂 **Scanned Directory:** \`$TARGET_DIR_ABS\`  
$SYNC_NOTE

---

## 📈 Executive Summary

| Metric | Count |
| :--- | :--- |
| **Total Subdirectories Scanned** | **$total_dirs** |
| **Git Repositories Identified** | **$total_repos** |
| 🟢 **Clean Repositories** | **$clean_repos** |
| 🔴 **Repositories with Changes** | **$dirty_repos** |
| 📥 **Repositories Auto-Pulled** | **$pulled_repos** |
| 🌐 **Repositories Fetched** | **$fetched_repos** |
| ⚪ **Non-Git Folders** | **$non_git_dirs** |

---

## 📋 Repositories Overview

| Folder / Repo | Branch | Status | Sync Action | Remote Sync | Latest Commit |
| :--- | :--- | :--- | :--- | :--- | :--- |
$(printf "%b" "$SUMMARY_ROWS")

---

## 🔍 Detailed Repository Status

$(if [ -n "$DETAILS_SECTIONS" ]; then printf "%b" "$DETAILS_SECTIONS"; else echo "✨ *All Git repositories are clean and in sync with their tracking branches!*"; fi)

---
*Report generated automatically using \`generate_git_report.sh\`.*
EOF

echo "✨ Report successfully generated at: $OUTPUT_FILE"
