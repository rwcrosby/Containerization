# Tech Talks

    Note: assumes that the registry and portainer containers from SharedEnvironment are running

## Containers

Containerization samples

### 2_cpp_minimized

Need to install 

- glibc-static
- libstdc++-static

### 7_python_jupyter

Need to specify `:z` on the mounted directory to allow write access.

## Kubernetes

### 0 - Setup a k8s cluster

### 1 - A simple three container environment using compose

### 2 - Simple three pod environment

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

### 3 - Cluster using configurations and secrets

# References

https://testdriven.io/blog/running-flask-on-kubernetes/