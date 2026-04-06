# Stack cleanup for the disposable GitLab app stack.
# The persistent data disk is deployed separately and is not removed by this script.
az stack sub delete --name "gitlab-stack" --yes

# (optioneel) delete env / preflight resources
Remove-Item .\.env