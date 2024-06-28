multibranchPipelineJob('Helm-Consumer-Webapp') {
    displayName('Consumer-Helm-Webapp-Multipipeline-Push-Messages')
    description('Validate Push and Pull Conventional Messages.')
    branchSources {
        github {
            id('Consumer-Helm-Webapp')
            repoOwner('cyse7125-su24-team16')
            repository('helm-webapp-cve-consumer')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(true)
            buildOriginBranchWithPR(false)
            includes('*')

        }
    }
}
