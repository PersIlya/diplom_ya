data "yandex_compute_image" "vm" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "worker" {
  count = 3
  name        = count.index == 0 ? "master" : "worker-${count.index}" 
  hostname    = count.index == 0 ? "master" : "worker-${count.index}" 
  platform_id = var.standard[count.index]
  zone = var.subnet[count.index] 

  resources {
    cores         = local.vm_common.cpu
    memory        = local.vm_common.ram
    core_fraction = local.vm_common.fract
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm.image_id
      type     = local.vm_common.hdd_type
      size     = local.vm_common.disk_size
    }
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys = "${local.ssh_opt.user_name}:${local.ssh_opt.pubkey}" 
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id = data.yandex_vpc_network.network.subnet_ids[count.index]
    nat       = true
  }

  allow_stopping_for_update = true
}
