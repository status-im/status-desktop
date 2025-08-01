#!/usr/bin/env node

const { Octokit } = require('@octokit/rest');

class CommitStatusManager {
    constructor(octokit, context) {
        this.octokit = octokit;
        this.context = context;
    }

    async determineTargetCommit(apkSourceType, buildRunId) {
        if (apkSourceType === 'github_artifact' && buildRunId) {
            return this.getCommitFromRun(buildRunId);
        }
        
        if (this.isExternalApk(apkSourceType)) {
            return null; // Skip status for external APKs
        }
        
        return this.context.sha; // Use current commit
    }

    async getCommitFromRun(runId) {
        try {
            const response = await this.octokit.rest.actions.getWorkflowRun({
                owner: this.context.repo.owner,
                repo: this.context.repo.repo,
                run_id: runId
            });
            return response.data.head_sha;
        } catch (error) {
            console.warn(`Failed to get commit from run ${runId}: ${error.message}`);
            return this.context.sha;
        }
    }

    isExternalApk(sourceType) {
        return ['direct_url', 'lambdatest_app_id'].includes(sourceType);
    }

    async setCommitStatus(targetSha, testStatus, runId) {
        if (!targetSha) {
            console.log('Skipping commit status for external APK');
            return false;
        }

        const state = testStatus === 'success' ? 'success' : 'failure';
        const description = `E2E tests ${state}`;
        
        await this.octokit.rest.repos.createCommitStatus({
            owner: this.context.repo.owner,
            repo: this.context.repo.repo,
            sha: targetSha,
            state,
            target_url: `${this.context.serverUrl}/${this.context.repo.owner}/${this.context.repo.repo}/actions/runs/${runId}`,
            description,
            context: 'e2e/appium-android'
        });
        
        return true;
    }
}

// CLI usage
if (require.main === module) {
    const [testStatus, apkSourceType, buildRunId] = process.argv.slice(2);
    
    // GitHub Actions provides context via environment
    const context = {
        repo: { owner: process.env.GITHUB_REPOSITORY_OWNER, repo: process.env.GITHUB_REPOSITORY.split('/')[1] },
        sha: process.env.GITHUB_SHA,
        serverUrl: process.env.GITHUB_SERVER_URL,
        runId: process.env.GITHUB_RUN_ID
    };
    
    const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
    const manager = new CommitStatusManager(octokit, context);
    
    manager.determineTargetCommit(apkSourceType, buildRunId)
        .then(targetSha => manager.setCommitStatus(targetSha, testStatus, context.runId))
        .then(success => {
            console.log(success ? 'Commit status set successfully' : 'Commit status skipped');
            process.exit(0);
        })
        .catch(error => {
            console.error('Failed to set commit status:', error.message);
            process.exit(1);
        });
}

module.exports = CommitStatusManager; 