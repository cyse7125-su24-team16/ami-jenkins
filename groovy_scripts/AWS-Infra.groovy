multibranchPipelineJob('AWS-Infra-Terraform') {
    displayName('AWS-Infra-Terraform-Validation')
    description('Validating Terraform code')
    branchSources {
        github {
            id('AWS-Infra-Terraform-Validation')
            repoOwner('cyse7125-su24-team16')
            repository('infra-aws')
            scanCredentialsId('github_token')
            buildForkPRMerge(true)
            buildOriginBranch(false)
            buildOriginBranchWithPR(false)
            includes('*')
        }
    }
}
