#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
# CODE BY RØÐ
# PRECONDITIONS
# 1)
# make sure the file is executable
# chmod +x {file-name}.sh
#
# 2)
# Your password may be necessary for some packages
#
# 3)
# https://docs.brew.sh/Installation#macos-requirements

# helpers 
function echo_ok() { echo -e '\033[1;32m'"$1"'\033[0m'; }
function echo_warn() { echo -e '\033[1;33m'"$1"'\033[0m'; }
function echo_error() { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

# install xcode and tools!
echo_ok "Installing Xcode"
if [[ ${XCODEINSTALLED} == "" ]]; then
  echo "Installing Xcode"
  xcode-select --install
fi


# find the CLI Tools update
echo_ok "find CLI tools update"
PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n') || true

# install it
if [[ ! -z "$PROD" ]]; then
  softwareupdate -i "$PROD" --verbose
fi

# Check for Homebrew, install if not installed
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
if hash brew &>/dev/null; then
	echo_ok "Homebrew already installed. Getting updates..."
	brew update
	brew doctor
else
	echo_warn "Installing homebrew..."
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Upgrade brew
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
brew tap homebrew/dupes
brew install coreutils
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-which --with-default-names
brew install gnu-grep --with-default-names

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

# Install packages
PACKAGES=(
  bash-completion
  bash-git-prompt
  mackup
  shellcheck
  cask
  git
  curl
  node
  tree
  wget
  youtube-dl
  zsh
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
  speedtest-cli
  tmux
  npm
  nvm
  yarn
  yarn-completion
  typescript
)

# Packages descriptions
#
# bash-completion =
# bash-git-prompt =
# mackup =
# shellcheck =
# cask =
# git =
# curl =
# node =
# tree = 
# wget =
# youtube-dl =
# zsh =
# zsh-autosuggestions =
# zsh-completions =
# zsh-syntax-highlighting =
# speedtest-cli =
# tmux =
# npm =
# nvm =
# yarn =
# yarn-completion =
# typescript = 

echo_ok "Installing packages..."
brew install "${PACKAGES[@]}"

echo_ok "Cleaning up..."
brew cleanup

echo_ok "Installing cask..."
# brew install caskroom/cask/brew-cask
brew tap caskroom/cask

CASKS=(
	alfred
	appcleaner
	appzapper
	cakebrew
	flycut
	github
	google-chrome
	iterm2
	skype
	slack
	sourcetree
	spotify
	transmission
	visual-studio-code
	vlc
  figma
)

echo_ok "Installing cask apps..."
brew cask install "${CASKS[@]}"

# brew install cask-versions
echo_ok "Installing cask-versions..."
brew tap homebrew/cask-versions

CASKS-VERSIONS=(
	firefox-developer-edition

)

echo_ok "Installing cask-versions apps..."
brew cask install "${CASKS-VERSIONS[@]}"

# brew cask quicklook
echo_ok "Installing QuickLook Plugins..."
brew cask install \
	qlcolorcode qlmarkdown qlprettypatch qlstephen \
	qlimagesize \
	quicklook-csv quicklook-json epubquicklook

# Install fonts
echo_ok "Installing fonts..."
brew tap caskroom/fonts
FONTS=(
	font-clear-sans
	font-consolas-for-powerline
	font-dejavu-sans-mono-for-powerline
	font-fira-code
	font-fira-mono-for-powerline
	font-inconsolata
	font-inconsolata-for-powerline
	font-liberation-mono-for-powerline
	font-menlo-for-powerline
	font-roboto
)
brew cask install "${FONTS[@]}"

# Install ZSH
echo_ok "Installing oh my zsh..."

if [[ ! -f ~/.zshrc ]]; then
	echo ''
	echo '##### Installing oh-my-zsh...'
	curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

	cp ~/.zshrc ~/.zshrc.orig
	cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
	chsh -s /bin/zsh
fi

# Github configuration
echo_ok "Configuring Github"

if [[ ! -f ~/.ssh/id_rsa ]]; then
	echo ''
	echo '##### Please enter your github username: '
	read github_user
	echo '##### Please enter your github email address: '
	read github_email

	# setup github
	if [[ $github_user && $github_email ]]; then
		# setup config
		git config --global user.name "$github_user"
		git config --global user.email "$github_email"
		git config --global github.user "$github_user"
		# git config --global github.token your_token_here
		git config --global color.ui true
		git config --global push.default current
		# VS Code support
		git config --global core.editor "code --wait"

		# set rsa key
		curl -s -O http://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
		chmod u+x git-credential-osxkeychain
		sudo mv git-credential-osxkeychain "$(dirname $(which git))/git-credential-osxkeychain"
		git config --global credential.helper osxkeychain

		# generate ssh key
		cd ~/.ssh || exit
		ssh-keygen -t rsa -C "$github_email"
		pbcopy <~/.ssh/id_rsa.pub
		echo ''
		echo '##### The following rsa key has been copied to your clipboard: '
		cat ~/.ssh/id_rsa.pub
		echo '##### Follow step 4 to complete: https://help.github.com/articles/generating-ssh-keys'
		ssh -T git@github.com
	fi
fi

# Install VSCode extensions
echo_ok "Installing VS Code Extensions..."

VSCODE_EXTENSIONS=(
	AlanWalk.markdown-toc
	CoenraadS.bracket-pair-colorizer
	DavidAnson.vscode-markdownlint
	DotJoshJohnson.xml
	EditorConfig.EditorConfig
	Equinusocio.vsc-material-theme
	HookyQR.beautify
	James-Yu.latex-workshop
	PKief.material-icon-theme
	PeterJausovec.vscode-docker
	Shan.code-settings-sync
	Zignd.html-css-class-completion
	akamud.vscode-theme-onedark
	akmittal.hugofy
	anseki.vscode-color
	arcticicestudio.nord-visual-studio-code
	aws-scripting-guy.cform
	bungcip.better-toml
	christian-kohler.npm-intellisense
	christian-kohler.path-intellisense
	codezombiech.gitignore
	dansilver.typewriter
	dbaeumer.jshint
	donjayamanne.githistory
	dracula-theme.theme-dracula
	eamodio.gitlens
	eg2.vscode-npm-script
	ipedrazas.kubernetes-snippets
	loganarnett.lambda-snippets
	lukehoban.Go
	mohsen1.prettify-json
	monokai.theme-monokai-pro-vscode
	ms-python.python
	ms-vscode.azure-account
	msjsdiag.debugger-for-chrome
	robertohuertasm.vscode-icons
	robinbentley.sass-indented
	waderyan.gitblame
	whizkydee.material-palenight-theme
	whtsky.agila-theme
	zhuangtongfa.Material-theme
)

if hash code &>/dev/null; then
	echo_ok "Installing VS Code extensions..."
	for i in "${VSCODE_EXTENSIONS[@]}"; do
		code --install-extension "$i"
	done
fi

# OSX Configuration
echo_ok "Configuring OSX..."

# Set fast key repeat rate
# The step values that correspond to the sliders on the GUI are as follow (lower equals faster):
# KeyRepeat: 120, 90, 60, 30, 12, 6, 2
# InitialKeyRepeat: 120, 94, 68, 35, 25, 15
defaults write NSGlobalDomain KeyRepeat -int 6
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Require password as soon as screensaver or sleep mode starts
# defaults write com.apple.screensaver askForPassword -int 1
# defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Expanded Save menu
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expanded Print menu
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable "natural" scroll
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo_ok 'Running OSX Software Updates...'
sudo softwareupdate -i -a

echo_ok "Creating folder structure..."
[[ ! -d Workspace ]] && mkdir DEV     

echo_ok "Bootstrapping complete"