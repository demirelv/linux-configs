# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# set -o vi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=
HISTFILESIZE=
HISTTIMEFORMAT="%d/%m/%y %T  "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\W \[\033[01;36m\]'$'\u2192 '' \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    # shellcheck source=/dev/null
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# shellcheck source=/dev/null
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# cd-ticket-dir
cdt() {
    if [ $# -ne 1 ]; then
	echo "Usage: ${FUNCNAME[0]} <ticket-name>"
	return 1
    fi
    mkdir -p ~/Documents/FixedIssues/"$1"
    cd ~/Documents/FixedIssues/"$1" || return
}
# vim-ticket
vimt() {
    if [ $# -ne 1 ]; then
	echo "Usage: ${FUNCNAME[0]} <ticket-name>"
	return 1
    fi
    mkdir -p ~/Documents/FixedIssues/"$1"
    vim ~/Documents/FixedIssues/"$1"/notes.md
}

# vim-jira
vimj() {
    if [ $# -ne 1 ]; then
	echo "Usage: ${FUNCNAME[0]} <ticket-name>"
	return 1
    fi
    mkdir -p ~/Documents/FixedIssues/"$1"
    vim ~/Documents/FixedIssues/"$1"/notes.jira
}

# tmux-ticket
tmuxt() {
    if [ $# -ne 1 ]; then
	echo "Usage: ${FUNCNAME[0]} <ticket-name>"
	return 1
    fi
    CUR_TICKET="$1"
    IPADDR_BYTE=$(if [[ "$(echo "${CUR_TICKET}" | awk '{print substr ($0, 1, 3)}')" == "RTS" ]]; \
	then echo "111"; else echo "2"; fi)
    tmux a -t "$1" || tmux new -s "$1" \; \
	send-keys 'sudo minicom -w -D /dev/ttyUSB0 -c on' C-m \; \
	split-window -v -p 40 \; \
	send-keys "vimt $CUR_TICKET" C-m \; \
	split-window -h -p 30\; \
	send-keys "sudo ifconfig eth0 192.168.$IPADDR_BYTE.200" C-m
}

# tmux: varsa session'a baglan, yoksa olustur. Kullanim: tm [isim]  (varsayilan: main)
# tmux icindeyse ic ice acmaz, switch-client ile gecer.
tm() {
    local name="${1:-main}"
    if [ -n "$TMUX" ]; then
        tmux has-session -t "$name" 2>/dev/null || tmux new -d -s "$name"
        tmux switch-client -t "$name"
    else
        tmux new -A -s "$name"
    fi
}

# tmux: baska session'daki pencereyi tasi. Kullanim: tmw kaynak [hedef]
#   kaynak: session:pencere (ornek main:2)   hedef: session: (varsayilan: simdiki session)
tmw() {
    [ -n "$1" ] || { echo "kullanim: tmw session:pencere [hedef_session]" >&2; return 1; }
    local dst="${2:-$(tmux display-message -p '#S')}"
    tmux move-window -s "$1" -t "${dst%:}:"
}

# tmux: baska session'daki pencereyi simdiki pencereye pane olarak birlestir.
# Kullanim: tmj [kaynak] [hedef]   kaynak/hedef: session:pencere (hedef varsayilan: simdiki pencere)
#   Parametresiz: tum session/pencereler arasindan sectirir (fzf varsa fzf, yoksa numarali menu).
tmj() {
    local src="$1" cur
    cur="$(tmux display-message -p '#S:#I')" || return 1
    if [ -z "$src" ]; then
        local list
        list="$(tmux list-windows -a -F '#{session_name}:#{window_index}  #{window_name}  [#{window_panes} pane]  #{pane_current_command}' \
                | awk -v cur="$cur" '$1 != cur')"
        [ -n "$list" ] || { echo "tmj: baska pencere yok" >&2; return 1; }
        if command -v fzf >/dev/null 2>&1; then
            src="$(printf '%s\n' "$list" | fzf --prompt='pencere> ' --height=40% --reverse | awk '{print $1}')"
        else
            local line
            select line in $(printf '%s\n' "$list" | awk '{print $1}'); do src="$line"; break; done
        fi
        [ -n "$src" ] || return 1
    fi
    tmux join-pane -s "$src" -t "${2:-$cur}"
}

# --- tm / tmw / tmj icin Tab tamamlamasi ---
# "main:2" icindeki ":" COMP_WORDBREAKS'te oldugu icin bash gercek terminalde onu uc kelimeye boler
# (COMP_CWORD sismis olur). bash-completion varsa mantiksal kelime/indeks ondan alinir; yoksa duz COMP_WORDS.
# Cagiran fonksiyon `local cur cword` tanimlar; asagidaki yardimcilar dinamik kapsamla onlari doldurur.
_tm_words() {
    if declare -F _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref -n : cur cword
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        cword="$COMP_CWORD"
    fi
}
_tm_reply() { # $1: aday listesi
    mapfile -t COMPREPLY < <(compgen -W "$1" -- "$cur")
    declare -F __ltrim_colon_completions >/dev/null && __ltrim_colon_completions "$cur"
    return 0
}
_tm_sessions() { tmux list-sessions -F '#S' 2>/dev/null; }
_tm_windows()  { tmux list-windows -a -F '#S:#I' 2>/dev/null; }
_tm_complete() {
    local cur cword; _tm_words
    [ "$cword" -eq 1 ] && _tm_reply "$(_tm_sessions)"
    return 0
}
_tmw_complete() {
    local cur cword; _tm_words
    case "$cword" in
        1) _tm_reply "$(_tm_windows)" ;;
        2) _tm_reply "$(_tm_sessions)" ;;
    esac
    return 0
}
_tmj_complete() {
    local cur cword; _tm_words
    [ "$cword" -le 2 ] && _tm_reply "$(_tm_windows)"
    return 0
}
complete -F _tm_complete tm
complete -F _tmw_complete tmw
complete -F _tmj_complete tmj

# Makineye ozel ayarlar (PATH, nvm, bun, takma adlar, kayit defteri adresleri, sirlar).
# Bu dosya repo'ya GIRMEZ; her makinede kendi ~/.bashrc.local'i olur.
# shellcheck source=/dev/null
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
