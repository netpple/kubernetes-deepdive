wget https://storage.googleapis.com/kubernetes-release/release/v1.19.5/bin/linux/amd64/kube-scheduler
chmod +x kube-scheduler
sudo ./kube-scheduler --master=http://localhost:8080