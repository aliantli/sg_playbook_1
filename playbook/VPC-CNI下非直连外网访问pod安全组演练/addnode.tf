可用创建原生节点
resource "tencentcloud_kubernetes_native_node_pool" "native_nodepool_cvm" {
  name                = "native"
  cluster_id          = "cls-g18s21is"
  type                = "Native"
  unschedulable       = false
  labels {
    name  = "test11"
    value = "test21"
  }

  native {
    instance_charge_type     = "POSTPAID_BY_HOUR"
    instance_types           = ["SA2.MEDIUM2"]
    security_group_ids       = ["sg-m2bb6vu3"]
    subnet_ids               = ["subnet-mw0fqo42"]
    auto_repair              = true
    health_check_policy_name = null
    enable_autoscaling       = false
    host_name_pattern        = null
    #key_ids                  = ["skey-oucbooj7"]
    key_ids                  = ["skey-oucbooj7"]
    replicas                 = 1
    machine_type             = "NativeCVM" # Native 原生节点，NativeCVM 原生节点CVM模式

    system_disk {
      disk_type = "CLOUD_PREMIUM"
      disk_size = 50
    }


    data_disks {
        auto_format_and_mount = true
        disk_type             = "CLOUD_PREMIUM"
        disk_size             = 50
        file_system           = "xfs"
        mount_target          = "/var/lib/containerd"
    }

    scaling {
      min_replicas  = 1
      max_replicas  = 3
      create_policy = "ZoneEquality"
    }
  }
    tags {
      resource_type = "machine"
      tags {
        key   = "k1"
        value = "v1"
      }
      tags {
        key   = "k2"
        value = "v2"
      }
      tags {
        key   = "key10"
        value = "value10"
      }
    }
}
##只能使用ssh密钥登录，要免密登录需开启tat组件
