multibranchPipelineJob('Project-Job') {
    displayName('Project-Multipipeline--Docker-Push')
    description('Validate Push and Pull Conventional Messages.')
    branchSources {
        github {
            id('Project')
            repoOwner('cyse7125-su24-team16')
            repository('project')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(true)
            buildOriginBranchWithPR(false)
            includes('*')
        }
    }
}
