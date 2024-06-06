multibranchPipelineJob('static-site') {
  branchSources {
    github {
      id('static-site')
      scanCredentialsId('github_token')
      repoOwner('cyse7125-su24-team16')
      repository('static-site')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}
