#!/bin/bash

# git
sudo apt-get install git
sudo apt-get install gitk

# vim					# includes cscope and fzf installation, too.
(cd vim && ./install.sh)
# nvim					# includes cscope and fzf installation, too.
(cd nvim && ./install.sh)


# status bar indicator
sudo apt-get install indicator-multiload
# Settings:
#	[$(percent(cpu.inuse))][$(size(mem.user))][$(speed(net.down))/$(speed(net.up))]

sudo apt-get install microcom		# serial communication
sudo apt-get install wireshark		# monitoring network packets
sudo apt-get install colordiff		# color diff results
sudo apt-get install meld		# diff tool with gui
sudo apt-get install unity-tweak-tool	# tweak tool for workspace switcher with hot corner
sudo apt-get install htop		# monitoring
sudo apt-get install tmux		# terminal multiplexer

