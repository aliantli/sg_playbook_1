read -p'输入集群标签的key值:' key 
read -p'输入集群标签的values值:' values
read -p'输入集群id:' cls_id
read -p'输入集群的子网id:' sub_net
sed -e "s/<key>/$key/g" -e "s/<values>/$values/g" -e "s/<cls-id>/$cls_id/g" -e "s/<sub-id>/$sub_net/g" lx.txt > no_sg.tf        
terraform apply -auto-approve
