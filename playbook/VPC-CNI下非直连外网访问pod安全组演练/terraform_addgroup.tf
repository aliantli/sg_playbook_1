# 安全组1：仅允许 TCP 22 入站，出站全放通
resource "tencentcloud_security_group" "mgmt_sg" {
  name        = "allow-ssh-only"
  description = "仅允许 SSH 22 入站，出站全放通"
  tags = {
    key = "values"  #配置标签
  }
}

resource "tencentcloud_security_group_rule" "ssh_ingress" {
  security_group_id = tencentcloud_security_group.mgmt_sg.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "22"    # 开放 SSH 端口
  policy            = "ACCEPT"
  description       = "允许 SSH 入站"
}

resource "tencentcloud_security_group_rule" "ssh_egress" {
  security_group_id = tencentcloud_security_group.mgmt_sg.id
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "ACCEPT"
  description       = "允许所有出站流量"
}

# 安全组2：拒绝所有入站，出站全放通
resource "tencentcloud_security_group" "baseline_sg" {
  name        = "deny-all-inbound"
  description = "拒绝所有入站，出站全放通"
  tags = {
    key ="values"
  }
}

# 显式拒绝所有入站（默认拒绝，此规则可省略但明确声明更清晰）
resource "tencentcloud_security_group_rule" "deny_ingress" {
  security_group_id = tencentcloud_security_group.baseline_sg.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "DROP"     # 丢弃所有入站
  description       = "拒绝所有入站流量"
}

resource "tencentcloud_security_group_rule" "allow_egress" {
  security_group_id = tencentcloud_security_group.baseline_sg.id
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "ACCEPT"   # 允许所有出站
  description       = "允许所有出站流量"
}

# 输出安全组 ID
# 输出安全组 ID

output "将此安全组绑定到clb上" {
  value = tencentcloud_security_group.mgmt_sg.id
}

