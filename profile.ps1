
$env:PYTHONIOENCODING="utf-8"


$env:POSH_THEME = "https://raw.githubusercontent.com/pietergobin/settings/main/oh-my-posh-theme.json"


function Get-KubectlPods {
    kubectl get pods
}


$env:VIRTUAL_ENV_DISABLE_PROMPT = 1
Set-Alias grep Select-String
Set-Alias pods Get-KubectlPods
Set-Alias which Get-Command
Set-Alias kc kubectl

# Import-Module CompletionPredictor
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView


oh-my-posh init pwsh | Invoke-Expression
