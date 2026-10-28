# ci-github-runners

intent: Run upstream's CI on GitHub-hosted runners instead of Blacksmith, which this fork has no account for, so PRs and pushes to main get the same checks upstream runs. Only the runs-on labels change; jobs, steps and triggers stay upstream's. Covers ci.yml, the PR mobile fingerprint check and the manual Windows tests.

edits:

- file .github/workflows/ci.yml
- file .github/workflows/mobile-fingerprint-check.yml
- file .github/workflows/windows-tests.yml
