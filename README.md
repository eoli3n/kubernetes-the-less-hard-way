IN PROGRESS

# Kubernetes The (Less) Hard Way

Ansible playbooks to learn how to host highly available Kubernetes cluster on premise with no SPOF.  
- [Hard Way](ansible/hard-way) is kind of between [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) and [KubeSpray](https://github.com/kubernetes-sigs/kubespray), it automates cluster install from scratch: it is a sandbox to learn how each components works.  
- [RKE](ansible/rke) automates production ready cluster install with [Rancher Kubernetes Engine](https://rancher.com/docs/rke/latest/en/) on top of [RancherOS hosts](https://rancher.com/docs/os/v1.x/en/). It has distributed persistent storage, container registry, true high availability with no Single Point Of Failure, ...  

## VMs provisionning

| Hostname          | OS for Hard Way     | OS for Rancher |
|-------------------|---------------------|----------------|
| k8s-controller1   | Ubuntu Server 20.04 | RancherOS      |
| k8s-controller2   | Ubuntu Server 20.04 | RancherOS      |
| k8s-controller3   | Ubuntu Server 20.04 | RancherOS      |
| k8s-worker1       | Ubuntu Server 20.04 | RancherOS      |
| k8s-worker2       | Ubuntu Server 20.04 | RancherOS      |
| k8s-worker3       | Ubuntu Server 20.04 | RancherOS      |
| k8s-loadbalancer1 | Debian 10           | Debian 10      |
| k8s-loadbalancer2 | Debian 10           | Debian 10      |
| k8s-storage1      | Debian 10           | Debian 10      |
| k8s-storage2      | Debian 10           | Debian 10      |
| k8s-storage3      | Debian 10           | Debian 10      |

## Network and DNS

All hosts needs a private IP on the same subnet.  
Create DNS or ``hosts`` file entries for each VM.  
Each VMs and your client should be able to resolve all hostnames.  

## Inventory

```
cp ansible/hosts.template ansible/hosts
```
Add all hostnames in ``ansible/hosts``.

## Firewall

All trafic between VMs should not be filtered.  
To access services from outside, you should open in your firewall:  

| Service        | Port           | Destination |
|----------------|----------------|-------------|
| ssh            | 22/tcp         | *           |
| kube-apiserver | 6443/tcp       | k8s-haproxy |
| ingress        | 80/tcp 443/tcp | k8s-haproxy |

## Run Ansible playbooks

Please read playbooks before running.  

Install SSH, authorize your SSH public key, then test if VMs are reachable.  
```
ansible all -m ping
```

##### Hard way
Read [hard-way](ansible/hard-way).

##### RKE way
Read [rke](ansible/rke).
