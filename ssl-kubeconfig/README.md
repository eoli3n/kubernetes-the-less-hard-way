On your host

### Install clients

```
go get -u github.com/cloudflare/cfssl/cmd/cfssl
go get -u github.com/cloudflare/cfssl/cmd/cfssljson
```

### Generate SSL certs and kubeconfigs

```
./gen-csr-json.sh
./gen-certs.sh
./gen-kubeconfigs.sh
./gen-encryption.sh
```

### Distribute to kubernetes nodes

```
# Workers
for instance in worker1 worker2 worker3; do
  scp ca.pem ${instance}-key.pem ${instance}.pem \
  ${instance}.kubeconfig kube-proxy.kubeconfig \
  root@tspeda-k8s-${instance}.infra.umontpellier.fr:~/
done

# Controllers
for instance in controller1 controller2 controller3; do
  scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem \
  admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig \
  encryption-config.yaml \
  root@tspeda-k8s-${instance}.infra.umontpellier.fr:~/
done
```
