#!/bin/bash

if [ $# -eq 0 ] ; then
    arg=0
    clear
else
    arg=1
fi



if [ $arg -eq 1 ] ; then

    set -x
    # rm -rf terraform.tfsta*
    # rm -rf .terrafor*
    if [ ! -f runner-terr/terraform.tfstate ] ; then
       terraform -chdir=runner-terr/ init 
    fi
    terraform -chdir=runner-terr/ apply 
    sleep 5

    runner_extip=$(yc compute instance list | awk '/runner/ {print $10}')
    runner_intip=$(yc compute instance list | awk '/runner/ {print $12}')


    # set -x
    sed -E '/runner/ s/([0-9]{1,3}[.]){3}[0-9]{1,3}/'$runner_extip'/' -i runner-ansible/inventory/hosts

    echo '########################################################'
    export RU=$(yc compute instance list | sed -n '/runner/ p' | awk '/10([.][0-9]{1,3}){3}/ {print "ssh -o StrictHostKeyChecking=no ubuntu@"$10 }')
    echo -e $RU
    echo '########################################################'

    gnome-terminal -- sh -c $RU
    sleep 15
    ssh -o StrictHostKeyChecking=no ubuntu@$i "sudo sed -i 's/127.0.1.1/'$runner_extip'/' /etc/cloud/templates/hosts.debian.tmpl"
    ssh -o StrictHostKeyChecking=no ubuntu@$i "sudo sed -i 's/127.0.1.1/'$runner_extip'/' /etc/hosts"

    ansible-playbook  -i runner-ansible/inventory/hosts runner-ansible/runner.yml  #--start-at-task=''


    master_intip=$(yc compute instance list | awk '/master/ {print $12}')
    sed -E '/runner/ s/([0-9]{1,3}[.]){3}[0-9]{1,3}/'$master_intip'/' -i app_ci/.gitlab-ci.yml

else 
    terraform -chdir=runner-terr/ destroy
fi