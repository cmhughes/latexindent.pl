#!/bin/bash

# latexindent.pl test-cases script to ensure that, as much as possible, 
# the script behaves as intended.
#
# Sample usage
#   ./test-cases.sh 
#   ./test-cases.sh -a              # do *all* test cases (toggles bench mark and file extension switches)
#   ./test-cases.sh -b              # do the benchmark test cases
#   ./test-cases.sh -c              # show the counter within loops
#   ./test-cases.sh -d              # don't stop mode
#   ./test-cases.sh -f              # do the file extension test cases
#   ./test-cases.sh -n              # play a noise at the end of each batch of test cases
#   ./test-cases.sh -o <INTEGER>    # only do the loops for <INTEGER>
#   ./test-cases.sh -s              # silent mode, don't echo the latexindent command
#
#-----------------------------
# total number of test cases: 2800
# total number of test cases last updated: 2025-05-12
#-----------------------------

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#
# bulk git rename of file
#
#   for file in $(git ls-files | grep com-rm-lb | sed -e 's/\(com-rm-lb[^/]*\).*/\1/' | uniq); do git mv $file $(echo $file | sed -e 's/com-rm-lb/com-rm-lb/'); done
#
# reference
#   https://stackoverflow.com/questions/9984722/git-rename-many-files-and-folders
#
# starting point for counting the number of calls to latexindent.pl 
#   https://stackoverflow.com/a/11229532/1091649

RED='\033[0;31m'          # red
YELLOW='\033[1;33m'       # yellow
BGreen='\033[1;32m'       # green
CYAN='\033[0;36m'         # cyan
COLOR_OFF='\033[0m'       # text reset

function checkgitdiff
{
    git diff --quiet
    result=$? && [[ result -gt 0  ]] && [[ $dontStopMode -eq 0 ]] &&  echo -e "${RED}git diff has differences, something has changed${COLOR_OFF}" && paplay /usr/share/sounds/freedesktop/stereo/bell.oga && exit

}

silentMode=0
silentModeFlag=''
gitStatus=0
showCounterFlag=''
noisyModeFlag=''
gitStatusFlag=''
benchmarkMode=0
fileExtensionMode=0
dontStopMode=0
updateTotalCount=1

# check flags, and change defaults appropriately
while getopts "abcdfgno:s" OPTION
do
 case $OPTION in 
  s)    
   echo "Silent mode on..."
   silentModeFlag='-s'
   silentMode=1
   ;;
  a)
    # all mode
    benchmarkMode=1
    fileExtensionMode=1
    ;;
  b)
    # bench mark mode
    benchmarkMode=1
    ;;
  c)    
   echo "Show counter mode active!"
   showCounterFlag='-c'
   ;;
  d)
    # don't stop
    dontStopMode=1
    ;;
  f)
    # file extension test mode
    fileExtensionMode=1
    ;;
  g)
    # show git status
    gitStatusFlag="-g"
    gitStatus=1
  ;;
  n)
    # only do this one in the loop
    noisyModeFlag="-n"
    noisyMode=1
   ;;
  o)
    # only do this one in the loop
    loopminFlag="-o $OPTARG"
    updateTotalCount=0
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed

checkgitdiff

dirExec=( 
  "commands;commands-test-cases.sh"
  "opt-args;opt-args-test-cases.sh"
  "mand-args;mand-args-test-cases.sh"
  "opt-and-mand-args;opt-mand-args-test-cases.sh"
  "namedGroupingBracesBrackets;named-grouping-test-cases.sh"
  "unnamed-braces;un-named-grouping-braces.sh"
  "keyEqualsValueBraces;key-equals-values-test-cases.sh"
  "environments;environments-test-cases.sh"
  "specials;specials-test-cases.sh"
  "ifelsefi;ifelsefi-test-cases.sh"
  "items;items-test-cases.sh"
  "poly-switch-blank-line;poly-switch-blank-line-test-cases.sh"
  # "alignment;alignment-test-cases.sh" 
  # "headings;headings-test-cases.sh"
  # "back-up-tests;back-up-tests.sh"
  # "path-tests;path-tests.sh"
  # "diacritics;diacritics-test-cases.sh"
  # "tokenChecks;token-checks.sh"
  # "cruftdirectory;cruft-directory-test-cases.sh"
  # "STDIN;stdin-test-cases.sh"
  # "filecontents;filecontents-test-cases.sh"
  # "text-wrap;text-wrap-remove-PLB.sh"
  # "texexchange;texexchange-test-cases.sh"
  # "horizontalWhiteSpace;whitespace-test-cases.sh"
  # "oneSentencePerLine;one-sentence-per-line.sh"
  # "verbatim;verbatim-test-cases.sh"
  # "fine-tuning;fine-tuning-test-cases.sh"
  # "replacements;replacement-test-cases.sh"
  # "check-switch-tests;check-switch-test-cases.sh"
  # "line-switch-test-cases;line-switch-test-cases.sh"
  # "batch-tests;batch-tests.sh"
  # "demonstrations;documentation-test-cases.sh"
  # "documentation;doc-indent.sh"
  ) 


