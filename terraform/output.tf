#masterNode의 public ip를 output에 저장
output "master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}
#workerNode의 public ip를 output에 저장
output "worker_public_ips" {
  value = [for instance in aws_instance.k8s_worker : instance.public_ip]
}
#masterNode의 private key를 output에 저장
#output "master_private_key" {
#  value = <<-EOF
#	${file("/home/ubuntu/.ssh/id_rsa")}
#	EOF
#  sensitive = true
#}

#생성된 keypair
output "private_key_pem" {
  value     = tls_private_key.k8s_key.private_key_pem
  sensitive = true
}

