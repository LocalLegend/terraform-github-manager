variable "repo" {
  type = object({
    name        = string
    description = string
    })
}

variable "secrets_dev" {
  type = list(object({
    name  = string
    value = string
    })
    )
  
  default = []
}

variable "secrets_prod" {
  type = list(object({
    name  = string
    value = string
    })
  )
  default = []
}

variable "secrets" {
  type = list(object({
    name  = string
    value = string
    })
  )
  default = []
}



variable "collabs" {
  type = list(object({
    username   = string
    permission = string
    })
  )
  default = []
}


variable "reviewer_username" {
  type = string
  default = "onedal"
}