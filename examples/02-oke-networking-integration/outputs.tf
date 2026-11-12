output "vcn_id" {
  value = module.vcn.vcn_id
}

output "subnet_ids" {
  value = module.vcn.subnet_ids
}

output "security_list_ids" {
  value = module.vcn.security_list_ids
}

output "route_table_ids" {
  value = module.vcn.route_table_ids
}

output "cluster_id" {
  value = module.oke.cluster.id
}

output "kubeconfig" {
  value     = module.oke.KubeConfig
  sensitive = true
}
