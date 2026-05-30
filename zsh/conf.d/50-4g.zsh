# 4G Clinical - work-specific config
if [[ -d "$HOME/prancer" ]]; then
  [[ -s "${HOME}/tools/k8s/aliases.sh" ]] && source "${HOME}/tools/k8s/aliases.sh"

  hash -d p=~/prancer
  hash -d d=~/data-hub

  alias -g BRTICK='$(git branch --show-current | tr / - | cut -d - -f 2-3)'
  alias load-reports="dkce backend python manage.py initialize_reports --override=True"
  alias load-glossaries="dkce backend python manage.py initialize_prancer_glossary --override=True"
  alias shell-plus-sql="dkce backend python manage.py shell_plus --print-sql"

  source $ZDOTDIR/snippets/wipe-db-prancer.zsh
fi
