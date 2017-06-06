#!/usr/bin/env zsh

plib_is_git(){
  if [[ $(\git branch 2>/dev/null) != "" ]]; then
    echo -n 1
  else
    echo -n 0
  fi
}

plib_git_branch(){
  __ref=$(\git symbolic-ref HEAD 2> /dev/null) || __ref="detached" || return;
  echo -n "${__ref#refs/heads/}";
  unset __ref;
}

plib_git_rev(){
  __rev=$(\git rev-parse HEAD | cut -c 1-7);
  echo -n "${__rev}";
  unset __rev;
}

plib_git_dirty(){
  __mod=$(\git status --porcelain 2>/dev/null | grep 'M ' | wc -l | tr -d ' ');
  __add=$(\git status --porcelain 2>/dev/null | grep 'A ' | wc -l | tr -d ' ');
  __del=$(\git status --porcelain 2>/dev/null | grep 'D ' | wc -l | tr -d ' ');
  __new=$(\git status --porcelain 2>/dev/null | grep '?? ' | wc -l | tr -d ' ');
  [[ "$__mod" != "0" ]] && echo -n " ⭑";
  [[ "$__add" != "0" ]] && echo -n " +";
  [[ "$__del" != "0" ]] && echo -n " -";
  [[ "$__new" != "0" ]] && echo -n " ?";

  unset __mod __new __add __del
}

plib_git_left_right(){
  function _branch(){
    __ref=$(\git symbolic-ref HEAD 2> /dev/null) || __ref="detached" || return;
    echo -ne "${__ref#refs/heads/}";
    unset __rev;
  }
  if [[ $(plib_git_branch) != "detached" ]]; then
    __pull=$(\git rev-list --left-right --count `_branch`...origin/`_branch` 2>/dev/null | awk '{print $2}' | tr -d ' \n');
    __push=$(\git rev-list --left-right --count `_branch`...origin/`_branch` 2>/dev/null | awk '{print $1}' | tr -d ' \n');
    [[ "$__pull" != "0" ]] && [[ "$__pull" != "" ]] && echo -n " ▼";
    [[ "$__push" != "0" ]] && [[ "$__push" != "" ]] && echo -n " ▲";

    unset __pull __push __branch
  fi
}