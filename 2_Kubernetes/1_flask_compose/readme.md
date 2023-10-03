# Testing with podman

- <2023-10-03 Tue 09:15> Working on MacOS

    - After figuring out how to get portainer running

- <2023-09-25 Mon 14:38>

    - Moved init_db and associated scripts to the flask pod to run via exec
    - Running on the RHEL MV

- <2023-08-18 Fri 08:56>

    - Had to manually install an old version of containernetworking-plugins

        http://archive.ubuntu.com/ubuntu/pool/universe/g/golang-github-containernetworking-plugins/containernetworking-plugins_1.1.1+ds1-3_amd64.deb

        ```shell
        sudo apt install ./containernetworking-plugins_1.1.1+ds1-3_amd64.de
        ```

    - Compose file working, had to manually release port 8080 in wsl after bringing containers down

        ```shell
        lsof -i:8080
        kill xxxxxx
        ```

- <2023-08-18 Fri 10:27> Changed to mysql

    ```shell
    pip install mysql-connector-python
    ```

- <2023-08-18 Fri 16:26> Flask app working

- <2023-08-18 Fri 16:27> Another, perhaps better, example

    https://testdriven.io/blog/running-flask-on-kubernetes/


    