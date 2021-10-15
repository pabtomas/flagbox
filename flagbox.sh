#!/bin/bash

function flagbox () {

# Options {{{1

  if [ "x${1}" == "x" ]; then
    echo "help" >&2
    return 1
  fi

  local ALIAS=0
  local CHAIN=""
  local FILE=""

  if [ "${1}" == "--alias" ] && [ ${#} -eq 1 ]; then
    ALIAS=1
  elif [ "${1}" == "--chain" ] && [ ${#} -eq 2 ] \
    && [ "${2}" == "$(echo "${2}" | sed 's/[^0-9]//')" ]; then
      CHAIN="${2}"
  elif [ "${1}" == "--chain" ] && [ ${#} -eq 3 ] && [ "${2}" == "11" ] \
    && [ "${3}" == "$(echo "${3}" | sed 's/[^a-zA-Z0-9/_.~-]//')" ]; then
      CHAIN="11"
      FILE="${3}"
  else
    echo "help" >&2
    return 1
  fi

# }}}

  declare -r RED=$(tput setaf 1)
  declare -r GREEN=$(tput setaf 2)
  declare -r RESET=$(tput sgr0)

  if [ ${ALIAS} -eq 1 ]; then
# Generate aliases case {{{1

    declare -g FLAGBOX_BOX=1

#   Default user variables {{{2

    declare -r DEFAULT_SZ=3
    declare -r DEFAULT_FLAG_SYMB=","
    declare -r DEFAULT_ACTION_SYMB="?"
    declare -r DEFAULT_STACK=0

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

    if [ "x${FLAGBOX_STACK}" == "x" ]; then
      FLAGBOX_STACK=${DEFAULT_STACK}
      echo "${GREEN}FLAGBOX_STACK default value attributed:${RESET} ${DEFAULT_STACK}"
    fi

#   }}}
#   Check user variables {{{2

    FLAGBOX_SZ=(echo "${FLAGBOX_SZ}")
    local QUOTED=()
    for TOKEN in "${FLAGBOX_SZ[@]}"; do
      QUOTED+=( "$(printf '%q' "${TOKEN}")" )
    done
    FLAGBOX_SZ="$(printf '%s\n' "${QUOTED[*]}")"

    if [ "$(eval "${FLAGBOX_SZ}")" != \
      "$(eval "${FLAGBOX_SZ}" | sed 's/[^0-9]//g')" ]; then
        echo "${RED}FLAGBOX_SZ has to be a positive integer${RESET}" >&2
        return 1
    fi

    if [ $(eval "${FLAGBOX_SZ}") -lt 3 ]; then
      echo "${RED}FLAGBOX_SZ has to be greater or equal to 3${RESET}" >&2
      return 1
    fi

    if [ ${#FLAGBOX_FLAG_SYMB} -ne 1 ]; then
      echo "${RED}FLAGBOX_FLAG_SYMB must be a single character${RESET}" >&2
      return 1
    fi

    declare -r PROHIBITED='.!#/~\$%'
    if [ "${FLAGBOX_FLAG_SYMB}" != \
      "$(echo "${FLAGBOX_FLAG_SYMB}" | sed 's/['${PROHIBITED}']//g')" ]; then
        echo "${RED}FLAGBOX_FLAG_SYMB contains prohibited characters:${RESET} ${PROHIBITED}" >&2
        return 1
    fi

    if [ ${#FLAGBOX_ACTION_SYMB} -ne 1 ]; then
      echo "${RED}FLAGBOX_ACTION_SYMB must be a single character${RESET}" >&2
      return 1
    fi

    if [ "${FLAGBOX_ACTION_SYMB}" != \
      "$(echo "${FLAGBOX_ACTION_SYMB}" | sed 's/['${PROHIBITED}']//g')" ]; then
        echo "${RED}FLAGBOX_ACTION_SYMB contains prohibited characters:${RESET} ${PROHIBITED}" >&2
        return 1
    fi

    if [ "${FLAGBOX_FLAG_SYMB}" == "${FLAGBOX_ACTION_SYMB}" ]; then
      echo "${RED}FLAGBOX_ACTION_SYMB and FLAGBOX_FLAG_SYMB have to be different${RESET}" >&2
      return 1
    fi

    if [ "${FLAGBOX_STACK}" != "0" ] && [ "${FLAGBOX_STACK}" != "1" ]; then
      echo "${RED}FLAGBOX_STACK should be ${RESET} 0 ${RED}or${RESET} 1" >&2
      return 1
    fi

    if [ "${FLAGBOX_FLAG_SYMB}" == "?" ] \
      || [ "${FLAGBOX_ACTION_SYMB}" == "?" ]; then
        alias ???="\???"
        alias ????="\????"
    fi

#   }}}
#   Generate aliases {{{2

    if [ ! -v FLAGBOX ]; then
      declare -g -A FLAGBOX
      for I in $(seq 1 $(eval "${FLAGBOX_SZ}")); do
        FLAGBOX[${FLAGBOX_BOX},${I}]=''
      done
    fi

    eval "declare -a -r BIN=( $(printf %$(eval "${FLAGBOX_SZ}")s \
      | sed 's/ /{0..1}/g') )"

    for I in $(seq 1 $(eval "${FLAGBOX_SZ}")); do
      local NAME=$(printf %${I}s | tr ' ' "${FLAGBOX_FLAG_SYMB}")
      alias "${NAME}"="flagbox --chain $(printf %${I}s | tr ' ' "0")"
    done

    for I in ${BIN[@]}; do
      if [ "x$(echo "${I}" | sed 's/0//g')" != "x" ]; then
        local NAME="$(echo "${I}" | sed "s/0/${FLAGBOX_FLAG_SYMB}/g;\
          s/1/${FLAGBOX_ACTION_SYMB}/g")"
        alias "${NAME}"="flagbox --chain ${I}"
      fi
    done

    alias "${FLAGBOX_ACTION_SYMB}"="flagbox --chain 1"
    alias "${FLAGBOX_ACTION_SYMB}${FLAGBOX_ACTION_SYMB}"="flagbox --chain 11"

    alias "${FLAGBOX_FLAG_SYMB}${FLAGBOX_ACTION_SYMB}"="flagbox --chain 01"
    alias "${FLAGBOX_ACTION_SYMB}${FLAGBOX_FLAG_SYMB}"="flagbox --chain 10"

#   }}}
# }}}
  else
# Evaluate chain case {{{1
#   Trigger-flag chain case {{{2

    if [ ${CHAIN} -eq 0 ]; then
      if [ "x${FLAGBOX[${FLAGBOX_BOX},${#CHAIN}]}" == "x" ]; then
        FLAGBOX[${FLAGBOX_BOX},${#CHAIN}]=$(realpath .)
      else
        cd ${FLAGBOX[${FLAGBOX_BOX},${#CHAIN}]}
      fi
#   }}}
#   Reset-flag chain case {{{2
    elif [ ${#CHAIN} -eq $(eval "${FLAGBOX_SZ}") ]; then
      for I in $(seq 1 ${#CHAIN}); do
        if [ "${CHAIN:$(( ${I} - 1 )):1}" == "1" ]; then
          FLAGBOX[${FLAGBOX_BOX},${I}]=''
        fi
      done
      flagbox --chain 1
#   List-flag chain case {{{2
    elif [ "${CHAIN}" == "1" ]; then
      for I in $(seq 1 $(eval "${FLAGBOX_SZ}")); do
        echo "$(printf %${I}s \
          | tr ' ' "${FLAGBOX_FLAG_SYMB}") = ${FLAGBOX[${FLAGBOX_BOX},${I}]}"
      done;
#   }}}
#   Backup chain case {{{2
    elif [ "${CHAIN}" == "11" ]; then
      local CONCAT=""
      for I in $(seq 1 $(eval "${FLAGBOX_SZ}")); do
        CONCAT="${CONCAT}x${FLAGBOX[${FLAGBOX_BOX},${I}]}"
      done
      local BACKUP="${HOME}/.flagbox_backup"
      if [ "x${FILE}" != "x" ]; then
        BACKUP="$(realpath ${FILE})"
      fi
      if [ "${CONCAT}" == \
        "$(printf %$(eval "${FLAGBOX_SZ}")s | tr ' ' 'x')" ]; then
          if [ -f "${BACKUP}" ]; then
            local I=1
            if [ $(cat ${BACKUP} | wc -l) -le $(eval "${FLAGBOX_SZ}") ]; then
              while IFS= read -r LINE; do
                FLAGBOX[${FLAGBOX_BOX},${I}]="${LINE}"
                (( I+=1 ))
              done < ${BACKUP}
            else
              local J=1
              while IFS= read -r LINE; do
                FLAGBOX[${J},${I}]="${LINE}"
                (( I+=1 ))
                if [ ${I} -gt $(eval "${FLAGBOX_SZ}") ]; then
                  (( J+=1 ))
                  I=1
                fi
              done < ${BACKUP}
            fi
            flagbox --chain 1 \
              && echo "${GREEN}Marks restored with:${RESET} ${BACKUP}"
          fi
      else
        [ -f ${BACKUP} ] && rm ${BACKUP}
        local TEXT=""
        for I in $(seq 1 $(eval "${FLAGBOX_SZ}")); do
          TEXT="${TEXT}$(echo "${FLAGBOX[${FLAGBOX_BOX},${I}]}")\n"
        done
        printf "${TEXT}" >> "${BACKUP}" \
          && echo "${GREEN}Marks saved at:${RESET} ${BACKUP}"
      fi
#   }}}
#   Navigation chain case {{{2
    elif [ "${CHAIN}" == "01" ]; then
      # local CONCAT=""
      # for I in $(seq 1 $(eval "${FLAGBOX_SZ}")); do
      #   CONCAT="${CONCAT}x${FLAGBOX[${FLAGBOX_BOX},${I}]}"
      # done
      echo ''
    elif [ "${CHAIN}" == "10" ]; then
      echo ''
    fi

#   }}}
# }}}
  fi
}

flagbox --alias
