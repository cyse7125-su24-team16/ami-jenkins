pipeline {
    agent any

    environment {
        GITHUB_CREDENTIALS_ID = 'github_token'
        DOCKER_CREDENTIALS_ID = 'docker_credentials'
        JENKINS_ADMIN_CREDENTIALS_ID = 'jenkins_credentials'
    }

    stages {
       stage('Checking out the code') {
            steps{
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: 'main']],
                        userRemoteConfigs: [[credentialsId: 'github_token', url: 'https://github.com/cyse7125-su24-team16/ami-jenkins.git']]
                    ])
                }
            }
        }
         stage('Compare Changes') {
            steps {
                sh 'git diff origin/main...HEAD'
            }
        }

        stage('Run Packer Init') {
            steps {
                sh 'packer init ./packer/jenkins-ami.pkr.hcl'
            }
        }

        stage('Run Packer Fmt') {
            steps {
                script {
                    def result = sh(script: 'packer fmt --check ./packer/jenkins-ami.pkr.hcl > packer_fmt_output.log 2>&1', returnStatus: true)
                    echo "packer fmt exit code: ${result}"
                    sh 'cat packer_fmt_output.log'
                    if (result != 0) {
                        error 'packer fmt failed'
                    }
                }
            }
        }

        stage('Run Packer Validate') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'github_token', usernameVariable: 'GITHUB_TOKEN_USR', passwordVariable: 'GITHUB_TOKEN_PSW'),
                    usernamePassword(credentialsId: 'docker_credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD'),
                    usernamePassword(credentialsId: 'jenkins_credentials', usernameVariable: 'JENKINS_ADMIN_USER', passwordVariable: 'JENKINS_ADMIN_PASSWORD')
                ]) {
                    script {
                        def result = sh(script: '''
                            packer validate \
                            -var 'github_username=${GITHUB_TOKEN_USR}' \
                            -var 'github_password=${GITHUB_TOKEN_PSW}' \
                            -var 'docker_username=${DOCKER_USERNAME}' \
                            -var 'docker_password=${DOCKER_PASSWORD}' \
                            -var 'jenkins_admin_user=${JENKINS_ADMIN_USER}' \
                            -var 'jenkins_admin_password=${JENKINS_ADMIN_PASSWORD}' \
                            -var 'ssh_username=ubuntu' \
                            -var 'source_ami=ami-04b70fa74e45c3917' \
                            -var 'instance_type=t2.micro' \
                            ./packer/jenkins-ami.pkr.hcl > packer_validate_output.log 2>&1
                        ''', returnStatus: true)
                        echo "packer validate exit code: ${result}"
                        sh 'cat packer_validate_output.log'
                        if (result != 0) {
                            error 'packer validate failed'
                        }
                    }
                }
            }
        }
    }
}
