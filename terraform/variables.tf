variable "service_account_key_file" {
  description = "Path to the service account authorized key file"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key" {
  description = "Your public SSH key"
  type        = string
}

variable "docker_image_name" {
  description = "Docker Hub image name"
  type        = string
}