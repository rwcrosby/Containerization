# K8S Installation

Based on: https://buildvirtual.net/deploy-a-kubernetes-cluster-using-ansible/

## Building a base box

- Basic install, system with two network interfaces, one hostonly

- Packages

    ```shell
    su -c "apt-get install sudo network-manager avahi-daemon"
    su -c "/usr/sbin/usermod -aG sudo rcrosby
    ```

- Add base user to sudoers file

    ```shell
    rcrosby ALL=(ALL) NOPASSWD: ALL
    ```

- Log out, ssh should be available

## Create clone of the base box

- Generate new mac addresses

- Set hostname

    https://linuxhandbook.com/debian-change-hostname/


    ```shell
    hostnamectl set-hostname new_hostname
    ```

    Check also /etc/hosts

- reboot

## Create the k8s environment

In the `2_Kubernetes/ansible` directory

- Create the environment

    ```
    ansible-playbook k8s_setup.yaml`--extra-vars ansible-password=xxx
    ```

# `kubectl` Commands

- List all pods in all namespaces

    ```
    kubectl get pods --all-namespaces
    ```

# Notes

- On a new host, make sure the ssh keys have been uploaded via `ansible-playbook playbook_k8s_install.yaml`

- Reinstalled the ansible vmware plugin: https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation
    - Had to restart the plugin via launchctl:
    ```
    sudo launchctl load -w com.vagrant.vagrant-vmware-utility
    ```

- Pinned IP addresses for the master and worker1 to 192.168.11.101 and 102

    - Need to figure out how to parameterize
    - Want to set in `/etc/hosts` on the machines and use the names 


<!-- ----------------------------------- -->


- Get the box ip addresses into the local environment

    `../Get_VM_IPs.sh > vm_ip_addrs`


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

    https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management

    or, on MacOs:

    `brew install kubectl`

- In the `2_kubernetes/k8s_boxes` directory:

    - Copy master's .kube directory

        `scp -r kube@$K8S_MASTER_IP:/home/kube/.kube .`

    - Link to the local config directory

        `ln -s $PWD/.kube ~/.kube`

## Kubernetes Dashboard

- Deploy the dashboard: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

    ```
    ansible-playbook playbook_k8s_dashboard.yaml
    ```

- Dashboard is accessible:

    - Start proxy for the dashboard

        ```
        kubectl proxy
        ```

    - http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

    - Token from `.\dashboard_token.txt

## Portainer

- Create the service

    ```
    kubectl apply -f https://downloads.portainer.io/ce2-18/portainer-agent-k8s-lb.yaml
    ```

- Add the ip address of the host to deal with the load-balancer

    ```
    kubectl patch svc portainer-agent -n portainer -p '{"spec": {"type": "LoadBalancer", "externalIPs":["$K8S_MASTER_IP"]}}'
    ```

