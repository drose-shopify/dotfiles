# local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
# PROMPT='${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

PROMPT='
${_return_status}$(_user_host)${_current_dir}
%{$fg[$CARETCOLOR]%}$(_prompt_caret)%{$reset_color%} '

PROMPT2=''
# PROMPT2='%{$fg[$CARETCOLOR]%}<%{$reset_color%} '

RPROMPT='%{$(echotc UP 1)%}$(git_super_status)%{$(echotc DO 1)%}'

local _current_dir="%{$fg_bold[blue]%}%3~%{$reset_color%} "
local _return_status="%(?..%{$fg[red]%} % ↳ %? %{$resetcolor%})"
local _hist_no="%{$fg[grey]%}%h%{$reset_color%}"

function _current_dir() {
  local _max_pwd_length="65"
  if [[ $(echo -n $PWD | wc -c) -gt ${_max_pwd_length} ]]; then
    echo "%{$fg_bold[blue]%}%-2~ ... %3~%{$reset_color%} "
  else
    echo "%{$fg_bold[blue]%}%~%{$reset_color%} "
  fi
}

function _user_host() {
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[cyan]%}$me%{$reset_color%}:"
  fi
}

if [[ $USER == "root" ]]; then
  CARETCOLOR="red"
else
  CARETCOLOR="white"
fi

function _git_status() {
    if [[ -n "$(git_super_status)" ]]; then
        echo " ~ $(git_super_status)"
    fi
}


function _prompt_caret() {
    if [[ -z "$(vi_mode_prompt_info)" ]]; then
        echo ">"
    else
        echo "$(vi_mode_prompt_info)"
    fi
}
function _vi_status() {
 if {echo $fpath | grep -q "plugins/vi-mode"}; then
   if [[ -n "$(vi_mode_prompt_info)" ]]; then
    echo "-- NORMAL --"
   fi
 fi
}

