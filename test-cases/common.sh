#!/bin/bash
# This routine is called by each of the test case scripts 
# to asses optional arguments
#
# reference: https://ubuntuforums.org/showthread.php?t=664657
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
loopmin=1
noisyMode=0
# check flags, and change defaults appropriately
while getopts 'ncsl:o:' OPTION
do
 case $OPTION in 
  s)    
   echo "Silent mode on...next thing you'll see is git status."
   silentMode=1
   ;;
  l)
    # change loopmax
    loopmax=$OPTARG
   ;;
  o)
    # only do this one in the loop
    loopmin=$OPTARG
    loopmax=$OPTARG
   ;;
  c)
    # show the loop counter
    showCounter=1
  ;;
  n)
    # show the loop counter
    noisyMode=1
  ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

echo "loopmin is $loopmin"
echo "loopmax is $loopmax"

function makenoise
{
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga
}
