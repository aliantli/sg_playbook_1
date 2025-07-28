背景与必要性：解决云原生环境的关键痛点​

在腾讯云容器服务（TKE）中，​客户端真实源IP的获取是安全审计、访问控制、日志分析等场景的核心需求。然而，默认的Kubernetes网络模型会导致源IP被替换为节点IP

例如：

非直连模式下流量经过NodePort转发，源IP丢失；
直连模式未正确配置时，CLB无法穿透节点直达Pod。
本项目提供五种标准化场景的解决方案，覆盖TKE两种网络模式和两种节点类型，确保业务零改造获取真实客户端IP。
[<img width="1720" height="1737" alt="Clipboard_Screenshot_1753700990" src="https://github.com/user-attachments/assets/f119eec0-6d72-4579-8c66-3922a706cc65" />
](https://github.com/aliantli/sg_playbook_1/blob/de2b28c6718825d4c671eba9587caf49fa51879d/playbook/image/flowchart.md)

| 场景    | 网络模式       | 连接方式       |节点类型|
|----------------|----------------|----------------|------|
| 场景1   | VPC-CNI   | 直连  |原生节点|
| 场景2  | VPC-CNI    | 非直连  |原生节点|
| 场景3  | VPC-CNI   | 直连   |超级节点|
| 场景4  | GlobalRouter  | 直连 |  原生节点|
| 场景5  | GlobalRouter  | 非直连|   原生节点|
