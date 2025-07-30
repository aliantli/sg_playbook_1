# 概述
&emsp;安全组作为容器基础设施层的核心流量控制组件，通过节点边界实施粗粒度访问控制，为容器环境提供基础网络隔离保障。然而，用户常因安全组规则复杂性及配置方式不当导致服务不可访问，本文针对VPC-CNI 网络模式下TKE 集群中创建的两个原生节点里Pod 服务之间访问，通过引导用户分层逐步排查访问链路,最终掌握安全组配置的核心逻辑


# 访问链路

 <br>&emsp;在日常生产环境中可以通过在上述三个位置是设置安全组来限制外网流量出入，以此控制入口流量的基础过滤，实现流量的精细管控，保障Pod资源安全(pod辅助网卡处的安全组默认关闭可根据自己需求开启)

# 环境部署
## 前提条件
**1:tke集群要求**

TKE版本>=1.20.6
<br>详情可参考:https://cloud.tencent.com/document/product/457/103981<br>
网络模式:VPC-CNI<br>
详情可参考:https://cloud.tencent.com/document/product/457/50355

**2:工具准备**

配置好[terraform:v1.8.2](https://developer.hashicorp.com/terraform)
## 快速开始
**以terraform为例**<br>
 1.创建两个原生节点
```
[root@VM-35-139-tlinux terraform]# terraform apply -auto-approve
```
 2.创建两个pod访问并分别绑定在两个原生节点上

```
[root@VM-35-139-tlinux terraform]#  change_pod.sh
[root@VM-35-139-tlinux terraform]# kubectl apply -f pod.yaml
```

# 演练分析
## 第一步:获取服务公网访问ip
```
[root@VM-35-179-tlinux ~]# kubectl get service -o wide
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE     SELECTOR
kubernetes   ClusterIP      172.16.0.1      <none>           443/TCP        4h22m   <none>
nginx        LoadBalancer   172.16.60.200   119.91.244.213   80:30713/TCP   156m    app=nginx
```
## 第二步:问题分析
### 若访问时出现以下现象:
```
# curl 10.0.35.150
curl: (28) Failed to connect to 10.0.35.150 port 80: Connection timed out
```
排查方向:
```
##出现这种情况可能为pod辅助网卡安全组被开启且安全组配置不正确
[root@VM-35-179-tlinux ~]# kubectl logs -n kube-system deploy/tke-eni-ipamd | grep "Event"|grep "security groups from"|awk '{print $24}'|awk -F'[' '{print $2}'|awk -F']' '{print $1}'                            ##查询其所绑定的安全组
sg-xxxxxx            ##输出的为pod(辅助)网卡所绑定的安全组id
##查看其绑定的安全组是否允许内网ip访问服务端口如果未放通放通即可
```
# 资源清理
```
[root@VM-35-179-tlinux ~]# kubectl delete apply -f addservice.yaml
[root@VM-35-179-tlinux ~]# kubectl delete apply -f deployment.yaml
[root@VM-35-179-tlinux ~]# terraform destroy -auto-approve
```
# 项目结构
```
VPC-CNI下非直连外网访问pod安全组演练/  
├── addservice.yaml      # 配置service并为clb绑定安全组
├── create_no_sg_td.sh   #配置tf文件脚本
├──deploy_service.sh     #配置服务yaml文件脚本
├── deployment.yaml    #部署deployment
├── node_sg.tf      #创建节点和安全组并给节点绑定安全组
├── readme.d        #本文件
```

