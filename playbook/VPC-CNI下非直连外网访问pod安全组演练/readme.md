# 概述
本方案通过脚本方式在tke集群内创建安全组,只为用户提供安全组id和对应绑定位置<br>
**优点：**
```
  通过脚本方式创建安全组可以更好模拟真实环境里安全组排障
  通过分析curl公网ip后出现的各种问题可以更好的理解安全组的核心逻辑
```
# 访问pod链路
 [<img width="4189" height="530" alt="a29df27e_16060273" src="https://github.com/user-attachments/assets/cf764160-5658-4c44-aadd-5ede1723fe96" />
](https://github.com/aliantli/sg_playbook_1/blob/33781e5b2ca438145665f67e67d86d79019c1309/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/image/flowchart.png)
# 前提条件
**1:tke集群要求**
```
网络模式：VPC-CNI
kubernets版本：>=1.20
至少有一个可用节点
```
**2:工具准备**
```
集群内配置好terraform/tccli(安装任意一种即可)
```
# 快速开始
### 本次以terraform工具为例

```
#1:创建安全组(脚本所需代码可从下列对应参考文件里获取)
[root@VM-35-179-tlinux ~]# touch terraform——addgroup.sh
[root@VM-35-179-tlinux ~]# echo '所要用的代码' > terraform——addgroup.sh
[root@VM-35-179-tlinux ~]# sh terraform——addgroup.sh
将此安全组绑定到节点上: sg-xxxxx1
将此安全组绑定到clb上: sg-xxxxx2
将此安全组绑定到pod(辅助)网卡上: sg-xxxxx3
#2:创建原生节点将上述对应安全组id进行绑定
#3:创建服务并通过注解方式为clb绑定安全组
[root@VM-35-179-tlinux ~]#touch  addservice.sh
[root@VM-35-179-tlinux ~]#echo '所要用的代码' > addservice.sh
[root@VM-35-179-tlinux ~]# sh addservice.sh
请输入要绑定到clb上的安全组id:	sg-xxxxx2	
#4按照terraform——addgroup.sh脚本输出内容对pod(辅助)网卡绑定对应安全组
```
参考文件:<br>[terraform_addgroup.sh](https://github.com/aliantli/sg_playbook_1/blob/23e03ca41ee3d9d72063de282f02bb76477146a5/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/c)<br>
[addservice.sh](https://github.com/aliantli/sg_playbook_1/blob/5ac7d518e42481bf563e288e8912280c3c64c713/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/add%20service.sh)<br>
[原生节点创建](https://cloud.tencent.com/document/product/457/78198)<br>
[pod(辅助)网卡安全组配置](https://cloud.tencent.com/document/product/457/50360)
# 排查演练
**公网ip获取**
```
#执行下面命令查看ingress所生成的供外网访问的IP
[root@VM-35-244-tlinux ~]# kubectl get service -o wide
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
clb层面：
```
**访问ip出现以下现象**
```
#再次curl获取到的公网ip
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
1:pod(辅助)网卡层面：
2:节点层面：
```
# 资源清理
```
[root@VM-35-179-tlinux ~]# touch  terraform_delete-all.sh
[root@VM-35-179-tlinux ~]# echo '所需代码' > terraform_delete-all.sh
[root@VM-35-179-tlinux ~]# sh terraform_delete-all.sh
资源清理完毕
```
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
