pipeline {
    agent any

    environment {
        GITHUB_CREDENTIALS_ID = 'github_token'
        DOCKER_CREDENTIALS_ID = 'docker_credentials'
        JENKINS_ADMIN_CREDENTIALS_ID = 'jenkins_credentials'
    }

    stages {
        stage('Checkout PR Branch') {
            steps {
                script {
                    // Fetch the latest changes from the origin using credentials
                    withCredentials([usernamePassword(credentialsId: GITHUB_CREDENTIALS_ID, usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                        sh 'git config --global credential.helper store'
                        sh 'echo "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com" > ~/.git-credentials'
                        // Fetch all branches including PR branches
                        sh 'git fetch origin +refs/pull/*/head:refs/remotes/origin/pr/*'
                        // Dynamically fetch the current PR branch name using environment variables
                        def prBranch = env.CHANGE_BRANCH
                        echo "PR Branch: ${prBranch}"
                        // Checkout the PR branch
                        sh "git checkout -B ${prBranch} origin/pr/${env.CHANGE_ID}"
                    }
                }
            }
        }

        stage('Check Commit Messages') {
            steps {
                script {
                    // Fetch the latest commit message in the PR branch
                    def latestCommitMessage = sh(script: "git log -1 --pretty=format:%s", returnStdout: true).trim()
                    echo "Latest commit message: ${latestCommitMessage}"
                   
                    // Regex for Conventional Commits
                    def pattern = ~/^\s*(feat|fix|docs|style|refactor|perf|test|chore)(\(.+\))?: .+\s*$/
                   
                    // Check the latest commit message
                    if (!pattern.matcher(latestCommitMessage).matches()) {
                        error "Commit message does not follow Conventional Commits: ${latestCommitMessage}"
                    }
                }
            }
        }

        stage('Compare Changes') {
            steps {
                script {
                    // Compare the PR branch with the main branch
                    def diff = sh(script: 'git diff origin/main...HEAD', returnStdout: true).trim()
                    echo "Git Diff: ${diff}"
                    if (diff == "") {
                        echo "No differences found."
                    } else {
                        echo "Differences found:\n${diff}"
                    }
                }
            }
        }

        stage('Run Packer Init') {
            steps {
                // Initialize Packer environment
                sh 'packer init ./packer/jenkins-ami.pkr.hcl'
            }
        }

        stage('Run Packer Fmt') {
            steps {
                script {
                    // Check if Packer files are formatted correctly
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
                        // Validate Packer configuration
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
