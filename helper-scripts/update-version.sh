#!/bin/bash
#
# PURPOSE
#
#   helper script to assist with pre-release tasks
#
# sample usage
#
# help
#
#   update-version.sh -h
#
# git mode, runs the checkout, merge, pull, tag, push commands, checking for confirmation before each 
#
#   update-version.sh -g
#
# update
#
#   update-version.sh -u
#
# update, but only minor version
#
#   update-version.sh -u -m
#
# get version details
#
#   update-version.sh -v
#
#-----------------------------------------
# archived notes:
#
#    (no longer necessary)
#        - git push
#        - git checkout main
#        - git merge --no-ff develop
#        - git pull
#        - git tag "V<number>"
#        - cmhtag=$(git describe --abbrev=0 --tags)
#        - git log --decorate -1|grep -i $cmhtag && echo "success, tag is contained in last commit, good to go"
#        - git push
#        - git push --tags
#        - <await completion of github actions!>
#        - <check release notes on github>
#    
#    (no longer necessary)
#    
#        - <download latexindent.zip>
#        - <upload latexindent.zip to ctan>

minorVersion=0
oldVersion='3.24.4'
newVersion='3.24.5'
oldDate='2024-07-18'
newDate='2025-03-13'
updateVersion=0
gitMode=0

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
RED='\033[0;31m'          # red
YELLOW='\033[1;33m'       # yellow
BGreen='\033[1;32m'       # green
CYAN='\033[0;36m'         # cyan
COLOR_OFF='\033[0m'       # text reset

#
# process options
#
while getopts "ghmuv" OPTION
do
 case $OPTION in 
  h)
    cat <<-____PLEH

${0##*/} [OPTIONS]
    
    -g  git mode, runs the checkout, merge, pull, tag, push commands, checking for confirmation before each 

    -h  help, outputs this message

    -m  minor version, not removing most recently updated stars from documentation

    -u  update version

    -v  version details

Typical running order pre-release:

  phase 1:

    update-version.sh -u
    - <update documentation/changelog.md manually>
    - <check everything has changed as you'd like using git diff>
    - git add .
    - <compile documentation> AND <run test-cases.sh -s -n>
    - <commit changes and push to develop>

  phase 2:

    update-version.sh -g

____PLEH
    exit 0
    ;;
  g)
   gitMode=1
   ;;
  m)    
   echo "minor version, not removing most recently updated stars from documentation..."
   minorVersion=1
   ;;
  u)    
   echo "update switch active"
   updateVersion=1
   ;;
  v)    
   echo ""
   echo "version details:"
   echo -e "${RED}old${COLOR_OFF} version details: $oldVersion, $oldDate"
   echo -e "${BGreen}NEW${COLOR_OFF} version details: $newVersion, $newDate"

   #
   # ctan announcement
   #
   egrep -i --color=auto '<!-- announcement:' ../documentation/changelog.md > tmp.log
   sed -i.bak s/\<\!\-\-\ announcement:\ // tmp.log
   sed -i.bak s/-\-\>// tmp.log
    
   echo ""
   echo "#"
   echo "# ctan (see ../documentation/changelog.md)"
   echo "#"
   echo -e "The following will be used as ${BGreen}*announcement* ${COLOR_OFF}text for ${BGreen}ctan:${YELLOW}"
   echo ""
   cat tmp.log
   echo -e ${COLOR_OFF}

   #
   # release text
   #
   trash-put cmh*
   csplit ../documentation/changelog.md '/^\#\#/' '{*}' -q -f cmh # split changelog at '##'
   for file in cmh*
   do
       mv "$file" "$file.log"
   done
   sed -i.bak s/\#\#.*\// cmh01.log

   echo "#"
   echo "# release text (see ../documentation/changelog.md)"
   echo "#"
   echo -e "The following will be used as ${BGreen}*release* ${COLOR_OFF}text for ${BGreen}github:${YELLOW}"
   cat cmh01.log
   echo -e ${COLOR_OFF}
   exit 0
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 1
        ;;
 # end case
 esac 
done

