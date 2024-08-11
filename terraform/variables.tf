variable "aws_region" {
  default = "us-west-2"
}

variable "aws_account_id" {
  default = "097890748571"
}

variable "ecs_cluster_name" {
  default = "ecs-cluster"
}

variable "ecr_controller_image" {
  default = "097890748571.dkr.ecr.us-west-2.amazonaws.com/controller:latest"
  description = "ECR image URI for the controller"
}

variable "ecr_simulated_robot_image" {
  default = "097890748571.dkr.ecr.us-west-2.amazonaws.com/simulated_robot:latest"
  description = "ECR image URI for the simulated robot"
}
