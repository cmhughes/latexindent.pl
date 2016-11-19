#!/bin/bash
# This routine is called by each of the test case scripts 
# to asses optional arguments
#
# reference: https://ubuntuforums.org/showthread.php?t=664657
silentMode=0
loopmin=1
# check flags, and change defaults appropriately
while getopts 'sl:o:' OPTION
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
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

echo "loopmin is $loopmin"
echo "loopmax is $loopmax"
