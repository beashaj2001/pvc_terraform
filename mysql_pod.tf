provider "kubernetes" {
  config_context_cluster   = "minikube"
}


resource "kubernetes_secret" "mysec" {
  metadata {
    name = "my-basic-auth"
  }

  data = {
    username = "Beashaj"
    rpass = "Beamana143"
    cpass = "Beamana143"
  }

  type = "kubernetes.io/basic-auth"
}


# resource "kubernetes_pod" "mypod1" {
#   metadata {
#     name = "mySqlpod"
#   }

#   spec {
#     container {
#       image = "mysql:5.6"
#       name  = "mySql"
#     }
#    }
# }

resource "kubernetes_deployment" "example" {
  metadata {
    name = "terraform-example"
    labels = {
      dc = "IN"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        dc = "IN"
      }
    }

    template {
      metadata {
        labels = {
          dc = "IN"
        }
      }

      spec {
        container {
          image = "mysql:5.6"
          name  = "sql-image"
           env {
              name = "MYSQL_ROOT_PASSWORD"
              value = "${kubernetes_secret.mysec.data.rpass}"
            }
            env {
                name = "MYSQL_USER"
                value = "${kubernetes_secret.mysec.data.username}"
            }
            env {
                name = "MYSQL_PASSWORD"
                value = "${kubernetes_secret.mysec.data.cpass}"
            }
            volume_mount {
                name = "myvol1"
                mount_path = "/var/lib/mysql"
            }
        }
        volume {
            name = "myvol1"
            persistent_volume_claim {
                claim_name = "mysqlpvc1"
            }
        }
      }
    }
  }
}
