#!/usr/bin/env groovy

// This script configures GitHub integration with Jenkins
// It sets up the GitHub server connection and webhook

import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import hudson.util.Secret
import jenkins.plugins.git.GitSCMSource
import org.jenkinsci.plugins.github_branch_source.*
import org.jenkinsci.plugins.github.config.*
import org.jenkinsci.plugins.github.*

// GitHub Configuration
def githubServerConfig = new GitHubServerConfig('github-webhook-token')
githubServerConfig.name = "GitHub"
githubServerConfig.apiUrl = "https://api.github.com"
githubServerConfig.manageHooks = true
githubServerConfig.clientCacheSize = 20

def githubPluginConfig = GlobalConfiguration.all().get(GitHubPluginConfig.class)
githubPluginConfig.configs = [githubServerConfig]
githubPluginConfig.save()

// Configure the GitHub Branch Source plugin
def descriptor = Jenkins.instance.getDescriptor(GitHubConfiguration.class)
def githubConfig = descriptor.configs[0]
githubConfig.credentialsId = 'github-webhook-token'
githubConfig.manageHooks = true

// Create Multibranch Pipeline job for each environment
def createMultibranchPipeline(name, branchPattern, jenkinsfilePath) {
    def jenkins = Jenkins.instance
    def factory = new org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProjectFactory()
    
    def multiBranchProject = jenkins.createProject(org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject, name)
    
    // Add GitHub source
    def sourcesList = new org.jenkinsci.plugins.github_branch_source.GitHubSCMSource.DescriptorImpl().getTraits()
    
    def source = new GitHubSCMSource(
        "github-webhook-token",
        "https://github.com",
        "your-org/your-repo",
        true
    )
    
    source.traits = [
        new BranchDiscoveryTrait(true, true),
        new OriginPullRequestDiscoveryTrait(1),
        new org.jenkinsci.plugins.github_branch_source.BranchSCMHeadFilterTrait(branchPattern)
    ]
    
    def branchSource = new jenkins.branch.BranchSource(source)
    multiBranchProject.sources.add(branchSource)
    
    // Set Jenkinsfile path
    def folderConfig = multiBranchProject.properties.get(org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig.class)
    if (folderConfig == null) {
        folderConfig = new org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig()
        multiBranchProject.properties.add(folderConfig)
    }
    folderConfig.scriptPath = jenkinsfilePath
    
    // Save and trigger initial scan
    multiBranchProject.save()
    multiBranchProject.scheduleBuild()
}

// Create pipelines for dev and production
createMultibranchPipeline("dev-pipeline", "dev", "Jenkinsfile")
createMultibranchPipeline("production-pipeline", "main", "Jenkinsfile")

println "GitHub webhook configuration complete"