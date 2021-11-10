export EDITOR=nvim
export CHROME_BIN=/usr/bin/chromium
export NPM_TOKEN=012ac755-676a-44d4-9629-2c2eee3b0fd8
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
