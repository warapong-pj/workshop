# Install Container Runtime
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_18.04/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list  
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.17/xUbuntu_18.04/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:1.17.list  

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:1.17/xUbuntu_18.04/Release.key | apt-key add -  
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_18.04/Release.key | apt-key add -  

apt-get update  
apt-get install -y cri-o cri-o-runc runc  

systemctl enable crio  
systemctl start crio  

# Setup System
echo 'br_netfilter' > /etc/modules  

cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF  
net.bridge.bridge-nf-call-iptables = 1  
net.bridge.bridge-nf-call-ip6tables = 1  
net.ipv4.ip_forward = 1  
EOF  

swapoff -a  

# Install Requirement Packages
apt-get update  
apt-get install -y apt-transport-https curl  

# Install Kubernetes Tools
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list  
deb https://apt.kubernetes.io/ kubernetes-xenial main  
EOF  

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -  

apt-get update  
apt-get install -y kubelet kubeadm kubectl  
apt-mark hold kubelet kubeadm kubectl  

# Initital Kubernetes Cluster
kubeadm init --control-plane-endpoint=cluster-endpoint --pod-network-cidr=10.244.0.0/16  

# Setup Access to Cluster
export KUBECONFIG=/etc/kubernetes/admin.conf  

mkdir -p $HOME/.kube  
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
sudo chown $(id -u):$(id -g) $HOME/.kube/config  

# Deploy Container Network Interface
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml  

kubectl taint nodes --all node-role.kubernetes.io/master-  

# Tear Down
1. kubectl drain ubuntu --delete-local-data --force --ignore-daemonsets  
2. kubeadm reset  
3. iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X *ipvsadm -C*  
4. kubectl delete node ubuntu  

# Get authenticate container registry and create token
cat ~/TOKEN.txt | docker login https://docker.pkg.github.com -u USERNAME --password-stdin  

### Sample file after login to container registry 
```
{
  "auths": {
    "docker.pkg.github.com": {
        "auth": "xxx"
    }
  }
}
```

kubectl create secret generic regcred --from-file=.dockerconfigjson=/path/to/config.json --type=kubernetes.io/dockerconfigjson  

# Config Host Network
```
network:
  version: 2
  ethernets: 
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.111/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

# Issue 
### LVM Disk Space
1. lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
2. resize2fs /dev/ubuntu-vg/ubuntu-lv