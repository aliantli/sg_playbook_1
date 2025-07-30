IP1=`kubectl get pods -o wide|awk '{printf $1"\t"$6"\n"}'|grep -v "NAME"|grep -v IP|head -1`
IP2=`kubectl get pods -o wide|awk '{printf $1"\t"$6"\n"}'|grep -v "NAME"|grep -v IP|tail -1`
sed -i 's/<pod_ip1>/$IP1/g' pod.yaml
sed -i 's/<pod_ip2>/$IP2/g' pod.yaml
