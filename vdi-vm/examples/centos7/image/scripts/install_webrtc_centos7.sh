#!/bin/bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Create user
(id vdi || (
  groupadd --gid 2000 vdi && \
  useradd --uid 2000 --gid 2000 --gecos '' --disabled-password --shell /bin/bash vdi && \
  echo "vdi ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
))

# Install docker CE
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
  yum install -y docker-ce docker-ce-cli containerd.io

systemctl enable docker && \
  systemctl start docker && \
  usermod -a -G docker vdi

# The container image is not driver specific and requires that the NVIDIA
# libraries are present at runtime. Create directory on host containing
# the local NVIDIA libraries that will be mounted to the container at runtime.
mkdir -p /usr/local/nvidia/lib64

# Copy NVIDIA libraries to /usr/local/nvidia/lib64/
NVIDIA_LIB_DIR=$(dirname $(ldconfig -p | grep libnvidia-encode.so | grep x86-64 | tr ' ' '\n' | grep / | tail -1))
if [[ ! -d "${NVIDIA_LIB_DIR}" ]]; then
    echo "ERROR: libnvidia-encode.so not found in library path, make sure the NVIDIA driver is installed."
    exit 1
fi
rsync -ra ${NVIDIA_LIB_DIR}/{lib*nv*,lib*cuda*,vdpau} /usr/local/nvidia/lib64/

# Install CUDA libraries
# NOTE the cuda package version must match the cuda driver version from the nvidia-smi output.
rpm --import https://developer.download.nvidia.com/compute/cuda/repos/GPGKEY
rpm --install http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-10.1.243-1.x86_64.rpm
yum install -y cuda-nvrtc-dev-10-1.x86_64

# Pull docker images
docker pull ${BROKER_PROXY_IMAGE:-"gcr.io/cloud-solutions-images/kube-pod-broker-gce-proxy:latest"}
docker pull ${GST_WEBRTC_IMAGE:-"gcr.io/cloud-solutions-images/webrtc-gpu-streaming-gst-webrtc-app:v1.4.0"}
