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

#CNI plugin 설치
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz


sudo apt-get update -y > /var/tmp/user_data.log 2>&1
sudo apt-get install -y apt-transport-https curl gpg > /var/tmp/user_data.log 2>&1

sudo apt-get install -y net-tools


#firewall setting
sudo apt install firewalld -y

sudo firewall-cmd --zone=public --permanent --add-port=179/tcp
sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10250/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10251/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10252/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
sudo firewall-cmd --reload


sudo iptables -A INPUT -p tcp --dport 179 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 23 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10250 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT




sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow 23/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 6443/tcp
sudo ufw status

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list




sudo apt-get update -y | tee -a ~/result.txt
sudo apt-get install -y docker.io kubelet kubeadm kubectl > /var/tmp/install_kube.log 2>&1
sudo apt-mark hold kubelet kubeadm kubectl | tee -a ~/result.txt

sudo systemctl enable docker
sudo systemctl start docker

sudo systemctl enable kubelet
sudo systemctl start kubelet


ip=$(hostname -i)

#set hostname
sudo hostnamectl set-hostname ${tags}



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


PORT=8080
echo $(hostname -i) | awk -F' ' '{print $1}' > /home/ubuntu/worker_ip



MY_CIDR="$(cat /home/ubuntu/worker_ip)/0"

echo "SECURITY_GROUP_ID:${SECURITY_GROUP_ID}"
echo "MY_CIDR:$MY_CIDR"

aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port $PORT \
    --cidr $MY_CIDR

aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 179 \
    --cidr $MY_CIDR




MY_CIDR="127.0.0.1/32"

aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port $PORT \
    --cidr $MY_CIDR


MY_CIDR="${MASTER_PRIVATE_IP}/0"

aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 10250\
    --cidr $MY_CIDR


if [ $? -eq 0 ]; then
    echo "Successfully added inbound rule to security group $SECURITY_GROUP_ID for IP $MY_CIDR on port $PORT."
else
    echo "Failed to add inbound rule to security group $SECURITY_GROUP_ID."
fi


MASTER_INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=KMH-TST-K8S-MASTER" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)


echo "master_instance_id : "$MASTER_INSTANCE_ID

echo "get kube_token_cmd"
echo `aws ec2 describe-tags --filters "Name=resource-id,Values=$MASTER_INSTANCE_ID" "Name=key,Values=kube_token" --query "Tags[?Key=='kube_token'].Value" --output text`
echo `aws ec2 describe-tags --filters "Name=resource-id,Values=$MASTER_INSTANCE_ID" "Name=key,Values=kube_token" --query "Tags[?Key=='kube_token'].Value" --output text` > /var/tmp/kube_token_cmd


COUNT=0
while true; do
	aws ec2 describe-tags --filters "Name=resource-id,Values=$MASTER_INSTANCE_ID" "Name=key,Values=kube_token" --query "Tags[?Key=='kube_token'].Value" --output text > /var/tmp/kube_token_cmd
	cat /var/tmp/kube_token_cmd
	if [[ "$(cat /var/tmp/kube_token_cmd)" == *"kubeadm join"* ]]; then
		echo "join this node: $(hostname)"
		break
	elif [ $COUNT -ge 10 ]; then
		echo "COUNT 10. Loop end."
		break
	else 
		echo "join worker node fail. try again..."
		((COUNT++))
		sleep 20
	fi
done


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

echo $MASTER_INSTANCE_ID
sudo chmod +x /var/tmp/kube_token_cmd
echo $(cat /var/tmp/kube_token_cmd) " --cri-socket unix:///var/run/cri-dockerd.sock" > /var/tmp/kube_token_cmd
echo "after kube_token_cmd : " $(cat /var/tmp/kube_token_cmd)
sudo /var/tmp/kube_token_cmd

#calico 설치
echo "calico install"
curl https://docs.projectcalico.org/manifests/calico.yaml -O --insecure
echo $(cat calico.yaml | cut -d ' ' -f 3) > calico.yaml
curl $(cat calico.yaml) > calico.yaml

#scp master kubeconfig 가져오기
echo "scp master kubeconfig get"

mkdir -p /home/ubuntu/.ssh


mv /home/ubuntu/k8s_key_pair.pem /home/ubuntu/.ssh/id_rsa
chown -R ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa
chmod 600 /home/ubuntu/.ssh/id_rsa
mkdir -p /home/ubuntu/.kube/

chown -R ubuntu:ubuntu /home/ubuntu/.kube/
chmod 700 /home/ubuntu/.kube


# SCP 파일 전송
# master node에 있는kubeconfig을 가져와야 calico 세팅 됨
scp -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER_PRIVATE_IP}:/home/ubuntu/.kube/config /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube/
sudo chmod 600 /home/ubuntu/.kube/config

sudo -u ubuntu kubectl apply -f calico.yaml


mkdir -p /var/lib/cni/networks
mkdir -p /var/run/calico
mkdir -p /var/lib/calico
mkdir -p /var/log/calico/cni

