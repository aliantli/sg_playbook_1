#临时文档方便快速配置terraform
curl -LO https://releases.hashicorp.com/terraform/1.8.2/terraform_1.8.2_linux_amd64.zip  
unzip terraform_1.8.2_linux_amd64.zip
sudo mv terraform /usr/local/bin
export TENCENTCLOUD_SECRET_ID=""
export TENCENTCLOUD_SECRET_KEY=""
cat <<EOF > ~/.terraform
provider_installation {
  network_mirror {
    url = "https://mirrors.tencent.com/terraform/"  # 腾讯云官方镜像源
    include = ["registry.terraform.io/tencentcloudstack/*"]  # 显式包含腾讯云 Provider
  }
  # 其他 Provider 走默认源（可选）
  direct {
    exclude = ["registry.terraform.io/tencentcloudstack/*"]
  }
}
EOF
cat <<EOF > main.tf

vim main.tf
terraform {
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "~>1.82.0" 
    }
  }
}
EOF
