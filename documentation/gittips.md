# gitmd preview site: https://jbt.github.io/markdown-editor/

development model:
=
http://nvie.com/posts/a-successful-git-branching-model/

logging commands
=
```
git log
git log --decorate
git log --all --graph
git shortlog -sn        # shows all contributors
```

commiting
=
```
git add . 				# everything, including subdirectories
git add <myfile>		# selectively add things
git commit --dry-run -a # dry run
```

split commits
=
```
git reset HEAD~
# you should now see all the files that have been changed.
# can now selectively add them, e.g

git add xsl/*
git commit -m "message for xsl files"
git add examples/*
git commit -m "message for example files"
```

checking 
=
```
git status      # lots of information
git diff        # show differences
git diff master # show differences when compared with master
git diff --cached # show differences in staged files compared to latest committed file

# show
git show e0a86c674a80a7440dde2072b4836bba2e0b93db xsl/omdchapter2tex.xsl
git show --name-only e0a86c674a80a7440dde2072b4836bba2e0b93db
git show HEAD
```

changing history
=
```
git reset --hard     # puts everything back to the last commit
git checkout myfile  # resets myfile to previous state
git clean -fdx       # removes all untracked files
git rebase -i --preserve-merges HEAD .... # combine, delete, change commits
```

branching
=
```
git branch -a 		   # list all current branches
git checkout develop   # move to develop
git branch -D mybranch # delete mybranch
git checkout -b myfeature # branch from current branch
```

stash
=
```
git stash  		# stash changes before, e.g, changing branches
git stash pop	# re-implement unsaved changes
```

pulling/fetching
=
```
git fetch upstream
git merge upstream/master
git remote -v
```

`gitinfo2` information
=
setup:
-
copy the file post-xxx-sample.txt from https://www.ctan.org/tex-archive/macros/latex/contrib/gitinfo2
and put it in `.git/hooks/post-checkout`
then
```
cd .git/hooks
chmod g+x post-checkout
chmod +x post-checkout
cp post-checkout post-commit
cp post-checkout post-merge
cd ../..
git checkout master
git checkout develop
ls .git
```
and you should see gitHeadInfo.gin

tagging release info: (see also https://git-scm.com/book/en/v2/Git-Basics-Tagging)
-
```
git add abc.tex
git commit -m "commit message"
git tag -a 3.2
git checkout abc.tex
pdflatex abc.tex 
git add abc.pdf
git commit -m "pdf now has correct gitinfo"

```
combining last n commits
=
for example, to combine the last *two* commits:
```
git reset --soft HEAD~2 && git commit --edit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"
```
