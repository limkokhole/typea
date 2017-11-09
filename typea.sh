#!/usr/bin/env bash
#Author: <limkokhole@gmail.com>

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

function typea3 {
 if (( "$#" == 0 )); then echo -e 'Usage: typea command OR command_path'; return 1; fi;
 if (( "$#" == 1 )); then vzone '-' r b; fi;
 type -a "$1" | highsh; vzone '-' y b; type -a "$1" | while IFS=" " read -r line; do echo "$line" | grep "^$1 is /" >/dev/null && atom=(`echo "${line}"`) && ls --color=always -lahiF --context "${atom[2]}" | awk 'NR>1{print PREV} {PREV=$0} END{printf("%s",$0)}' && rp=`realpath "${atom[2]}"` && if [ "$rp" == "${atom[2]}" ]; then echo; file "${atom[2]}"; echo; else echo ' --> ... --->' `ls --color=always -F $rp`; printf "%s" "${p_lblue}"; echo "[goto $rp]"; printf "%s" "${p_orig}"; typea3 "$rp" 'recur' | awk 'NR>1{print PREV} {PREV=$0} END{printf("%s",$0)}'; printf "%s" "${p_lblue}"; echo "[return $rp]"; echo; namei -l "${atom[2]}"; printf "%s" "${p_orig}"; fi; done
 if (( "$#" == 1 )); then vzone '-' g b; whereis "$1"; echo; fi;
}
export -f typea3 #to be able used typea on `$ find . -type f -exec bash -c 'typea "$1"' - {} \;`, but unfortunately this got prefix ./ on each file
#so do this instead: find /usr/bin/  -printf '%f\n' | while read f; do typea "$f"; done #rf: http://stackoverflow.com/questions/4763041/strip-leading-dot-from-filenames-bash-script

