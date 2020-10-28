Prepare environment with
```
ansible-playbook 00-configure.yml
```

**SSL** : Generate Certificate Authority, Certificates, and kubeconfigs.
```
ansible-playbook 01-local.yml
```

**Kubernetes Control Plane and etcd** : Install and configure Kubernetes controllers.
```
ansible-playbook 02-controllers.yml
```
Test etcd with
```
ansible-playbook tests.yml -v -t etcd
```
Returns on each
```
dd5995046894cdd4, started, k8s-controller3, https://X.X.X.X:2380, https://X.X.X.X:2379, false
ec778b58d61b4683, started, k8s-controller1, https://X.X.X.X:2380, https://X.X.X.X:2379, false
f1c47e23a339d1cf, started, k8s-controller2, https://X.X.X.X:2380, https://X.X.X.X:2379, false
```

Test control plane with
```
ansible-playbook tests.yml -v -t components
```
Returns on each
```
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-1               Healthy   {"health":"true"}   
etcd-0               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"}   
```
Test health with
```
ansible-playbook tests.yml -v -t healthz
```
Returns
```
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Fri, 16 Oct 2020 16:57:04 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: keep-alive
Cache-Control: no-cache, private
X-Content-Type-Options: nosniffA

ok
```

**HAProxy** : Install and configure HA proxy in front of controllers.

```
ansible-galaxy install manala.haproxy -p roles
ansible-playbook 03-haproxy.yml
ansible haproxy -m shell -a "systemctl restart haproxy"
```
Test with
```
ansible-playbook tests.yml -v -t haproxy
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

**Kubernetes Worker Nodes** : Install and configure Kubernetes worker nodes.
By default, it uses ``containerd`` runtime, and ``cni`` network addon.
You can change these by uncommenting specific lines in the playbook.
```
ansible-playbook 04-workers.yml
```
Test with
```
ansible-playbook tests.yml -v -t nodes
```
Returns on each
```
NAME                 STATUS   ROLES    AGE     VERSION
k8s-worker1   Ready    <none>   2m27s   v1.18.6
k8s-worker2   Ready    <none>   2m17s   v1.18.6
k8s-worker3   Ready    <none>   2m17s   v1.18.6
```

**Remote Access** : Configure kubectl on your host

Test with
```
ansible-playbook tests.yml -v -t remote
```

**Network** : Add routes between pod subnets
```
ansible-playbook 05-network.yml
```

Test with
```
ansible-playbook tests.yml -v -t route
```
Returns on each
```
# Where X are pod subnets, and Y default interface of worker
default via $gateway dev ens3 proto static 
X.X.1.0/24 via Y.Y.Y.1 dev ens3 
X.X.2.0/24 dev cnio0 proto kernel scope link src X.X.2.1 linkdown 
X.X.3.0/24 via Y.Y.Y.3 dev ens3
Y.Y.Y.Y/24 dev ens3 proto kernel scope link src Y.Y.Y.2
```

**CoreDNS** : Deploy DNS cluster Add-On
```
ansible-playbook 06-addons.yml -t coredns
```

Test with
```
kubectl get pods -l k8s-app=kube-dns -n kube-system
ansible-playbook tests.yml -v -t coredns
```
Returns
```
NAME                       READY   STATUS    RESTARTS   AGE
coredns-XXXXXXXXXX-XXXXX   1/1     Running   0          105s
coredns-XXXXXXXXXX-XXXXX   1/1     Running   0          105s
###
pod/busybox created
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
pod "busybox" deleted
```
Then see [Kubernetes The Hard Way #Dns Addon verification](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/12-dns-addon.md#verification)

**Metrics** : Deploy metrics server
```
ansible-playbook 06-addons.yml -t metrics
```
Test with
```
kubectl top nodes
```

**Dashboard** : Deploy Webui
```
ansible-playbook 06-addons.yml -t dashboard
kubectl proxy
```
Access at [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)and connect with ``token``.
