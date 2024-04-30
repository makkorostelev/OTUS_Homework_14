locals {
  ceph_1_instance = yandex_compute_instance.ceph-1.network_interface.0.ip_address
  ceph_2_instance = yandex_compute_instance.ceph-2.network_interface.0.ip_address
  ceph_3_instance = yandex_compute_instance.ceph-3.network_interface.0.ip_address
  admin_instance  = yandex_compute_instance.admin.network_interface.0.nat_ip_address
}

resource "local_file" "hosts-ini" {
  filename = "ceph-ansible/inventory/hosts.ini"
  content = templatefile("ceph-ansible/inventory/hosts.tftpl", {
    ceph_1_instance  = local.ceph_1_instance
    ceph_2_instance  = local.ceph_2_instance
    ceph_3_instance  = local.ceph_3_instance
    private_key_path = var.private_key_path
    admin_instance   = local.admin_instance
  })
}

resource "yandex_compute_instance" "admin" {
  platform_id = "standard-v1"
  hostname    = "admin"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8idfolcq1l43h1mlft" # ОС (Ubuntu, 22.04 LTS)
    }

  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.custom_subnet.id
    security_group_ids = [yandex_vpc_security_group.custom_sg.id]
    nat                = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ubuntu\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${var.public_key}"
  }
}

resource "yandex_compute_instance" "ceph-1" {
  platform_id = "standard-v1"
  hostname    = "cluster-01"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8idfolcq1l43h1mlft" # ОС (Ubuntu, 22.04 LTS)
      size     = 20
    }

  }
  secondary_disk {
    disk_id     = yandex_compute_disk.ceph-disk-1.id
    auto_delete = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.custom_subnet.id
    security_group_ids = [yandex_vpc_security_group.custom_sg.id]
    nat                = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ubuntu\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${var.public_key}"
  }
}

resource "yandex_compute_disk" "ceph-disk-1" {
  name = "ceph-disk-0"
  type = "network-hdd"
  size = 20
}

resource "yandex_compute_instance" "ceph-2" {
  platform_id = "standard-v1"
  hostname    = "cluster-02"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8idfolcq1l43h1mlft" # ОС (Ubuntu, 22.04 LTS)
      size     = 20
    }

  }
  secondary_disk {
    disk_id     = yandex_compute_disk.ceph-disk-2.id
    auto_delete = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.custom_subnet.id
    security_group_ids = [yandex_vpc_security_group.custom_sg.id]
    nat                = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ubuntu\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${var.public_key}"
  }
}

resource "yandex_compute_disk" "ceph-disk-2" {
  name = "ceph-disk-1"
  type = "network-hdd"
  size = 20
}

resource "yandex_compute_instance" "ceph-3" {
  platform_id = "standard-v1"
  hostname    = "cluster-03"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8idfolcq1l43h1mlft" # ОС (Ubuntu, 22.04 LTS)
      size     = 20
    }

  }
  secondary_disk {
    disk_id     = yandex_compute_disk.ceph-disk-3.id
    auto_delete = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.custom_subnet.id
    security_group_ids = [yandex_vpc_security_group.custom_sg.id]
    nat                = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ubuntu\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${var.public_key}"
  }
}

resource "yandex_compute_disk" "ceph-disk-3" {
  name = "ceph-disk-2"
  type = "network-hdd"
  size = 20
}

resource "yandex_vpc_network" "custom_vpc" {
  name = "custom_vpc"

}
resource "yandex_vpc_subnet" "custom_subnet" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.custom_vpc.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_vpc_security_group" "custom_sg" {
  name        = "WebServer security group"
  description = "My Security group"
  network_id  = yandex_vpc_network.custom_vpc.id
  /*  
  dynamic "ingress" {
    for_each = ["80", "443", "22", "3300", "6789"]
    content {
      protocol       = "TCP"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = ingress.value
    }
  }
  ingress {
    from_port      = 6800
    to_port        = 7568
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
*/
  ingress {
    protocol       = "ANY"
    description    = "Incoming traf"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = -1
  }

  egress {
    protocol       = "ANY"
    description    = "Outcoming traf"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = -1
  }
}


resource "terraform_data" "run_ansible" {
  depends_on = [yandex_compute_instance.ceph-2, yandex_compute_instance.ceph-3, yandex_compute_instance.ceph-1, local_file.hosts-ini]
  provisioner "local-exec" {
    command = <<EOF
    ansible-playbook -i ceph-ansible/inventory/hosts.ini ceph-ansible/site.yml
    EOF
  }
}

