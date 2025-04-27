locals {
  VPC_Name= "Network"
  vm_common = { cpu=2, ram=3, fract=20, hdd_type="network-hdd", disk_size=25 } 
  # vpc_names = { net1="public_subnet" , net2="private_subnet"}  

  ssh_opt = {proto="ssh", user_name="ubuntu", pubkey=file("~/.ssh/id_ed25519.pub"), time="120s"}
}