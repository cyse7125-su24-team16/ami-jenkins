pipelineJob('StaticSite Docker Image Build') {
    displayName('StaticSite Docker Image Build')
    description('Creates docker image with release on Static Site repository')
    logRotator {
        daysToKeep(30)
        numToKeep(10)
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/cyse7125-su24-team16/static-site.git')
                        credentials('github_token')
                    }
                    branch('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }
    triggers{
        githubPush()
    }
}
