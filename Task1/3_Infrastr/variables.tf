variable "YaCloud" {
  description = "YaCloud options"
  type = object({cloud_id=string, folder_id=string, default_zone=string, default_cidr = list(string)})
  sensitive = true
}

variable "subnet" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "cidr" {
  type    = map(list(string))
  default = {
    diap = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]    
  }
}