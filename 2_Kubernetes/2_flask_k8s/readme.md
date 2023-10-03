# Log

- <2023-09-29 Fri 10:37>

    - DB initializer run from lily-arm with PyMysql virtualenv
        ```
        python init_db.py --password=example user.sql schema.sql data.sql
        ```

    - Got updated app working in pod
        - `imagePullPolicy: Always` required

- <2023-09-22 Fri 10:35>

    - TODO: Setup container to initialize database (k8s job)
        - File names passed as parameters
        - File contents set as config items

    - TODO: Create secrets for mysql root and user password
        - Pass via environment variables

    - TODO: Investigate exposing flask app on a more typical port (8080)

- <2023-09-21 Thu 07:56>

    - Update dashboard timeout
        https://stackoverflow.com/questions/58012223/how-can-i-make-the-automatic-timed-logout-longer#58126649

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


