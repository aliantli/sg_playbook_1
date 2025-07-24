##注解部分为主要配置
resource "tencentcloud_kubernetes_native_node_pool" "native_nodepool_cvm" {
  name                = "native"
  cluster_id          = "cls-g18s21is"   ##集群id
  type                = "Native"        ##节点类型
  unschedulable       = false            ##是否封锁节点，true为封锁
  labels {
    name  = "test11"
    value = "test21"
  }

  native {
    instance_charge_type     = "POSTPAID_BY_HOUR"    ##按量计费，其他计费模式可能会导致创建节点时卡在第一步
    instance_types           = ["SA2.MEDIUM2"]    ##机器类型
    security_group_ids       = ["sg-m2bb6vu3"]    ##安全组id
    subnet_ids               = ["subnet-mw0fqo42"]    ##子网id
    auto_repair              = true
    health_check_policy_name = null
    enable_autoscaling       = false
    host_name_pattern        = null
    key_ids                  = ["skey-oucbooj7"]    ##ssh密钥，改为自己的否则创建节点时会卡第二步
    replicas                 = 1                #节点池内节点数量
    machine_type             = "NativeCVM"     # Native原生节点需要开启tat组件才能登录，NativeCVM原生节点CVM模式不需要tat组件但需要用ssh密钥登录

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
