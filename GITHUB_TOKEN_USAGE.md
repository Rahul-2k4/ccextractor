# 🔐 GitHub Token Usage for CCExtractor Development

## Setup Complete ✓

Your GitHub token has been saved to:
```
/home/rahul/Desktop/ccextractor/.env.github
```

## How to Use

### 1. Load the Token (Each Terminal Session)
```bash
cd /home/rahul/Desktop/ccextractor
source .env.github
```

### 2. Verify It's Loaded
```bash
echo $GITHUB_TOKEN
# Should show: github_pat_11BKB2XDI0cC05rAFmICLi_8BwECzaok69Q6Wt1I35WlfLuzxy06sGd414MoJcolBoTY4OGKYMxSuZj06
```

### 3. Use with Git Operations
```bash
# Clone repositories (no password prompt)
git clone https://$GITHUB_TOKEN@github.com/CCExtractor/sample-platform.git

# Push to your fork
git remote set-url origin https://$GITHUB_TOKEN@github.com/YOUR_USERNAME/sample-platform.git
git push origin your-branch
```

### 4. Use with GitHub API
```bash
# Create issue via API
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/CCExtractor/sample-platform/issues \
  -d '{"title":"My Issue","body":"Issue description"}'
```

## Automatic Loading (Optional)

Add to your `~/.bashrc` or `~/.zshrc`:
```bash
# CCExtractor GitHub token
source /home/rahul/Desktop/ccextractor/.env.github
```

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

## Security Notes

- ✓ Token is saved with `chmod 600` (owner read/write only)
- ✓ `.env.github` is in `.gitignore` (won't be committed)
- ✓ Token only works with CCExtractor repositories (as configured)
- ⚠️ Never share this token or commit it to a repo

## Token Scope
- **Repositories**: Full control (read/write)
- **Organizations**: Read access (to view CCExtractor org)
- **User**: Read access (basic profile info)

## For GSoC Contributions

This token will be used for:
1. Forking and cloning CCExtractor repositories
2. Creating pull requests
3. Managing issues and comments
4. Interacting with the GitHub API

---

**Next Step**: Start with [TODO 1: Setup Sample Platform Development Environment](./gsoc-2026-ccextractor-sample-platform-strategy.md#todo-1-setup-sample-platform-development-environment)
