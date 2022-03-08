ARG BASE_IMAGE=ubuntu:18.04
FROM $BASE_IMAGE

ARG GO_VERSION=1.17.6
ARG K8S_GIT_TAG=v1.19.16
# 
ARG DEBIAN_FRONTEND=noninteractive

# install packages
RUN apt -qq update \
&& apt-get -qq -y install systemd gcc make pkg-config libseccomp-dev curl wget vim jq iproute2 rsync \
&& wget https://github.com/mikefarah/yq/releases/download/v4.18.1/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq \
&& find /lib/systemd/system/sysinit.target.wants/ -name "systemd-tmpfiles-setup.service" -delete \
&& rm -f /lib/systemd/system/multi-user.target.wants/* \
&& rm -f /etc/systemd/system/*.wants/* \
&& rm -f /lib/systemd/system/local-fs.target.wants/* \
&& rm -f /lib/systemd/system/sockets.target.wants/*udev* \
&& rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
&& rm -f /lib/systemd/system/basic.target.wants/* \
&& echo "ReadKMsg=no" >> /etc/systemd/journald.conf

# install docker
RUN apt-get -qq -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add - \
&& add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
&& apt -qq update \
&& apt -qq -y install docker-ce

# install go
RUN curl --stderr /dev/null -OL https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz \
&& tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
&& echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile 

ENV PATH="${PATH}:/usr/local/go/bin"

WORKDIR /root

# install delve 
RUN go install github.com/go-delve/delve/cmd/dlv@latest \
&& cp /root/go/bin/dlv /usr/local/bin/

# tell systemd that it is in docker (it will check for the container env)
ENV container docker

# git clone
RUN git clone https://github.com/kubernetes/kubernetes.git --branch ${K8S_GIT_TAG} --single-branch \
&& cd kubernetes \
&& make clean \
&& make all WHAT=cmd/kubelet GOFLAGS=-v GOGCFLAGS="all=-N -l" GOLDFLAGS="" \
&& make all WHAT=cmd/kube-apiserver GOFLAGS=-v GOGCFLAGS="all=-N -l" GOLDFLAGS="" \
&& cp _output/bin/kube-apiserver /usr/local/bin/

# systemd exits on SIGRTMIN+3, not SIGTERM (which re-executes it)
STOPSIGNAL SIGRTMIN+3

ENTRYPOINT [ "/sbin/init" ]
