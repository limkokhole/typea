#!/usr/bin/env bash
#Author: <limkokhole@gmail.com>

export p_lgreen=$(tput setaf 118)
export STDERRED_ESC_CODE=`echo -e "$p_lgreen"` #used by stderred which default is red

<<"whyEnvGotColor"
'env' command output color. Originally I though is bcoz of subshell from `$(tput setaf 1)` blah blah race condition bug, but nope.

The reason is:
$(tput setaf 1) stored(used by printf) same like "\033[31m"(used by echo -e)
but it will output as '^[[31m' when print to file, and output directly as color when print to terminal, which `env` do
look carefully where the color start in `env`, it's start every "p_red|green...=" without right side value, which actuallt is ^[[31m,
try `env | cat -v` or env > /tmp/env.log will able to see this hidden color codes.

Problem:
export p_rredd="\033[31m"
printf "%s" "$p_rredd" #this will not work, so printf MUST use `tput setaf 1` ?
echo "$p_rredd"555 #this will work

[toask:0] \033[31m" vs `tput setaf 1`

whyEnvGotColor
export p_blod=$(tput bold) #use p_orig to reset it
export p_red=$(tput setaf 1) #print black red
export p_lred=$(tput setaf 196) #print light red
export p_white=$(tput setaf 15) #print white
export p_blue=$(tput setaf 21) #print blue
export p_lblue=$(tput setaf 50) #print light blue
export p_yellow=$(tput setaf 11) #print yellow
export p_orig=$(tput sgr0) #print back original color

vzone() { #mainly use for ~/.vimrc lines separator

    #rf: http://unix.stackexchange.com/questions/25945/how-to-check-if-there-are-no-parameters-provided-to-a-command
    : "${3?"Usage : vzone '='(separator) y/r/g/b(color) b(bold)/nb(not blod. Please use \\x27 for single quote if separator surround by single quotes.  Else u might use this style: '(◔‿\\\"'◔) ♥\"  )"}" #\space or \(

    #Bonus: change 3rd arg #set -- "${@:1:2}" "1" "${@:4}"

    local vzone_sep="$1"

    #cleaned="${vzone_sep//\\/}"

        #local t_cols="${#cleaned}"
    local t_cols="${#vzone_sep}"

    #echo "$t_cols"
    #esc_sep=$(echo $vzone_sep)
    #esc_len=${#esc_sep}
    #t_cols="$(($COLUMNS/$esc_len))"
    #t_cols="$3" #the above way will fail if i want to get the length exclude escape character, e.g. \*, so let caller provide args len

    if [[ "$3" == "b" ]]; then
        printf "%s" "${p_blod}"
    fi

    if [[ "$2" == "y" ]]; then
        printf "%s" "${p_yellow}"
    elif [[ "$2" == "r" ]]; then
        printf "%s" "${p_red}"
    elif [[ "$2" == "g" ]]; then
        printf "%s" "${p_lgreen}"
    else
        printf "%s" "${p_blue}"
    fi

    vcolumns=$(tput cols) #so now script no such problem to echo empty $COLUMNS

    #even though '\ \*' works without quotes for ...%.0s"$vzone_sep"... below, but '\*\ ' need quotes to works
    printf %.0s"$vzone_sep" $(seq 1 "$((vcolumns/t_cols))"); echo #no more eval :p
    #Alternative is `tput cols` #odd(if args len is 2)/remainder cols will lead to extra space(s)

    printf "%s" "${p_orig}"
}

export -f vzone

#[TODO:0] make autocomplete for command, e.g. typea h[TAB]
#http://unix.stackexchange.com/questions/239795/how-to-make-ls-warning-me-about-parent-directory-is-symlink?noredirect=1#comment411008_239795
#Alternative to awk 'NR>1{print PREV} {PREV=$0} END{printf("%s",$0)}' is sed -z 's/\n$/ /'g
#no nid "[WARN] check inode before modify bcoz ls -l doesn't reflect parent dir like /bin is a symlink to /usr/bin" anymore after use realpath hack
#even though ls expand to ls --color=auto --color=always but --color=always will able to override
#LD_PRELOAD=/home/xiaobai/libisatty.so; #don't see any point of this, might put here before bcoz old code handle differently
#should no nid care if `file "${atom[2]}" &&` success baru do next, bcoz i believe `grep "^$@ is /"` already stop invalid file
#pwd -P /bin can resolved directly
#
#rf: http://unix.stackexchange.com/questions/140727/how-can-i-delete-a-trailing-newline-in-bash #for rm_newline
## [1] NR>1{print PREV} Print previous line (except the first time).
## [2] {PREV=$0} Stores current line in PREV variable.
## [3] END{printf("%s",$0)} Finally, print last line withtout line break.
##Also note this would remove at most one empty line at the end (no support for removing "one\ntwo\n\n\n").
#
#dont worry about what if type -a output got slash, i.e dir/, bcoz type wouldn't find dir and direct typing like command oso will not included.
#`type -a "$1"  | highsh`, rf: http://superuser.com/questions/546452/alias-defined-in-bashrc-not-working-after-pipe , pls make highsh a func
#
#jus noticed `type -a` will make 2>/dev/null become 2> [1 SPACE] /dev/null
#rf: http://unix.stackexchange.com/a/282319/64403, even though type has advantage included executable (`$ l /usr/bin/ | g '\-\-\.'` to find out those files), but type -a included multiple symlink like /usr/bin, /bin, so it win. 

function typea {
 if (( "$#" == 0 )); then echo -e 'Usage: typea command OR command_path'; return 1; fi;
 if (( "$#" == 1 )); then vzone '-' r b; fi;
 type -a "$1" | highsh; vzone '-' y b; type -a "$1" | while IFS=" " read -r line; do echo "$line" | grep "^$1 is /" >/dev/null && atom=(`echo "${line}"`) && ls --color=always -lahiF --context "${atom[2]}" | awk 'NR>1{print PREV} {PREV=$0} END{printf("%s",$0)}' && rp=`realpath "${atom[2]}"` && if [ "$rp" == "${atom[2]}" ]; then echo; file "${atom[2]}"; echo; else echo ' --> ... --->' `ls --color=always -F $rp`; printf "%s" "${p_lblue}"; echo "[goto $rp]"; printf "%s" "${p_orig}"; typea "$rp" 'recur' | awk 'NR>1{print PREV} {PREV=$0} END{printf("%s",$0)}'; printf "%s" "${p_lblue}"; echo "[return $rp]"; echo; namei -l "${atom[2]}"; printf "%s" "${p_orig}"; fi; done
 if (( "$#" == 1 )); then vzone '-' g b; whereis "$1"; echo; fi;
}
export -f typea #to be able used typea on `$ find . -type f -exec bash -c 'typea "$1"' - {} \;`, but unfortunately this got prefix ./ on each file
#so do this instead: find /usr/bin/  -printf '%f\n' | while read f; do typea "$f"; done #rf: http://stackoverflow.com/questions/4763041/strip-leading-dot-from-filenames-bash-script


