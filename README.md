IN PROGRESS

# Kubernetes The (Less) Hard Way

From https://github.com/kelseyhightower/kubernetes-the-hard-way

The whole process with ansible playbooks hosted on local VMs instead of [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine).

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

Copy configuration template files.
```
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

**SSL** : Generate Certificate Authority, Certificates, and kubeconfigs.
```
ansible-playbook 00-configure.yml
```

**Etcd** : Install and configure etcd cluster.
```
ansible-playbook 01-etcd.yml -l test
```
Test with
```
ansible controllers -m shell -a "ETCDCTL_API=3 etcdctl member list \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/etcd/ca.pem \
    --cert=/etc/etcd/kubernetes.pem \
    --key=/etc/etcd/kubernetes-key.pem"
```
Returns on each
```
dd5995046894cdd4, started, tspeda-k8s-controller3, https://162.38.60.203:2380, https://162.38.60.203:2379, false
ec778b58d61b4683, started, tspeda-k8s-controller1, https://162.38.60.201:2380, https://162.38.60.201:2379, false
f1c47e23a339d1cf, started, tspeda-k8s-controller2, https://162.38.60.202:2380, https://162.38.60.202:2379, false
```

**Kubernetes Control Plane** : Install and configure Kubernetes controllers.
```
ansible-playbook 01-controllers.yml
```
Test with
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
