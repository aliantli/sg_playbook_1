# TKE安全组故障演练全景指南
## 概述

&emsp;安全组作为容器基础设施层的核心流量控制组件，通过节点边界实施粗粒度访问控制，为容器环境提供基础网络隔离保障。然而，用户常因安全组规则复杂性及配置方式不当导致服务不可访问，本文playbook通过GlobalRouter和VPC-CNI两种网络模式下TKE 集群中创建的节点上部署的Pod服务，利用脚本创建安全组的方式模拟真实生产环境下的网络访问异常，通过引导用户分层逐步排查访问链路,最终掌握安全组配置的核心逻辑
## 访问链路总图
[<img width="762" height="539" alt="Clipboard_Screenshot_1753944807" src="https://github.com/user-attachments/assets/b7754ffa-5913-4a7e-a364-f63bad206ead" />
](https://github.com/aliantli/sg_playbook_1/blob/e7146fc9d53601b87e36ae54f81f09206ae800fc/playbook/image/flowchart.md)
## 安全组访问场景
| 场景            | 网络模式         |节点类型 |访问场景|
|----------------|----------------|------|--|
| 场景1   | VPC-CNI   |原生节点|[clb直连pod访问](https://github.com/aliantli/sg_playbook_1/tree/6268ea5ea1e869fa87a9eb415be3ebf86332cf35/playbook/VPV-CNI%E4%B8%8B%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景2  | VPC-CNI      |原生节点|[clb非直连pod访问](https://github.com/aliantli/sg_playbook_1/tree/a7c4fe2f343182e9921c47fd3e42c765678308fa/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景3  | VPC-CNI   |超级节点|[clb pod访问](https://github.com/aliantli/sg_playbook_1/tree/18cff2a100b43cc57bbcb45bb4b13ebea31f79af/playbook/VPC-CNI%E8%B6%85%E7%BA%A7%E8%8A%82%E7%82%B9%E4%B8%8B%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景4  | GlobalRouter  |  原生节点|[clb直连pod访问](https://github.com/aliantli/sg_playbook_1/tree/22fa43527ba348d7cc2dde6ab319b707ea9e2cbe/playbook/Global%20Router%E4%B8%8B%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
| 场景5  | GlobalRouter  |   原生节点|[clb非直连pod访问](https://github.com/aliantli/sg_playbook_1/tree/615d247343c827a5ec32cfd86e0d0709ca67408f/playbook/Global%20Router%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83)|
|场景6 |VPC-CNI|原生节点|[pod与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/59eb1270cc5abb758d3175fa1ed152667afd95ab/playbook/VPC_PodAccessPod)|
|场景7 |VPC-CNI|原生节点|[节点与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/5f05d580db0f0e3e7d833898f1ac838c57ac2b6a/playbook/VPC-NodeAccessPod)|
|场景8 |GlobalRouter |原生节点|[pod与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/9c12f9b9ee56c64694f2145377eee1e6ebf2d69a/playbook/GlobalRouter_PodAccessPod)|
|场景9 |GlobalRouter |原生节点|[节点与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/6947e55c8c36ecd7dac6f6705fea99b82d61ddeb/playbook/GlobalRouter_NodeAccessPod)|
|场景10 |VPC-CNI|超级节点|[pod与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/1103903f09fa14b21da25005db1641640da881ad/playbook/VPC_Super_PodAccessPod)|
|场景11 |VPC-CNI|超级节点|[非超级节点与pod跨节点访问](https://github.com/aliantli/sg_playbook_1/tree/c977c6afde19d1e6efd028643956fe0ccb50bf7c/playbook/VPC_Super_NodeAccessPod)|
