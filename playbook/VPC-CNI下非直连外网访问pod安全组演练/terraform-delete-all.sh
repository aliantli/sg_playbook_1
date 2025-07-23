echo '' > group.tf
terraform plan
terraform apply
kubectl delete apply -f ng-deploy-service.yaml
