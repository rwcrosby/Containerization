Based on: https://buildvirtual.net/deploy-a-kubernetes-cluster-using-ansible/

## On the Vagrant host

In the `2_Kubernetes/boxes` directory

- Bring the boxes up

    `vagrant up`

- Get the box ip addresses into the local environment

    `Get_VM_IPs.sh > vm_ip_addrs`


## On the Ansible host

In the `2_Kubernetes` directory

- Source the address file into the local environment

    `. boxes/vm_ip_addrs`

- Set the ssh keys for the vagrant user

    `ansible-playbook playbook_ssh_keys.yaml`

- Create the kube user on the all vms

    `ansible-playbook playbook_users.yaml`

- Install k8s on all vms

    `ansible-playbook playbook_k8s_install.yaml`

- Create the k8s master node

    `ansible-playbook playbook_k8s_master.yaml`
