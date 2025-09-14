# Automated k3s cluster via Ansible

## Introduction

This project is based on the work from official ansible project from k3s: [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible). The default setting is for single server node k3s cluster and with http proxy settings.

## Added components
- Cilium CNI with kube-proxy replacement and with l2 announcement support
- ArgoCD

