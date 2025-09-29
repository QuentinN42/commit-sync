# Commit Sync

Fork this repo to sync your GitLab commit history with GitHub.

This tool automatically creates commits on GitHub with dates matching your GitLab activity calendar, helping maintain a consistent contribution history across platforms.

## How it works

The GitHub Action will:

- Run automatically on every commit to main/master branch
- Run daily at midnight UTC via scheduled cron job
- Fetch your GitLab activity calendar
- Create commits with matching dates for any missing activity
- Push the changes back to your repository

## Setup

1. Fork this repository
2. Go to your fork's Settings → Secrets and variables → Actions
3. Add the following secrets:
   - `GITLAB_USERNAME`: Your GitLab username
   - `REPOSITORY`: The Git repository URL to sync to (e.g., `https://github.com/username/repo.git`)
   - `GITHUB_USERNAME`: Your GitHub username
   - `GITHUB_EMAIL`: Your GitHub email address

## Manual Usage

You can also run the script manually:

```bash
export GITLAB_USERNAME="your-gitlab-username"
export REPOSITORY="https://github.com/username/repo.git"
export GITHUB_USERNAME="your-github-username"
export GITHUB_EMAIL="your-github-email@example.com"

./script.sh
```
