# yazi: `y` changes into the directory you were in when you quit
function y
    set -l tmp (mktemp -t yazi-cwd.XXXXXX)
    yazi $argv --cwd-file="$tmp"
    if set -l cwd (command cat -- $tmp); and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- $cwd
    end
    command rm -f -- $tmp
end
