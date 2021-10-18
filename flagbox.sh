#!/bin/bash

function flagbox () {

# Options {{{1

  if [ "x${1}" == "x" ]; then
    echo "help" >&2
    return 1
  fi

  local ALIAS=false
  local CHAIN=""
  local FILE=""

  declare -r FILE_AUTHORIZED='a-zA-Z0-9/_.~-'

  if [ ${#} -eq 1 ] && [ "${1}" == "--alias" ]; then
    ALIAS=true
  elif [ ${#} -eq 2 ] && [ "${1}" == "--chain" ] \
    && [ ${#2} -le $(eval "${FLAGBOX_SIZE}") ] \
    && [ "${2}" == "$(echo "${2}" | sed 's/[^01]//')" ]; then
      CHAIN="${2}"
  elif [ ${#} -eq 3 ] && [ "${1}" == "--chain" ] && [ "${2}" == "11" ] \
    && [ "${3}" == "$(echo "${3}" | sed 's/[^'"${FILE_AUTHORIZED}"']//')" ]; then
      CHAIN="11"
      FILE="${3}"
  else
    echo "help" >&2
    return 1
  fi

# }}}

  declare -r RED=$(tput setaf 1)
  declare -r GREEN=$(tput setaf 2)
  declare -r YELLOW=$(tput setaf 3)
  declare -r RESET=$(tput sgr0)

  if ${ALIAS}; then
# --alias {{{1

#   Default user variables {{{2

    declare -r DEFAULT_SIZE=3
    declare -r DEFAULT_FLAG_SYMB=","
    declare -r DEFAULT_ACTION_SYMB="?"
    declare -r DEFAULT_GENERATEALIASES=true
    declare -r DEFAULT_BACKUPCONFIRM=true
    declare -r DEFAULT_STACKMODE=false
    declare -r DEFAULT_AUTOWRITE=false
    declare -r DEFAULT_AUTOWRITEFILE="${HOME}/.flagbox_autowrite"
    declare -r DEFAULT_AUTORESTORE=false
    declare -r DEFAULT_AUTORESTOREFILE="${HOME}/.flagbox_autowrite"

    if [ ! -v FLAGBOX_SIZE ] || [ "x${FLAGBOX_SIZE}" == "x" ]; then
      FLAGBOX_SIZE=${DEFAULT_SIZE}
    fi

    if [ ! -v FLAGBOX_FLAG_SYMB ] || [ "x${FLAGBOX_FLAG_SYMB}" == "x" ]; then
      FLAGBOX_FLAG_SYMB="${DEFAULT_FLAG_SYMB}"
    fi

    if [ ! -v FLAGBOX_ACTION_SYMB ] \
      || [ "x${FLAGBOX_ACTION_SYMB}" == "x" ]; then
        FLAGBOX_ACTION_SYMB="${DEFAULT_ACTION_SYMB}"
    fi

    if [ ! -v FLAGBOX_GENERATEALIASES ] \
      || [ "x${FLAGBOX_GENERATEALIASES}" == "x" ]; then
        FLAGBOX_GENERATEALIASES=${DEFAULT_GENERATEALIASES}
    fi

    if [ ! -v FLAGBOX_BACKUPCONFIRM ] \
      || [ "x${FLAGBOX_BACKUPCONFIRM}" == "x" ]; then
        FLAGBOX_BACKUPCONFIRM=${DEFAULT_BACKUPCONFIRM}
    fi

    if [ ! -v FLAGBOX_STACKMODE ] || [ "x${FLAGBOX_STACKMODE}" == "x" ]; then
      FLAGBOX_STACKMODE=${DEFAULT_STACKMODE}
    fi

    if [ ! -v FLAGBOX_AUTOWRITE ] || [ "x${FLAGBOX_AUTOWRITE}" == "x" ]; then
      FLAGBOX_AUTOWRITE=${DEFAULT_AUTOWRITE}
    fi

    if [ ! -v FLAGBOX_AUTOWRITEFILE ] \
      || [ "x${FLAGBOX_AUTOWRITEFILE}" == "x" ]; then
        FLAGBOX_AUTOWRITEFILE=${DEFAULT_AUTOWRITEFILE}
    fi

    if [ ! -v FLAGBOX_AUTORESTORE ] \
      || [ "x${FLAGBOX_AUTORESTORE}" == "x" ]; then
        FLAGBOX_AUTORESTORE=${DEFAULT_AUTORESTORE}
    fi

    if [ ! -v FLAGBOX_AUTORESTOREFILE ] \
      || [ "x${FLAGBOX_AUTORESTOREFILE}" == "x" ]; then
        FLAGBOX_AUTORESTOREFILE=${DEFAULT_AUTORESTOREFILE}
    fi

#   }}}
#   Check user variables {{{2

    FLAGBOX_SIZE=(echo "${FLAGBOX_SIZE}")
    local QUOTED=()
    for TOKEN in "${FLAGBOX_SIZE[@]}"; do
      QUOTED+=( "$(printf '%q' "${TOKEN}")" )
    done
    FLAGBOX_SIZE="$(printf '%s\n' "${QUOTED[*]}")"

    if [ "$(eval "${FLAGBOX_SIZE}")" != \
      "$(eval "${FLAGBOX_SIZE}" | sed 's/[^0-9]//')" ]; then
        echo "${RED}FLAGBOX_SIZE has to be a positive integer${RESET}" >&2
        return 1
    fi

    if [ $(eval "${FLAGBOX_SIZE}") -lt 3 ]; then
      echo "${RED}FLAGBOX_SIZE has to be greater or equal to 3${RESET}" >&2
      return 1
    fi

    if [ ${#FLAGBOX_FLAG_SYMB} -ne 1 ]; then
      echo "${RED}FLAGBOX_FLAG_SYMB must be a single character${RESET}" >&2
      return 1
    fi

    declare -r PROHIBITED='.!#%'
    if [ "${FLAGBOX_FLAG_SYMB}" != "$(echo "${FLAGBOX_FLAG_SYMB}" \
      | sed 's/['${PROHIBITED}']//')" ]; then
        echo "${YELLOW}Your are highly discouraged to use one of those characters for FLAGBOX_FLAG_SYMB or FLAGBOX_ACTION_SYMB:${RESET} ${PROHIBITED}"
    fi

    if [ ${#FLAGBOX_ACTION_SYMB} -ne 1 ]; then
      echo "${RED}FLAGBOX_ACTION_SYMB must be a single character${RESET}" >&2
      return 1
    fi

    if [ "${FLAGBOX_ACTION_SYMB}" != "$(echo "${FLAGBOX_ACTION_SYMB}" \
      | sed 's/['${PROHIBITED}']//')" ]; then
        echo "${YELLOW}Your are highly discouraged to use one of those characters for FLAGBOX_FLAG_SYMB or FLAGBOX_ACTION_SYMB:${RESET} ${PROHIBITED}"
    fi

    if [ "${FLAGBOX_FLAG_SYMB}" == "${FLAGBOX_ACTION_SYMB}" ]; then
      echo "${RED}FLAGBOX_ACTION_SYMB and FLAGBOX_FLAG_SYMB have to be different${RESET}" >&2
      return 1
    fi

    eval "declare -r -a BIN=( $(printf %$(eval "${FLAGBOX_SIZE}")s \
      | sed 's/ /{0..1}/g') )"

    local DUP=$(echo -e "$(compgen -c \
      | sort -u)\n$(echo "0 1 00 01 10 11 ${BIN[@]}" \
      | sed 's/0/'${FLAGBOX_FLAG_SYMB}'/g' \
      | sed 's/1/'${FLAGBOX_ACTION_SYMB}'/g' | tr ' ' '\n')" | sort | uniq -d)
    if [ ${#DUP} -gt 0 ]; then
      echo -e "${YELLOW}Your are highly discouraged to use those characters for FLAGBOX_FLAG_SYMB and FLAGBOX_ACTION_SYMB. Generating aliases with those characters will hide these commands:${RESET}\n${DUP}"
    fi

    if [ "${FLAGBOX_STACKMODE}" != "false" ] \
      && [ "${FLAGBOX_STACKMODE}" != "true" ]; then
        echo "${RED}FLAGBOX_STACKMODE should be ${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [ "${FLAGBOX_GENERATEALIASES}" != "false" ] \
      && [ "${FLAGBOX_GENERATEALIASES}" != "true" ]; then
        echo "${RED}FLAGBOX_GENERATEALIASES should be ${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [ "${FLAGBOX_BACKUPCONFIRM}" != "false" ] \
      && [ "${FLAGBOX_BACKUPCONFIRM}" != "true" ]; then
        echo "${RED}FLAGBOX_BACKUPCONFIRM should be ${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi


    if [ "${FLAGBOX_AUTOWRITE}" != "false" ] \
      && [ "${FLAGBOX_AUTOWRITE}" != "true" ]; then
        echo "${RED}FLAGBOX_AUTOWRITE should be ${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [ "${FLAGBOX_AUTOWRITEFILE}" != "$(echo "${FLAGBOX_AUTOWRITEFILE}" \
      | sed 's/[^'"${FILE_AUTHORIZED}"']//')" ]; then
        echo "${RED}FLAGBOX_AUTOWRITEFILE should only contains authorized filename characters:${RESET} ${FILE_AUTHORIZED}" >&2
        return 1
    fi

    if [ "${FLAGBOX_AUTORESTORE}" != "false" ] \
      && [ "${FLAGBOX_AUTORESTORE}" != "true" ]; then
        echo "${RED}FLAGBOX_AUTORESTORE should be ${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [ "${FLAGBOX_AUTORESTOREFILE}" != "$(echo "${FLAGBOX_AUTORESTOREFILE}" \
      | sed 's/[^'"${FILE_AUTHORIZED}"']//')" ]; then
        echo "${RED}FLAGBOX_AUTORESTOREFILE should only contains authorized filename characters:${RESET} ${FILE_AUTHORIZED}" >&2
        return 1
    fi

#   }}}
#   Generate aliases {{{2

    if [ ! -v FLAGBOX ]; then
      declare -g -A FLAGBOX
      FLAGBOX[BOX]=1
      FLAGBOX[MAX]=1
      for I in $(seq 1 $(eval "${FLAGBOX_SIZE}")); do
        FLAGBOX[${FLAGBOX[BOX]},${I}]=''
      done
    fi

    for I in $(seq 1 $(eval "${FLAGBOX_SIZE}")); do
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
# --chain {{{1
#   Trigger-flag chain {{{2

    if [ ${CHAIN} -eq 0 ]; then
      if [ "x${FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]}" == "x" ]; then
        FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]=$(realpath .)
      else
        [ -d ${FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]} ] \
          && cd ${FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]}
      fi
#   }}}
#   Reset-flag chain {{{2
    elif [ ${#CHAIN} -eq $(eval "${FLAGBOX_SIZE}") ]; then
      for I in $(seq 1 ${#CHAIN}); do
        if [ "${CHAIN:$(( ${I} - 1 )):1}" == "1" ]; then
          FLAGBOX[${FLAGBOX[BOX]},${I}]=''
        fi
      done
      flagbox --chain 1
#   List-flags chain {{{2
    elif [ "${CHAIN}" == "1" ]; then
      local TEXT=""
      for I in $(seq 1 $(eval "${FLAGBOX_SIZE}")); do
        TEXT="${TEXT}$(printf %${I}s \
          | tr ' ' "${FLAGBOX_FLAG_SYMB}") = ${FLAGBOX[${FLAGBOX[BOX]},${I}]}"
        [ ${I} -lt $(eval "${FLAGBOX_SIZE}") ] && TEXT="${TEXT}\n"
      done
      local BOXTEXT="[ Box ${FLAGBOX[BOX]}/${FLAGBOX[MAX]} ]"
      local BAR="$(printf %$(echo -e "0\n$(( ($(echo -e "${TEXT}" | wc -L) \
        - ${#BOXTEXT} + 1) / 2 ))" | sort -n -r | head -n 1)s | tr ' ' '=')"
      echo -e "${BAR}${BOXTEXT}${BAR}\n${TEXT}"
#   }}}
#   Backup chains {{{2
    elif [ "${CHAIN}" == "11" ]; then
      local CONCAT=""
      for I in $(seq 1 $(eval "${FLAGBOX_SIZE}")); do
        CONCAT="${CONCAT}x${FLAGBOX[${FLAGBOX[BOX]},${I}]}"
      done
      local BACKUP="${HOME}/.flagbox_backup"
      if [ "x${FILE}" != "x" ]; then
        BACKUP="$(realpath ${FILE})"
      fi
#     Restore {{{3
      if [ ${#CONCAT} -eq $(eval "${FLAGBOX_SIZE}") ]; then
        if [ -f "${BACKUP}" ]; then
          local I=1
#       Box restore {{{4
          if [ $(cat ${BACKUP} | wc -l) -le $(eval "${FLAGBOX_SIZE}") ]; then
            while IFS= read -r LINE; do
              FLAGBOX[${FLAGBOX[BOX]},${I}]="${LINE}"
              (( I+=1 ))
            done < ${BACKUP}
#       }}}
#       Full restore {{{4
          else
            local J=1
            unset FLAGBOX && declare -g -A FLAGBOX
            while IFS= read -r LINE; do
              FLAGBOX[${J},${I}]="${LINE}"
              (( I+=1 ))
              if [ ${I} -gt $(eval "${FLAGBOX_SIZE}") ]; then
                (( J+=1 ))
                I=1
              fi
            done < ${BACKUP}
          fi
#       }}}
          flagbox --chain 1 \
            && echo "${GREEN}Marks restored with:${RESET} ${BACKUP}"
        fi
#     }}}
#     Save {{{3
      else
        if ${FLAGBOX_BACKUPCONFIRM}; then
          [ -f ${BACKUP} ] && rm -iv ${BACKUP}
        else
          [ -f ${BACKUP} ] && rm ${BACKUP}
        fi
        local TEXT=""
        for I in $(seq 1 $(eval "${FLAGBOX_SIZE}")); do
          TEXT="${TEXT}$(echo "${FLAGBOX[${FLAGBOX[BOX]},${I}]}")\n"
        done
        printf "${TEXT}" > "${BACKUP}" \
          && echo "${GREEN}Marks saved at:${RESET} ${BACKUP}"
      fi
#     }}}
#   }}}
#   Navigation chains {{{2
    elif [ "${CHAIN}" == "01" ]; then
      local CONCAT=""
      for I in $(seq 1 $(eval "${FLAGBOX_SIZE}")); do
        CONCAT="${CONCAT}x${FLAGBOX[${FLAGBOX[BOX]},${I}]}"
      done
      if [ ${FLAGBOX[BOX]} -lt ${FLAGBOX[MAX]} ]; then
        (( FLAGBOX[BOX]+=1 ))
      elif [ ${#CONCAT} -gt $(eval "${FLAGBOX_SIZE}") ]; then
        (( FLAGBOX[BOX]+=1 ))
        for I in $(seq 1 $(eval "${FLAGBOX_SIZE}")); do
          FLAGBOX[${FLAGBOX[BOX]},${I}]=''
        done
      else
        FLAGBOX[BOX]=1
      fi
      FLAGBOX[MAX]=$(echo -e "${FLAGBOX[BOX]}\n${FLAGBOX[MAX]}" \
        | sort -n -r | head -n 1)
    elif [ "${CHAIN}" == "10" ]; then
      if [ ${FLAGBOX[BOX]} -gt 1 ]; then
        (( FLAGBOX[BOX]-=1 ))
      else
        FLAGBOX[BOX]=${FLAGBOX[MAX]}
      fi
    fi

#   }}}
# }}}
  fi
}

[ -f "${HOME}/.flagbox.conf" ] && source "${HOME}/.flagbox.conf"
if [ ! -f "${HOME}/.flagbox.conf" ]; then
  flagbox --alias
elif [ -v FLAGBOX_GENERATEALIASES ] && ${FLAGBOX_GENERATEALIASES}; then
  flagbox --alias
fi
