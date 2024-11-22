FROM python:3.11-slim

ARG TARGETARCH

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    apt-transport-https \
    ca-certificates \
    gnupg \
    make \
    ansible \
    python3-pip \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN /usr/bin/python3 -m pip install --break-system-packages --no-cache-dir boto3 botocore yamllint

# Install Argo CD CLI
RUN ARGOCD_DOWNLOAD_URL=$(case ${TARGETARCH} in \
    "amd64") echo "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64" ;; \
    "arm64") echo "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-arm64" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac) && \
    curl -sSL -o /usr/local/bin/argocd ${ARGOCD_DOWNLOAD_URL} && \
    chmod +x /usr/local/bin/argocd

# Install AWS CLI
RUN AWS_CLI_URL=$(case ${TARGETARCH} in \
    "amd64") echo "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" ;; \
    "arm64") echo "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac) && \
    curl "${AWS_CLI_URL}" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Install yq
RUN YQ_DOWNLOAD_URL=$(case ${TARGETARCH} in \
    "amd64") echo "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" ;; \
    "arm64") echo "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac) && \
    curl -sSL -o /usr/local/bin/yq ${YQ_DOWNLOAD_URL} && \
    chmod +x /usr/local/bin/yq

# Install kubectl
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    rm -rf /var/lib/apt/lists/*

# Install Ansible Galaxy Collections
RUN ansible-galaxy collection install amazon.aws community.aws community.general

WORKDIR /app

CMD ["/bin/bash"]
