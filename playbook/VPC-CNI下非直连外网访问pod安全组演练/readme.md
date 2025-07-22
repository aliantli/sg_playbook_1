# 概述
本方案通过脚本方式在tke集群内创建安全组只为用户提供安全组id和绑定位置<br>
```
使用本方案优点
    ·通过脚本方式创建安全组可以更好模拟真实环境里安全组排障
    ·通过分析curl公网ip后出现的各种问题可以更好的理解安全组的核心逻辑
```
# 访问pod链路
 
# 前提条件
### 1:tke集群要求<br>
``
网络模式：VPC-CNI
``<br>
``
kubernets版本：>=1.20
``<br>
``
至少有一个可用节点
``
### 2:工具准备
集群内配置好terraform/tccli(安装任意一种即可)
# 快速开始
### 本次以terraform工具为例
参考文件:[terraform_addgroup.sh](https://github.com/aliantli/sg_playbook_1/blob/23e03ca41ee3d9d72063de282f02bb76477146a5/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/c)
```
#1:创建安全组
[root@VM-35-179-tlinux ~]# touch terraform——addgroup.sh
[root@VM-35-179-tlinux ~]# echo '所要用的代码' > terraform——addgroup.sh
[root@VM-35-179-tlinux ~]# sh terraform——addgroup.sh
将此安全组绑定到节点上:
将此安全组绑定到clb上:
将此安全组绑定到pod(辅助)网卡上:
#2:创建原生节点将上述对应安全组id进行绑定
#3:创建服务并通过注解方式为clb绑定安全组
[root@VM-35-179-tlinux ~]#touch  addservice.sh
[root@VM-35-179-tlinux ~]#echo '所要用的代码' > addservice.sh
[root@VM-35-179-tlinux ~]# sh addservice.sh
请输入要绑定到clb上的安全组id:		#此处以	为例
#4按照terraform——addgroup.sh脚本输出内容对pod(辅助)网卡绑定对应安全组
```
到此环境已经部署好了可以开始演练了
# 排查演练
```
#执行下面命令查看ingress所生成的供外网访问的IP
[root@VM-35-244-tlinux ~]# kubectl get service -o wide
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE     SELECTOR
kubernetes   ClusterIP      172.16.0.1      <none>           443/TCP        4h22m   <none>
nginx        LoadBalancer   172.16.60.200   119.91.244.213   80:30713/TCP   156m    app=nginx
#执行curl命令访问,返回200即为成功
[root@VM-35-22-tlinux ~]# curl -I http://119.91.244.213:80
```
1:访问出现502
排查方式：
该模式下非直连pod出现502一般为clb安全组配置有问题,检查clb安全组配置，看是否放通ingress的监听端口，端口可在控制台-->集群-->服务与路由-->ingress-->更新转发配置 里查到
参考下图
![输入图片说明](https://foruda.gitee.com/images/1752673737686125089/96caf20d_16060273.png "Clipboard_Screenshot_1752670266.png")
2:访问出现504
该模式下出现504一般为节点或者弹性网卡安全组配置问题
2.1节点安全组
排查方式：
在非pod所在节点执行：
	telnet node_ip  主机端口
输出如下代表未放通对应端口
 	Trying node_ip...
前往节点所绑定安全组修改规则
路径:控制台-->集群-->自己所创集群-->节点管理-->点击节点名-->详情-->安全组名
放通service服务所设置的主机端口
该端口可在：控制台-->集群-->服务与路由-->service-->service_name-->更新配置  	里查到
可参照下图
![输入图片说明](https://foruda.gitee.com/images/1752673743195239787/ba5a262a_16060273.png "Clipboard_Screenshot_1752669443.png")
2.2弹性网卡安全组
排查方式
如果节点端口正常再进入弹性网卡绑定安全组查看是否放通service所绑定的服务端口
查看路径：控制台-->集群-->服务与路由-->ingress-->更新转发配置 
可参考下图
![输入图片说明](https://foruda.gitee.com/images/1752673737686125089/96caf20d_16060273.png "Clipboard_Screenshot_1752670266.png")
# 资源清理
复制deletegroup.sh文件创建脚本执行即可
