# 다운로드
wget https://storage.googleapis.com/kubernetes-release/release/v1.19.5/bin/linux/amd64/kubelet
chmod +x kubelet

# 기동
sudo swapoff -a
mkdir manifests
sudo ./kubelet --pod-manifest-path=$PWD/manifests \
--runtime-cgroups=/systemd/system.slice \
--kubelet-cgroups=/systemd/system.slice

# Pod 생성
cat > manifests/nginx.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  nodeName: ubuntu1804
  containers:
  - image: nginx
    name: nginx
EOF

# Pod 삭제
rm -f manifests/nginx.yaml