# dir  branch*  ❯   (❯ turns red if the last command failed) — same as the zsh prompt
function fish_prompt
    set -l last_status $status

    set -g __fish_git_prompt_showdirtystate 1
    set -g __fish_git_prompt_char_dirtystate '*'
    set -g __fish_git_prompt_char_stagedstate '+'
    set -g __fish_git_prompt_char_cleanstate ''
    set -g __fish_git_prompt_color_branch magenta
    set -g __fish_git_prompt_showcolorhints 0

    set_color blue
    set -l fish_prompt_pwd_dir_length 0
    echo -n (prompt_pwd)
    set_color magenta
    echo -n (fish_git_prompt '  %s')
    if test $last_status -eq 0
        set_color cyan
    else
        set_color red
    end
    echo -n ' ❯ '
    set_color normal
end
