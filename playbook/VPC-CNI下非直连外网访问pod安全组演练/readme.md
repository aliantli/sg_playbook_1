# 概述
&emsp;&emsp;在VPC-CNI网络模式的TKE集群原生节点上部署非直连Pod(如Nginx服务),安全组通过脚本动态生成,用户仅需获取安全组ID及其绑定目标节点或pod标签),无需操作底层规则.此举可精准模拟真实环境的安全组策略冲突(如端口误放行、IP 段失效),并通过分析curl公网IP的典型故障(连接超时、端口拒绝),验证安全组的核心逻辑

# 业务访问链路
[<img width="1120" height="257" alt="Clipboard_Screenshot_1753259552" src="https://github.com/user-attachments/assets/8498cac5-6dbb-42f5-bb65-2b903eebbea0" />
](https://github.com/aliantli/sg_playbook_1/blob/5f13a3b65f06196feabb83ce06483d146f852d77/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/image/service_flow_chart.png)
# 前提条件
**1:tke集群要求**

&emsp;&emsp;[网络模式：VPC-CNI](https://cloud.tencent.com/document/product/457/103981)<br>
&emsp;&emsp;[kubernets版本：>=1.20](https://kubernetes.io/docs/tasks/tools/)<br>

**2:工具准备**

&emsp;&emsp;集群内配置好[terraform](https://developer.hashicorp.com/terraform)/[ccli](https://cloud.tencent.com/document/product/440/34012)(安装任意一种即可)

# 快速开始
## 步骤1:环境部署
### 本次以terraform工具为例

```
#脚本所需代码或配置安全组出现问题可查看对应参考文件
#1:创建安全组
[root@VM-35-179-tlinux ~]# cat <<EOF > terraform——addgroup.tf
-----------------------------------------------------------
---------填写脚本所需代码可参考terraform——addgroup.tf文件--------
-----------------------------------------------------------
EOF
[root@VM-35-179-tlinux ~]# terraform apply -auto-approve |tail -3
将此安全组绑定到clb上 = "sg-xxxxxxxx"    ##该安全组对clb访问节点的入站流量进行阻断出站流量放通
将此安全组绑定到eni上 = "sg-xxxxxxxx"    ##该安全组对外网访问clb的入站流量进行阻断出站流量放通
将此安全组绑定到节点上 = "sg-xxxxxxxx"    ##该安全组对节点到pod(辅助)网卡的入站流量进行阻断出站流量放通
#2:创建原生节点将上述对应安全组id进行绑定
#3:创建服务并通过注解方式为clb绑定安全组
[root@VM-35-179-tlinux ~]# cat <<EOF > addservice.yaml
---------------------------------------------------------------------
-填写脚本所需代码可参考addservice.yaml文件，需根据上面输出替换掉yaml文件里的安全组-
---------------------------------------------------------------------
EOF
[root@VM-35-179-tlinux ~]# kubectl apply -f addservice.yaml
#4按照terraform——addgroup.sh脚本输出内容对pod(辅助)网卡绑定对应安全组
```
参考文件:<br>[terraform_addgroup.tf](https://github.com/aliantli/sg_playbook_1/blob/4bf57c58c5268102d1276e2b6aa683e4812e3247/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/terraform_addgroup.tf)&emsp;&emsp;
[addservice.yaml](https://github.com/aliantli/sg_playbook_1/blob/de60eb196079c2188615d0b6a66b5989de0a0e1d/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/addservice.yaml)<br>
[原生节点创建](https://cloud.tencent.com/document/product/457/78198)&emsp;&emsp;
[pod(辅助)网卡安全组配置](https://cloud.tencent.com/document/product/457/50360)
## 步骤2:问题分析
**公网ip获取**
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
HTTP/1.1 504 Gateway Time-out
Server: stgw
Date: Tue, 22 Jul 2025 12:41:43 GMT
Content-Type: text/html
Content-Length: 159
Connection: keep-alive
```
**简要分析**
```
出现这种现象一般分为以下两种情况
1:pod(辅助)网卡层面：前往pod(辅助)网卡所绑定的安全组，查看其是否放通pod服务端口，如果未放通放通即可
2:节点层面：前往节点所绑定的安全组，查看其是否放通service所绑定的主机端口，如果未放通放通即可
```
## 步骤3:资源清理
```
[root@VM-35-179-tlinux ~]# kubectl delete apply -f addservice.yaml
[root@VM-35-179-tlinux ~]# terraform destroy -auto-approve
[root@VM-35-179-tlinux ~]# rm -f terraform——addgroup.tf  addservice.yaml
```
**项目结构**
```
VPC-CNI下非直连外网访问pod安全组演练/  
├── addservice.yaml      # 一键部署服务并为clb绑定安全组 
├── readme.md       # 本文档
├── tccli-delet-all.sh  #tccli工具示例清理脚本
├── tccli_addgroup.sh  #tccli工具示例一键创建安全组脚本
├── terraform——addgroup.tf  #terraform工具示例一键创建安全组脚本
```
