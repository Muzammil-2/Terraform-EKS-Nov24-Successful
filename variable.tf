variable "ec2_name" {
  type = list(string)
  default = [ "server","prometheus","grafana" ]
}

variable "ami" {
    default = "ami-0dee22c13ea7a9a67"
}

variable "instance_type" {
  type = string
  default  = "t2.nano"
    
  
}