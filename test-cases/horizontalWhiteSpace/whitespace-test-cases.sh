#!/bin/bash
. ../common.sh
openingtasks

latexindent.pl -s whitespace -l=remove-TWS.yaml -o +-rm-yes
latexindent.pl -s whitespace -l=remove-TWS1.yaml -o +-rm-no

set +x 
wrapuptasks
