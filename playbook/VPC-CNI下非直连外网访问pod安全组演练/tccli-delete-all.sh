##安全组部署脚本讲生成的安全组id存储在group.txt文件内
##循环利用group.txt清安全组
#!/bin/bash
group=`cat group.txt`
for i in $group
do
    echo "正在删除安全组: $group ..."   
    tccli vpc DeleteSecurityGroup --cli-unfold-argument --SecurityGroupId "$group"
done
echo "批量删除操作完成！"
##清理deployment
echo "正在清理服务“
kubectl delete deployment nginx 
kubectl delete svc nginx
echo "清理完成"
