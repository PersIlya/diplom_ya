#!/bin/bash

if [ $# -eq 0 ] ; then
    arg=0
    clear
else
    arg=1
fi



if [ $arg -eq 1 ] ; then

    # rm -rf terraform.tfsta*
    # rm -rf .terrafor*
    if [ ! -f Cluster/terraform.tfstate ] ; then
       terraform -chdir=Cluster/ init 
    fi
    terraform -chdir=Cluster/ apply 
    sleep 5

    master_extip=$(yc compute instance list | awk '/master/ {print $10}')
    worker1_extip=$(yc compute instance list | awk '/worker-1/ {print $10}')
    worker2_extip=$(yc compute instance list | awk '/worker-2/ {print $10}')

    # set -x
    sed -E '/master/ s/([0-9]{1,3}[.]){3}[0-9]{1,3}/'$master_extip'/' -i ansible/inventory/hosts
    sed -E '/worker-1/ s/([0-9]{1,3}[.]){3}[0-9]{1,3}/'$worker1_extip'/' -i ansible/inventory/hosts
    sed -E '/worker-2/ s/([0-9]{1,3}[.]){3}[0-9]{1,3}/'$worker2_extip'/' -i ansible/inventory/hosts


    master_intip=$(yc compute instance list | awk '/master/ {print $12}')
    master_intnet=$(echo $master_intip | grep -Eo '([0-9]{1,3}[.]){3}')
    worker1_intip=$(yc compute instance list | awk '/worker-1/ {print $12}')
    worker2_intip=$(yc compute instance list | awk '/worker-2/ {print $12}')
    
    sed -i '/pod_network_cidr: / d' ansible/k8s_master_init.yml
        sed -i '/vars:/ a pod_network_cidr: "'$master_intnet'0/18"' ansible/k8s_master_init.yml
        sed -i '/'$master_intnet'/ s|^|    |' ansible/k8s_master_init.yml

    sed -i '/k8s_master_ip: / d' ansible/k8s_master_init.yml
        sed -i '/pod_network_cidr:/ a k8s_master_ip: "'$master_intip'"' ansible/k8s_master_init.yml
        sed -i '/'$master_intip'/ s|^|    |' ansible/k8s_master_init.yml

    echo '########################################################'
    export MA=$(yc compute instance list | sed -n '/master/ p' | awk '/10([.][0-9]{1,3}){3}/ {print "ssh -o StrictHostKeyChecking=no ubuntu@"$10 }')
    export W1=$(yc compute instance list | sed -n '/worker-1/ p' | awk '/10([.][0-9]{1,3}){3}/ {print "ssh -o StrictHostKeyChecking=no ubuntu@"$10 }')
    export W2=$(yc compute instance list | sed -n '/worker-2/ p' | awk '/10([.][0-9]{1,3}){3}/ {print "ssh -o StrictHostKeyChecking=no ubuntu@"$10 }')
    echo -e $MA"\n"$W1"\n"$W2
    echo '########################################################'

    for i in $(grep  -Eo '([0-9]{1,3}[.]){3}[0-9]{1,3}' ansible/inventory/hosts) ; do
        sleep 15
        gnome-terminal -- sh -c "ssh -o StrictHostKeyChecking=no ubuntu@$i"
        tmp=$(ssh -o StrictHostKeyChecking=no ubuntu@$i "ip -br a | grep  -Eo '10([.][0-9]{1,3}){3}'")
        echo $tmp
        ssh -o StrictHostKeyChecking=no ubuntu@$i "sudo sed -i 's/127.0.1.1/'$tmp'/' /etc/cloud/templates/hosts.debian.tmpl"
        ssh -o StrictHostKeyChecking=no ubuntu@$i "sudo sed -i 's/127.0.1.1/'$tmp'/' /etc/hosts"
    done
    sleep 10

    ansible-playbook  -i ansible/inventory/hosts ansible/k8s_containrd_pkg.yml  #--start-at-task=''
    sleep 10
    ansible-playbook  -i ansible/inventory/hosts ansible/k8s_master_init.yml  #--start-at-task=''
    sleep 10
    ansible-playbook  -i ansible/inventory/hosts ansible/k8s_workers.yml

    #kubectl get po -o wide

else 
    terraform -chdir=Cluster/ destroy
fi