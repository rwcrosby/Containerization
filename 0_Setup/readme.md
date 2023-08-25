# Setting up the background containers

- Ports 5000 (registry) and 9443 (portainer) need to be available

- Make the local registry insecure

    https://podman-desktop.io/docs/getting-started/insecure-registry

    `\etc\containers\registries.conf.d\localhost.conf`

    ```
    [[registry]]
    location = "localhost:5000"
    insecure = true
    ```

- Copy portainer to local registry

    ```shell
    ./docker2local.sh docker.io/portainer/portainer-ce:latest localhost:5000/portainer-ce:latest
    ```


# Hyper-v setup

- Getting network connectibity between a vm and wsl

    https://automatingops.com/allowing-windows-subsystem-for-linux-to-communicate-with-hyper-v-vms

    Bottom line is setting the forwarding enabled on both the wsl and default virtual switches