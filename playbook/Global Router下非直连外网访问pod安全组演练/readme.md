
# 概述
&emsp;安全组作为容器基础设施层的核心流量控制组件，通过节点边界实施粗粒度访问控制，为容器环境提供基础网络隔离保障。然而，用户常因安全组规则复杂性及配置方式不当导致服务不可访问，本文针对GlobalRouter 网络模式下TKE 集群中创建的原生节点上部署的直连 Pod 服务，利用脚本创建安全组的方式模拟真实生产环境下的网络访问异常，通过引导用户分层逐步排查访问链路,最终掌握安全组配置的核心逻辑


# 访问链路

<br>在日常生产环境中常常通过在上述两个个位置是设置安全组来限制外网流量出入
# 环境部署
## 前提条件
**1:tke集群要求**

TKE版本:>=1.20.6
<br>可参考:https://cloud.tencent.com/document/product/457/103981<br>
网络模式:GlobalRouter<br>
可参考:https://cloud.tencent.com/document/product/457/50354

**2:工具准备**

集群内配置好[terraform](https://developer.hashicorp.com/terraform)
## 快速开始

### 本次以terraform工具为例
1:获取本节点名字
```
[root@VM-35-179-tlinux ~]#kubectl get nodes -o wide|awk  '{print $1}'|grep -v 'NAME' > node_name.txt
```
2:创建节点和安全组并为节点绑定安全组
```
[root@VM-35-179-tlinux ~]# terraform apply -auto-approve|tail -1 > sg_id.txt  ##根据node_sg.tf文件注解更改配置
```
3:服务部署
```
[root@VM-35-179-tlinux ~]#a=`cat node_name.txt`    
[root@VM-35-179-tlinux ~]#b=kubectl get nodes -o wide|awk  '{print $1}'|grep -v 'NAME'|grep $a  ##找出新创建的节点名字
[root@VM-35-179-tlinux ~]#sed -i 's/node_name/$b/g' deployment.yaml    ##使创建的deployment绑定到新节点上
[root@VM-35-179-tlinux ~]#kubectl apply -f seployment.yaml
[root@VM-35-179-tlinux ~]#c=`cat sg_id.txt|awk -F'"' '{print $2}'`    
[root@VM-35-179-tlinux ~]#sed -i 's/sg-id/$c/g' service.yaml    ##使创建的安全组绑定到clb上
[root@VM-35-179-tlinux ~]# kubectl apply -f service.yaml
```

# 问题分析
**获取公网ip**
```
#执行下面命令查看ingress所生成的供外网访问的IP
[root@VM-35-179-tlinux ~]# kubectl get service -o wide
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE     SELECTOR
kubernetes   ClusterIP      172.16.0.1      <none>           443/TCP        4h22m   <none>
nginx        LoadBalancer   172.16.60.200   119.91.244.213   80:30713/TCP   156m    app=nginx
```
**访问ip出现以下现象**
```
[root@VM-35-179-tlinux ~]# curl -I http://119.91.244.213
curl: (7) Failed to connect to 119.91.244.213 port 80: Connection timed out
```
**简要分析**
```
clb层面:出现这种情况一般为clb安全组配置问题，查看clb绑定的安全组，查看其是否放通http/https的监听端口
```
**访问ip出现以下现象**
```
[root@VM-35-179-tlinux ~]# curl -I http://119.91.244.213
curl: (7) Failed to connect to 119.91.244.213 port 80: Connection timed out
```
**简要分析**
```
节点层面：出现这种情况一般为节点安全组配置问题，前往节点所绑定的安全组，查看其是否放通service所绑定的主机端口和pod服务所暴露的端口，如果未放通放通即可
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
├── addservice.yaml      # 一键部署服务并为clb绑定安全组 
├── readme.md       # 本文档
├── tccli-delet-all.sh  #tccli工具示例清理脚本
├── tccli_addgroup.sh  #tccli工具示例一键创建安全组脚本
├── terraform——addgroup.tf  #terraform工具示例一键创建安全组脚本
```
