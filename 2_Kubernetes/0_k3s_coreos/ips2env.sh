#/bin/bash

get_ip() {

    arp.exe -a | grep $(echo $1 | sed s/:/-/g) | awk '{print $1;}'
}

export wsl_ip=$(get_ip "00:15:5d:ad:4b:4f")
export vm1_ip=$(get_ip "00-15-5d-38-01-0b")
export vm2_ip=$(get_ip "00-15-5d-38-01-0c")

echo "WSL ip: " $wsl_ip
echo "Vm1 ip: " $vm1_ip
echo "Vm2 ip: " $vm2_ip