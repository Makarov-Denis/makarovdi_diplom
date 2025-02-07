variable "yc_id" {
  default = "b1gd691r29c5ghf8ujpd"
}

variable "yf_id" {
  default = "b1gusa0rlmql2290uftn"
}

variable "a-zone" {
  default = "ru-central1-a"
}

variable "OS" {
  default = "fd8l04iucc4vsh00rkb1"
}

variable "subnet-zones" {
  type = list(string)
  default = [ "ru-central1-a", "ru-central1-b", "ru-central1-d" ]
}

variable "cidr" {
  type = map(list(string))
  default = {
    "cidr" = [ "10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24" ]
  }
}
