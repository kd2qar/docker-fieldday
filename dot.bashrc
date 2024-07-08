
color_prompt=yes

if [ "$color_prompt" = yes ]; then
  PS1='${USER}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\$\[\033[00m\] '
else
  PS1='${USER}\u@\h:\w\$ '
fi

alias dir='dir --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -l'
alias ls='ls --color=auto'
alias vdir='vdir --color=auto'
