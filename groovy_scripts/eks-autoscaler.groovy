multibranchPipelineJob('EKS-Autoscaler-Job') {
    displayName('EKS-Autoscalerr-Job')
    description('Validate Push and Pull Conventional Messages.')
    branchSources {
        github {
            id('EKS-Autoscaler')
            repoOwner('cyse7125-su24-team16')
            repository('helm-eks-autoscaler')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(true)
            buildOriginBranchWithPR(false)
            includes('*')
        }
    }
}
