# Next Steps

- <2023-08-07 Mon 18:42> From cri-o to containerd
    - <2023-08-10 Thu 00:40> Unable to get containerd working, sticking with cri-o
- <2023-08-07 Mon 18:43> From calico to flannel
- <2023-08-07 Mon 18:43> Multi-pod deployment
    - App with database
- <2023-08-07 Mon 18:45> k3s version of the cluster

# K8S Installation

Based on: https://buildvirtual.net/deploy-a-kubernetes-cluster-using-ansible/

## Building a base box

- Basic install

- Packages

    ```shell
    su -c "apt update"
    su -c "apt-get install sudo network-manager avahi-daemon tmux"
    ```

- Create user sudo file `\etc\sudoers.d\rcrosby`

    ```
    rcrosby ALL=(ALL) NOPASSWD: ALL
    ```

- Setup ssh key exchange

    ```shell
    ssh-copy-id hostname.local
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

- Create new machine keys

    ```shell
    sudo -i
    cd /etc/ssf
    rm ssh_host_*
    ssh-keygen -A
    ```

- reboot

## Create the k8s environment

In the `2_Kubernetes/ansible` directory

- Create the environment

    ```
    ansible-playbook k8s_setup.yaml`--extra-vars ansible-password=xxx
    ```

## Local support for kubectl

Based on: https://medium.com/@raj10x/configure-local-kubectl-to-access-remote-kubernetes-cluster-ee78feff2d6d

- Install kubectl locally

    https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management

    or, on MacOs:

    `brew install kubectl`

- Kubeneters config has been copied to `ansible\config`

    - `.envrc` is set to export `KUBECONFIG`

### `kubectl` Commands

- List all pods in all namespaces

    ```
    kubectl get pods --all-namespaces
    ```

-  Allowing pods on the master node

    https://computingforgeeks.com/how-to-schedule-pods-on-kubernetes-control-plane-node/?expand_article=1


    ```shell
    kubectl taint nodes --all node-role.kubernetes.io/control-plane- 
    ```

## Kubernetes Dashboard

- Start proxy for the dashboard

    ```
    kubectl proxy
    ```

- http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login


- Token from `.\dashboard_token.txt

# Notes

- <2023-08-03 Thu 20:37> Appears that the ip addresses for the pods are the enp0s3 addresses

    - Reset the cluster
    - Rebuild through k8s install
    - Init the cluster with the nat interface down 

        ```shell
        sudo ip link set enp0s3 down
        sudo systemctl restart networking.service
        sudo kubeadm init
        ```

    - Verified that pods have the correct ip's

        ```shell
        sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl get pods --all-namespaces -o wide
        ```

    - Restarted the net interface, networking service

    - Rebooted

        Came up with the nat ip's

        ```shell
        sudo nmcli con show
        sudo nmcli con down uuid
        sudo nmcli con up uuid
        sudo kubeadm config images pull
        sudo ip link set enp0s3 down
        sudo kubeadm init
        sudo systemctl restart networking.service
        sudo ip route add default via 192.168.56.1 dev enp0s8
        ```

    - Copy the admin.conf to the ~/.kube directory

- <2023-08-07 Mon 17:58> Network is operational
    - dhcp on both interfaces
    - avahi providing dns

- <2023-08-10 Thu 16:16> mDNS on WSL2
    - Worked when the avahi service on WSL was disabled, used windows native zeroconf
    - https://github.com/microsoft/WSL/issues/5944