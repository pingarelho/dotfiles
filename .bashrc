#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'
alias vim='nvim'
alias ls='lsd'
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

PS1='\[\e[38;5;208m\]\u\[\e[38;5;252m\]@\[\e[38;5;196m\]\H \[\e[38;5;220m\]\w \[\e[38;5;105m\]\$ \[\e[0m\]'

set -o vi
