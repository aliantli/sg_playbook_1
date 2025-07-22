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
