variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "k8s_version" {
  description = "OKE Kubernetes version. Select a version supported by your target region."
  type        = string
  default     = "v1.35.2"
}
