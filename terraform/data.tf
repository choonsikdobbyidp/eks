#main.tf의 리소스에서 사용하는 aws_security_group
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["tst-kmh-kube-master-01"] # 기존 보안 그룹의 이름으로 변경하세요.
  }
}

