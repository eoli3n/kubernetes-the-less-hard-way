### Init

Init shell configuration and ssh keys
```
ansible-playbook 00-init.yml -l test
```

### SSL

Generate Certificate Authority, Certificates, and kubeconfigs
See [ssl-kubeconfig](ssl-kubeconfig/)

### Install components

##### Etcd
```
ansible-playbook 01-etcd.yml -l test
```
Test with
```
ansible controllers_test -m shell -a "ETCDCTL_API=3 etcdctl member list \
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
ansible-playbook 02-kubernetes-controllers.yml -l test
```
Test with
```
ansible controllers_test -m shell -a 'kubectl get componentstatuses --kubeconfig admin.kubeconfig \
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
ansible-playbook 03-haproxy.yml -l test
```
