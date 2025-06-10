# config.nu
#
# Installed by:
# version = "0.104.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

$env.config.show_banner = false

$env.config.table.missing_value_symbol = ""

# Configure carapace shell completions
# https://pixi.carapace.sh/
# source ~/.cache/carapace/init.nu

$env.PROMPT_COMMAND = {
  $env.pwd
    | path expand
    | str replace $env.home '~'
    | $"[nu] (ansi red_bold)\((if CLUSTER in $env {$env.CLUSTER} else {})\) (ansi green_bold)($in)(ansi reset)"
}

# ##############################
# Aliases & Commands
# ##############################

# Interactive file operations
alias rm = rm -i
alias cp = cp -i
alias mv = mv -i

# Openstack aliases
alias ofl = openstack floating ip list
alias ofc = openstack floating ip create public
alias osl = openstack server list
alias onl = openstack network list
alias ovl = openstack volume list

# K8s and nodes
alias k = kubectl
alias kctl = kubectl
alias sshmain = ssh ubuntu@$"($env.IP)" -L 6443:localhost:6443

# Misc
alias h = history
alias hist = history

source ./nos.nu
source ./kn.nu
