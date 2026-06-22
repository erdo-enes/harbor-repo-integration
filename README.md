# Jenkins + Kaniko + Harbor Test

A minimal end-to-end test that:

1. Builds a container image from `nginx:alpine` (see `Dockerfile`).
2. Uses a Jenkins Kubernetes agent running the **Kaniko** executor.
3. Pushes the resulting image to a local **Harbor** registry at
   `harbor.k8s-enes.local/jenkins-test/hello-jenkins` with two tags:
   `<BUILD_NUMBER>` and `latest`.

## Repository layout

```
.
├── Dockerfile          # FROM nginx:alpine, serves index.html
├── Jenkinsfile         # Pipeline: build & push via Kaniko
├── index.html          # Static page served by nginx
└── README.md
```

## Prerequisites

- Jenkins controller with the **Kubernetes** plugin installed.
- A Kubernetes namespace reachable from the Jenkins agent where build pods
  can be scheduled.
- A Harbor robot account credentials stored as a Kubernetes secret named
  `harbor-robot` in the build namespace, with key `.dockerconfigjson`.
  Example:

  ```bash
  kubectl create secret docker-registry harbor-robot \
    --docker-server=harbor.k8s-enes.local \
    --docker-username=robot\$jenkins \
    --docker-password='<robot-token>' \
    -n jenkins
  ```

  The `--docker-email` flag is optional. The Jenkinsfile mounts this secret
  into the Kaniko container at `/kaniko/.docker`.

- Harbor project `jenkins-test` must exist (create it in the Harbor UI or
  via the API before the first build).

## Pipeline overview

The pipeline (see `Jenkinsfile`):

1. **Checkout** – pulls this repository into the workspace.
2. **Build and Push Image** – inside the `kaniko` container, runs
   `/kaniko/executor` with:
   - `--context` and `--dockerfile` pointing to the workspace.
   - Two `--destination` tags:
     - `harbor.k8s-enes.local/jenkins-test/hello-jenkins:${BUILD_NUMBER}`
     - `harbor.k8s-enes.local/jenkins-test/hello-jenkins:latest`
   - `--skip-tls-verify-registry=harbor.k8s-enes.local` to allow the
     self-signed Harbor certificate.

## Running

1. Create a Jenkins **Pipeline** job (or use a multibranch pipeline) that
   points at this repository.
2. Trigger a build.
3. After success, verify the image in Harbor:

   ```bash
   docker pull harbor.k8s-enes.local/jenkins-test/hello-jenkins:latest
   ```

## Notes

- The Kaniko debug image (`gcr.io/kaniko-project/executor:debug`) is used so
  the pod has a shell. In production you would use
  `gcr.io/kaniko-project/executor:latest` (no shell).
- TLS verification is disabled for Harbor because the local registry uses a
  self-signed certificate. Replace with `--skip-tls-verify` only for
  non-production environments.
