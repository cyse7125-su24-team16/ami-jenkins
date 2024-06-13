multibranchPipelineJob('Terrform') {
    displayName('Terraform-Validation')
    description('Validating Terraform code')
    branchSources {
        github {
            id('Terraform-Validation')
            repoOwner('cyse7125-su24-team16')
            repository('infra-jenkins')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(false)
            buildOriginBranchWithPR(false)
            includes('*')
        }
    }
}
