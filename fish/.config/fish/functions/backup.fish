function backup --description 'Copy each FILE to FILE.bak (keeps mode/times)'
    if not set -q argv[1]
        echo 'usage: backup FILE...' >&2
        return 2
    end
    for file in $argv
        command cp -a -- $file $file.bak; or return
    end
end
