# 概述
&emsp;&emsp;在VPC-CNI网络模式的TKE集群原生节点上部署非直连Pod(如Nginx服务),安全组通过脚本动态生成,用户仅需获取安全组ID及其绑定目标节点或pod标签),无需操作底层规则.此举可精准模拟真实环境的安全组策略冲突(如端口误放行、IP 段失效),并通过分析curl公网IP的典型故障(连接超时、端口拒绝),验证安全组对流量方向(入站/出站),协议控制(TCP/UDP)及优先级冲突的核心逻辑。

# 业务访问链路
[<img width="1110" height="112" alt="Clipboard_Screenshot_1753240236" src="https://github.com/user-attachments/assets/cfb3a1e2-77a0-4f93-b25b-2734c353acfa" />
](https://github.com/aliantli/sg_playbook_1/blob/b20254ac7a931bcc08bcf2ab5afc51a87a643052/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/image/flow_chart.png)
# 前提条件
**1:tke集群要求**

&emsp;&emsp;网络模式：VPC-CNI<br>
&emsp;&emsp;kubernets版本：>=1.20<br>
&emsp;&emsp;至少有一个可用节点

**2:工具准备**

&emsp;&emsp;集群内配置好terraform/tccli(安装任意一种即可)

# 快速开始
## 步骤1:环境部署
### 本次以terraform工具为例

```
#脚本所需代码或配置安全组出现问题可查看对应参考文件
#1:创建安全组
[root@VM-35-179-tlinux ~]# cat <<EOF > terraform——addgroup.sh
-----------------------------------------------------------
---------填写脚本所需代码可参考terraform——addgroup.sh文件--------
-----------------------------------------------------------
EOF
[root@VM-35-179-tlinux ~]# sh terraform——addgroup.sh
将此安全组绑定到节点上: sg-xxxxx1
将此安全组绑定到clb上: sg-xxxxx2
将此安全组绑定到pod(辅助)网卡上: sg-xxxxx3
#2:创建原生节点将上述对应安全组id进行绑定
#3:创建服务并通过注解方式为clb绑定安全组
[root@VM-35-179-tlinux ~]# cat <<EOF > addservice.sh
-----------------------------------------------------------
-------------填写脚本所需代码可参考addservice.sh文件-------------
-----------------------------------------------------------
EOF
[root@VM-35-179-tlinux ~]# sh addservice.sh
请输入要绑定到clb上的安全组id:	sg-xxxxx2	
#4按照terraform——addgroup.sh脚本输出内容对pod(辅助)网卡绑定对应安全组
```
参考文件:<br>[terraform_addgroup.sh](https://github.com/aliantli/sg_playbook_1/blob/23e03ca41ee3d9d72063de282f02bb76477146a5/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/c)<br>
[addservice.sh](https://github.com/aliantli/sg_playbook_1/blob/5ac7d518e42481bf563e288e8912280c3c64c713/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/add%20service.sh)<br>
[原生节点创建](https://cloud.tencent.com/document/product/457/78198)<br>
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
**问题分析**
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
**问题分析**
```
出现这种现象一般分为以下两种情况
1:pod(辅助)网卡层面：前往pod(辅助)网卡所绑定的安全组，查看其是否放通pod服务端口，如果未放通放通即可
2:节点层面：前往节点所绑定的安全组，查看其是否放通service所绑定的主机端口，如果未放通放通即可
```
## 步骤3:资源清理
```
#脚本所需代码可查看下列参考文件
[root@VM-35-179-tlinux ~]# cat <<EOF > terraform_delete-all.sh
-----------------------------------------------------------
------填写脚本所需代码可参考terraform_delete-all.sh文件----------
-----------------------------------------------------------
EOF
[root@VM-35-179-tlinux ~]# sh terraform_delete-all.sh
资源清理完毕
```
参考文件：[terraform_delete-all.sh](https://github.com/aliantli/sg_playbook_1/blob/3dd794359187c885fc89f41336fe582e96e2cd91/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/terraform-delete-all.sh)<br>
**项目结构**
```
VPC-CNI下非直连外网访问pod安全组演练/  
├── addservice.sh       # 一键部署服务并为clb绑定安全组 
├── readme.md       # 本文档
├── tccli-delet-all.sh  #tccli工具示例清理脚本
├── tccli_addgroup.sh  #tccli工具示例一键创建安全组脚本
├── terraform_delete.sh     # terraform工具示例清理脚本  
├── terraform——addgroup.sh  #terraform工具示例一键创建安全组脚本
```
