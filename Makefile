# Makefile for k3s-ansible

# Prevent accidental target matching from sub-commands
%:
	@:

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
.PHONY: all $(filter-out site,$(PLAYBOOKS)) help site

all: help

# Help target to show available commands
help:
	@echo "Usage: make [target] [sub-target] [EXTRA_ARGS=...]"
	@echo ""
	@echo "Available playbook targets:"
	@$(foreach playbook,$(sort $(PLAYBOOKS)),echo "  $(playbook)\t\t- Runs the $(playbook) playbook.";)
	@echo ""
	@echo "Available site targets:"
	@echo "  site cilium   - Run the site playbook with the 'cilium' tag."
	@echo "  site certmanager   - Run the site playbook with the 'certmanager' tag."
	@echo "  site argocd   - Run the site playbook with the 'argocd' tag."
	@echo ""
	@echo "Example with extra arguments:"
	@echo "  make site cilium EXTRA_ARGS=\"--check\""


# Generic rule for non-site playbooks
$(filter-out site,$(PLAYBOOKS)):
	$(ANSIBLE_CMD) $(PLAYBOOK_DIR)/$@.yml $(EXTRA_ARGS)

# Rule for site playbook with optional sub-target for tags
site:
	$(eval SUBCMD := $(filter-out $@,$(MAKECMDGOALS)))
	$(if $(SUBCMD), \
		$(ANSIBLE_CMD) $(PLAYBOOK_DIR)/site.yml --tags "$(SUBCMD)" $(EXTRA_ARGS), \
		$(ANSIBLE_CMD) $(PLAYBOOK_DIR)/site.yml $(EXTRA_ARGS) \
	)