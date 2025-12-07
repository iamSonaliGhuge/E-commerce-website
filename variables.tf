variable "aws_region" {
  default = "ap-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  default     = "ami-0ecb62995f68bb549" 
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  default     = "springbootkey" 
}

variable "db_name" {
  default = "springbootidb"
}

variable "db_username" {
  default = "root"
}

variable "db_password" {
  sensitive = true
  default   = "admin2123"
}

variable "artifact_bucket_name" {
  default = "my-springboot-artifact-bucket-neha-unique"
}
