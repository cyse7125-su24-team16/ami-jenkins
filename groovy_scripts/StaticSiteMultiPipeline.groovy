multibranchPipelineJob('Static-Site-Multipipeline') {
    displayName('Static-Site-Multipipeline-Push-Messages')
    description('Validate Push Conventional Messages.')
    branchSources {
        github {
            id('Static-Site-Pull')
            repoOwner('cyse7125-su24-team16')
            repository('static-site')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(false)
            buildOriginBranchWithPR(false)
            includes('*')
        }
    }
}
