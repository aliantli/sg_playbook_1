# TKE安全组故障演练全景指南
## 概述

&emsp;安全组作为容器基础设施层的核心流量控制组件，通过节点边界实施粗粒度访问控制，为容器环境提供基础网络隔离保障。然而，用户常因安全组规则复杂性及配置方式不当导致服务不可访问，本文playbook通过GlobalRouter和VPC-CNI两种网络模式下TKE 集群中创建的节点上部署的Pod服务，利用脚本创建安全组的方式模拟真实生产环境下的网络访问异常，通过引导用户分层逐步排查访问链路,最终掌握安全组配置的核心逻辑
## 访问链路总图
[<img width="762" height="539" alt="Clipboard_Screenshot_1753944807" src="https://github.com/user-attachments/assets/b7754ffa-5913-4a7e-a364-f63bad206ead" />
](https://github.com/aliantli/sg_playbook_1/blob/e7146fc9d53601b87e36ae54f81f09206ae800fc/playbook/image/flowchart.md)
## 安全组访问场景
| 场景            | 网络模式         |节点类型 |访问场景|
|----------------|----------------|------|--|
| 场景1   | VPC-CNI   |原生节点|[clb直连pod访问](https://github.com/aliantli/sg_playbook_1/tree/c93a40df5ac90e3b3636e35c0b3966f2b04a12c9/playbook/VPV-CNI%E4%B8%8B%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景2  | VPC-CNI      |原生节点|[clb非直连pod访问](https://github.com/aliantli/sg_playbook_1/tree/b11154428f05574158877680daf83727fa417b7a/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景3  | VPC-CNI   |超级节点|[clb pod访问](https://github.com/aliantli/sg_playbook_1/tree/de0749b5b363cd777ececeb3bdbc8b7a3b61030e/playbook/VPC-CNI%E8%B6%85%E7%BA%A7%E8%8A%82%E7%82%B9%E4%B8%8B%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景4  | GlobalRouter  |  原生节点|[clb直连pod访问](https://github.com/aliantli/sg_playbook_1/tree/844f0155c66f09ec6179a91dcaf37ffca483977a/playbook/Global%20Router%E4%B8%8B%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景5  | GlobalRouter  |   原生节点|[clb非直连pod访问](https://github.com/aliantli/sg_playbook_1/tree/7fc8c2ddafcb59823404bcf99929ce6023f2fbc7/playbook/Global%20Router%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
|场景6 |VPC-CNI|原生节点|[pod与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/8b56bae03a24887a4478d25536bb7c5a2d465dea/playbook/VPC_PodAccessPod)|
|场景7 |VPC-CNI|原生节点|[节点与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/051322efd793853028f515df1b0f282b95f06be7/playbook/VPC-NodeAccessPod)|
|场景8 |GlobalRouter |原生节点|[pod与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/380d6893c868d7f02063d183ee98bd7337a951e8/playbook/GlobalRouter_PodAccessPod)|
|场景9 |GlobalRouter |原生节点|[节点与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/e8408ecc6f8de8bde2d3865bd1d2230a0e7ebaee/playbook/GlobalRouter_NodeAccessPod)|
|场景10 |VPC-CNI|超级节点|[pod与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/c945b0c559538d6de0a3b235292447ed5a9fc30c/playbook/VPC_Super_PodAccessPod)|
|场景11 |VPC-CNI|超级节点|[非超级节点与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/6e65caaba24f66da63ec4232de3bde54c5082024/playbook/VPC_Super_NodeAccessPod)|
