if (( ${+commands[brew]} )); then
  eval "$(brew shellenv)"
else
  test -d /home/linuxbrew/.linuxbrew && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
