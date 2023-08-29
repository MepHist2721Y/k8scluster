#!/bin/bash

echo "Enter username"
read username
echo "Enter Validity"
read validity

cd /home/master/K8s

mkdir userAuthentication

cd userAuthentication

mkdir $username

openssl genrsa -out /home/master/K8s/userAuthentication/$username/$username.key 2048

openssl req -new -key /home/master/K8s/userAuthentication/$username/$username.key -out /home/master/K8s/userAuthentication/$username/$username.csr -subj /CN=$username

openssl x509 -req -in /home/master/K8s/userAuthentication/$username/$username.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /home/master/K8s/userAuthentication/$username/$username.crt -days $validity

kubectl create namespace $username

kubectl config set-credentials $username --client-certificate=/home/master/K8s/userAuthentication/$username/$username.crt --client-key=/home/master/K8s/userAuthentication/$username/$username.key

kubectl config set-context $username --cluster=kubernetes --namespace=$username --user=$username

sed -n '1,9 p' /etc/kubernetes/admin.conf  > /home/master/K8s/userAuthentication/$username/$username.config

cat <<EOT >> /home/master/K8s/userAuthentication/$username/$username.config
    namespace: $username
    user: $username
  name: $username
current-context: $username
kind: Config
preferences: {}
users:
- name: $username
  user:
    client-certificate: $username.crt
    client-key: $username.key
EOT
echo "New User Added"
echo "Enter password for New User"

read password

useradd -m -s /bin/bash $username

echo "$username:$password" | sudo chpasswd

mkdir /home/$username/.kube

cd /home/master/K8s/userAuthentication/$username

cp * /home/$username/.kube

chown -R $username:$username /home/$username/.kube

