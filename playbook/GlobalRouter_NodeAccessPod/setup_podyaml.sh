IP1=`kubectl get nodes -l test11=test21 -o jsonpath='{.items[*].metadata.name}'`
sed -i 's/<node_ip1>/$IP1/g' pod.yaml
