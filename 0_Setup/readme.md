# Setting up the background containers

- Ports 5000 (registry) and 9443 (portainer) need to be available

## Local Registry

- Make the local registry insecure

    https://podman-desktop.io/docs/getting-started/insecure-registry

    `\etc\containers\registries.conf.d\localhost.conf`
    ```

    [[registry]]
    location = "localhost:5000"
    insecure = true
    ```

    For MacOS this needs to be done in the podman machine cm

- Pull and save registry image

    ```shell
    podman pull docker.io/registry:latest
    podman save docker.io/library/registry:latest -o registry_arm_latest.tar
    ```

- Copy registry to local image

    ```
    podman load -i registry_arm_latest.tar
    ```

## Portainer

Note: On MacOS need to init the machine with --rootful to be able to connect to the socket!

    /run/podman/podman.sock:/var/run/docker.sock:Z


- Pull and save portainer image

    ```shell
    podman pull docker.io/portainer/portainer-ce:latest
    podman save docker.io/portainer/portainer-ce:latest -o portainer_arm_latest.tar
    ```

    ```
    podman load -i portainer_arm_latest.tar
    ```

- Copy portainer to local image

# Hyper-v setup

- Getting network connectibity between a vm and wsl

    https://automatingops.com/allowing-windows-subsystem-for-linux-to-communicate-with-hyper-v-vms

    Bottom line is setting the forwarding enabled on both the wsl and default virtual switches