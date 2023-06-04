#!/bin/bash

MASTER_IP=$(vagrant ssh master -c 'hostname -I' | cut -d' ' -f1)
echo "export K8S_MASTER_IP=$MASTER_IP"

CLIENT_IP=$(vagrant ssh client -c 'hostname -I' | cut -d' ' -f1)
echo "export K8S_CLIENT_IP=$CLIENT_IP"
