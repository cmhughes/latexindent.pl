#!/bin/bash
cp ../environments/environments-nested-fourth.tex ../../
cp ../environments/env-all-on.yaml ../../localSettings.yaml
cp ../environments/env-all-on.yaml ../../env-all-on.yaml
cd ../../
echo "----------1. basic test--------------\n"
perl latexindent.pl environments-nested-fourth.tex
echo "----------2. no file extension--------------\n"
perl latexindent.pl environments-nested-fourth
echo "----------3. overwrite--------------\n"
perl latexindent.pl -w environments-nested-fourth.tex
echo "----------4. localSettings and modify line breaks--------------\n"
perl latexindent.pl -l -m environments-nested-fourth
echo "----------5. localSettings renamed and modify line breaks--------------\n"
perl latexindent.pl -l=env-all-on -m environments-nested-fourth
echo "----------6. STDIN/cat mode--------------\n"
cat environments-nested-fourth.tex|perl latexindent.pl
exit
