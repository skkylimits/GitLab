# Stack cleanup
az stack sub delete --name "gitlab-stack" --yes

# (optioneel) delete env / preflight resources
Remove-Item .\.env