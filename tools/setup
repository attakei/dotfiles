let dotfiles_dir = `pwd`
let config_dir = $"($env.HOME)/.config"

# Install all global toolchaions
mise i

# TODO: Program to link from any config sub-folders
ln -sf $"($dotfiles_dir)/root/.config/wezterm" $"($config_dir)/"
ln -sf $"($dotfiles_dir)/root/.config/nushell" $"($config_dir)/"
ln -sf $"($dotfiles_dir)/root/.config/mise" $"($config_dir)/"

# Starship
if (not ($'($env.HOME)/.cache/starship/init.nu' | path exists)) {
  mkdir $"($env.HOME)/.cache/starship"
  starship init nu | save -f ~/.cache/starship/init.nu
}
