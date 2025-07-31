
# 概述
&emsp;安全组作为容器基础设施层的核心流量控制组件，通过节点边界实施粗粒度访问控制，为容器环境提供基础网络隔离保障。然而，用户常因安全组规则复杂性及配置方式不当导致服务不可访问，本文针对Global Router网络模式下TKE 集群中节点访问另一个原生节点里Pod 服务，通过引导用户分层逐步排查访问链路,最终掌握安全组配置的核心逻辑


# 访问链路
Global Router下节点与pod跨节点访问:<br>
[<img width="702" height="378" alt="Clipboard_Screenshot_1753945920" src="https://github.com/user-attachments/assets/fb22816b-aa10-4a24-9c81-2a959dc5a048" />
](https://github.com/aliantli/sg_playbook_1/blob/863b2efa3496eee52044f4cff2ec190373ffa26b/playbook/GlobalRouter_NodeAccessPod/image/flowchart.md)
 <br>&emsp;在日常生产环境中可以通过在上述位置是设置安全组来限制流量出入，以此控制入口流量的基础过滤，实现流量的精细管控，保障Pod资源安全(一般不限制出口流量)
# 环境部署
## 前提条件
**1.tke集群要求**

TKE版本>=1.20.6
<br>详情可参考:https://cloud.tencent.com/document/product/457/103981<br>
网络模式:GlobalRouter<br>
详情可参考:https://cloud.tencent.com/document/product/457/50355

**2.工具准备**

配置好[terraform:v1.8.2](https://developer.hashicorp.com/terraform)
## 快速开始
**以terraform为例**<br>
 1.创建原生节点和安全组并将安全组绑定到节点上
```
[root@VM-35-20-tlinux terraform]# sh create_node_sg_tf.sh 
[root@VM-35-20-tlinux terraform]# terraform apply -auto-approve
```
 2.创建deployment并将其绑定在指定原生节点上
```
[root@VM-35-20-tlinux terraform]# sh setup_deploy_yaml.sh
[root@VM-35-20-tlinux terraform]#kubectl apply -f deployment.yaml
```

# 演练分析
## 第一步:获取服务名与访问ip
```
[root@VM-35-20-tlinux terraform]# kubectl get pods -o wide|awk '{printf "podname:"$1"\t""pod_ip:"$6"\n"}'|grep -v "NAME"|grep -v IP
podname:nginx-pod       pod_ip:172.17.0.131
```
## 第二步:问题分析
### 若访问时出现以下现象(time out):
```
[root@VM-35-20-tlinux terraform]# 172.17.0.131
curl: (28) Failed to connect to 172.17.0.131 port 80: Connection timed out
```
排查方向:
```
节点层面：出现这种情况一般为节点组网卡安全组配置问题，前往节点所绑定的安全组，查看其是否允许内网ip访问访问端口，如果未放通放通即可
```
# 演练环境清理
```
[root@VM-35-20-tlinux terraform]# kubectl delete apply -f deployment.yaml
[root@VM-35-20-tlinux terraform]# terraform destroy -auto-approve
```
# 项目结构
```
GlobalRouter_NodeAccessPod/  
├── deployment.yaml      # 创建deployment并指定deployment绑定到对应节点上
├── create_node_sg_tf.sh   #配置tf文件脚本
├── create_node_sg.template      #创建节点和安全组并给节点绑定安全组
├── readme.d        #本文件
├── setup_deploy_yaml  #为deployment指定节点
```


