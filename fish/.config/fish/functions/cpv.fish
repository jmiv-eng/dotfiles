function cpv --wraps rsync --description 'Copy with a progress bar (oh-my-zsh cp plugin)'
    # -pog keep permissions/owner/group, -r recurse, -b move files the copy
    # overwrites to /tmp/rsync-$USER; -e /dev/null keeps it local-only
    rsync -pogbr -hhh --backup-dir=/tmp/rsync-$USER -e /dev/null --progress $argv
end