totalTestCases=0
dirExecCount=0
dirExecCountTotal=${#dirExec[@]}
# loop through the files
for file in "${dirExec[@]}"
do
  ((dirExecCount++))

  dirExec=(${file//;/ })

  # grab the directory
  directory=${dirExec[0]}

  # grab the executable
  executable=${dirExec[1]}

  [[ $directory == 'demonstrations' ]] && cd ../documentation/
  cd $directory

  [[ $silentMode == 1 ]] && echo -ne "./$directory/${YELLOW}$executable ($dirExecCount of $dirExecCountTotal)${COLOR_OFF}\r"

  ./$executable $silentModeFlag $showCounterFlag $loopminFlag $noisyModeFlag $gitStatusFlag

  currentCount=$(egrep -i 'latexindent.pl' latexindent-count.log|wc -l)
  totalTestCases=$((totalTestCases+currentCount))
  checkgitdiff

  # check log files for errors
  egrep -i --color=auto 'Use of uninitialized value' latexindent-count.log

  echo -e "./$directory/${BGreen}$executable SUCCESS ($dirExecCount of $dirExecCountTotal) [$currentCount tests]${COLOR_OFF}\r"

  cd ..
  [[ $directory == 'demonstrations' ]] && cd ..
done

# file extension
cd test-cases/fileextensions/
[[ $fileExtensionMode == 1 ]] && [[ $silentMode == 1 ]] && echo "./fileextensions/file-extension-test-cases.sh"
[[ $fileExtensionMode == 1 ]] && ./file-extension-test-cases.sh $silentModeFlag $showCounterFlag $loopminFlag $noisyModeFlag $gitStatusFlag

checkgitdiff

# benchmark mode, if appropriate
cd ../benchmarks
[[ $benchmarkMode == 1 ]] && ./benchmarks.sh $silentModeFlag $showCounterFlag $loopminFlag $noisyModeFlag $gitStatusFlag
checkgitdiff

#
# TOTAL test cases: possibly update test-cases.sh with total count, and date last updated
#
echo "TOTAL test cases $totalTestCases"
if [ $updateTotalCount == 1 ]; then
   totalTestCasesOLD=$(egrep -i --color=auto '^# total number of test cases:' test-cases.sh)
   totalTestCasesOLD=$(echo $totalTestCasesOLD |  cut -d ":" -f 2|awk '{$1=$1};1')

   if [ $updateTotalCount == 1 ] && [ $totalTestCasesOLD == $totalTestCases ]; then
       echo "Total number of test-cases NOT changed" 
   else
       totalTestCasesDateOLD=$(egrep -i --color=auto '^# total number of test cases last updated:' test-cases.sh)
       totalTestCasesDateOLD=$(echo $totalTestCasesDateOLD|  cut -d ":" -f 2|awk '{$1=$1};1')
       totalTestCasesDateNEW=$(date '+%Y-%m-%d')
       echo "Total number of test-cases CHANGED" 
       sed -i.bak "s/# total number of test cases: $totalTestCasesOLD/# total number of test cases: $totalTestCases/" test-cases.sh
       sed -i.bak "s/# total number of test cases last updated: $totalTestCasesDateOLD/# total number of test cases last updated: $totalTestCasesDateNEW/" test-cases.sh
   fi
fi

# play sounds
for i in {1..5}
do 
  [[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
done

exit 0
