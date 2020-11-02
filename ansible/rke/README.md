# Configure

Copy then edit gateway, domain...

```
cp group_vars/all.yml.template group_vars/all.yml
```

# Install RancherOS

On each worker|controller nodes
- Boot RancherOS iso
- Configure network
To configure static ip
```
sudo ros config set rancher.network.interfaces.eth0.address X.X.X.X/24
sudo ros config set rancher.network.interfaces.eth0.gateway X.X.X.Y
sudo ros config set rancher.network.interfaces.eth0.dhcp false
sudo system-docker restart network
```
- Change to ubuntu console with
```
sudo ros console switch ubuntu -f
sudo apt update
sudo apt install python -y
```
- Change default ``rancher`` password
```
sudo passwd rancher
```
Then

```
ansible-playbook 00-configure.yml -k
# enter rancher password
# it will fail with unreachable status du to reboot, that's normal
```

**RKE** : Generate RKE config based on ansible hosts file
```
ansible-playbook 01-local.yml
```
Then run rke manually with
```
cd cluster
./rke up
```
Test with
```
kubectl --kubeconfig ./kube_config_cluster.yml get nodes
```
