#!/usr/bin/env bash

# TODO: help

flagbox () {

# Options {{{1

  local SOURCE="false"
  local CHAIN=""
  local FILE=""

  declare -r FILE_AUTHORIZED='a-zA-Z0-9/_.~\-'
  declare -r PROHIBITED_KEY='.!#%'

  if [[ ${#} -eq 0 ]]; then
    SOURCE="true"
  elif [[ ${#} -eq 1 && ${#1} -le ${FLAGBOX_SIZE} \
    && "x${1//[01]}" == "x" ]]; then
      CHAIN="${1}"
  elif [[ ${#} -eq 2 && "${1}" == "11" \
    && "x${2//[${FILE_AUTHORIZED}]}" == "x" ]]; then
      CHAIN="11"
      FILE="${2}"
  else
    echo -e "help" >&2
    return 1
  fi

# }}}

  declare -r RED="\e[38;5;1m"
  declare -r GREEN="\e[38;5;2m"
  declare -r YELLOW="\e[38;5;3m"
  declare -r REVERSE="\e[38;5;0m\e[48;5;7m\e[1m"
  declare -r RESET="\e[m"

  if [[ "${SOURCE}" == "true" ]]; then
# Sourcing {{{1

    if [[ -v FLAGBOX[BIN_ALIAS] ]]; then
      local TMP
      for A in ${FLAGBOX[BIN_ALIAS]}; do
        TMP=$(alias "${A}" 2> /dev/null)
        if [[ ${#TMP} -gt 0 ]]; then
          unalias "${A}"
        fi
      done
    fi

    if [[ -v FLAGBOX[ALIAS] ]]; then
      local TMP
      for A in ${FLAGBOX[ALIAS]}; do
        TMP=$(alias "${A}" 2> /dev/null)
        if [[ ${#TMP} -gt 0 ]]; then
          unalias "${A}"
        fi
      done
    fi

#   Default user variables {{{2

    declare -r DEFAULT_SIZE=3
    declare -r DEFAULT_KEY1=","
    declare -r DEFAULT_KEY2="?"
    declare -r DEFAULT_DECIMAL_NAVMODE="false"
    declare -r DEFAULT_BACKUPCONFIRM="true"
    declare -r DEFAULT_VINSERT="false"
    declare -r DEFAULT_VNAV="true"
    declare -r DEFAULT_VRESET="false"
    declare -r DEFAULT_VRESTORE="true"
    declare -r DEFAULT_FOLDLISTING="false"

    FLAGBOX_SIZE=${FLAGBOX_SIZE:=${DEFAULT_SIZE}}
    FLAGBOX_KEY1="${FLAGBOX_KEY1:=${DEFAULT_KEY1}}"
    FLAGBOX_KEY2="${FLAGBOX_KEY2:=${DEFAULT_KEY2}}"

#   }}}

    local NAME=""

#   Check user variables {{{2

    if [[ "x${FLAGBOX_SIZE//[0-9]}" != "x" ]]; then
      echo -e "FLAGBOX_SIZE ${RED}has to be a positive integer${RESET}" >&2
      return 1
    fi

    if [[ ${FLAGBOX_SIZE} -lt 3 ]]; then
      echo -e "FLAGBOX_SIZE ${RED}has to be greater or equal to${RESET} 3" >&2
      return 1
    fi

    if [[ ${#FLAGBOX_KEY1} -ne 1 ]]; then
      echo -e "FLAGBOX_KEY1 ${RED}must be a single character${RESET}" >&2
      return 1
    fi

    if [[ "x${FLAGBOX_KEY1//[[:space:]]}" == "x" ]]; then
      echo -e "FLAGBOX_KEY1 ${RED}must be different than a space character" >&2
      return 1
    fi

    if [[ "x${FLAGBOX_KEY1//[${PROHIBITED_KEY}])}" == "x" ]]; then
      echo -e "${YELLOW}Your are highly discouraged to use one of those characters for ${RESET}FLAGBOX_KEY1${YELLOW} or ${RESET}FLAGBOX_KEY2${YELLOW}:${RESET} ${PROHIBITED_KEY}"
    fi

    if [[ "${FLAGBOX_DECIMAL_NAVMODE:=${DEFAULT_DECIMAL_NAVMODE}}" == "true" \
      && "x${FLAGBOX_KEY1//[0-9]}" == "x" ]]; then
        echo -e "${RED}if${RESET} FLAGBOX_DECIMAL_NAVMODE ${RED}is${RESET} true ${RED},${RESET} FLAGBOX_KEY1 ${RED}can not be a digit character${RESET}" >&2
    fi

    if [[ ${#FLAGBOX_KEY2} -ne 1 ]]; then
      echo -e "FLAGBOX_KEY2 ${RED}must be a single character${RESET}" >&2
      return 1
    fi

    if [[ "x${FLAGBOX_KEY2//[[:space:]]}" == "x" ]]; then
      echo -e "FLAGBOX_KEY2 ${RED}must be different than a space character" >&2
      return 1
    fi

    if [[ "x${FLAGBOX_KEY2//[${PROHIBITED_KEY}]}" == "x" ]]; then
      echo -e "${YELLOW}Your are highly discouraged to use one of those characters for ${RESET}FLAGBOX_KEY2${YELLOW} or ${RESET}FLAGBOX_KEY2${YELLOW}:${RESET} ${PROHIBITED_KEY}"
    fi

    if [[ "${FLAGBOX_DECIMAL_NAVMODE}" == "true" \
      && "x${FLAGBOX_KEY2//[0-9]}" == "x" ]]; then
        echo -e "${RED}if${RESET} FLAGBOX_DECIMAL_NAVMODE ${RED}is${RESET} true ${RED},${RESET} FLAGBOX_KEY2 ${RED}can not be a digit character${RESET}" >&2
    fi

    if [[ "${FLAGBOX_KEY1}" == "${FLAGBOX_KEY2}" ]]; then
      echo -e "FLAGBOX_KEY2 ${RED}and${RESET} FLAGBOX_KEY1 ${RED}have to be different${RESET}" >&2
      return 1
    fi

    declare -a BIN=( $(
      I=1
      J=$(echo {0..1})
      while [[ ${I} -lt ${FLAGBOX_SIZE} ]]; do
        J=$(for K in ${J}; do
              B=$(echo ${K}{0..1})
              echo "${B//[[:space:]]/$'\n'}"
            done)
        (( I+=1 ))
      done
      echo "${J}"
    ) )

    local CHAINS="0 1 00 01 10 11"
    CHAINS="${CHAINS//0/${FLAGBOX_KEY1}}"
    CHAINS="${CHAINS//1/${FLAGBOX_KEY2}}"
    CHAINS="${CHAINS} ${BIN[@]}"
    IFS=$'\n' read -d "" -ra COMP < <(compgen -c)
    COMP=$(
      # https://github.com/dylanaraps/pure-bash-bible/blob/master/README.md#remove-duplicate-array-elements
      uniq () {
        declare -A TMP_ARRAY

        for I in "$@"; do
          [[ ${I} ]] && IFS=" " TMP_ARRAY["${I:- }"]=1
        done

        printf '%s\n' "${!TMP_ARRAY[@]}"
      }

      uniq ${COMP[@]}
    )
    IFS=$'\n' read -d "" -ra WARNING < <(
      # https://github.com/dylanaraps/pure-bash-bible/blob/master/README.md#use-regex-on-a-string
      escaped_exact_regex () {
        local ESC=$(while IFS= read -n1 CHAR;
          do printf "\\%s" "${CHAR}"; done < <(echo -n "${2}"))
        local REG="^(${ESC})$|^(${ESC})["$'\n'"]|["$'\n'"](${ESC})$|["$'\n'"](${ESC})["$'\n'"]"
        [[ "${1}" =~ ${REG} ]] && printf '%s\n' "${BASH_REMATCH[1]:-${BASH_REMATCH[2]:-${BASH_REMATCH[3]:-${BASH_REMATCH[4]}}}}"
      }

      DUP=""
      for ALIAS_CHAIN in ${CHAINS}; do
        DUP=$(escaped_exact_regex "${COMP}" "${ALIAS_CHAIN}")
        if [[ ${#DUP} -gt 0 ]]; then
          echo -e "${YELLOW}Your are highly discouraged to use those characters for${RESET} FLAGBOX_KEY1 ${YELLOW}and${RESET} FLAGBOX_KEY2${YELLOW}. Generating aliases with those characters will hide this command:${RESET}\n${DUP}" > $(mktemp)
        fi
      done
    )

    [[ ${#WARNING[@]} -gt 0 ]] && for I in ${!WARNING[@]}; do \
      echo -e "${WARNING[${I}}"; done

    if [[ "${FLAGBOX_DECIMAL_NAVMODE}" != "false" \
      && "${FLAGBOX_DECIMAL_NAVMODE}" != "true" ]]; then
        echo -e "FLAGBOX_DECIMAL_NAVMODE ${RED}should be${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [[ "${FLAGBOX_BACKUPCONFIRM:=${DEFAULT_BACKUPCONFIRM}}" != "false" \
      && "${FLAGBOX_BACKUPCONFIRM}" != "true" ]]; then
        echo -e "FLAGBOX_BACKUPCONFIRM ${RED}should be${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [[ "${FLAGBOX_VINSERT:=${DEFAULT_VINSERT}}" != "false" \
      && "${FLAGBOX_VINSERT}" != "true" ]]; then
        echo -e "FLAGBOX_VINSERT ${RED}should be${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [[ "${FLAGBOX_VNAV:=${DEFAULT_VNAV}}" != "false" \
      && "${FLAGBOX_VNAV}" != "true" ]]; then
        echo -e "FLAGBOX_VNAV ${RED}should be${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [[ "${FLAGBOX_VRESET:=${DEFAULT_VRESET}}" != "false" \
      && "${FLAGBOX_VRESET}" != "true" ]]; then
        echo -e "FLAGBOX_VRESET ${RED}should be${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [[ "${FLAGBOX_VRESTORE:=${DEFAULT_VRESTORE}}" != "false" \
      && "${FLAGBOX_VRESTORE}" != "true" ]]; then
        echo -e "FLAGBOX_VRESTORE ${RED}should be${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

    if [[ "${FLAGBOX_FOLDLISTING:=${DEFAULT_FOLDLISTING}}" != "false" \
      && "${FLAGBOX_FOLDLISTING}" != "true" ]]; then
        echo -e "FLAGBOX_FOLDLISTING ${RED}should be${RESET} true ${RED}or${RESET} false" >&2
        return 1
    fi

#   }}}

    if [[ ! -v FLAGBOX ]]; then
      declare -g -A FLAGBOX
      FLAGBOX[BOX]=1
      FLAGBOX[MAX]=1
      FLAGBOX[MODE]="EDIT"
      FLAGBOX[ALIAS]=""
      FLAGBOX[BIN_ALIAS]=""
      for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
        FLAGBOX[1,${I}]=''
      done
    fi

#   Generate aliases {{{2

    local ALIAS_CHAIN=""
    for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
      NAME="$(printf %${I}s)"
      NAME="${NAME//[[:space:]]/${FLAGBOX_KEY1}}"
      ALIAS_CHAIN=$(printf %${I}s)
      ALIAS_CHAIN=${ALIAS_CHAIN//[[:space:]]/0}
      alias "${NAME}"="flagbox ${ALIAS_CHAIN}"
      FLAGBOX[ALIAS]="${FLAGBOX[ALIAS]} ${NAME}"
    done

    for B in ${BIN[@]}; do
      if [[ ${B} -gt 0 ]]; then
        NAME="$(printf "${B}")"
        NAME="${NAME//0/${FLAGBOX_KEY1}}"
        NAME="${NAME//1/${FLAGBOX_KEY2}}"
        alias "${NAME}"="flagbox ${B}"
        FLAGBOX[BIN_ALIAS]="${FLAGBOX[BIN_ALIAS]} ${NAME}"
      fi
    done

    alias "${FLAGBOX_KEY2}"="flagbox 1"
    alias "${FLAGBOX_KEY2}${FLAGBOX_KEY2}"="flagbox 11"
    FLAGBOX[ALIAS]="${FLAGBOX[ALIAS]} ${FLAGBOX_KEY2}"
    FLAGBOX[ALIAS]="${FLAGBOX[ALIAS]} ${FLAGBOX_KEY2}${FLAGBOX_KEY2}"

    alias "${FLAGBOX_KEY1}${FLAGBOX_KEY2}"="flagbox 01"
    alias "${FLAGBOX_KEY2}${FLAGBOX_KEY1}"="flagbox 10"
    FLAGBOX[ALIAS]="${FLAGBOX[ALIAS]} ${FLAGBOX_KEY1}${FLAGBOX_KEY2}"
    FLAGBOX[ALIAS]="${FLAGBOX[ALIAS]} ${FLAGBOX_KEY2}${FLAGBOX_KEY1}"

#   }}}

    unset BIN NAME DUP QUOTED CHAINS COMP ALIAS_CHAIN WARNING

#   ascii drawing {{{2

    echo -e '\n   .xXEa.           ,:;!;;!:,..\n'\
'   W@@@@@@    .!/eW@@@@@@@@@@@@Qdy!\n'\
'   ?Q@@@@O  p@@@@@@@@@@@@@@@@@@@@@@O`\n'\
"     '"'!Q@6   ?A@@@@@@@@@@@@@@@@@@@@@c     ,!rr+>|\\\\r,\n'\
"       'Q@m    ,Q@@@@@@@@@@@@@@@@@@@Q- v%@@@@@@@@@@@@Qe>-\n"\
'        "B@\    :@@@@@@@@@@@@@@@@@@@@d :@@@@@@@@@@@@@@@@@6!\n'\
"         .Q@^    :Q@@@@@@@@@@@@@@@@@@@8,'"'o@@@@@@@@@@Q3?;!:!'"'\n"\
"          ,@@:    'Q@@@@@@@@@@@@@@@@@@@@t "'!@@@@@@@@@=,`\n'\
'           |@@:    v@@@@@@@@@@@@@@@@@@@@@v x@@@@@@@@@@@@Q0As;`\n'\
'            X@Q,   ,@@@@@@@@@@@@@@@Q##BQ@@: Q@@@@@@@@@@@@@@@@@K|-\n'\
"             9@Q'"'   @@@@@@@@Q6s=:.` .,, `!/ j@@@@@@@@@@@@@@@@@@@@e-\n'\
'             `0@#` !@@QKf?:-      u@@@@@B=. z@@@@@@@@@@@Qpyv\+>+-'"'"'`\n'\
'              .Q@k !>'"'            -N@@@@#+ ,Q@@@@@@@@D7"'"\n'\
"               :@@|                 |N@@  e@@@@@@@p|-\n"\
"                ?@@'                  :\ :Q@@@@%/'\n"\
"                 z@Q-                       "'``\n'\
'                  p@0`\n'\
'    ad88 88       `%@O-            88\n'\
'   d8"   88        `Q@B-           88\n'\
'   88    88          ^iO-          88\n'\
" MM88MMM 88 ,adPPYYba,  ,adPPYb,d8 88,dPPYba,   ,adPPYba, 8b,     ,d8\n"\
'   88    88 ""     `Y8 a8"    `Y88 88P'"'"'    "8a a8"     "8a `Y8, ,8P'"'\n"\
'   88    88 ,adPPPPP88 8b       88 88       d8 8b       d8   )888(\n'\
'   88    88 88,    ,88 "8a,   ,d88 88b,   ,a8" "8a,   ,a8" ,d8" "8b,\n'\
'   88    88 `"8bbdP"Y8  `"YbbdP"Y8 8Y"Ybbd8"'"'"'   `"YbbdP"'"'"' 8P'"'"'     `Y8\n'\
'                        aa,    ,88\n'\
'                         "Y8bbdP"\n\nFlagbox - a 2-keys bookmarks written in bash\nhttps://github.com/pabtomas/flagbox'

#   }}}
# }}}
  else
# Chainis {{{1
#   Trigger-flag chains {{{2

    if [[ ${CHAIN} -eq 0 ]]; then
      local NAME=""
      local LENGTH=0
      local LOG=1
      local TMP=""

      if [[ "x${FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]}" == "x" ]]; then
        FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]=${PWD}
        [[ "${FLAGBOX_VINSERT}" == "true" ]] && flagbox 1
      else
        if [[ "${PWD}" == "${FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]}" ]]; then

#     EDITION mode {{{3

          if [[ "${FLAGBOX[MODE]}" == "EDIT" ]]; then

#       Enter NAVIGATION mode {{{4

            FLAGBOX[MODE]="NAV"

            for A in ${FLAGBOX[BIN_ALIAS]}; do
              TMP=$(alias "${A}" 2> /dev/null)
              if [[ ${#TMP} -gt 0 ]]; then
                unalias "${A}"
              fi
            done
            unset FLAGBOX[BIN_ALIAS]

#         Generate NAVIGATION mode aliases {{{5

            LOG=$(
              # http://phodd.net/gnu-bc/bcfaq.html#bashlog
              log () {
                local X=${2}
                local BASE=${1}
                local L=-1
                while ((X)); do
                  (( L+=1 ))
                  (( X/=${BASE} ))
                done
                echo ${L}
              }

              log 2 ${FLAGBOX[MAX]}
            )
            LENGTH=$(( 3 > ${LOG} ? 3 : ${LOG} ))
            declare -a BIN=( $(
              I=1
              J=$(echo {0..1})
              while [[ ${I} -lt ${FLAGBOX_SIZE} ]]; do
                J=$(for K in ${J}; do
                      B=$(echo ${K}{0..1})
                      echo "${B//[[:space:]]/$'\n'}"
                    done)
                (( I+=1 ))
              done
              echo "${J}"
            ) )
            for ((I=1;I<=${FLAGBOX[MAX]};I++)); do
              if [[ "${FLAGBOX_DECIMAL_NAVMODE}" == "true" ]]; then
                NAME="${I}"
              else
                NAME="$(printf "${BIN[${I}]}")"
                NAME="${NAME//0/${FLAGBOX_KEY1}}"
                NAME="${NAME//1/${FLAGBOX_KEY2}}"
              fi
              alias "${NAME}"="flagbox ${BIN[${I}]}"
              FLAGBOX[BIN_ALIAS]="${FLAGBOX[BIN_ALIAS]} ${NAME}"
            done
            unset BIN

#         }}}
#       }}}

            echo -e "NAVIGATION${GREEN} mode used${RESET}"

#     }}}
#     NAVIGATION mode {{{3

          elif [[ "${FLAGBOX[MODE]}" == "NAV" ]]; then

#       Enter EDITION mode {{{4

            FLAGBOX[MODE]="EDIT"

            for A in ${FLAGBOX[BIN_ALIAS]}; do
              TMP=$(alias "${A}" 2> /dev/null)
              if [[ ${#TMP} -gt 0 ]]; then
                unalias "${A}"
              fi
            done
            unset FLAGBOX[BIN_ALIAS]

#         Generate EDITION mode aliases {{{5

            declare -a BIN=( $(
              I=1
              J=$(echo {0..1})
              while [[ ${I} -lt ${FLAGBOX_SIZE} ]]; do
                J=$(for K in ${J}; do
                      B=$(echo ${K}{0..1})
                      echo "${B//[[:space:]]/$'\n'}"
                    done)
                (( I+=1 ))
              done
              echo "${J}"
            ) )
            for B in ${BIN[@]}; do
              if [[ ${B} -gt 0 ]]; then
                NAME="$(printf "${B}")"
                NAME="${NAME//0/${FLAGBOX_KEY1}}"
                NAME="${NAME//1/${FLAGBOX_KEY2}}"
                alias "${NAME}"="flagbox ${B}"
                FLAGBOX[BIN_ALIAS]="${FLAGBOX[BIN_ALIAS]} ${NAME}"
              fi
            done
            unset BIN

#         }}}
#       }}}

            echo -e "EDITION${GREEN} mode used${RESET}"
          fi

#     }}}

        else
          if [[ -d "${FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]}" ]]; then
            cd ${FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]}
          else
            echo -e "${RED}Directory pointed by flag ${RESET}${FLAGBOX[${FLAGBOX[BOX]},${#CHAIN}]}{RED} is not available${RESET}"
          fi
        fi
      fi

      unset LENGTH NAME LOG TMP

#   }}}
#   Binary chains {{{2

    elif [[ ${#CHAIN} -eq ${FLAGBOX_SIZE} ]]; then
      local DECIMAL=1
      local CONCAT=""
      local BOX_DELETED="false"

#     EDITION mode {{{3

      if [[ "${FLAGBOX[MODE]}" == "EDIT" ]]; then
        if [[ "${CHAIN}" =~ ^1+$ && ${FLAGBOX[MAX]} -gt 1 ]]; then
          for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
            CONCAT="${CONCAT}x${FLAGBOX[${FLAGBOX[BOX]},${I}]}"
          done
          if [[ ${#CONCAT} -eq ${FLAGBOX_SIZE} ]]; then
            for ((I=$(( ${BOX} + 1 ));I<=${MAX};I++)); do
              for ((J=1;J<=${FLAGBOX_SIZE};J++)); do
                FLAGBOX[$(( ${I} - 1 )),${J}]=${FLAGBOX[${I},${J}]}
              done
            done
            for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
              unset FLAGBOX[${FLAGBOX[MAX]},${J}]
            done
            (( FLAGBOX[MAX]-=1 ))
            [[ ${FLAGBOX[BOX]} -gt ${FLAGBOX[MAX]} ]] && (( FLAGBOX[BOX]-=1 ))
            BOX_DELETED="true"
          fi
        fi

        if [[ "${BOX_DELETED}" == "false" ]]; then
          for ((I=1;I<=${#CHAIN};I++)); do
            if [[ "${CHAIN:$(( ${I} - 1 )):1}" == "1" ]]; then
              FLAGBOX[${FLAGBOX[BOX]},${I}]=''
            fi
          done
        fi
        [[ "${FLAGBOX_VRESET}" == "true" ]] && flagbox 1

#     }}}
#     NAVIGATION mode {{{3

      elif [[ "${FLAGBOX[MODE]}" == "NAV" ]]; then
        DECIMAL=$(( 2#${CHAIN} ))
        if [[ ${DECIMAL} -gt 0 && ${DECIMAL} -le ${FLAGBOX[MAX]} ]]; then
          FLAGBOX[BOX]=${DECIMAL}
        fi
      fi

#     }}}

      unset DECIMAL CONCAT BOX_DELETED

#   }}}
#   List-flags chain {{{2

    elif [[ "${CHAIN}" == "1" ]]; then
      local TEXT=""
      local TEXT_LINE=""
      local FLAG=""
      local BOXTEXT=""
      local BAR=""
      local TEXT_WIDTH=0
      local BARLEN=0
      local HEIGHT=$(( ${FLAGBOX_SIZE} + 1 ))
      [[ "${FLAGBOX_FOLDLISTING}" == "true" ]] && (( HEIGHT+=1 ))
      for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
        FLAG="$(printf %${I}s)"
        FLAG="${FLAG//[[:space:]]/${FLAGBOX_KEY1}}"
        TEXT_LINE="${FLAG} = ${FLAGBOX[${FLAGBOX[BOX]},${I}]}"
        [[ ${#TEXT_LINE} -gt ${TEXT_WIDTH} ]] && TEXT_WIDTH=${#TEXT_LINE}
        if [[ "${PWD}" == "${FLAGBOX[${FLAGBOX[BOX]},${I}]}" ]]; then
          TEXT="${TEXT}${REVERSE}${TEXT_LINE}${RESET}"
        else
          TEXT="${TEXT}${TEXT_LINE}"
        fi
        [[ ${I} -lt ${FLAGBOX_SIZE} ]] && TEXT="${TEXT}\n"
      done
      BOXTEXT="[ Box ${FLAGBOX[BOX]}/${FLAGBOX[MAX]} | ${FLAGBOX[MODE]} ]"
      BARLEN=$(( ( ${TEXT_WIDTH} - ${#BOXTEXT} + 1) / 2 ))
      BARLEN=$(( 0 > ${BARLEN} ? 0 : ${BARLEN} ))
      BAR="$(printf %${BARLEN}s)"
      BAR="${BAR//[[:space:]]/=}"
      echo -e "${BAR}${BOXTEXT}${BAR}\n${TEXT}"
      if [[ "${FLAGBOX_FOLDLISTING}" == "true" ]]; then
        if [[ ${HEIGHT} -le ${LINES} && ${TEXT_WIDTH} -le ${COLUMNS} ]]; then
          echo -n "Press ? to continue"
          while :; do
            read -s -n 1 INPUT <&1
            [[ "${INPUT}" == "?" ]] && break
          done
          echo -e -n "\e[${LINES}D\e[$(( ${HEIGHT} - 1 ))A\e[J"
        else
          echo "Flagbox foldlisting setting ignored"
        fi
      fi
      unset TEXT TEXT_LINE TEXT_WIDTH BOXTEXT BARLEN BAR HEIGHT

#   }}}
#   Backup chains {{{2

    elif [[ "${CHAIN}" == "11" ]]; then
      local BACKUP="${HOME}/.flagbox_backup"
      local CONCAT=""
      local TEXT=""
      local I=1
      local J=1
      for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
        CONCAT="${CONCAT}x${FLAGBOX[${FLAGBOX[BOX]},${I}]}"
      done
      if [[ "x${FILE}" != "x" ]]; then
        BACKUP="$(
          # https://github.com/dylanaraps/pure-bash-bible/blob/master/README.md#get-the-directory-name-of-a-file-path
          dirname () {
            local TMP=${1:-.}

            [[ ${TMP} != *[!/]* ]] && {
              printf '/\n'
              return
            }

            TMP=${TMP%%"${TMP##*[!/]}"}

            [[ ${TMP} != */* ]] && {
              printf '.\n'
              return
            }

            TMP=${TMP%/*}
            TMP=${TMP%%"${TMP##*[!/]}"}

            printf '%s\n' "${TMP:-/}"
          }

          # https://github.com/dylanaraps/pure-bash-bible/blob/master/README.md#get-the-base-name-of-a-file-path
          basename () {
            local TMP

            TMP=${1%"${1##*[!/]}"}
            TMP=${TMP##*/}
            TMP=${TMP%"${2/"$TMP"}"}

            printf '%s\n' "${TMP:-/}"
          }

          cd "$(dirname "${FILE}")" && echo ${PWD})/$(basename "${FILE}"
        )"
      fi

#     Restore {{{3

      if [[ ${#CONCAT} -eq ${FLAGBOX_SIZE} ]]; then
        if [[ -f "${BACKUP}" ]]; then

          I=1
          while IFS= read -r LINE; do
            FLAGBOX[${FLAGBOX[BOX]},${I}]="${LINE}"
            (( I+=1 ))
          done < ${BACKUP}

          echo -e "${GREEN}Marks restored with:${RESET} ${BACKUP}"
          [[ "${FLAGBOX_VRESTORE}" == "true" ]] && flagbox 1
        fi

#     }}}
#     Save {{{3

      else
        if [[ "${FLAGBOX_BACKUPCONFIRM}" == "true" ]]; then
          [[ -f "${BACKUP}" ]] && rm -iv ${BACKUP}
        else
          [[ -f "${BACKUP}" ]] && rm ${BACKUP}
        fi
        I=1
        for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
          TEXT="${TEXT}$(echo "${FLAGBOX[${FLAGBOX[BOX]},${I}]}")\n"
        done
        printf "${TEXT}" > "${BACKUP}" \
          && echo -e "${GREEN}Box marks saved at:${RESET} ${BACKUP}"
      fi

#     }}}

      unset I J BACKUP CONCAT TEXT

#   }}}
#   Navigation chains {{{2

    elif [[ "${CHAIN}" == "01" ]]; then
      local CONCAT=""
      for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
        CONCAT="${CONCAT}x${FLAGBOX[${FLAGBOX[BOX]},${I}]}"
      done
      if [[ ${FLAGBOX[BOX]} -lt ${FLAGBOX[MAX]} ]]; then
        (( FLAGBOX[BOX]+=1 ))
      elif [[ ${#CONCAT} -gt ${FLAGBOX_SIZE} ]]; then
        (( FLAGBOX[BOX]+=1 ))
        for ((I=1;I<=${FLAGBOX_SIZE};I++)); do
          FLAGBOX[${FLAGBOX[BOX]},${I}]=''
        done
      else
        FLAGBOX[BOX]=1
      fi
      [[ ${FLAGBOX[BOX]} -gt ${FLAGBOX[MAX]} ]] && FLAGBOX[MAX]=${FLAGBOX[BOX]}
      unset CONCAT
      [[ "${FLAGBOX_VNAV}" == "true" ]] && flagbox 1
    elif [[ "${CHAIN}" == "10" ]]; then
      if [[ ${FLAGBOX[BOX]} -gt 1 ]]; then
        (( FLAGBOX[BOX]-=1 ))
      else
        FLAGBOX[BOX]=${FLAGBOX[MAX]}
      fi
      [[ "${FLAGBOX_VNAV}" == "true" ]] && flagbox 1
    fi

#   }}}
# }}}

  fi
}

flagbox
