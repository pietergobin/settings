# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git 
    kube-ps1
    golang
    kubectl
    )

source $ZSH/oh-my-zsh.sh
PROMPT='$(kube_ps1)'$PROMPT;kubeoff

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias kc='kubectl'
alias kctx='kubectx'
alias kns='kubens'

flogs(){
    # dont enable if kubeoff is set allowing other functions to do other things in their context
    [[ "${KUBE_PS1_ENABLED}" == "off" ]] && return
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
      kubectl logs --help
      return
    fi 
    local pod=$(kubectl get pods -o name | fzf)
    print -s "kubectl logs $pod $*"
    kubectl logs $pod $*
    
}


fdescribe(){
    # dont enable if kubeoff is set
    [[ "${KUBE_PS1_ENABLED}" == "off" ]] && return
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
      kubectl describe --help
      return
    fi
    
    if [ -z "$1" ]; then
        local rtype="$(kubectl api-resources -o name | fzf)"
    else
        local rtype=$1
    fi
    local r=$(kubectl get $rtype -o name | fzf)
    print -s "kubectl describe $r"
    kubectl describe $r

}

pipelines(){
  local gitname="$(git config --get remote.origin.url | rev | cut -d / -f1 | rev)"
  echo "querying azure devops for repo $gitname"
  local pipeline="$(az pipelines list --repository $gitname -o table | fzf --header-lines 2 --layout=reverse | awk '{print $1}')"
  echo $pipeline
  az pipelines runs list --branch $(git rev-parse --abbrev-ref HEAD) \
    -o table \
    --top 10 \
    --pipeline-ids $pipeline | 
    fzf --header-lines 2 \
    --layout reverse \
    --preview 'az pipelines runs show --id {1} -o yamlc' --preview-window down:10:nowrap

}



help(){
    echo "
=== Kubernetes Aliases and Functions ===
Aliases:
  kc    - Short for 'kubectl'
  kctx  - Short for 'kubectx' (switch between Kubernetes contexts)
  kns   - Short for 'kubens' (switch between Kubernetes namespaces)

Functions:
  flogs
    - Interactive pod log viewer
    - Uses fzf to select a pod
    - Pushes kubectl cmd into zsh history
    - Disabled when KUBE_PS1 is off (kubeoff)

  fdescribe [resource-type]
    - Interactive resource descriptor
    - If resource-type is omitted, lets you select from available API resources
    - Uses fzf for interactive selection of resource
    - Pushes kubectl command into zsh history
    - Disabled when KUBE_PS1 is off (kubeoff)

Kubernetes Context Management:
  kubeoff  - Disable Kubernetes prompt integration
  kubeon   - Enable Kubernetes prompt integration

=== ZSH Tips and Tricks ===
Navigation:
  cd -     - Go to previous directory
  ..       - Shorthand for 'cd ..'
  ...      - Shorthand for 'cd ../..'

History:
  !!       - Run last command
  !$       - Use last argument of previous command
  ctrl-r   - Search command history (with fzf integration)

Git (via oh-my-zsh git plugin):
  ga       - git add
  gc       - git commit
  gco      - git checkout
  gst      - git status
  
Oh-My-Zsh Theme:
  Current theme: robbyrussell
  Change theme by editing ZSH_THEME in .zshrc

Active Plugins:
  - git
  - kube-ps1
  - golang

Package Management:
  ASDF is configured for version management
  Shims path is automatically added to PATH
"
}

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH:$HOME/.local/bin"
