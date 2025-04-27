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


    # set -x
    sed -E '/runner/ s/([0-9]{1,3}[.]){3}[0-9]{1,3}/'$runner_extip'/' -i runner-ansible/inventory/hosts

    echo '########################################################'
    export RU="ssh -o StrictHostKeyChecking=no ubuntu@"$runner_extip
    echo -e $RU
    echo '########################################################'
    sleep 15
    gnome-terminal -- sh -c $RU
    sleep 15
    ssh -o StrictHostKeyChecking=no ubuntu@$runner_extip "sudo sed -i 's/127.0.1.1/'$runner_extip'/' /etc/cloud/templates/hosts.debian.tmpl"
    ssh -o StrictHostKeyChecking=no ubuntu@$runner_extip "sudo sed -i 's/127.0.1.1/'$runner_extip'/' /etc/hosts"

    ansible-playbook  -i runner-ansible/inventory/hosts runner-ansible/runner.yml  #--start-at-task=''


    master_intip=$(yc compute instance list | awk '/master/ {print $10}')
    sed -E '/depl-site/ s/([0-9]{1,3}[.]){3}[0-9]{1,3}/'$master_extip'/' -i diplom_ci/.gitlab-ci.yml

else 
    terraform -chdir=runner-terr/ destroy
fi