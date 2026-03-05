#!/bin/sh

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=/mnt/sharebox/backups/jarvis/borgbackup

# The below command assumes that I have an encrypted gpg password file
# root must also be able to access this if you are running from root account
export BORG_PASSPHRASE=$(gpg --decrypt --quiet --batch --no-tty /home/jmiv/.secure/borgbackup_encrypted.asc)

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup to $BORG_REPO"

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

borg create                          \
    --verbose                        \
    --filter AME                     \
    --stats                          \
    --show-rc                        \
    --compression zstd               \
    --exclude-caches                 \
    --exclude 'home/*/.cache/*'      \
    --exclude 'var/tmp/*'            \
    --exclude 'var/lib/pacman/*'     \
    --exclude 'var/spool'            \
    --exclude 'var/log'              \
    --exclude 'var/cache'            \
    ::'{hostname}-{now}'             \
    /etc                             \
    /var                             \
    /home                            


backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-*' matching is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                          \
    --list                          \
    --glob-archives '{hostname}-*'  \
    --show-rc                       \
    --keep-daily    5               \
    --keep-weekly   4               \
    --keep-monthly  12 

prune_exit=$?

# actually free repo disk space by compacting segments

info "Compacting repository"

borg compact

compact_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune, and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune, and/or Compact finished with warnings"
else
    info "Backup, Prune, and/or Compact finished with errors"
fi

exit ${global_exit}
