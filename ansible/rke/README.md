Prepare environment with
```
ansible-playbook 00-configure.yml
```

**RKE** : Generate RKE config based on ansible hosts file
```
ansible-playbook 01-local.yml
```

