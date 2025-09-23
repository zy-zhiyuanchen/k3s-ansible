# Automated k3s cluster via Ansible

## Introduction

This project is based on the work from official ansible project from k3s: [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible). The default setting is for single server node k3s cluster.

## Components
- Cilium CNI installation via helm
- CIlium kube-proxy replacement
- Cilium hubble
- CIlium BGP support, peer Cilium node with Router and advertise LB type svcs in LAN, peer IP address auto-discovery.
- ArgoCD installation via helm

