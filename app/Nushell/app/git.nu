# Run CD to root of git repository.
export def --env git-cd [] {
  mut root = (^git rev-parse --show-toplevel)
  cd $root
}

export alias "git cd" = git-cd
