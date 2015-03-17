# Variáveis de controle do script de provisionamento (pacotes atualizados? senha root setada?)
export PROV_FIRST_UPDATE=true
export PROV_FIRST_ROOT_PASS=true

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
# Set autocomplete
[[ -r "$rvm_path/scripts/completion" ]] && source "$rvm_path/scripts/completion"

function parse_git_branch {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\[\033[38m\]\u@\h\[\033[01;34m\] \w \[\033[31m\]\$(parse_git_branch)\[\033[37m\]$\[\033[00m\] "
export RUBYOPT=-Ku

# Added by travis gem
[ -f /home/dani/.travis/travis.sh ] && source /home/dani/.travis/travis.sh

# Git aliases
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

# SSH aliases
alias gateway='ssh -i ~/.ssh/id_rsa_gateway _dsilvestre@nibbler0001.linux.locaweb.com.br'

# General aliases
size_with_du() {
  du -a $1 | sort -n -r | head -n 15
}
alias size=size_with_du
alias power='sudo powertop --auto-tune'
alias free_mem='sudo sh -c "free -m && sync && echo 3 > /proc/sys/vm/drop_caches && free -m"'
alias lss='ls -ltr'

# Dev aliases
alias Rails='bundle exec spring rails'
alias Server='Rails s'
alias Console='Rails c'
alias Rake='bundle exec rake'
alias Rspec='bundle exec spring rspec'
alias Cucumber='rm rerun.txt; Rake cucumber'
alias Bundle='bundle install --path vendor/bundle'

# Docker aliases (TODO: move to another place)
docker_rm_containers() {
  for i in $(docker ps -a | grep -v CONTAI | awk '{print $1}'); do docker stop $i; docker rm $i; done
}
alias dk_rm_containers=docker_rm_containers
alias dk_status="sudo service docker.io status"
alias dk_start="sudo service docker.io start"
alias dk_stop="sudo service docker.io stop"

# grep 'CurrencyExchange' -rl app/ spec/ | xargs sed -i 's/CurrencyExchange/Base/g'
