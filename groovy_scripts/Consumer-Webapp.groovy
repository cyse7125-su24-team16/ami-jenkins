multibranchPipelineJob('Consumer-Webapp-Job') {
    displayName('Consumer-Webapp-Job')
    description('Validate Push and Pull Conventional Messages.')
    branchSources {
        github {
            id('Consumer-Webapp')
            repoOwner('cyse7125-su24-team16')
            repository('webapp-cve-consumer')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(true)
            buildOriginBranchWithPR(false)
            includes('*')
        }
    }
}
