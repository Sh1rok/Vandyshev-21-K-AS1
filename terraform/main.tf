# Указываем провайдера Yandex Cloud
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

# Конфигурация провайдера. Путь к авторизованному ключу и ID каталога укажите в переменных
provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

# Создаем виртуальную сеть
resource "yandex_vpc_network" "vandyshev-network" {
  name = "vandyshev-network"
}

# Создаем подсеть внутри сети
resource "yandex_vpc_subnet" "vandyshev-subnet" {
  name           = "vandyshev-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.vandyshev-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Данные об образе для ВМ (Ubuntu 22.04 LTS)
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Создаем саму виртуальную машину
resource "yandex_compute_instance" "vm" {
  name        = "vandyshev-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vandyshev-subnet.id
    nat       = true # Включаем публичный IP
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}" # Передаем ваш публичный SSH-ключ
    user-data = templatefile("${path.module}/cloud-init.yaml", {
      docker_image_name = var.docker_image_name
    })
  }
}

# Выводим публичный IP созданной ВМ
output "vm_external_ip" {
  value = yandex_compute_instance.vm.network_interface.0.nat_ip_address
}