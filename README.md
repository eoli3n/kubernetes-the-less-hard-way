IN PROGRESS

# Kubernetes The (Less) Hard Way

Ansible playbooks to learn how to host Kubernetes on premise.
Kind of between [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) and [KubeSpray](https://github.com/kubernetes-sigs/kubespray).

## VMs provisionning

| Hostname        | OS for Hard Way     | OS for Rancher |
|-----------------|---------------------|----------------|
| k8s-controller1 | Ubuntu Server 20.04 | RancherOS      |
| k8s-controller2 | Ubuntu Server 20.04 | RancherOS      |
| k8s-controller3 | Ubuntu Server 20.04 | RancherOS      |
| k8s-worker1     | Ubuntu Server 20.04 | RancherOS      |
| k8s-worker2     | Ubuntu Server 20.04 | RancherOS      |
| k8s-worker3     | Ubuntu Server 20.04 | RancherOS      |
| k8s-haproxy     | Debian 10           | Debian 10      |

## Configuration

Create dirs and copy configuration template files.
```
mkdir -p ssl/csr kubeconfigs
cp ansible/hosts.template ansible/hosts
cp ansible/group_vars/all.yml.template ansible/group_vars/all.yml
```
Add all hostnames in ``ansible/hosts``.
Configure vars in ``ansible/group_vars/all.yml``.
- Domain
- Cluster Name

## Network and DNS

All hosts needs a private IP on the same subnet.
Create DNS or ``hosts`` file entries for each VM.

## Firewall

All trafic between VMs should not be filtered.
To access services from outside, you should open in your firewall:

| Service        | Port     | Destination |
|----------------|----------|-------------|
| kube-apiserver | 6443/tcp | k8s-haproxy |

## Run Ansible playbooks
Please read playbooks before running.

Install SSH, authorize your SSH public key, then test if VMs are reachable.
```
ansible all -m ping
```

##### Hard way
Read [hard-way](ansible/hard-way).

##### Rancher way
Read [rancher](ansible/rancher).
