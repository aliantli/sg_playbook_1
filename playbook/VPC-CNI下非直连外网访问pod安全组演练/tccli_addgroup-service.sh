cat <<EOF > ng-deploy-service.yaml
# Deployment 配置
apiVersion: apps/v1
kind: Deployment
cat <<EOF > service.yaml
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        readinessProbe:  # 基础健康检查（CLB 依赖）
          httpGet:
            path: /
            port: 80
---
# Service 配置（绑定 CLB 及安全组）
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    service.cloud.tencent.com/security-groups: 'sg-ephmfdsf'  # 绑定安全组 ID[1,6](@ref)
spec:
  type: LoadBalancer
  selector:
    app: nginx  # 匹配 Deployment 的 Pod 标签
  ports:
    - protocol: TCP
      port: 80      # CLB 监听端口
      targetPort: 80  # 容器端口
      nodePort: 31234
EOF
##addgroup.sh 
read  -p'请输入你要创建安全组的标签key值' key
read  -p'请输入你要创建安全组标签的value值' value
echo "开始创建安全组"
group1=`tccli vpc CreateSecurityGroup --cli-unfold-argument   --GroupName TestGroup      --GroupDescription test-group-desc  --Tags.0.Value $value   --Tags.0.Key  $key  | jq -r '.SecurityGroup.SecurityGroupId' `
echo "绑定到节点安全组"
echo $group1
echo $group1 >>group.txt
a=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group1   --SecurityGroupPolicySet '{"Ingress": [{"Protocol": "ALL","CidrBlock": "0.0.0.0/0","Action": "DROP","PolicyIndex": 0,"Action": "DROP","PolicyIndex": 0}]}'`
b=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group1   --SecurityGroupPolicySet '{"Egress": [{"PolicyIndex": 0,"Protocol": "ALL","CidrBlock": "0.0.0.0/0","Action": "ACCEPT"}]}'`
group2=`tccli vpc CreateSecurityGroup --cli-unfold-argument   --GroupName TestGroup      --GroupDescription test-group-desc  --Tags.0.Value $value   --Tags.0.Key  $key  | jq -r '.SecurityGroup.SecurityGroupId' `
echo "绑定到eni安全组"
echo  $group2
echo $group2 >>group.txt
c=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group2   --SecurityGroupPolicySet '{"Ingress": [{"Protocol": "TCP","Port":80,"CidrBlock": "0.0.0.0/0","Action": "ACCEPT","PolicyIndex": 0}]}'`
d=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group2   --SecurityGroupPolicySet '{"Egress": [{"PolicyIndex": 0,"Protocol": "ALL","CidrBlock": "0.0.0.0/0","Action": "ACCEPT"}]}'`
group3=`tccli vpc CreateSecurityGroup --cli-unfold-argument   --GroupName TestGroup      --GroupDescription test-group-desc  --Tags.0.Value $value   --Tags.0.Key  $key  | jq -r '.SecurityGroup.SecurityGroupId' `
echo "绑定到clb安全组"
echo $group3
echo $group3 >>group.txt
e=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group3   --SecurityGroupPolicySet '{"Ingress": [{"Protocol": "TCP","Port":22,"CidrBlock": "0.0.0.0/0","Action": "ACCEPT","PolicyIndex": 0}]}'`
f=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group3   --SecurityGroupPolicySet '{"Egress": [{"PolicyIndex": 0,"Protocol": "ALL","CidrBlock": "0.0.0.0/0","Action": "ACCEPT"}]}'`
echo  "安全组创建完成"
