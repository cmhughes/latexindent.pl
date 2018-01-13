#!/bin/bash
# check for undefined/multiply-defined references

set -x
egrep -i --color=auto 'undefined' latexindent.log
egrep -i --color=auto 'multiply-defined' latexindent.log
egrep -i --color=auto 'fixthis' latexindent.log
exit
