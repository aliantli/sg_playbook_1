read  -p'输入集群的标签的key值' $key
read  -p'输入集群的标签的values值' $values
read  -p'输入集群的id' $cls_id
read  -p'输入集群的子网id' $sub_net
sed -e "s/<key>/$key/g" -e "s/<values>/$values/g" -e "s/<cls_id>/$cls_id/g" -e "s/<sub_net>/$sub_net/g" no_sg.txt > no_sg.tf        ##创建节点和安全组的tf文件 
terraform apply -auto-approve
