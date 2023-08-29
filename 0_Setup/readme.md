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