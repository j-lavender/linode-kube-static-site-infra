resource "linode_lke_cluster" "cluster1" {
    k8s_version = var.k8s_version
    label = var.label
    region = var.region
    tags = var.tags

   dynamic "pool" {
      for_each = var.pools
      content {
            type  = pool.value["type"]
            count = pool.value["count"]
      }
   }
}

output "kubeconfig" {
  description = "Linode kubeconfig."
  value       = base64decode(linode_lke_cluster.cluster1.kubeconfig)
  sensitive   = true
}

resource "local_file" "kubeconfig" {
  content  = base64decode(linode_lke_cluster.cluster1.kubeconfig)
  filename = "../.kube-config"
  file_permission = "0400"
}

output "api_endpoints" {
   value = linode_lke_cluster.cluster1.api_endpoints
}

output "status" {
   value = linode_lke_cluster.cluster1.status
}
