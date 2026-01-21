# Avoid issues with `gpg` as installed via Homebrew.
export GPG_TTY=`tty`

gitrei() {
  local ref=${1:-main}
  git -c rebase.instructionFormat='%s%nexec GIT_COMMITTER_DATE="%cD" git commit --amend --no-edit' rebase -i $ref
}

gitprune() {
  git fetch -p && git branch --no-color -vv | awk '/: gone]/{print $1}' | xargs -n 1 git branch -D 2>/dev/null
}
