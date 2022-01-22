#!/bin/bash
# PURPOSE
#
#   helper script to assist with pre-release tasks
#
# sample usage
#
#   update-version.sh -h
#   update-version.sh -m
#   update-version.sh 

minorVersion=0
oldVersion='3.14'
newVersion='3.15'
oldDate='2022-01-08'
newDate='2022-01-21'

while getopts "hmv" OPTION
do
 case $OPTION in 
  h)
    cat <<-____PLEH

${0##*/} [OPTIONS]
    
    -h  help, outputs this message

    -m  minor version, not removing most recently updated stars from documentation

Typical running order pre-release:

    update-version.sh
    - <update documentation/changelog.md>
    - <check everything has changed as you'd like using git diff>
    - <commit changes and push to develop>
    - git push
    - git checkout main
    - git merge --no-ff develop
    - git tag "V<number>"
    - git push --tags
    - <update release notes on github>
    - <download latexindent.zip>
    - <upload latexindent.zip to ctan>
____PLEH
    exit 0
    ;;
  m)    
   echo "minor version, not removing most recently updated stars from documentation..."
   minorVersion=1
   ;;
  v)    
   echo "version details:"
   echo "old version details: $oldVersion, $oldDate"
   echo "NEW version details: $newVersion, $newDate"
   exit 0
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 1
        ;;
 # end case
 esac 
done

echo "old version details: $oldVersion, $oldDate"
echo "NEW version details: $newVersion, $newDate"

cd ../
cd documentation
[[ $minorVersion == 0 ]] && find -name "s*.tex" -print0|xargs -0 perl -p0i -e "s|announce\*\{|announce\{|sg"

set -x
pdflatex --interaction=batchmode latexindent

# update .rst
perl documentation-default-settings-update.pl
perl documentation-default-settings-update.pl -r

# change \announce{new}{message} into \announce*{message}
find -name "s*.tex" -print0|xargs -0 perl -p0i -e "s|announce\{new|announce\*\{$newDate|sgi"
set +x

cd ../

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
  documentation/conf.py 
  documentation/readme.txt
  documentation/latexindent-yaml-schema.json
  documentation/title.tex
  documentation/demonstrations/pre-commit-config-cpan.yaml
  documentation/demonstrations/pre-commit-config-conda.yaml
  documentation/demonstrations/pre-commit-config-demo.yaml
  ) 

# loop through the files
for file in "${filesToUpdate[@]}"
do
  echo "updating $file"
  sed -i.bak "s/$oldDate/$newDate/" $file
  sed -i.bak "s/$oldVersion/$newVersion/" $file
done

# check for new announcements in the documentation
egrep -i --color=auto 'announce{new' documentation/*.tex

# update changelog.md manually
gedit documentation/changelog.md

cat <<-____TXEN

Next steps:
    - <update documentation/changelog.md>
    - <check everything has changed as you'd like using git diff>
    - <commit changes and push to develop>
    - git push
    - git checkout main
    - git merge --no-ff develop
    - git tag "V<number>"
    - git push --tags
    - <update release notes on github>
    - <download latexindent.zip>
    - <upload latexindent.zip to ctan>
____TXEN
    
exit 0
