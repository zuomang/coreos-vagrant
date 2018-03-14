#!/bin/bash
set -ex

# master

if [[ -f /opt/bin/ready ]]; then
    echo 'Server already initialized'
    exit 0
fi

# hosts
cat > /etc/hosts << EOF
127.0.0.1      localhost
$(ifconfig eth1 | grep -e 'inet\b' | awk '{printf $2}')     $(hostname)
192.168.58.101   cd.waken.cc
10.58.81.136   oo.kkops.cc
10.58.81.136   registry.kkops.cc
EOF

# add self sap root ca certificate into system
cat > /etc/ssl/certs/sap.pem << EOF
-----BEGIN CERTIFICATE-----
MIIFuDCCA6CgAwIBAgIJANo16duPpzooMA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNV
BAYTAkNOMREwDwYDVQQIDAhTaGFuZ0hhaTERMA8GA1UEBwwIU2hhbmdIYWkxDDAK
BgNVBAoMA1NBUDEMMAoGA1UECwwDU01FMRgwFgYDVQQDDA9TQVAgU01FIFJPT1Qg
Q0EwHhcNMTgwMzAyMDMwMjMyWhcNMjgwMjI4MDMwMjMyWjBpMQswCQYDVQQGEwJD
TjERMA8GA1UECAwIU2hhbmdIYWkxETAPBgNVBAcMCFNoYW5nSGFpMQwwCgYDVQQK
DANTQVAxDDAKBgNVBAsMA1NNRTEYMBYGA1UEAwwPU0FQIFNNRSBST09UIENBMIIC
IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAz3O0aRUBoRjp7NFfMBaeDzLu
7vmseYGly7mCjrK0uz4rDpe9du2xgRFVH3zRh8llQAy5NhXp1EFsMrlikEkyYKvg
PfKgc/XNuhux7COo7rBVqp5/19Owzc+Bvrn4sK24fr7GFFIefbwwuAIu/ILXDzhr
qgsUc6u4DA9Taxt7Zqvan68m00JxGFBSANUE07x3KeWdyRDszA/7nmDO0voiXRUH
Gj9gqJfcWkUY9KVMaL5I+M8rdUNEPSv60LWQSTQF6UAcmfAStbCKwrK7GfeMmwju
rKSQ+jqXkENK/ndRX5mQNndB+DiBJL4NGDwEfER/peYW4/G+FLwfIy+F1mgI7o4d
yf7ea0nUmLyulbffKoUNvAtUQwsJgkqm1pMvW+xLqazg+TUenlAU/SAcswzwbfuz
lP6DeI3zbR+BGEd+w+txX9D7h15123mTWEoVUGIkaC37+LFLLBDL9vKnly3sP+bT
D6QntVT+E5l4auM/GO1BwbG71bdeLtYcIw2zW3IjZu9tTU7v8CZ9SFU5YTa49/UJ
HEmw9Cl1aoeT4FH1xZX6j0timwmAFv5AyE9YJVAmVlqeKQRmrLrM8RrMK2eUGUNZ
MiVOJ1vPFWfHuyrqc7uU9WOlQZYdW+e1XIP9H9A4ouk1NV4WrFZLVcUUBRFfUw6+
jR9fEOlLu2ww49hq7TECAwEAAaNjMGEwHQYDVR0OBBYEFPRjfbcR4oht6/y8SjMV
wsSKXnsAMB8GA1UdIwQYMBaAFPRjfbcR4oht6/y8SjMVwsSKXnsAMA8GA1UdEwEB
/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMA0GCSqGSIb3DQEBCwUAA4ICAQBAphEj
NxFl5ntLwUgNkn+hE0jPIF+PVhCWhskS+xy9QZoBagPvUgQooQfz4EXzwrZB/Il1
SN5mIM9vfdM7fGs9W0eqEqohfQwZUQ/V1ddLX7dEdW0lFwMTA1MUDirGVGf3Fgic
aloB5d8hbFpjLy7Y+ppLsUJVYshalsOo77rjjDeBRZfUpve8Z/kysaaqfKzhiJuU
5Q5RPv858Oy21ObKGFFqxnTEltS4W2Lx4pH9KvlTKpmCm1MC07B1/zWinJvHETzU
LzA6IgTbi7VUtqV8AcFdoZtEc/zj4LpE8GX4lI9zWGpdiBvx6OK1eURq4fVSJ/Wp
zEJIHYYpSyQlL0wTvSd83AlgbjFaSFPDWxiSyp0XJmYktlxoBJXVQOws8sGIzD09
Q64P18BbJZ9KQVyPyFeyzYmJCypZA00woETkwlfQwRQZH0OXQIoD3/m1U5aIuOZL
Pn/3vqdxojcqxIryzpLvrGE0BPWYDfCBKEner+5Y5N5mlCXOIbI82nZ9zznoFGt9
rsZm7lAFUk7CM+JNRGpWo2eHIlpL8T78ExS6INBX+EMbxx4NOX8iCJbgiMQxx6GB
nYww4cIZKBeaxOdtHBm6/BxWxW6VYzFxG/xPt/tRlp6Z3Ti+CoBiKPU47aZNyfkr
giISeFGrRSzx1HDtU6k/mhkWdhvS4JvJklb2zQ==
-----END CERTIFICATE-----
EOF

