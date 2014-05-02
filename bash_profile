# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

function parse_git_branch {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\[\033[38m\]\u@\h\[\033[01;34m\] \w \[\033[31m\]\$(parse_git_branch)\[\033[37m\]$\[\033[00m\] "
export RUBYOPT=-Ku

# Atalhos do GIT
alias gst='git status'
alias gcm='git commit'
alias gad='git add'
alias gb='git branch'
alias gpl='git pull'
alias gps='git push'
alias gck='git checkout'
alias gm='git merge'
alias grm='git rm'
alias gmv='git mv'
alias gdf='git diff'
alias gttest='git tag | grep testing | sort -V'
alias gtstable='git tag | grep stable | sort -V'

# Atalhos do SSH
alias gateway='ssh -i ~/.ssh/id_rsa_gateway _dsilvestre@nibbler0001.linux.locaweb.com.br'

# Atalhos do gerais
alias lss='ls -ltr'
alias Rails='bundle exec rails'
alias Server='Rails s'
alias Console='Rails c'
alias Ruby='bundle exec ruby'
alias Rake='bundle exec rake'
alias Rspec='bundle exec rspec'
alias Cucumber='rm rerun.txt; Rake cucumber'

# rename s/.yml.example/.yml/ *.yml.* # to mv all files from *.yml.example to *.yml
