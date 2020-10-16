#!/bin/bash

# Certificate Authority
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# Client and Server Certificates
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

# Kubelet Client Certificates
for instance in worker1 worker2 worker3; do
  EXTERNAL_IP=$(dig +short tspeda-k8s-haproxy.infra.umontpellier.fr | tail -n1)
  INTERNAL_IP=$(dig +short tspeda-k8s-${instance}.infra.umontpellier.fr | tail -n1)
  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
    -profile=kubernetes \
    ${instance}-csr.json | cfssljson -bare ${instance}
done

# Controller Manager Client Certificate
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

# Kube Proxy Client Certificate
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

# Scheduler Client Certificate
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

# Kubernetes API Server Certificate
KUBERNETES_PUBLIC_ADDRESS=$(dig +short tspeda-k8s-haproxy.infra.umontpellier.fr | tail -n1)
KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
KUBERNETES_CONTROLLERS=162.38.60.201,162.38.60.202,162.38.60.203
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,${KUBERNETES_CONTROLLERS},${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

# Service Account Key Pair
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

# Final check
if [[ $(ls *.pem | wc -l) -eq 20 ]]
then
  echo "ok"
else
  echo "not ok"
fi