# update ca certificate
update-ca-certificates

# RESOURCE_SERVER server
RESOURCE_SERVER=https://oo.kkops.cc

# create dir for binary
mkdir -p /opt/bin

# prepare binaries
cd /opt/bin
curl -RO "${RESOURCE_SERVER}/flanneled/flanneld" && chmod a+x flanneld
curl -RO "${RESOURCE_SERVER}/kubernetes/kube-apiserver" && chmod a+x kube-apiserver
curl -RO "${RESOURCE_SERVER}/kubernetes/kube-controller-manager" && chmod a+x kube-controller-manager
curl -RO "${RESOURCE_SERVER}/kubernetes/kube-scheduler" && chmod a+x kube-scheduler
curl -RO "${RESOURCE_SERVER}/kubernetes/kubelet" && chmod a+x kubelet
curl -RO "${RESOURCE_SERVER}/kubernetes/kube-proxy" && chmod a+x kube-proxy
curl -RO "${RESOURCE_SERVER}/kubernetes/kubectl" && chmod a+x kubectl
curl -RO "${RESOURCE_SERVER}/etcd/etcd" && chmod a+x etcd
curl -RO "${RESOURCE_SERVER}/etcd/etcdctl" && chmod a+x etcdctl
cd -

# create dir for ssl
mkdir -p /opt/ssl

# downloads relevant certificate
cd /opt/ssl
curl -RO "${RESOURCE_SERVER}/ssl/ca.pem"
curl -RO "${RESOURCE_SERVER}/ssl/apiserver-key.pem"
curl -RO "${RESOURCE_SERVER}/ssl/apiserver.pem"
curl -RO "${RESOURCE_SERVER}/ssl/worker-key.pem"
curl -RO "${RESOURCE_SERVER}/ssl/worker.pem"
curl -RO "${RESOURCE_SERVER}/ssl/admin-key.pem"
curl -RO "${RESOURCE_SERVER}/ssl/admin.pem"
chown root:root *
cd -

# add instance metric
mkdir -p /opt/env
cat > /opt/env/host.env << EOF
HOST_NAME=$(hostname)
HOST_IP=$(ifconfig eth1 | grep -e 'inet\b' | awk '{printf $2}')
KUBE_APISERVER_URL="https://cd.waken.cc"
EOF

# cp ca certificate to /etc/ssl/certs/
cp /opt/ssl/ca.pem /etc/ssl/certs/
update-ca-certificates

# wait etcd cluster ready
# while [[ $(etcdctl --endpoints http://192.168.56.101:2379,http://192.168.56.101:2379,http://192.168.2.156:2379 cluster-health | grep 'cluster is healthy' | wc -l) -ne 1 ]]; do
#     echo 'Wait etcd cluster ready...'
#     sleep 15s
# done

# mark ready
touch /opt/bin/ready
echo 'done'

HOST_NAME=$(hostname)
HOST_IP=$(ifconfig eth1 | grep -e 'inet\b' | awk '{printf $2}')
KUBE_APISERVER_URL="https://cd.waken.cc"
sudo sed -i "s/{{ HOST_NAME }}/${HOST_NAME}/g" /etc/systemd/system/*.service
sudo sed -i "s/{{ HOST_IP }}/${HOST_IP}/g" /etc/systemd/system/*.service
