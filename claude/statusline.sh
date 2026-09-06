#!/bin/bash
# Claude Code statusline: [CAVEMAN] model | dizin | git branch
input=$(cat)
model=$(printf '%s' "$input" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d.get("model",{}).get("display_name",""))' 2>/dev/null)
dir=$(printf '%s' "$input" | python3 -c 'import sys,json,os;d=json.load(sys.stdin);print(os.path.basename(d.get("workspace",{}).get("current_dir","")))' 2>/dev/null)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
out="\033[33m[CAVEMAN]\033[0m \033[34m$(whoami)@$(hostname -s)\033[0m \033[90m|\033[0m \033[36m$model\033[0m"
[ -n "$dir" ] && out="$out \033[90m|\033[0m \033[32m$dir\033[0m"
[ -n "$branch" ] && out="$out \033[90m|\033[0m \033[35m$branch\033[0m"
printf "$out"
