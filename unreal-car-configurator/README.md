## Unreal Realtime Car Configurator Demo

## Description

This demo shows how to stream a real time car configurator using the [Unreal Engine demo from Darul Solutions](https://darulsolutions.com/Downloads/Interactive-Realtime-Car-Configurator). 

Wine is used to run the demo in a container because only a Windows build is available.

For convenience, the [demo zip file](https://storage.googleapis.com/cloud-solutions-images-vdi/unreal-car-config/CarconfiguratorV2.2.zip) and the cached [wine directory contents](https://storage.googleapis.com/cloud-solutions-images-vdi/unreal-car-config/wine-dir.tar.gz) are stored on GCS and extracted into the container when the image is built. 

## Dependencies

- App Launcher: [v1.0.0+](https://github.com/GoogleCloudPlatform/solutions-k8s-stateful-workload-operator/tree/v1.0.0)
- WebRTC Streaming Stack: [v1.4.0+](https://github.com/GoogleCloudPlatform/solutions-webrtc-gpu-streaming/tree/v1.4.0)

## Features

- GPU or software renderer per Node Tier selection.
- Uses Wine64 base image.

## Installed Software

- Wine64
- Unreal Engine car configurator demo

## Tutorials

This tutorial will walk you through the following:

- Verifying cluster pre-requisites.
- Building the image and deploying the manifests with Cloud Build.

## Setup

1. Set the project, replace `YOUR_PROJECT` with your project ID:

```bash
export PROJECT_ID=YOUR_PROJECT
```

```bash
gcloud config set project ${PROJECT_ID?}
```

## Pre-requisites

This tutorial requires that you have already deployed the Kubernetes App Launcher Operator in your GKE cluster.

If you have not already deployed the operator, follow this Cloud Shell tutorial to do so:

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/solutions-k8s-stateful-workload-operator&cloudshell_git_branch=v1.0.0&cloudshell_tutorial=setup/README.md)

This tutorial requires that you have deployed the WebRTC streaming app launcher stack to the cluster.

If you have not installed the WebRTC stack, follow this Cloud Shell tutorial to do so:

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/solutions-webrtc-gpu-streaming&cloudshell_git_branch=v1.0.0&&cloudshell_tutorial=tutorials/gke/00_Setup.md). 

## Platform verification

3. Obtain cluster credentials:

```bash
REGION=us-west1
```

> NOTE: change this to the region of your cluster.

```bash
gcloud --project ${PROJECT_ID?} container clusters get-credentials broker-${REGION?} --region ${REGION?}
```

2. Verify that the WebRTC streaming manifest bundle is present:

```bash
kubectl get configmap webrtc-gpu-streaming-manifests-1.4.0 -n pod-broker-system
```

3. Verify that GPU sharing is enabled:

```bash
kubectl describe node -l cloud.google.com/gke-accelerator-initialized=true | grep nvidia.com/gpu
```

Example output:

```
 nvidia.com/gpu:             48
 nvidia.com/gpu:             48
```

> Verify that the number of availble GPUs is greater than 1.

## Build the app image

1. Build the container image using cloud build:

```bash
(cd images && gcloud builds submit)
```

## Deploy the app manifests

1. Deploy manifests to the cluster:

```bash
gcloud builds submit --substitutions=_REGION=${REGION?}
```

2. Open the app launcher web interface and launch the app.

> NOTE: after the Cloud Build has completed from the previous step, it will take a few minutes for the nodes to pre-pull the image. As a result, the first launch may take longer than usual.
