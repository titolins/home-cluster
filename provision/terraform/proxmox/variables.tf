variable "kube_node_hostname_prefix" {
  type    = string
  default = "k8s-"
}

variable "kube_nodes" {
  type = map(map(string))
  default = {
    master01 = {
      id      = 4010
      cores   = 2
      sockets = 1
      memory  = 2048
    },
    master02 = {
      id      = 4011
      cores   = 2
      sockets = 1
      memory  = 2048
    },
    master03 = {
      id      = 4012
      cores   = 2
      sockets = 1
      memory  = 2048
    },
    worker01 = {
      id      = 4020
      cores   = 2
      sockets = 1
      memory  = 2048
    },
    worker02 = {
      id      = 4021
      cores   = 2
      sockets = 1
      memory  = 2048
    },
    worker03 = {
      id      = 4022
      cores   = 2
      sockets = 1
      memory  = 2048
    },
    worker04 = {
      id      = 4023
      cores   = 2
      sockets = 1
      memory  = 2048
    },
  }
}
