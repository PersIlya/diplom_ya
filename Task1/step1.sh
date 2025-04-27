#!/bin/bash

clear
if [ $# -eq 0 ] ; then
    arg=0
    clear
else
    arg=1
fi


if [ $arg -eq 1 ] ; then

    rm -rf {1_Backend,2_Bucket,3_Infrastr}/terraform.tfsta*
    rm -rf {1_Backend,2_Bucket,3_Infrastr}/.terrafor*
    # if [ ! -f 1_Backend/terraform.tfstate ] ; then
       terraform -chdir=1_Backend/ init 
    # fi
    terraform -chdir=1_Backend/ apply
    account_id=$(cat 1_Backend/terraform.tfstate | jq '.outputs.account_id.value')
    bucket_name=$(cat 1_Backend/terraform.tfstate | jq '.outputs.bucket_name.value')
    access_key=$(cat 1_Backend/terraform.tfstate | jq '.outputs.access_key.value')
    secret_key=$(cat 1_Backend/terraform.tfstate | jq '.outputs.secret_key.value')

    # set -x

    sed -i '/sa_account/ d' 2_Bucket/personal.auto.tfvars 
        sed -i '/YaCloud/ a sa_account = '$account_id 2_Bucket/personal.auto.tfvars 
        sed -i '/'$account_id'/ s|^|  |' 2_Bucket/personal.auto.tfvars 
    
    sed -i '/bucket/ d' 2_Bucket/providers.tf 
        sed -i '/ru-central1/ a bucket = '$bucket_name 2_Bucket/providers.tf
        sed -i '/'$bucket_name'/ s|^|    |' 2_Bucket/providers.tf 

    sed -i '/access_key/ d' 2_Bucket/providers.tf 
        sed -i '/bucket/ a access_key = '$access_key 2_Bucket/providers.tf
        sed -i '/'$access_key'/ s|^|    |' 2_Bucket/providers.tf 
    
    sed -i '/secret_key/ d' 2_Bucket/providers.tf 
        sed -i '/access_key/ a secret_key = '$secret_key 2_Bucket/providers.tf
        sed -i '/'$secret_key'/ s|^|    |' 2_Bucket/providers.tf 

    terraform -chdir=2_Bucket/ init 
    terraform -chdir=2_Bucket/ apply 
    terraform -chdir=3_Infrastr/ init 
    terraform -chdir=3_Infrastr/ apply
else 
    terraform -chdir=3_Infrastr/ destroy
    terraform -chdir=2_Bucket/ destroy
    terraform -chdir=1_Backend/ destroy
fi