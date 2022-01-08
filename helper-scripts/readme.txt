Typical running order of these helper scripts:
    # NOTE: documentation-default-settings-update.pl is now located in documentation folder
    - <at least one pdflatex of documentation to get total listings correct (for .rst)>
    - perl documentation-default-settings-update.pl
    - perl documentation-default-settings-update.pl -r
    - <change update-version appropriately>
    - update-version.sh
    ###### GitHub actions, so no longer needed - copy-to-usb.sh
    ###### GitHub actions, so no longer needed - <reboot to Windows>
    ###### GitHub actions, so no longer needed - create-windows-executable.bat
    ###### GitHub actions, so no longer needed - <reboot to Ubuntu>
    - <update documentation/changelog.md>
    - <commit changes and push to develop>
    - git push
    ###### - <pull request to main>
    - git checkout main
    - git merge --no-ff develop
    - git tag "V<number>"
    - git push --tags
    - <update release notes on github>
    ###### GitHub actions, so no longer needed - <add latexindent.exe to directory>
    ###### GitHub actions, so no longer needed - prepctan.sh
    - <download latexindent-ctan.zip>
    - <upload latexindent-ctan.zip to ctan>
