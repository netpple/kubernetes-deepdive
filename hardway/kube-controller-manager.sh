wget https://storage.googleapis.com/kubernetes-release/release/v1.19.5/bin/linux/amd64/kube-controller-manager
chmod +x kube-controller-manager
sudo ./kube-controller-manager --master=127.0.0.1:8080 -v 3