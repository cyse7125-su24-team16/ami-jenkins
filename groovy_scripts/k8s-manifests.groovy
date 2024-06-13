multibranchPipelineJob('K8s-Multipipeline') {
    displayName('K8s-Multipipeline-Push-Messages')
    description('Validate Pull Conventional Messages.')
    branchSources {
        github {
            id('K8s')
            repoOwner('cyse7125-su24-team16')
            repository('k8s-yaml-manifests')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(false)
            buildOriginBranchWithPR(false)
            includes('*')
        }
    }
}
