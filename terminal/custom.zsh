# Avoid issues with `gpg` as installed via Homebrew.
export GPG_TTY=`tty`

gitrei() {
  local ref=${1:-main}
  git -c rebase.instructionFormat='%s%nexec GIT_COMMITTER_DATE="%cD" git commit --amend --no-edit' rebase -i $ref
}