function helper_section_print() {
    set +x
    echo "--------------------------------------"
    echo -e "     ${CYAN}$1${COLOR_OFF}"
    echo "--------------------------------------"
}

#
# update-version.sh -g
#
if [ $gitMode -eq 1 ]; then
    git diff --quiet
    result=$? && [[ result -gt 0  ]] &&  echo -e "${RED}-g switch failure: git diff has differences, something has changed${COLOR_OFF}" && paplay /usr/share/sounds/freedesktop/stereo/bell.oga && exit

    git diff --cached --quiet
    ###result=$? && [[ result -gt 0  ]] &&  echo -e "${RED}-g switch failure: git diff --cached has differences you'll need to commit them${COLOR_OFF}" && paplay /usr/share/sounds/freedesktop/stereo/bell.oga && exit

    allmode=0
    for mycommand in 'git pull' 'git push' 'git checkout main' 'git merge --no-ff develop' 'git pull' "git tag V${newVersion}" 'git push' 'git push --tags' 'git checkout develop' 'git merge main' 'git push'
    do
        while true; do
           [[ allmode -eq 1 ]] && helper_section_print "$mycommand" && $mycommand && break
           echo -e "${YELLOW}Would you like to run the following command:"
           echo ""
           echo -e "    $mycommand"
           echo ""
           echo -e ${COLOR_OFF}
           read -p "choose [y/n/q/a] (yes/no/quit/all)" yn
           case $yn in
               [Yy]* ) helper_section_print "$mycommand" && $mycommand && break;;
               [Aa]* ) allmode=1 && helper_section_print "$mycommand" && $mycommand && break;;
               [Nn]* ) echo -e "${RED} not performing $mycommand ${COLOR_OFF}" && break;;
               [Qq]* ) echo -e "${RED} exiting, no further work${COLOR_OFF}" && exit;;
               * ) echo "Please answer yes, no or exit.";;
           esac
        done
    done
    exit
fi

set +x
helper_section_print "version details"
echo -e "${RED}old${COLOR_OFF} version details: $oldVersion, $oldDate"
echo -e "${BGreen}NEW${COLOR_OFF} version details: $newVersion, $newDate"

[[ $updateVersion == 0 ]] && printf "not updating, you can run the following instead\n\n    update-version.sh -u\n\n" && exit 0

helper_section_print "documentation update"
# back to project route directory
cd ../

#
# documentation update
#
cd documentation

[[ $minorVersion == 0 ]] && set -x && find -name "s*.tex" -print0|xargs -0 perl -p0i -e "s|announce\*\{|announce\{|sg"

# change \announce{new}{message} into \announce*{message}
find -name "s*.tex" -print0|xargs -0 perl -p0i -e "s|announce\{new|announce\*\{$newDate|sgi"

pdflatexneeded=1

[[ -z $(git diff --name-only main|grep -i documentation/s) ]] && pdflatexneeded=0

[[ $pdflatexneeded -eq 0 ]] && echo -e "${YELLOW}documentation *not* updated, no need to run pdflatex${COLOR_OFF}"

if [ $pdflatexneeded -eq 1 ]; then
   echo ""
   echo -e "${YELLOW}pdflatex needed because of the following files:"
   git diff --name-only main|grep -i documentation/s
   echo -e "${COLOR_OFF}"

   set -x
   pdflatex --interaction=batchmode latexindent
   
   # update .rst
   perl documentation-default-settings-update.pl
   perl documentation-default-settings-update.pl -r
fi

# documentation-default-settings-update.pl changes the .tex files
git checkout s*.tex

[[ $minorVersion == 0 ]] && find -name "s*.tex" -print0|xargs -0 perl -p0i -e "s|announce\*\{|announce\{|sg"

# change \announce{new}{message} into \announce*{message}
find -name "s*.tex" -print0|xargs -0 perl -p0i -e "s|announce\{new|announce\*\{$newDate|sgi"

#
# perltidy
#
helper_section_print "perl tidy"

cd ../LatexIndent
set -x
perltidy -b *.pm
set +x

# back to project route directory
cd ../
perltidy -b latexindent.pl

