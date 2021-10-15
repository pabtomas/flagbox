#!/bin/bash

function safer_input () {
  local QUOTED=()
  for TOKEN in "$@"; do
    QUOTED+=( "$(printf '%q' "${TOKEN}")" )
  done
  printf '%s\n' "${QUOTED[*]}"
}

function flagbox_aliases () {

  declare -r RED=$(tput setaf 1)
  declare -r GREEN=$(tput setaf 2)
  declare -r RESET=$(tput sgr0)

  declare -r DEFAULT_SZ=3
  declare -r DEFAULT_FLAG_SYMB=","
  declare -r DEFAULT_ACTION_SYMB="?"

  if [ "x${FLAGBOX_SZ}" == "x" ]; then
    FLAGBOX_SZ=${DEFAULT_SZ}
    echo "${GREEN}FLAGBOX_SZ default value attributed:${RESET} ${DEFAULT_SZ}"
  fi

  if [ "x${FLAGBOX_FLAG_SYMB}" == "x" ]; then
    FLAGBOX_FLAG_SYMB="${DEFAULT_FLAG_SYMB}"
    echo "${GREEN}FLAGBOX_FLAG_SYMB default value attributed:${RESET} ${DEFAULT_FLAG_SYMB}"
  fi

  if [ "x${FLAGBOX_ACTION_SYMB}" == "x" ]; then
    FLAGBOX_ACTION_SYMB="${DEFAULT_ACTION_SYMB}"
    echo "${GREEN}FLAGBOX_ACTION_SYMB default value attributed:${RESET} ${DEFAULT_ACTION_SYMB}"
  fi

  FLAGBOX_SZ=(echo "${FLAGBOX_SZ}")
  FLAGBOX_SZ="$(safer_input "${FLAGBOX_SZ[@]}")"
  FLAGBOX_FLAG_SYMB=(echo "${FLAGBOX_FLAG_SYMB}")
  FLAGBOX_FLAG_SYMB="$(safer_input "${FLAGBOX_FLAG_SYMB[@]}")"
  FLAGBOX_ACTION_SYMB=(echo "${FLAGBOX_ACTION_SYMB}")
  FLAGBOX_ACTION_SYMB="$(safer_input "${FLAGBOX_ACTION_SYMB[@]}")"
  unset -f safer_input

  if [ "$(eval "${FLAGBOX_SZ}")" != \
    "$(eval "${FLAGBOX_SZ}" | sed 's/[^0-9]//g')" ]; then
      echo "${RED}FLAGBOX_SZ has to be a positive integer${RESET}"
      return 1
  fi

  if [ $(eval "${FLAGBOX_SZ}") -lt 3 ]; then
    echo "${RED}FLAGBOX_SZ has to be greater or equal to 3${RESET}"
    return 1
  fi

  declare SYMB=$(eval "${FLAGBOX_FLAG_SYMB}")
  if [ ${#SYMB} -ne 1 ]; then
    echo "${RED}FLAGBOX_FLAG_SYMB must be a single character${RESET}"
    return 1
  fi

  declare -r PROHIBITED='.!#'
  if [ "$(eval "${FLAGBOX_FLAG_SYMB}")" != \
    "$(eval "${FLAGBOX_FLAG_SYMB}" | sed 's/['${PROHIBITED}']//g')" ]; then
      echo "${RED}FLAGBOX_FLAG_SYMB contains prohibited characters:${RESET} ${PROHIBITED}"
      return 1
  fi

  SYMB=$(eval "${FLAGBOX_ACTION_SYMB}")
  if [ ${#SYMB} -ne 1 ]; then
    echo "${RED}FLAGBOX_ACTION_SYMB must be a single character${RESET}"
    return 1
  fi

  if [ "$(eval "${FLAGBOX_ACTION_SYMB}")" != \
    "$(eval "${FLAGBOX_ACTION_SYMB}" | sed 's/['${PROHIBITED}']//g')" ]; then
      echo "${RED}FLAGBOX_ACTION_SYMB contains prohibited characters:${RESET} ${PROHIBITED}"
      return 1
  fi

  if [ $(eval "${FLAGBOX_FLAG_SYMB}") == \
    $(eval "${FLAGBOX_ACTION_SYMB}") ]; then
      echo "${RED}FLAGBOX_ACTION_SYMB and FLAGBOX_FLAG_SYMB have to be different${RESET}"
      return 1
  fi

  if [ "$(eval "${FLAGBOX_FLAG_SYMB}")" == "?" ] \
    || [ "$(eval "${FLAGBOX_ACTION_SYMB}")" == "?" ]; then
      alias ???="\???"
      alias ????="\????"
  fi

  eval "declare -a -g FLAGBOX=( $(printf %$(eval "${FLAGBOX_SZ}")s \
    | sed "s/ /'' /g") )"
  declare FN=""
  declare NAME=""
  for I in $(seq 1 $(eval "${FLAGBOX_SZ}")); do
    NAME=$(printf %${I}s | tr ' ' "$(eval "${FLAGBOX_FLAG_SYMB}")")
    FN="${FN}function flagbox${NAME} () { "
    FN="${FN}  if [ \"x\${FLAGBOX[$(( ${I} - 1 ))]}\" == \"x\" ]; then"
    FN="${FN}    FLAGBOX[$(( ${I} - 1 ))]=\$(realpath .);"
    FN="${FN}  else"
    FN="${FN}    cd \${FLAGBOX[$(( ${I} - 1 ))]};"
    FN="${FN}  fi;"
    FN="${FN}};"
    FN="${FN}alias ${NAME}=\"flagbox${NAME}\";"
  done

  eval "declare -a -r BIN=( $(printf %$(eval "${FLAGBOX_SZ}")s \
    | sed 's/ /{0..1}/g') )"
  for I in ${BIN[@]}; do
    if [ "x$(echo "${I}" | sed 's/0//g')" != "x" ]; then
      I="$(echo "${I}" \
        | sed "s/0/$(eval "${FLAGBOX_FLAG_SYMB}")/g;\
          s/1/$(eval "${FLAGBOX_ACTION_SYMB}")/g")"
      FN="${FN}function flagbox"${I}" () {"
      for J in $(seq 0 $(( ${#I} - 1 )) ); do
        if [ "${I:${J}:1}" == "$(eval "${FLAGBOX_ACTION_SYMB}")" ]; then
          FN="${FN} FLAGBOX["${J}"]='';"
        fi
      done
      FN="${FN} flagbox$(eval "${FLAGBOX_ACTION_SYMB}"); };"
      FN="${FN} alias ${I}=\"flagbox${I}\";"
    fi
  done

  FN="${FN}function flagbox$(eval "${FLAGBOX_ACTION_SYMB}") () {"
  FN="${FN}  for I in \$(seq 1 $(eval "${FLAGBOX_SZ}")); do"
  FN="${FN}    echo \"\$(printf %\${I}s | tr ' ' \"$(eval \
                 "${FLAGBOX_FLAG_SYMB}")\") = \${FLAGBOX[\$(( \${I} - 1 ))]}\";"
  FN="${FN}  done;"
  FN="${FN}};"
  FN="${FN}alias $(eval "${FLAGBOX_ACTION_SYMB}")=\"flagbox$(eval \
    "${FLAGBOX_ACTION_SYMB}")\";"

  FN="${FN}function flagbox$(eval "${FLAGBOX_ACTION_SYMB}")$(eval \
                                "${FLAGBOX_ACTION_SYMB}") () {"
  FN="${FN}  local CONCAT=\"\";"
  FN="${FN}  for I in \$(seq 1 $(eval "${FLAGBOX_SZ}")); do"
  FN="${FN}    CONCAT=\"\${CONCAT}x\${FLAGBOX[\$(( \${I} - 1 ))]}\";"
  FN="${FN}  done;"
  FN="${FN}  local BACKUP=\"\${HOME}/.flagbox_backup\";"
  FN="${FN}  if [ \"x\${1}\" != \"x\" ]; then"
  FN="${FN}    BACKUP=\"\${1}\";"
  FN="${FN}  fi;"
  FN="${FN}  if [ \"\${CONCAT}\" == \"\$(printf %$(eval "${FLAGBOX_SZ}")s"
  FN="${FN}    | tr ' ' 'x')\" ]; then"
  FN="${FN}      [ -f \"\${BACKUP}\" ]"
  FN="${FN}        && readarray -t FLAGBOX < \${BACKUP};"
  FN="${FN}      flagbox$(eval "${FLAGBOX_ACTION_SYMB}") && echo"
  FN="${FN}        \"${GREEN}Marks restored with:${RESET} \${BACKUP}\";"
  FN="${FN}  else"
  FN="${FN}    echo \"\${FLAGBOX[@]}\" | tr ' ' '\\n' > \"\${BACKUP}\";"
  FN="${FN}    echo \"${GREEN}Marks saved at:${RESET} \${BACKUP}\";"
  FN="${FN}  fi;"
  FN="${FN}};"
  FN="${FN} alias $(eval "${FLAGBOX_ACTION_SYMB}")$(eval \
    "${FLAGBOX_ACTION_SYMB}")=\"flagbox$(eval \
      "${FLAGBOX_ACTION_SYMB}")$(eval "${FLAGBOX_ACTION_SYMB}")\";"

  eval "${FN}"
}

# FLAGBOX_SZ=3
# FLAGBOX_FLAG_SYMB=","
# FLAGBOX_ACTION_SYMB="?"
flagbox_aliases
unset flagbox_aliases
