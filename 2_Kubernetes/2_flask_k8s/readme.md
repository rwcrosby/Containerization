# Log

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

- <2023-09-20 Wed 06:24> Getting the app working

    - Disabled selinux (`\etc\selinux\config`) to get pvc mountable
        https://www.redhat.com/sysadmin/container-permission-denied-errors
    - Created local storage class

- <2023-09-17 Sun 09:00> Cluster on MacOS

    - Using fedora (arm cri-o is available)
    - Swapoff doesn't appear to work in an ansible script (but does from the command line)
    - Need iproute-tc package
    - Disable firewall
    - /etc/resolve.conf is pointing to a stub, kubelet needs to point to /run/systemd/resolve/resolve.conf
    - got master working, has to change to flannel, calico didn't have a full set of arm pods

    - Cloned creating k8s-2
    - Had to enable mdns in https://bbs.archlinux.org/viewtopic.php?id=244754


