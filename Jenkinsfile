pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-kaniko-harbor-test
spec:
  restartPolicy: Never
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
        - /busybox/cat
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
  volumes:
    - name: docker-config
      secret:
        secretName: harbor-robot
        items:
          - key: .dockerconfigjson
            path: config.json
"""
    }
  }

  environment {
    HARBOR_REGISTRY = "harbor.k8s-enes.local"
    HARBOR_PROJECT  = "cı-cd-test"
    IMAGE_NAME      = "hello-jenkins"
    IMAGE_TAG       = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build and Push Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context "${WORKSPACE}" \
              --dockerfile "${WORKSPACE}/Dockerfile" \
              --destination "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}" \
              --destination "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:latest" \
              --skip-tls-verify-registry="${HARBOR_REGISTRY}"
          '''
        }
      }
    }
  }
}
