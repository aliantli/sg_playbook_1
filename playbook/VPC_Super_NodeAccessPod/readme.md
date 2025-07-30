# 概述
&emsp;安全组作为容器基础设施层的核心流量控制组件，通过节点边界实施粗粒度访问控制，为容器环境提供基础网络隔离保障。然而，用户常因安全组规则复杂性及配置方式不当导致服务不可访问，本文针对VPC-CNI 网络模式下TKE 集群中节点访问超级节点的Pod 服务，通过引导用户分层逐步排查访问链路,最终掌握安全组配置的核心逻辑


# 访问链路
[<img width="1183" height="157" alt="Clipboard_Screenshot_1753866712" src="https://github.com/user-attachments/assets/f3920457-a799-4bec-9df0-2fb28ae1a83f" />](https://github.com/aliantli/sg_playbook_1/blob/bbc589b5be97c44a140677fb3b0cee192987d2f1/playbook/VPC_Super_NodeAccessPod/image/flowchart.md)
 <br>&emsp;在日常生产环境中可以通过在上述位置设置安全组来限制外网流量出入，以此控制入口流量的基础过滤，实现流量的精细管控，保障Pod资源安全(pod辅助网卡处的安全组默认关闭可根据自己需求开启)

# 环境部署
## 前提条件
**1.tke集群要求**

TKE版本>=1.20.6
<br>详情可参考:https://cloud.tencent.com/document/product/457/103981<br>
网络模式:VPC-CNI<br>
详情可参考:https://cloud.tencent.com/document/product/457/50355

**2.工具准备**

配置好[terraform:v1.8.2](https://developer.hashicorp.com/terraform)
## 快速开始
**以terraform为例**<br>
 1.创建原生节点
```
[root@VM-35-139-tlinux terraform]# sh create_super_node_tf.sh 
[root@VM-35-139-tlinux terraform]# terraform apply -auto-approve
```
 2.创建pod服务并将其绑定在指定原生节点上
```
[root@VM-35-139-tlinux terraform]# sh setup_podyaml.sh
[root@VM-35-139-tlinux terraform]# kubectl apply -f pod.yaml
```

# 演练分析
## 第一步:获取服务名与访问ip
```
[root@VM-35-139-tlinux terraform]# kubectl get pods -o wide|awk '{printf "podname:"$1"\t""pod_ip:"$6"\n"}'|grep -v "NAME"|grep -v IP
podname:nginx-pod       pod_ip:10.0.35.23
```
## 第二步:问题分析
### 若访问时出现以下现象(time out):
```
[root@VM-35-139-tlinux terraform]# curl 10.0.35.150
curl: (28) Failed to connect to 10.0.35.150 port 80: Connection timed out
```
排查方向:
```
##出现这种情况可能为pod辅助网卡安全组被开启且安全组配置不正确
[root@VM-35-179-tlinux ~]# kubectl logs -n kube-system deploy/tke-eni-ipamd | grep "Event"|grep "security groups from"|awk '{print $24}'|awk -F'[' '{print $2}'|awk -F']' '{print $1}'                            ##查询其所绑定的安全组
sg-xxxxxx            ##输出的为pod(辅助)网卡所绑定的安全组id
##查看其绑定的安全组是否允许内网ip访问服务端口如果未放通放通即可
```
# 演练环境清理
```
[root@VM-35-179-tlinux ~]# kubectl delete apply -f pod.yaml
[root@VM-35-179-tlinux ~]# terraform destroy -auto-approve
```
# 项目结构
```
VPC-CNIr_NodeAccessPod/  
├── pod.yaml      # 创建pod并指定pod绑定到对应节点上
├── create_node_tf.sh   #配置tf文件脚本
├── create_node_.template      #创建节点
├── readme.d        #本文件
├── setup_podyaml  #为pod指定节点
```


