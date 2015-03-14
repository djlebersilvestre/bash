# Variáveis de controle do script de provisionamento (pacotes atualizados? senha root setada?)
export PROV_FIRST_UPDATE=true
export PROV_FIRST_ROOT_PASS=true

# set PATH so it includes user's private bin if it exists
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

# Atalhos do provisionador
alias prov_setup='$HOME/.bash/provision.sh setup'

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

# Atalhos do google drive
alias gdrive='google-drive-ocamlfuse ~/gdrive; cd ~/gdrive'
alias gdriveumount='cd ~; fusermount -u ~/gdrive'

# Atalhos do SSH
alias gateway='ssh -i ~/.ssh/id_rsa_gateway _dsilvestre@nibbler0001.linux.locaweb.com.br'

# Atalhos do gerais
size_with_du() {
  du -a $1 | sort -n -r | head -n 15
}
alias size=size_with_du
alias power='sudo powertop --auto-tune'
alias free_mem='sudo sh -c "free -m && sync && echo 3 > /proc/sys/vm/drop_caches && free -m"'
alias lss='ls -ltr'

alias Rails='bundle exec spring rails'
alias Server='Rails s'
alias Console='Rails c'
alias Ruby='bundle exec ruby'
alias Rake='bundle exec rake'
alias Rspec='bundle exec spring rspec'
alias Cucumber='rm rerun.txt; Rake cucumber'
alias Bundle='bundle install --path vendor/bundle'

redis_cli() {
  docker run -it --link redis:redis --rm redis:2.8.9 sh -c 'exec redis-cli -h "$REDIS_PORT_6379_TCP_ADDR" -p "$REDIS_PORT_6379_TCP_PORT"'
}
postgres_cli() {
  docker run -it --link postgres:postgres --rm postgres:9.4.1 sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
}
docker_rm_containers() {
  for i in $(docker ps -a | grep -v CONTAI | awk '{print $1}'); do docker stop $i; docker rm $i; done
}
alias redis_start='docker run --name redis -d redis:2.8.9'
alias redis_stop='docker stop redis'
alias redis_cli=redis_cli
alias postgres_start='docker run --name postgres -e POSTGRES_PASSWORD=testing -d postgres:9.4.1'
alias postgres_stop='docker stop postgres'
alias postgres_cli=postgres_cli

alias dk_rm_containers=docker_rm_containers
alias dk_status="sudo service docker.io status"
alias dk_start="sudo service docker.io start"
alias dk_stop="sudo service docker.io stop"

# grep 'CurrencyExchange' -rl app/ spec/ | xargs sed -i 's/CurrencyExchange/Base/g'
