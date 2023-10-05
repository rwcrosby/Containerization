# Containerization

    Note: assumes that the registry and portainer containers from SharedEnvironment are running

## 0_setup

Provision the VMs to be used for the cluster. Assumes VMs already exist and networking is in place.

## 1_Containers

Containerization samples

### 2_cpp_minimized

Need to install 

- glibc-static
- libstdc++-static

### 7_python_jupyter

Need to specify `:z` on the mounted directory to allow write access.

## 2_Kubernetes

### 1 - A simple three container environment using compose

### 2 - Simple three pod environment

- <2023-09-17 Sun 09:00> Cluster on MacOS

    - Using fedora (arm cri-o is available)
    - Swapoff doesn't appear to work in an ansible script (but does from the command line)
    - Need iproute-tc package
    - Disable firewall
    - /etc/resolve.conf is pointing to a stub, kubelet needs to point to /run/systemd/resolve/resolve.conf
    - got master working, has to change to flannel, calico didn't have a full set of arm pods

    - Cloned creating k8s-2
    - Had to enable mdns in https://bbs.archlinux.org/viewtopic.php?id=244754


- <2023-09-20 Wed 06:24> Getting the app working

    - Disabled selinux (`\etc\selinux\config`) to get pvc mountable
        https://www.redhat.com/sysadmin/container-permission-denied-errors
    - Created local storage class

- <2023-09-20 Wed 09:55> IT WORKS!

    - Revised nodePorts to be consistent

- <2023-09-20 Wed 07:47> Flask app

    - Pointed to mysql node instead of db node
    - `podman save localhost/flaskapp -o flaskapp.tar`
    - `scp flaskapp.tar k8s-1.local:~`

    - pinging repo works (need to make sure firewalls are disabled)
        `curl http://lily-arm.local:5000/v2/_catalog`

    - Allowing insecure registries (on each node)
        https://stackoverflow.com/questions/65681045/adding-insecure-registry-in-containerd
        ```
        sudo nano /etc/containers/registries.conf
        sudo systemctl restart crio.service
        sudo crictl pull lily-arm.local:5000/flaskapp:latest
        ```

- <2023-09-20 Wed 07:46> Adminer working

    - Pointed to mysql node instead of db node

- <2023-09-20 Wed 06:54> Initialized database

    - Updated service adding nodeport
    - Update init_db.py setting host and port

- <2023-09-21 Thu 07:56>

    - Update dashboard timeout
        https://stackoverflow.com/questions/58012223/how-can-i-make-the-automatic-timed-logout-longer#58126649

- <2023-09-22 Fri 10:35>

    - TODO: Setup container to initialize database (k8s job)
        - File names passed as parameters
        - File contents set as config items

    - TODO: Create secrets for mysql root and user password
        - Pass via environment variables

    - TODO: Investigate exposing flask app on a more typical port (8080)

- <2023-09-29 Fri 10:37>

    - DB initializer run from lily-arm with PyMysql virtualenv
        ```
        python init_db.py --password=example user.sql schema.sql data.sql
        ```

    - Got updated app working in pod
        - `imagePullPolicy: Always` required

- <2023-10-03 Tue 12:59> Created namespace 2-flask

    ```
    kubectl config set-context --current --namespace=2-flask
    ```

- <2023-10-03 Tue 13:35> Working in 2-flask namespace

    - Storage classes and persistent volumes are independent of namespaces

    - Created all objects in the 2-flask namespace

    - Updated `/etc/containers/container.conf` adding insecure registry for lily.local

    - Reloaded crio.service on k8s-2 node

    - Initialized database

        ```
        python init_db.py --password=example schema.sql user.sql data.sql
        ```

    - All working

### 3 - Cluster using configurations, secrets, and init job

- <2023-09-30 Sat 15:52> Broke the db init out into it's own pod as a job

- <2023-09-29 Fri 17:02> Added environment variables and arguments

    - Secret for password

- <2023-10-03 Tue 12:59> Created namespace 3-flask

    ```
    kubectl config set-context --current --namespace=3-flask
    ```
- <2023-10-03 Tue 15:29> Setup

    - Create pv and pvc `mysql_storage.yaml`

    - Started mysql in the 3-flask namespace
        - Accessible in dns as mysql.3-flask

    - Flask app working
        - Cleaned up port assignment

- <2023-10-04 Wed 08:13> Init working

### 4 - CoreOS

- <2023-10-05 Thu 11:33> Building initial image

    - Created base.bu file and converted to ignition format

        - MacOS lily's ssh key
        - Hostname: coreos-base
        - systemd unit to install avahi and python

        ```
        podman run -i --rm quay.io/coreos/butane:release --pretty --strict < coreos-base.bu > coreos-base.ign
        ```

    - Downloaded CoreOS iso and built an iso with the ignition file built it

        https://coreos.github.io/coreos-installer/cmd/iso/

        ```
        podman run --rm -v $(PWD):/data -w /data quay.io/coreos/coreos-installer:release download -s stable -p metal -f iso
        
        podman run --rm -v $(PWD):/data -w /data quay.io/coreos/coreos-installer:release iso customize -o coreos-base.iso --dest-ignition=coreos-base.ign --dest-device=/dev/nvme0n1 fedora-coreos-38.20230918.3.0-live.aarch64.iso
        ```

    - Setup VM, booted from iso

        - Need to disable cd rom after install
        - Change hostname after first boot
            `sudo hostnamectl hostname blahblah`
        - Need to reboot installed system to get avahi running 

    - Enable mdns on all nodes

        ```
        sudo nano /etc/systemd/resolved.conf

        MulticastDNS=yes

        ```

- <2023-10-05 Thu 14:11> K3S Server Installation

    - Installed https://github.com/k3s-io/k3s-selinux/releases/download/v1.4.stable.1/k3s-selinux-1.4-1.el8.noarch.rpm

    ```
    sudo -i
    export K3S_KUBECONFIG_MODE="644"
    export INSTALL_K3S_EXEC=" --disable servicelb --disable traefik"

    curl -sfL https://get.k3s.io | sh -
    ```

    - Get node token

    ```
    K10411ea3ddb97d7ce0e85e218ecad7b449edc926d9478510a85fd27c27214f1611::server:7cdeb9743d07d5c798559f00280de5dc
    ```

- <2023-10-05 Thu 14:31> K3S Worker Installation

    ```
    export K3S_KUBECONFIG_MODE="644"
    export K3S_URL="https://k3s-1.local:6443"
    export K3S_TOKEN="K10411ea3ddb97d7ce0e85e218ecad7b449edc926d9478510a85fd27c27214f1611::server:7cdeb9743d07d5c798559f00280de5dc"

    curl -sfL https://get.k3s.io | sh -
    ```

- <2023-10-05 Thu 15:39> Remote access

    - Downloaded `/etc/rancher/k3s/k3s.yaml`
    - Pointed KUBECONFIG to downloaded file in `.envrc`

# References

https://testdriven.io/blog/running-flask-on-kubernetes/