#
# codespell
#
helper_section_print "codespell"

set -x
codespell -w -S test-cases,*.bak,.git,./documentation/build/*,*.bbl,*.log,*.pdf -L reacher,alph,crossreferences,ist,termo,te

set +x

helper_section_print "update version number across files"

#
# change
#
#   oldDate to newDate
#   oldVersion to newVersion
#
filesToUpdate=( 
  latexindent.pl
  defaultSettings.yaml
  LatexIndent/Version.pm 
  readme.md
  Dockerfile
  documentation/conf.py 
  documentation/readme.txt
  documentation/latexindent-yaml-schema.json
  documentation/title.tex
  documentation/demonstrations/pre-commit-config-cpan.yaml
  documentation/demonstrations/pre-commit-config-conda.yaml
  documentation/demonstrations/pre-commit-config-docker.yaml
  documentation/demonstrations/pre-commit-config-demo.yaml
  ) 

# loop through the files
for file in "${filesToUpdate[@]}"
do
  echo "updating $file"
  sed -i.bak "s/$oldDate/$newDate/" $file
  sed -i.bak "s/$oldVersion/$newVersion/" $file
done

#
# check for new announcements in the documentation
#
helper_section_print "announcements in documentation"
egrep -i --color=auto 'announce{new' documentation/*.tex

cat documentation/latexindent.new

# check for cmhlistings* in the documentation
# 
# note:
#
#   sed -i.bak "s/cmhlistingsfromfile\*/cmhlistingsfromfile/" s*.tex
helper_section_print "new listings in documentation"
egrep -i --color=auto 'cmhlistingsfromfile\*' documentation/s*.tex

# update changelog.md manually
helper_section_print "update changelog.md"
gedit documentation/changelog.md

#
# really important to check that the ctan announcement is as you like
#

helper_section_print "check release text"

trash-put cmh*
#
# github release text
#
while true; do
   # get the most recent information from changelog.md
   csplit documentation/changelog.md '/^\#\#/' '{*}' -q -f cmh # split changelog at '##'
   for file in cmh*
   do
       mv "$file" "$file.log"
   done
   sed -i.bak s/\#\#.*\// cmh01.log

   echo -e "The following will be used as ${BGreen}*release* ${COLOR_OFF}text for ${BGreen}github:${YELLOW}"
   cat cmh01.log
   echo -e ${COLOR_OFF}
   read -p "Are you happy to continue? [y/n/e] (click 'e' to edit changelog.md)" yn
   case $yn in
       [Yy]* ) echo -e "${BGreen} ... changelog.md updated ${COLOR_OFF}" && break;;
       [Nn]* ) echo -e "${RED} exiting${COLOR_OFF}" && exit;;
       [Ee]* ) gedit documentation/changelog.md;;
       * ) echo "Please answer yes, no or edit.";;
   esac
   trash-put cmh*
done

# 
# ctan announcement text
#
helper_section_print "check announcement text"
echo ""
echo ""
while true; do
   # get the announcement information from changelog.md
    egrep -i --color=auto '<!-- announcement:' documentation/changelog.md > tmp.log
    sed -i.bak s/\<\!\-\-\ announcement:\ // tmp.log
    sed -i.bak s/-\-\>// tmp.log
    
    echo -e "The following will be used as ${BGreen}*announcement* ${COLOR_OFF}text for ${BGreen}ctan:${YELLOW}"
    cat tmp.log
    echo -e ${COLOR_OFF}
    read -p "Are you happy to continue? [y/n/e] (click 'e' to edit changelog.md)" yn
    case $yn in
        [Yy]* ) echo -e "${BGreen} ... changelog.md updated ${COLOR_OFF}" && break;;
        [Nn]* ) echo -e "${RED} exiting${COLOR_OFF}" && exit;;
        [Ee]* ) gedit documentation/changelog.md;;
        * ) echo "Please answer yes, no or edit.";;
    esac
done

echo ""
echo -e "${BGreen}SUCCESS: ${COLOR_OFF}update version number ${BGreen}COMPLETE ${COLOR_OFF}"
echo ""
exit 0
