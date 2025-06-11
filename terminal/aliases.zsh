# Inspect
alias gstatus='git status'
alias glog='git log --oneline --graph --decorate'
alias gdiff='git diff'
alias greflog='git reflog'

# Commit
alias gcommit='git commit'
alias gamend='git commit --amend --no-edit'

# Remote
alias gpush='git push --force-with-lease'
alias gpull='git pull'

# Working tree
gadd() { git add "${@:--A}" }
alias grestore='git restore .'
alias gstash='git stash'
alias gpop='git stash pop'
alias greset='git reset --hard'

# Branch
gbranch() { [ $# -eq 0 ] && git branch || git switch -c "$@" }
alias gbranchrm='git branch -D'
alias gbranchmv='git branch -m'
gswitch() { git switch "${@:--}" }
_gswitch() {
  local -a refs
  refs=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags 2>/dev/null)"})
  _describe 'branch' refs
}
compdef _gswitch gswitch
gprune() { git fetch -p && git branch --no-color -vv | awk '/: gone]/{print $1}' | xargs -n 1 git branch -D 2>/dev/null }

# Rebase
grebase() { git -c rebase.instructionFormat='%s%nexec GIT_COMMITTER_DATE="%cD" git commit --amend --no-edit' rebase -i ${1:-main} }
grebasen() { grebase HEAD~${1:-1} }
gcontinue() { local d=$(git rev-parse --git-dir); if [[ -d "$d/rebase-merge" || -d "$d/rebase-apply" ]]; then git rebase --continue; elif [[ -f "$d/MERGE_HEAD" ]]; then git merge --continue; elif [[ -f "$d/CHERRY_PICK_HEAD" ]]; then git cherry-pick --continue; else echo "Nothing to continue"; fi }
gabort() { local d=$(git rev-parse --git-dir); if [[ -d "$d/rebase-merge" || -d "$d/rebase-apply" ]]; then git rebase --abort; elif [[ -f "$d/MERGE_HEAD" ]]; then git merge --abort; elif [[ -f "$d/CHERRY_PICK_HEAD" ]]; then git cherry-pick --abort; else echo "Nothing to abort"; fi }

# Merge
alias gmerge='git merge'

# Cherry-pick
alias gpick='git cherry-pick'
