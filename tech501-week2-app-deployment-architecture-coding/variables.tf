variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone."
  type        = string
  default     = "us-central1-a"
}
