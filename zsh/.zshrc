# All configuration lives in $ZDOTDIR/conf.d/*.zsh (sourced in lexicographic order).
# Do NOT add config directly here — create or edit a file in conf.d/ instead.
# Machine-specific secrets go in ~/.zshrc.local (sourced by conf.d/99-local.zsh).
for f in $ZDOTDIR/conf.d/*.zsh; do source $f; done
