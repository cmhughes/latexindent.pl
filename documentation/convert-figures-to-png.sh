#!/bin/bash

# check if figure-schematic.tex is changed (possibly staged)
# and, if so, compile it and then convert it

# references: https://stackoverflow.com/questions/5143795/how-can-i-check-in-a-bash-script-if-my-local-git-repository-has-changes
#             https://stackoverflow.com/questions/5139290/how-to-check-if-theres-nothing-to-be-committed-in-the-current-branch/5139346
( [[ -n "$(git diff --exit-code figure-schematic.tex)" ]] || [[ -n "$(git diff --cached --exit-code figure-schematic.tex)" ]] ) && pdflatex figure-schematic.tex && convert figure-schematic.pdf figure-schematic.png
