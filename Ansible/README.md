# Ansible Configuration

This folder contains Ansible playbooks for configuring infrastructure.

## Prerequisites

- Ansible installed (>= 2.9)
- SSH access to target servers
- SSH key configured

## Usage

### Test Connection
```bash
ansible all -m ping
```

### Run Playbook
```bash
ansible-playbook webserver.yml
```

### Run with Specific Inventory
```bash
ansible-playbook -i inventory.ini webserver.yml
```

### Check Mode (Dry Run)
```bash
ansible-playbook webserver.yml --check
```

## Files

- `webserver.yml` - Main playbook for web server setup
- `inventory.ini` - Inventory file (update with your IPs)
- `ansible.cfg` - Ansible configuration
