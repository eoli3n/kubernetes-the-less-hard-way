IN PROGRESS

# Kubernetes The (Less) Hard Way

From https://github.com/kelseyhightower/kubernetes-the-hard-way

The whole process with ansible playbooks hosted on local VMs instead of [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine).

This is not an alternative to ``Kubeadm``, and just designed for learning.

## VMs provisionning

| Hostname        | OS                  |
|-----------------|---------------------|
| k8s-controller1 | Ubuntu Server 20.04 |
| k8s-controller2 | Ubuntu Server 20.04 |
| k8s-controller3 | Ubuntu Server 20.04 |
| k8s-worker1     | Ubuntu Server 20.04 |
| k8s-worker2     | Ubuntu Server 20.04 |
| k8s-worker3     | Ubuntu Server 20.04 |
| k8s-haproxy     | Debian 10           |

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

All hosts needs an private IP on the same subnet.
Create DNS or ``hosts`` file entries for each VM.

## Firewall

All trafic between VMs should not be filtered.
To access services from outside, you should open in your firewall:

| Service        | Port     | Destination |
|----------------|----------|-------------|
| kube-apiserver | 6443/tcp | k8s-haproxy |

## Run Ansible playbooks

Install SSH, authorize your SSH public key, then test if VMs are reachable.
```
ansible all -m ping
```

Please read playbooks before running.

**SSL** : Generate Certificate Authority, Certificates, and kubeconfigs.
```
ansible-playbook 00-configure.yml
```

**Kubernetes Control Plane and etcd** : Install and configure Kubernetes controllers.
```
ansible-playbook 01-controllers.yml
```
Test etcd with
```
ansible controllers -m shell -a "ETCDCTL_API=3 etcdctl member list \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/etcd/ca.pem \
    --cert=/etc/etcd/kubernetes.pem \
    --key=/etc/etcd/kubernetes-key.pem"
```
Returns on each
```
dd5995046894cdd4, started, k8s-controller3, https://X.X.X.X:2380, https://X.X.X.X:2379, false
ec778b58d61b4683, started, k8s-controller1, https://X.X.X.X:2380, https://X.X.X.X:2379, false
f1c47e23a339d1cf, started, k8s-controller2, https://X.X.X.X:2380, https://X.X.X.X:2379, false
```

Test control plane with
```
ansible controllers -m shell -a 'kubectl get componentstatuses --kubeconfig admin.kubeconfig \
  && curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz'
```
Returns on each
```
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-1               Healthy   {"health":"true"}   
etcd-0               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"}   
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Fri, 16 Oct 2020 16:57:04 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: keep-alive
Cache-Control: no-cache, private
X-Content-Type-Options: nosniff
```

**Kubernetes Worker Nodes** : Install and configure Kubernetes worker nodes.
```
ansible-playbook 02-workers
```
Test with
```
ansible controllers -m shell -a "kubectl get nodes --kubeconfig admin.kubeconfig"
```
Returns on each
```
NAME                 STATUS   ROLES    AGE     VERSION
k8s-worker1   Ready    <none>   2m27s   v1.18.6
k8s-worker2   Ready    <none>   2m17s   v1.18.6
k8s-worker3   Ready    <none>   2m17s   v1.18.6
```

**HAProxy** : Install and configure HA proxy in front of controllers.

```
ansible-galaxy install manala.haproxy -p roles
ansible-playbook 03-haproxy.yml
```
Test with
```
curl --cacert ca.pem https://k8s-haproxy:6443/version
```
Returns
```
{
  "major": "1",
  "minor": "18",
  "gitVersion": "v1.18.6",
  "gitCommit": "dff82dc0de47299ab66c83c626e08b245ab19037",
  "gitTreeState": "clean",
  "buildDate": "2020-07-15T16:51:04Z",
  "goVersion": "go1.13.9",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

**Remote Access** : Configure kubectl on your host

```
ansible-playbook 04-remote.yml
```
Test with
```
kubectl get componentstatuses && kubectl get node
```
Returns
```
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"}   
NAME                 STATUS   ROLES    AGE   VERSION
tspeda-k8s-worker1   Ready    <none>   18m   v1.18.6
tspeda-k8s-worker2   Ready    <none>   18m   v1.18.6
tspeda-k8s-worker3   Ready    <none>   18m   v1.18.6
```
