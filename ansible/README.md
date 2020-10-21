### Run

```
ansible-playbook 00-init.yml
ansible-playbook 00-configure.yml
ansible-playbook 01-controllers.yml -l (test|prod)
ansible-playbook 02-workers.yml -l (test|prod)
ansible-playbook 03-haproxy.yml -l (test|prod)
```
