##addgroup.sh 

echo "开始创建安全组"
group1=`tccli vpc CreateSecurityGroup --cli-unfold-argument   --GroupName TestGroup      --GroupDescription test-group-desc  --Tags.0.Value $value   --Tags.0.Key  $key  | jq -r '.SecurityGroup.SecurityGroupId' `
echo "绑定到节点安全组"
echo $group1
echo $group1 >>group.txt
rule1="'{
"Ingress": [{
"Protocol": "ALL",
"CidrBlock": "0.0.0.0/0",
"Action": "DROP",
"PolicyIndex": 0,
"Action": "DROP",
"PolicyIndex": 0
}]}'"
rule2="'{
"Egress": [{
"PolicyIndex": 0,
"Protocol": "ALL",
"CidrBlock": "0.0.0.0/0",
"Action": "ACCEPT"
}]}'"
a=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group1   --SecurityGroupPolicySet $rule1`
b=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group1   --SecurityGroupPolicySet $rule2`
group2=`tccli vpc CreateSecurityGroup --cli-unfold-argument   --GroupName TestGroup      --GroupDescription test-group-desc  --Tags.0.Value $value   --Tags.0.Key  $key  | jq -r '.SecurityGroup.SecurityGroupId' `
echo "绑定到eni安全组"
echo  $group2
echo $group2 >>group.txt
rule3="'{
"Ingress": [{
"Protocol": "TCP",
"Port":80,
"CidrBlock": "0.0.0.0/0",
"Action": "ACCEPT",
"PolicyIndex": 0
}]}'"
rule4="'{
"Egress": [{
"PolicyIndex": 0,
"Protocol": "ALL",
"CidrBlock": "0.0.0.0/0",
"Action": "ACCEPT"
}]}'"
c=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group2   --SecurityGroupPolicySet $rule3`
d=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group2   --SecurityGroupPolicySet $rule4`
group3=`tccli vpc CreateSecurityGroup --cli-unfold-argument   --GroupName TestGroup      --GroupDescription test-group-desc  --Tags.0.Value $value   --Tags.0.Key  $key  | jq -r '.SecurityGroup.SecurityGroupId' `
echo "绑定到clb安全组"
echo $group3
echo $group3 >>group.txt

rule5="'{
"Ingress": [{
"Protocol": "TCP",
"Port":22,
"CidrBlock": "0.0.0.0/0",
"Action": "ACCEPT",
"PolicyIndex": 0}]}'"
rule6="'{
"Egress":[{
"PolicyIndex": 0,
"Protocol": "ALL",
"CidrBlock": "0.0.0.0/0",
"Action": "ACCEPT"}]}'"
e=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group3   --SecurityGroupPolicySet $rule5`
f=`tccli vpc CreateSecurityGroupPolicies  --SecurityGroupId $group3   --SecurityGroupPolicySet $rule6`
echo  "安全组创建完成"
