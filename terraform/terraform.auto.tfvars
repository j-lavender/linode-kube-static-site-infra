label = "production-lke-cluster"
k8s_version = "1.22"
region = "us-central"
pools = [
  {
    type : "g6-standard-1"
    count : 1
  }
]