# K8S Installation

Based on: https://buildvirtual.net/deploy-a-kubernetes-cluster-using-ansible/

## On the Vagrant host

In the `2_Kubernetes/k8s_boxes` directory

- Bring the boxes up

    `vagrant up`

- Get the box ip addresses into the local environment

    `Get_VM_IPs.sh > vm_ip_addrs`


## On the Ansible host

In the `2_Kubernetes` directory

- Source the address file into the local environment

    `. k8s_boxes/vm_ip_addrs`

- Set the ssh keys for the vagrant user

    `ansible-playbook playbook_ssh_keys.yaml`

- Create the kube user on the all vms

    `ansible-playbook playbook_users.yaml`

- Install k8s on all vms

    `ansible-playbook playbook_k8s_install.yaml`

- Create the k8s master node

    `ansible-playbook playbook_k8s_master.yaml`

- Join the k8s worker to the master

    `ansible-playbook playbook_k8s_workers.yaml`

## Local support for kubectl

Based on: https://medium.com/@raj10x/configure-local-kubectl-to-access-remote-kubernetes-cluster-ee78feff2d6d

- Install kubectl locally

    `brew install kubectl`

- Copy master's .kube directory

    `scp -r kube@$K8S_MASTER_IP:/home/kube/.kube .`

- Link to the local config directory

    `ln -s $PWD/.kube ~/.kube`

## Portainer

- Create the service

    `kubectl apply -f https://downloads.portainer.io/ce2-18/portainer-agent-k8s-lb.yaml`

- Add the ip address of the host to deal with the load-balancer

    `kubectl patch svc portainer-agent -n portainer -p '{"spec": {"type": "LoadBalancer", "externalIPs":["$K8S_MASTER_IP"]}}'`

# `kubectl` Commands

- List all pods in all namespaces

    `kubectl get pods --all-namespaces`

# Notes

- On a new host, make sure the ssh keys have been uploaded via `ansible-playbook playbook_k8s_install.yaml`
