Typical running order of these helper scripts:
    # NOTE: documentation-default-settings-update.pl is now located in documentation folder
    - perl documentation-default-settings-update.pl
    - perl documentation-default-settings-update.pl -r
    - <change update-version appropriately>
    - update-version.sh
    - copy-to-usb.sh
    - <reboot to Windows>
    - create-windows-executable.bat
    - <reboot to Ubuntu>
    - <add latexindent.exe to directory>
    - <commit changes and push>
    - <pull request to master>
    - <pull from master>
    - prepctan.sh
