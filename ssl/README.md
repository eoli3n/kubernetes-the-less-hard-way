### Install

```
go get -u github.com/cloudflare/cfssl/cmd/cfssl
go get -u github.com/cloudflare/cfssl/cmd/cfssljson
```

### Generate CSRs

```
./gen-csr-json.sh
```

### Generate Certs

```
./gen-certs.sh
```

### Distribute

```
# Workers
for instance in worker1 worker2 worker3; do
  scp ca.pem ${instance}-key.pem ${instance}.pem root@tspeda-k8s-${instance}.infra.umontpellier.fr:~/
done

# Controllers
for instance in controller1 controller2 controller3; do
  scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem root@tspeda-k8s-${instance}.infra.umontpellier.fr:~/
done
```
