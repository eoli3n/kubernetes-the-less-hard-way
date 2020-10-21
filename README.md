### Init

Init shell configuration and ssh keys
```
ansible-playbook 00-init.yml
```

### SSL

Generate Certificate Authority, Certificates, and kubeconfigs
```
ansible-playbook 00-configure.yml
```

### Install components

##### Etcd
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

##### Kubernetes Control Plane
```
ansible-playbook 02-controllers.yml
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

##### HAProxy

```
ansible-galaxy install manala.haproxy -p roles
ansible-playbook 03-haproxy.yml
```
Test with
```
curl --cacert ca.pem https://162.38.60.207:6443/version
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
