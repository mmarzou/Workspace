.PHONY: install create-env-file create-workspace create-dirs generate-ssh-key configure-git install-software install-brew install-git

WORKSPACE_NAME := Student
WORKSPACE_PATH := $(shell mkdir -p ~/Workspace/$(WORKSPACE_NAME) && cd ~/Workspace/$(WORKSPACE_NAME) && pwd)
DOTENV_PATH := $(WORKSPACE_PATH)/.env
SSH_KEY_PATH := $(WORKSPACE_PATH)/.ssh/$(WORKSPACE_NAME)_rsa
GIT_CONFIG_PATH := $(WORKSPACE_PATH)/.git/config

install: create-env-file create-dirs generate-ssh-key configure-git install-software

create-env-file:
	@echo "Creating .env file..."
	@read -p "Enter your Github First & last name: " USER_NAME; \
	read -p "Enter your Github email address (e.g., johndoe@email.com): " USER_EMAIL; \
	echo "USER_NAME=$$USER_NAME" > $(DOTENV_PATH); \
	echo "USER_EMAIL=$$USER_EMAIL" >> $(DOTENV_PATH)
	@echo ".env file created in $(DOTENV_PATH)"

create-dirs:
	@echo "Creating .ssh and .git directories..."
	mkdir -p $(WORKSPACE_PATH)/.ssh
	mkdir -p $(WORKSPACE_PATH)/.git
	@echo ".ssh and .git directories created."

generate-ssh-key:
	@if [ -f $(SSH_KEY_PATH) ]; then \
		echo "SSH key already exists."; \
	else \
		echo "Generating SSH key..."; \
		ssh-keygen -q -f $(SSH_KEY_PATH) -N ""; \
		echo "SSH key generated."; \
		echo "Copy the following SSH key and add it to your GitHub account:"; \
		cat $(SSH_KEY_PATH).pub; \
		echo "Instructions: https://github.com/settings/keys"; \
	fi

configure-git: configure-git-local configure-git-global

configure-git-local:
	@echo "Configuring local Git..."
	@if [ ! -f $(GIT_CONFIG_PATH) ]; then \
		source $(DOTENV_PATH); \
		echo "[user]\n\tname = $$USER_NAME\n\temail = $$USER_EMAIL\n[core]\n\tsshCommand = \"ssh -i $(SSH_KEY_PATH)\"" > $(GIT_CONFIG_PATH); \
		echo "Local Git configured."; \
	else \
		echo "Local Git config already exists."; \
	fi

configure-git-global:
	@echo "Configuring global Git to include workspace-specific config..."
	touch ~/.gitconfig
	@grep -qxF '[includeif "gitdir:$(WORKSPACE_PATH)/"]' ~/.gitconfig || echo '[includeif "gitdir:$(WORKSPACE_PATH)/"]\n\tpath = $(GIT_CONFIG_PATH)' >> ~/.gitconfig
	@echo "Global Git configured to include workspace-specific config."

install-software: install-brew install-git

install-brew:
	@echo "Checking for Homebrew..."
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@echo "Homebrew installed."
	@eval "$(/opt/homebrew/bin/brew shellenv)"

install-git:
	@echo "Checking for Git..."
	@which git > /dev/null || brew install git
	@echo "Git installed."
