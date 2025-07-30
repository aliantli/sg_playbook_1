# TKE安全组故障演练全景指南
## 概述

&emsp;安全组作为容器基础设施层的核心流量控制组件，通过节点边界实施粗粒度访问控制，为容器环境提供基础网络隔离保障。然而，用户常因安全组规则复杂性及配置方式不当导致服务不可访问，本文playbook通过GlobalRouter和VPC-CNI两种网络模式下TKE 集群中创建的节点上部署的Pod服务，利用脚本创建安全组的方式模拟真实生产环境下的网络访问异常，通过引导用户分层逐步排查访问链路,最终掌握安全组配置的核心逻辑
## 访问链路总图
[<img width="1720" height="1737" alt="Clipboard_Screenshot_1753700990" src="https://github.com/user-attachments/assets/f119eec0-6d72-4579-8c66-3922a706cc65" />
](https://github.com/aliantli/sg_playbook_1/blob/de2b28c6718825d4c671eba9587caf49fa51879d/playbook/image/flowchart.md)
## 十一大场景对比
| 场景            | 网络模式         | 连接方式         |节点类型 |访问方式|
|----------------|----------------|----------------|------|--|
| 场景1   | VPC-CNI   | 直连  |原生节点|[外网访问直连pod](https://github.com/aliantli/sg_playbook_1/tree/8a3f7303e28fdacd5ccf2d7caf6551613de86f01/playbook/VPV-CNI%E4%B8%8B%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景2  | VPC-CNI    | 非直连  |原生节点|外网访问非直连pod|
| 场景3  | VPC-CNI   | 直连   |超级节点|外网访问直连pod|
| 场景4  | GlobalRouter  | 直连 |  原生节点|外网访问直连pod|
| 场景5  | GlobalRouter  | 非直连|   原生节点|外网访问非直连pod|
|场景6 |VPC-CNI||原生节点|pod访问pod|
|场景7 |VPC-CNI||原生节点|节点访问pod|
|场景8 |GlobalRouter ||原生节点|pod访问pod|
|场景9 |GlobalRouter ||原生节点|节点访问直连pod|
|场景10 |VPC-CNI||超级节点|pod访问pod|
|场景11 |VPC-CNI||超级节点|节点访问pod|
