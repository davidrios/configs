# A two-line colored Bash prompt (PS1) with Git branch and a line decoration
# Original version by Michal Kottman, 2012
 
RESET="\[\033[0m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[01;32m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\033[0;33m\]"
 
PS_INFO="$GREEN\u@\h$RESET:$BLUE\w"
PS_GIT='$(__git_ps1 " '${YELLOW}'[%s]")'
#PS_TIME="\[\033[\$((COLUMNS-10))G\] $RED[\t]"

export PS1="${PS_INFO}${PS_GIT} ${PS_TIME}\n${RESET}\$ "
