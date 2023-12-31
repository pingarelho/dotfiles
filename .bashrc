#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias sudo='sudo '
alias grep='grep --color=auto'
alias vim=nvim
alias ls=lsd
alias cat=bat
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias feh='feh --scale-down'
alias navid-hdd='sudo mount -t cifs -o username=david,dir_mode=0777,file_mode=0777 //192.168.69.1/hdd /mnt/hdd'
alias navid-ssd='sudo mount -t cifs -o username=david,dir_mode=0777,file_mode=0777 //192.168.69.1/ssd /mnt/ssd'

PS1='\[\e[38;5;208m\]\u\[\e[38;5;252m\]@\[\e[38;5;196m\]\H \[\e[38;5;220m\]\w \[\e[38;5;105m\]\$ \[\e[0m\]'

set -o vi

# Created by `pipx` on 2023-12-22 16:07:41
export PATH="$PATH:/home/david/.local/bin"
