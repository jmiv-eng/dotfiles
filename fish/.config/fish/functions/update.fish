function update --description 'Upgrade repo packages, then AUR packages (paru)'
    sudo pacman -Syu; or return
    if type -q paru
        paru -Sua
    end
end
