IP1=`kubectl get pods -o wide|awk '{printf $6"\n"}'|grep -v IP`
sed -i 's/<pod_ip1>/$IP1/g' pod.yaml
