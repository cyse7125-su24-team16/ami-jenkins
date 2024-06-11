multibranchPipelineJob('Jenkins-AMI') {
    displayName('Jenkins-AMI')
    description('Creates AMI with Jenkins installed')
    branchSources {
        github {
            id('Jenkins-AMI')
            apiUri('https://api.github.com')
            repoOwner('cyse7125-su24-team16')
            repository('ami-jenkins')
            scanCredentialsId('github_token')
            includes('*')
        }
    }
    configure {
        def traits = it / 'sources' / 'data' / 'jenkins.branch.BranchSource' / 'source' / 'traits'
        traits << 'org.jenkinsci.plugins.github__branch__source.TagDiscoveryTrait' {}
    }
    configure { node ->
        def webhookTrigger = node / triggers / 'com.igalg.jenkins.plugins.mswt.trigger.ComputedFolderWebHookTrigger' {
            spec('')
            token("Jenkins-AMI")
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
}