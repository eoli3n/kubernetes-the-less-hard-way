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
Returns
```
tspeda-k8s-controller2.infra.umontpellier.fr | CHANGED | rc=0 >>
dd5995046894cdd4, started, tspeda-k8s-controller3, https://162.38.60.203:2380, https://162.38.60.203:2379, false
ec778b58d61b4683, started, tspeda-k8s-controller1, https://162.38.60.201:2380, https://162.38.60.201:2379, false
f1c47e23a339d1cf, started, tspeda-k8s-controller2, https://162.38.60.202:2380, https://162.38.60.202:2379, false
tspeda-k8s-controller3.infra.umontpellier.fr | CHANGED | rc=0 >>
dd5995046894cdd4, started, tspeda-k8s-controller3, https://162.38.60.203:2380, https://162.38.60.203:2379, false
ec778b58d61b4683, started, tspeda-k8s-controller1, https://162.38.60.201:2380, https://162.38.60.201:2379, false
f1c47e23a339d1cf, started, tspeda-k8s-controller2, https://162.38.60.202:2380, https://162.38.60.202:2379, false
tspeda-k8s-controller1.infra.umontpellier.fr | CHANGED | rc=0 >>
dd5995046894cdd4, started, tspeda-k8s-controller3, https://162.38.60.203:2380, https://162.38.60.203:2379, false
ec778b58d61b4683, started, tspeda-k8s-controller1, https://162.38.60.201:2380, https://162.38.60.201:2379, false
f1c47e23a339d1cf, started, tspeda-k8s-controller2, https://162.38.60.202:2380, https://162.38.60.202:2379, false
```
