FROM ubuntu:rolling

ENV ANSIBLE_CORE_VERSION=2.18.0
ENV ANSIBLE_VERSION=10.6.0
ENV ANSIBLE_LINT=24.9.2
ENV DEBIAN_FRONTEND=noninteractive
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install system packages
RUN apt-get update && \
    apt-get install -y \
        python3-pip \
        python3.12-venv \
        python3-full \
        git \
        jq \
        yq \
        curl \
        unzip && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb && \
    rm session-manager-plugin.deb

RUN python3 -m venv $VIRTUAL_ENV

RUN pip3 install --upgrade pip cffi && \
    pip3 install ansible-core==${ANSIBLE_CORE_VERSION} && \
    pip3 install ansible==${ANSIBLE_VERSION} ansible-lint==${ANSIBLE_LINT} && \
    pip install boto3 botocore && \
    rm -rf /root/.cache/pip

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD ["/bin/bash"]
