variable "YaCloud" {
  description = "YaCloud options"
  type = object({cloud_id=string, folder_id=string, default_zone=string, default_cidr = list(string)})
  sensitive = true
}

variable "subnet" {
  type    = list(string)
  default = ["ru-central1-b", "ru-central1-a", "ru-central1-d"]
}

variable "standard" {
  type    = list(string)
  default = ["standard-v1", "standard-v1", "standard-v2"]
}