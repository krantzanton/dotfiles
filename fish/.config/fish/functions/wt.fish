# Git worktrees: a separate checkout per task, so parallel agents don't trample each other.
#   wt              list worktrees
#   wt <branch>     create ../<repo>-<branch> (new or existing branch) and cd into it
#   wt rm <branch>  remove that worktree (the branch itself is kept)
function wt
    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "wt: not inside a git repository" >&2
        return 1
    end

    # Always name worktrees after the main checkout, even when run from inside one
    set -l main (dirname (git rev-parse --path-format=absolute --git-common-dir))
    set -l repo (basename $main)

    switch (count $argv)
        case 0
            git worktree list
        case 1
            set -l branch $argv[1]
            set -l dir (dirname $main)/$repo-(string replace -a / - $branch)
            if test -d $dir
                echo "wt: $dir already exists, switching to it"
            else if git show-ref --verify --quiet refs/heads/$branch
                git worktree add $dir $branch; or return
            else
                git worktree add -b $branch $dir; or return
            end
            builtin cd $dir
        case 2
            if test $argv[1] != rm
                echo "usage: wt [<branch> | rm <branch>]" >&2
                return 1
            end
            set -l dir (dirname $main)/$repo-(string replace -a / - $argv[2])
            string match -q "$dir*" $PWD; and builtin cd $main
            git worktree remove $dir
        case '*'
            echo "usage: wt [<branch> | rm <branch>]" >&2
            return 1
    end
end
