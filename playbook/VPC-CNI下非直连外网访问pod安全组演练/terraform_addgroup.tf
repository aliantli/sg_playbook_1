##
# 安全组1：仅允许 TCP 80 入站，出站全放通
resource "tencentcloud_security_group" "web_sg" {
  name        = "allow-http-only"
  description = "仅允许 TCP 80 入站，出站全放通"
}

resource "tencentcloud_security_group_rule" "web_ingress" {
  security_group_id = tencentcloud_security_group.web_sg.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "80"    # 开放 HTTP 端口
  policy            = "ACCEPT"
  description       = "允许 HTTP 入站"
}

resource "tencentcloud_security_group_rule" "web_egress" {
  security_group_id = tencentcloud_security_group.web_sg.id
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"   # 允许所有协议出站
  policy            = "ACCEPT"
  description       = "允许所有出站流量"
}

# 安全组2：仅允许 TCP 22 入站，出站全放通
resource "tencentcloud_security_group" "mgmt_sg" {
  name        = "allow-ssh-only"
  description = "仅允许 SSH 22 入站，出站全放通"
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

# 安全组3：拒绝所有入站，出站全放通
resource "tencentcloud_security_group" "baseline_sg" {
  name        = "deny-all-inbound"
  description = "拒绝所有入站，出站全放通"
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
output "web_sg_id" {
  value = tencentcloud_security_group.web_sg.id
  description  = "将此安全组绑定到eni上"
}

output "mgmt_sg_id" {
  value = tencentcloud_security_group.mgmt_sg.id
  description  = "将此安全组绑定到clb上"
}

output "baseline_sg_id" {
  value = tencentcloud_security_group.baseline_sg.id
  description  = "将此安全组绑定到节点上"
}
