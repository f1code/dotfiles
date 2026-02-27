# Should be symlinked to ~/.zshenv.
# All it does is set the ZDOTDIR variable, then zsh will process
# the files in there.
ZDOTDIR=$HOME/.config/dotfiles/zsh
source $ZDOTDIR/.zshenv
