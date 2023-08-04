#!/bin/bash

get_ip () {
    vagrant ssh $1 -c 'hostname -I' | cut -d' ' -f1
}

echo "export K8S_MASTER_IP=$(get_ip master)"
echo "export K8S_WORKER1_IP=$(get_ip worker1)"
