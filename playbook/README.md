# TKE安全组故障演练全景指南
## 概述

&emsp;安全组作为容器基础设施层的核心流量控制组件，通过节点边界实施粗粒度访问控制，为容器环境提供基础网络隔离保障。然而，用户常因安全组规则复杂性及配置方式不当导致服务不可访问，本文playbook通过GlobalRouter和VPC-CNI两种网络模式下TKE 集群中创建的节点上部署的Pod服务，利用脚本创建安全组的方式模拟真实生产环境下的网络访问异常，通过引导用户分层逐步排查访问链路,最终掌握安全组配置的核心逻辑
## 访问链路总图
[<img width="1720" height="1737" alt="Clipboard_Screenshot_1753700990" src="https://github.com/user-attachments/assets/f119eec0-6d72-4579-8c66-3922a706cc65" />
](https://github.com/aliantli/sg_playbook_1/blob/de2b28c6718825d4c671eba9587caf49fa51879d/playbook/image/flowchart.md)
## 五大场景对比
| 场景    | 网络模式       | 连接方式       |节点类型|
|----------------|----------------|----------------|------|
| 场景1   | VPC-CNI   | 直连  |原生节点|
| 场景2  | VPC-CNI    | 非直连  |原生节点|
| 场景3  | VPC-CNI   | 直连   |超级节点|
| 场景4  | GlobalRouter  | 直连 |  原生节点|
| 场景5  | GlobalRouter  | 非直连|   原生节点|
## 业务场景配置举例说明
### 原生节点创建
```
resource "tencentcloud_kubernetes_native_node_pool" "native_nodepool_cvm" {
  name                = "native"
  cluster_id          = "<cls-id>"   ##集群id
  type                = "Native"        ##节点类型
  unschedulable       = false            ##是否封锁节点，true为封锁
  labels {
    name  = "test11"
    value = "test21"
  }

  native {
    instance_charge_type     = "POSTPAID_BY_HOUR"    ##按量计费，其他计费模式可能会导致创建节点时卡在第一步
    instance_types           = ["SA2.MEDIUM2"]    ##机器类型
    security_group_ids       = [tencentcloud_security_group.baseline_sg.id]    ##安全组id
    subnet_ids               = ["<sub-id>"]    ##子网id
    auto_repair              = true
    health_check_policy_name = null
    enable_autoscaling       = false
    host_name_pattern        = null
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
        mount_target          = "/var/lib/container"
    }

    scaling {
      min_replicas  = 1
      max_replicas  = 3
      create_policy = "ZoneEquality"
    }
  }
}
```
### 超级节点创建
```
resource "tencentcloud_kubernetes_serverless_node_pool" "example" {
  cluster_id = "<cls-id>"  #集群id
  name       = "tf_example_serverless_node_pool"

  serverless_nodes {
    display_name = "tf_example_serverless_node1"
    subnet_id    = "<sub-id>"  #子网id
  }


  security_group_ids = [tencentcloud_security_group.baseline_sg.id]  #安全组id
  labels = {
    "label1" : "value1",  #标签
  }
}
```
### 安全组的创建
```
resource "tencentcloud_security_group" "mgmt_sg" {
  name        = "allow-ssh-only"
  description = "仅允许 SSH 22 入站，出站全放通"
  tags = {
    <key> = "<values>"  #配置标签
  }
}
resource "tencentcloud_security_group_rule" "ssh_ingress" {
  security_group_id = tencentcloud_security_group.mgmt_sg.id
  type              = "ingress"  #入站
  cidr_ip           = "0.0.0.0/0"  #ip
  ip_protocol       = "tcp"  #协议
  port_range        = "22"    # 开放端口
  policy            = "ACCEPT"
  description       = "允许 SSH 入站"
}
resource "tencentcloud_security_group_rule" "ssh_egress" {
  security_group_id = tencentcloud_security_group.mgmt_sg.id
  type              = "egress"  #出站
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "ACCEPT"
  description       = "允许所有出站流量"
}
```
