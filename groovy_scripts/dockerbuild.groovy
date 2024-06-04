pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dckr_pat_1XEm0AqyPtAIfAaW-BdQ7TK8fg8'
        DOCKER_HUB_REPO = 'anu398/my-custom-caddy'
        DOCKER_TAG = 'latest'
        DOCKER_TAG_VERSION = '0.0.1'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/cyse7125-su24-team16/ami-jenkins.git', branch: 'main'
            }
        }

        stage('Build Multi-Platform Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS_ID) {
                        sh 'docker buildx create --use'
                        sh 'docker buildx inspect --bootstrap'
                        sh 'docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKER_HUB_REPO:$DOCKER_TAG -t $DOCKER_HUB_REPO:$DOCKER_TAG_VERSION . --push'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'The Docker image has been built and pushed successfully.'
        }
        failure {
            echo 'There was an error during the build process.'
        }
    }
}
