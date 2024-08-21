
#####################
#     provider
#####################

provider "aws" {
  region = "ap-northeast-2" //아시아 태평양(서울) 리전
}

#####################
#   security_group
#####################
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = "vpc-0e0171d1b781bebef"

  # SSH 접근 허용
  ingress {
    from_port   = 22
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 쿠버네티스 API 서버 접근 허용
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # etcd 서버 접근 허용
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # kubelet 서버 접근 허용
  ingress {
    from_port   = 10248
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Readiness probe 서버 접근 허용
  ingress {
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  # 노드 간 통신 허용
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["127.0.0.1/32"]
  }


  # 로컬 접속
  ingress {
    from_port   = 22
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["124.243.13.157/32"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}



#####################
#     KeyPair
#####################

resource "tls_private_key" "k8s_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "k8s_key_pair" {
  key_name   = "k8s_key_pair"
  public_key = tls_private_key.k8s_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.k8s_key.private_key_pem
  filename        = "/home/ubuntu/.ssh/k8s_key_pair.pem"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = aws_key_pair.k8s_key_pair.public_key
  filename        = "/home/ubuntu/.ssh/k8s_key_pair.pub"
  file_permission = "0600"
}



#####################
#     masterNode
#####################

resource "aws_instance" "k8s_master" {
  ami           = "ami-0f6fd022a077cae2d" # Ubuntu 20.04 LTS AMI
  instance_type = "t3.xlarge"             # aws instance type  
  key_name      = aws_key_pair.k8s_key_pair.key_name
  #  vpc_security_group_ids = [                 # aws security group (array)
  #	data.aws_security_group.existing_sg.id
  #  ]
  subnet_id       = "subnet-03e78f7f15cfa96ac"
  security_groups = [aws_security_group.k8s_sg.id]
  depends_on      = [local_file.private_key]

  lifecycle {
    create_before_destroy = true # instance 업데이트시 생성 후 기존 instance 삭제
  }

  user_data = templatefile("./user_data_master.sh.tpl", {
    #    SECURITY_GROUP_ID = data.aws_security_group.existing_sg.id
    #    IP = aws_instance.k8s_master.public_ip
    SECURITY_GROUP_ID = aws_security_group.k8s_sg.id
    AWS_ACCESS_KEY_ID = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
    KMH_GIT_PRIVATE_REPO  = var.KMH_GIT_PRIVATE_REPO
  })

  # instance tags
  tags = {
    Name         = "KMH-TST-K8S-MASTER"
    AutoSchedule = "True"
  }

  provisioner "file" {
    source      = "/home/ubuntu/.ssh/"
    destination = "/home/ubuntu/"
  }

  #  provisioner "file" {
  #    source      = "/home/ubuntu/k8s_key_pair.pem"
  #    destination = "/home/ubuntu/.ssh/id_rsa"
  #
  #  }

  connection {
    type = "ssh"
    user = "ubuntu"
    #   private_key = file("/home/ubuntu/k8s_key_pair.pem")
    private_key = tls_private_key.k8s_key.private_key_pem
    host        = self.public_ip
  }


}

######################                                                                                               
#     workerNode
######################

resource "aws_instance" "k8s_worker" {
  count         = 2
  ami           = "ami-0f6fd022a077cae2d" # Ubuntu 20.04 LTS AMI
  instance_type = "t3.medium"             # aws instance type 
  key_name      = aws_key_pair.k8s_key_pair.key_name
  #  vpc_security_group_ids = [                 # aws security group (array)
  #	data.aws_security_group.existing_sg.id    
  #  ]

  #  depends_on=[null_resource.fetch_public_key]
  depends_on      = [aws_instance.k8s_master]
  security_groups = [aws_security_group.k8s_sg.id]
  subnet_id       = "subnet-03e78f7f15cfa96ac"

  lifecycle {
    create_before_destroy = true # instance 업데이트시 생성 후 기존 instance 삭제
  }

  user_data = templatefile("./user_data_worker.sh.tpl", {
    master_instance_id = aws_instance.k8s_master.id          # k8s_master 인스턴스의 id 전달
    tags               = "KMH-TST-K8S-WORKER-${count.index}" # 태그 생성
    SECURITY_GROUP_ID  = aws_security_group.k8s_sg.id
    MASTER_PUBLIC_IP   = aws_instance.k8s_master.public_ip
    MASTER_PRIVATE_IP  = aws_instance.k8s_master.private_ip
    AWS_ACCESS_KEY_ID  = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
  })

  # instance tags
  tags = {
    Name         = "KMH-TST-K8S-WORKER-${count.index}"
    AutoSchedule = "True"
  }


  provisioner "file" {
    source      = "/home/ubuntu/.ssh/"
    destination = "/home/ubuntu/"
  }

  #  provisioner "file" {
  #    source      = "/home/ubuntu/k8s_key_pair.pem"
  #    destination = "/home/ubuntu/.ssh/id_rsa"
  #
  #  }




  connection {
    type = "ssh"
    user = "ubuntu"
    #   private_key = file("/home/ubuntu/k8s_key_pair.pem")
    private_key = tls_private_key.k8s_key.private_key_pem
    host        = self.public_ip
  }

}


