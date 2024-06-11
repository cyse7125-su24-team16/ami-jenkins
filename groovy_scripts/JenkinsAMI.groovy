multibranchPipelineJob('Jenkins-AMI') {
    displayName('Jenkins-AMI')
    description('Creates AMI with Jenkins installed')
    branchSources {
        github {
            id('Jenkins-AMI')
            repoOwner('cyse7125-su24-team16')
            repository('ami-jenkins')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(false)
            buildOriginBranchWithPR(false)
            includes('*')
        }
    }
}
