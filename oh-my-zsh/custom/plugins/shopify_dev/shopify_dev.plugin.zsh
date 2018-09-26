

#
# Aliases
#

alias d='dev'

alias ddu='dev down && dev up'
alias dr='dev reset-railgun'
alias dt='dev test'
alias dcd='dev cd'
alias ds='dev up && dev sv start'
alias dsr='dev sv stop && dev up && dev sv start'
alias dupdate='git pull && dev up'
alias pr='dev open pr'

# rake tasks for shopify

alias gql_dump='bin/rails graphql:schema:dump'
alias gql_lint='bin/rails graphql:schema:lint'
alias gql_dump_admin='BREAK_SCHEMA=admin bin/rails graphql:schema:dump'
alias gql_dump_sf='BREAK_SCHEMA=storefront bin/rails graphql:schema:dump'
alias es_restart='bundle exec rake elasticsearch:drop && bundle exec rake elasticsearch:reindex'
# misc ruby aliases

# alias pry_rails='pry -r ./config/environment.rb'
alias pry_rails='bin/rails console'
