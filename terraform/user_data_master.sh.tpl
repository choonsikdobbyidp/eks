#!/bin/bash
#

# swap off
sudo swapoff -a
	      
#EBS mount
sudo mkfs.ext4 /dev/nvme1n1
sudo mkdir /data -p
echo '/dev/nvme1n1 /data ext4 defaults 0 0' | sudo tee -a /etc/fstab > /dev/null
sudo mount -a

# network plugin setting
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl prarams setting
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables    = 1
net.bridge.bridge-nf-call-ip6tables   = 1
net.ipv4.ip_forward                   = 1
EOF

sudo sysctl --system

#runc 설치
wget https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc


sudo apt-get update -y > /var/tmp/user_data.log 2>&1
sudo apt-get install -y apt-transport-https curl gpg > /var/tmp/user_data.log 2>&1

sudo apt-get install -y net-tools


#firewall setting
sudo apt install firewalld -y




sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10250/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10251/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10252/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10253/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10254/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10255/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10256/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10257/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10258/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10259/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow 23/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 6443/tcp
sudo ufw status

sudo iptables -A INPUT -p tcp --dport 179 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 23 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10250 -j ACCEPT


sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


mv /home/ubuntu/k8s_key_pair.pem /home/ubuntu/.ssh/id_rsa
chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa



sudo apt-get update -y | tee -a ~/result.txt
sudo apt-get install -y docker.io kubelet kubeadm kubectl > /var/tmp/install_kube.log 2>&1
sudo apt-mark hold kubelet kubeadm kubectl | tee -a ~/result.txt

sudo systemctl enable docker
sudo systemctl start docker

sudo systemctl enable kubelet
sudo systemctl start kubelet

sudo usermod -a -G docker ubuntu

#set hostname
sudo hostnamectl set-hostname k8sMasterNode

#cri-dockerd 설치
echo "cri-dockerd install"
sudo snap install go --classic
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
mkdir bin
sudo go build -o bin/cri-dockerd
sudo cp bin/cri-dockerd /usr/bin
sudo cp packaging/systemd/* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket



ip=echo $(hostname -i) | awk -F' ' '{print $1}'



sudo kubeadm init --ignore-preflight-errors=all --apiserver-advertise-address=$ip --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock | tee /var/tmp/kubeadm_init.log 2>&1
sudo tail -q -n 2 /var/tmp/kubeadm_init.log > /var/tmp/kube_token_cmd



#aws 설치 및 세팅
sudo snap install aws-cli --classic

sudo aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
sudo aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
sudo aws configure set default.region ap-northeast-2
sudo aws configure set default.output json

echo "after aws configure set"
aws configure list

echo "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" | tee -a /home/ubuntu/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" | tee -a /home/ubuntu/.bashrc
echo "export AWS_DEFAULT_REGION=ap-northeast-2" | tee -a /home/ubuntu/.bashrc
echo "export AWS_DEFAULT_OUTPUT=json" | tee -a /home/ubuntu/.bashrc
su - ubuntu -c 'source /home/ubuntu/.bashrc'


sudo mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

#calico 설치
curl https://docs.projectcalico.org/manifests/calico.yaml -O --insecure
echo $(cat calico.yaml | cut -d ' ' -f 3) > calico.yaml
curl $(cat calico.yaml) > calico.yaml
kubectl apply -f calico.yaml --validate=false

sudo firewall-cmd --add-port=179/tcp --permanent
sudo firewall-cmd --add-port=4789/udp --permanent
sudo firewall-cmd --add-port=5473/tcp --permanent
sudo firewall-cmd --add-port=443/tcp --permanent
sudo firewall-cmd --add-port=6443/tcp --permanent
sudo firewall-cmd --add-port=2379/tcp --permanent
sudo firewall-cmd --reload


#현재 master node에 worker node에서 사용할 cmd를 tag로 저장
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id > /var/tmp/instance_id

INSTANCE_ID=$(cat /var/tmp/instance_id)
echo "instance id : $INSTANCE_ID"
echo "kube_token_cmd : $(cat /var/tmp/kube_token_cmd)"

aws ec2 create-tags --resources $INSTANCE_ID --tags Key=kube_token,Value="$(sed ':a;N;$!ba;s/\\\n//g' /var/tmp/kube_token_cmd)"


PORT=6443

echo $(hostname -i) | awk -F' ' '{print $1}' > /home/ubuntu/master_ip



MY_CIDR="$(cat /home/ubuntu/master_ip)/32"

echo "SECURITY_GROUP_ID:${SECURITY_GROUP_ID}"
echo "MY_CIDR:$MY_CIDR"

aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port $PORT \
    --cidr $MY_CIDR

MY_CIDR="$(cat /home/ubuntu/master_ip)/32"
aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 23 \
    --cidr $MY_CIDR

MY_CIDR="$(cat /home/ubuntu/master_ip)/32"
aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 179 \
    --cidr $MY_CIDR



if [ $? -eq 0 ]; then
    echo "Successfully added inbound rule to security group $SECURITY_GROUP_ID for IP $MY_CIDR on port $PORT."
else
    echo "Failed to add inbound rule to security group $SECURITY_GROUP_ID."
fi

#kubectl apply -f calico.yaml --validate=false
sudo -u ubuntu kubectl apply -f calico.yaml

mkdir -p /var/lib/cni/networks
mkdir -p /var/run/calico
mkdir -p /var/lib/calico

#create namespace
sudo -u ubuntu kubectl create namespace test

#git source clone 
echo "git source clone"
#private repository 접근
sudo -u ubuntu git config --global url."${KMH_GIT_PRIVATE_REPO}".insteadOf "https://github.com/vaudgnsv"

cd /home/ubuntu/
sudo -u ubuntu git clone https://github.com/vaudgnsv/nginx.git

kubectl apply -f /home/ubuntu/nginx/nginx-deployment.yaml -n test

#k8s create service
kubectl expose deployment nginx-deployment -n test --type NodePort

