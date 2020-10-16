#!/bin/bash

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Montpellier",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Herault"
    }
  ]
}
EOF

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Montpellier",
      "O": "system:masters",
      "OU": "IPT",
      "ST": "Herault"
    }
  ]
}
EOF

for instance in worker1 worker2 worker3; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Montpellier",
      "O": "system:nodes",
      "OU": "IPT",
      "ST": "Herault"
    }
  ]
}
EOF
done

cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Montpellier",
      "O": "system:kube-controller-manager",
      "OU": "IPT",
      "ST": "Herault"
    }
  ]
}
EOF

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Montpellier",
      "O": "system:node-proxier",
      "OU": "IPT",
      "ST": "Herault"
    }
  ]
}
EOF

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Montpellier",
      "O": "system:kube-scheduler",
      "OU": "IPT",
      "ST": "Herault"
    }
  ]
}
EOF

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Montpellier",
      "O": "Kubernetes",
      "OU": "IPT",
      "ST": "Herault"
    }
  ]
}
EOF

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Montpellier",
      "O": "Kubernetes",
      "OU": "IPT",
      "ST": "Herault"
    }
  ]
}
EOF
