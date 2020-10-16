### Init servers config

```
ansible-playbook 00-init.yml -l test
```

### SSL and kubeconfigs

Voir [ssl-kubeconfig](ssl-kubeconfig/README.md)

### Install components

```
ansible-playbook 01-etcd.yml -l test
```
