echo '' > group.tf
terraform plan
terraform apply
kubectl delete apply -f ng-deploy-service.yaml
echo '资源清理完毕'
