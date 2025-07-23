# 概述
&emsp;&emsp;本方案中服务为VPV-CNI网络模式的tke集群下原生节点的直连pod(nginx)服务,演练所需安全组通过脚本方式,只为用户提供安全组id和对应绑定位置<br>
**优点：**
```
    通过自动化脚本构建安全组规则，能够精准复现真实环境中安全组配置异常的场景，使故障排查演练更贴近实际运维挑战
    用户自己对安全组进行绑定可用更好熟悉安全组配置方式，理解安全组核心配置逻辑
```
# 业务访问链路

# 前提条件
**1:tke集群要求**
```
网络模式：VPC-CNI
kubernets版本：>=1.20
至少有一个可用的原生节点
```
**2:工具准备**
```
在原生节点上配置好terraform/tccli(安装任意一种即可)
```
# 快速开始
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
将此安全组绑定到clb上: sg-xxxxx1
将此安全组绑定到pod(辅助)网卡上: sg-xxxxx2
#2:创建原生节点将上述对应安全组id进行绑定
#3:创建服务并通过注解方式为clb绑定安全组
[root@VM-35-179-tlinux ~]# cat <<EOF > addservice.sh
-----------------------------------------------------------
-------------填写脚本所需代码可参考addservice.sh文件-------------
-----------------------------------------------------------
EOF
[root@VM-35-179-tlinux ~]# sh addservice.sh
请输入要绑定到clb上的安全组id:	sg-xxxxx1
#4按照terraform——addgroup.sh脚本输出内容对pod(辅助)网卡绑定对应安全组
```
参考文件:
[原生节点创建](https://cloud.tencent.com/document/product/457/78198)<br>
[pod(辅助)网卡安全组配置](https://cloud.tencent.com/document/product/457/50360)
# 排查演练
**公网ip获取**
```
#执行下面命令查看ingress所生成的供外网访问的IP

```
**访问ip出现以下现象**
```

```
**问题分析**
```

```
**访问ip出现以下现象**
```

```
**问题分析**
```

```
# 资源清理
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

