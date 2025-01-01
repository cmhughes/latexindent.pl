#!/bin/bash
# This routine is called by each of the test case scripts 
# to asses optional arguments
#
# reference: https://ubuntuforums.org/showthread.php?t=664657
#            http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
#
# each of the test case scripts can be called with the following, for example:
#
# sample usage:
#   non-silent
#       commands-test-cases.sh
#   silent mode
#       commands-test-cases.sh -s
#   silent mode, loopmax 5
#       commands-test-cases.sh -s -l 5
#   silent mode, loopmin is 13, loopmax is 13
#       commands-test-cases.sh -s -o 13
#   silent mode, loopmin is 13, loopmax is 13, show the loop counter 
#       commands-test-cases.sh -s -o 13 -c

silentMode=0
gitStatus=0
loopmin=1
userSpecifiedLoopMin=0
[[ $verbatimTest == 1 ]] && loopmin=-1
noisyMode=0

# check flags, and change defaults appropriately
while getopts 'cgl:no:s' OPTION
do
 case $OPTION in 
  c)
    # show the loop counter
    showCounter=1
  ;;
  g)
    # show git status
    gitStatus=1
  ;;
  l)
    # change loopmax
    loopmax=$OPTARG
   ;;
  n)
    # show the loop counter
    noisyMode=1
  ;;
  o)
    # only do this one in the loop
    loopmin=$OPTARG
    loopmax=$OPTARG
    userSpecifiedLoopMin=1
   ;;
  s)    
   silentMode=1
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

function makenoise
{
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga
}
