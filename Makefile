# Makefile for k3s-ansible

# Default Ansible configuration
ANSIBLE_PLAYBOOK := ansible-playbook
INVENTORY      := -i inventory.yml
VAULT_PASS     := --vault-password-file .vault_pass
PLAYBOOK_DIR   := playbooks

# Base command
ANSIBLE_CMD := $(ANSIBLE_PLAYBOOK) $(INVENTORY) $(VAULT_PASS)

# Get playbook names by stripping the .yml extension from files in playbooks/
PLAYBOOKS := $(patsubst $(PLAYBOOK_DIR)/%.yml,%,$(wildcard $(PLAYBOOK_DIR)/*.yml))

# Phony targets for playbooks
.PHONY: all $(PLAYBOOKS) help cilium argocd

all: help

# Help target to show available commands
help:
	@echo "Usage: make [target] [EXTRA_ARGS=...]"
	@echo ""
	@echo "Available playbook targets:"
	@$(foreach playbook,$(sort $(PLAYBOOKS)),echo "  $(playbook)\t\t- Runs the $(playbook) playbook.";)
	@echo ""
	@echo "Available tagged targets (for site.yml):"
	@echo "  cilium\t\t- Run the site playbook with the 'cilium' tag."
	@echo "  argocd\t\t- Run the site playbook with the 'argocd' tag."
	@echo ""
	@echo "Example with extra arguments:"
	@echo "  make site EXTRA_ARGS=\"--check\""


# Generic rule for playbooks
$(PLAYBOOKS):
	$(ANSIBLE_CMD) $(PLAYBOOK_DIR)/$@.yml $(EXTRA_ARGS)

# Targets for tagged plays in site.yml
cilium:
	$(ANSIBLE_CMD) $(PLAYBOOK_DIR)/site.yml --tags "cilium" $(EXTRA_ARGS)

argocd:
	$(ANSIBLE_CMD) $(PLAYBOOK_DIR)/site.yml --tags "argocd" $(EXTRA_ARGS)
