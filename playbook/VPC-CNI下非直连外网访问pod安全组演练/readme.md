# 背景
安全组在容器层面是基础设施级的流量守门员，通过节点边界的粗粒度过滤，为容器环境提供基础网络隔离，本playbook旨在引导用户通过排查安全组故障，最终掌握eni模式下原生节点非直连pod的安全组核心配置逻辑
本次操作以ingress下clb类型为例
# 访问pod链路
 
# 前置条件
已创建VPC-CNI模式集群，并创建一个可用节点且配置kubectl已配置访问权限
集群内安装并配置好terraform或tccli任意一个工具本次以terraform为例
安装jq命令行工具
# 环境准备
1:创建安全组<br>
参考文件:[terraform_addgroup.sh](https://github.com/aliantli/sg_playbook_1/blob/23e03ca41ee3d9d72063de282f02bb76477146a5/playbook/VPC-CNI%E4%B8%8B%E9%9D%9E%E7%9B%B4%E8%BF%9E%E5%A4%96%E7%BD%91%E8%AE%BF%E9%97%AEpod%E5%AE%89%E5%85%A8%E7%BB%84%E6%BC%94%E7%BB%83/c)
```
#创建terraform——addgroup.sh文件
执行下列命令
[root@VM-35-179-tlinux ~]# sh terraform——addgroup.sh
将此安全组绑定到节点上:
将此安全组绑定到clb上:
将此安全组绑定到pod(辅助)网卡上:
```
2:创建原生节点并绑定对应安全组到节点上
3:服务部署
```
#创建addservice.sh
执行下列命令
[root@VM-35-179-tlinux ~]# sh addservice.sh

```
4:按照上面输出绑定eni安全组

到此环境已经部署好了可以开始演练了
# 为何通过上述方式创建演练环境
1，通过脚本方式创建安全组可以使用户不知道安全组配置内容，模拟真实环境下访问故障
2，通过手动绑定安全组可以使用户对tke环境更为熟悉
3，浏览器或节点curl公网ip出现不同问题后通过一步步排查更深刻理解安全组的核心逻辑
# 问题排查方向
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
