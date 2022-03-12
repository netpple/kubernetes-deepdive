# RUN ETCD
function run_etcd() {
  mkdir etcd-data
  sudo docker container run --rm --volume=$PWD/etcd-data:/default.etcd --detach --net=host quay.io/coreos/etcd | sudo tee etcd-container-id
}

# RUN APISERVER
function run_apiserver {
  wget https://storage.googleapis.com/kubernetes-release/release/v1.19.5/bin/linux/amd64/kube-apiserver
  chmod +x kube-apiserver
  sudo nohup ./kube-apiserver --etcd-servers=http://127.0.0.1:2379 > apiserver.log 2>&1 &
}

# RUN KUBELET
function run_kubelet {
cat > kubelet.conf <<EOF
apiVersion: v1
clusters:
- cluster:
    server: http://127.0.0.1:8080
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: system:node:ubuntu1804
  name: system:node:ubuntu1804@cluster.local
current-context: system:node:ubuntu1804@cluster.local
kind: Config
preferences: {}
users:
- name: system:node:ubuntu1804
EOF

  sudo nohup ./kubelet --node-ip=192.168.100.2 \
    --kubeconfig=$PWD/kubelet.conf \
    --runtime-cgroups=/systemd/system.slice \
    --kubelet-cgroups=/systemd/system.slice > kubelet.log 2>&1 &
}

function get_nodes() {
    curl --stderr /dev/null http://localhost:8080/api/v1/nodes
}

function create_sa() {
cat > sa.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
  namespace: default
automountServiceAccountToken: false
EOF

  yq eval -o=json -I2 sa.yaml > sa.json
  curl --stderr /dev/null -H 'Content-Type: application/json;charset=utf-8' \
  --request POST http://localhost:8080/api/v1/namespaces/default/serviceaccounts \
  --data @sa.json
}

function create_pod() {
cat > nginx.yaml <<EOF
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
  yq eval -o=json -I2 nginx.yaml > nginx.json
  curl --stderr /dev/null -H 'Content-Type: application/json;charset=utf-8' \
    --request POST http://localhost:8080/api/v1/namespaces/default/pods \
    --data @nginx.json
}

function get_pods() {
  curl --stderr /dev/null \
    --request GET http://localhost:8080/api/v1/namespaces/default/pods
}

function install_kubectl() {
  wget https://storage.googleapis.com/kubernetes-release/release/v1.19.5/bin/linux/amd64/kubectl
  chmod +x kubectl
}