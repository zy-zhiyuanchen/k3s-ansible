# Ansible for K3s

This is a customizable Ansible collection to install and manage [K3s](https://k3s.io/), the lightweight Kubernetes distribution, on servers and agents. It allows for the rapid deployment of single-node or high-availability (HA) clusters with integrated support for additional components like Cilium, Cert-Manager, and ArgoCD.

This project is forked from the official [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible) and has been modified for custom use cases.

## Key Features

- **Automated K3s Installation**: Deploys K3s on server and agent nodes.
- **HA Cluster Support**: Configure multiple servers for a high-availability control plane.
- **Integrated Add-ons**:
    - **Cilium CNI**: Installs Cilium for networking, with options for BGP and Hubble observability.
    - **Cert-Manager**: Sets up Cert-Manager for automated TLS certificate management.
    - **ArgoCD**: Deploys ArgoCD for GitOps-based continuous delivery.
- **Cluster Management**: Includes playbooks to upgrade K3s versions and reset/uninstall the cluster.
- **Air-Gap Support**: Can be used in environments without internet access.
- **Customizable Configuration**: Easily configure K3s, components, and networking via Ansible variables.

## System Requirements

### Control Node (where you run Ansible)
- **Ansible**: `ansible-core` >= 2.12
- **Ansible Collections**: The following collections are required and can be installed from `collections/requirements.yml`:
    - `community.general`
    - `ansible.posix`
    - `kubernetes.core`
- **Python**: Python 3.x

### Target Nodes (where K3s will be installed)
- **Operating System**: A modern Linux distribution (e.g., Ubuntu, CentOS, RHEL, Debian, Raspbian).
- **Hardware**:
    - **Servers**: At least 1 CPU and 1GB of RAM.
    - **Agents**: At least 1 CPU and 512MB of RAM.
- **Networking**: Nodes should have network connectivity to each other. For Cilium BGP, proper network configuration is required.

## Basic Usage

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd k3s-ansible
```

### 2. Install Ansible Dependencies
Install the required Ansible collections:
```bash
ansible-galaxy collection install -r collections/requirements.yml
```

### 3. Configure Your Inventory
Edit the `inventory.yml` file to define your server and agent nodes.

**Example for a single server:**
```yaml
k3s_cluster:
  children:
    server:
      hosts:
        192.168.2.119:  # Replace with your server's IP
  vars:
    ansible_user: myuser # Replace with your SSH user
    k3s_version: v1.28.14+k3s1
    token: "your-secret-token" # A secure, random string
    api_endpoint: "192.168.2.119" # Should match your first server's IP
```

### 4. Customize Installation (Optional)
You can override default variables in your `inventory.yml` file to customize the cluster.

**Example: Disable Traefik and enable Cilium with BGP**
```yaml
k3s_cluster:
  # ... (host definitions)
  vars:
    # ... (ansible_user, k3s_version, etc.)

    # Enable/disable components
    install_cilium: true
    install_certmgr: true
    install_argocd: true

    # K3s config to disable default CNI and proxy
    server_config_yaml: |
      disable:
        - servicelb
        - traefik
        - network-policy
      flannel-backend: none
      disable-network-policy: true
      disable-kube-proxy: true

    # Cilium BGP configuration
    cilium_bgp: true
    cilium_bgp_local_asn: 65000
    cilium_bgp_peer_asn: 65001
    cilium_bgp_lb_cidr: "192.168.31.0/24"
```

### 5. Run the Installation Playbook
Execute the main playbook to create your cluster:
```bash
ansible-playbook -i inventory.yml playbooks/site.yml
```

