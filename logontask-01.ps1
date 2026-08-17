Start-Transcript -Path C:\WindowsAzure\Logs\LogonTask.txt -Append

$commonscriptpath = "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.*\Downloads\0\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py

refreshenv

pip install python-dotenv
pip install python-dotenv semantic-kernel
pip install streamlit
pip install fastapi uvicorn
pip install azure-search-documents
code --install-extension GitHub.copilot
code --install-extension ms-python.python

# Clone the Git repository to C:\LabFiles
$repoUrl = "https://github.com/CloudLabsAI-Azure/ai-developer.git"
$destinationPath = "C:\LabFiles\ai-developer"
git clone $repoUrl $destinationPath

# Manual status agent check
# Validate all deployments and assignments for manual status agent
if(Test-Path "C:\LabFiles\ai-developer" -PathType Container)
{
    Write-Information "Validation Passed"
    $validstatus = "Successfull"
}
else {
   Write-Warning "Validation Failed - see log output"
   $validstatus = "Failed"
   }

Function SetDeploymentStatus($ManualStepStatus, $ManualStepMessage)
{
    (Get-Content -Path "C:\WindowsAzure\Logs\status-sample.txt") | ForEach-Object {$_ -Replace "ReplaceStatus", "$ManualStepStatus"} | Set-Content -Path "C:\WindowsAzure\Logs\validationstatus.txt"
   (Get-Content -Path "C:\WindowsAzure\Logs\validationstatus.txt") | ForEach-Object {$_ -Replace "ReplaceMessage", "$ManualStepMessage"} | Set-Content -Path "C:\WindowsAzure\Logs\validationstatus.txt"
}
if ($validstatus -eq "Successfull") {
    $ValidStatus="Succeeded"
    $ValidMessage="Environment is validated and the deployment is successful"

Remove-Item 'C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt' -force
      }
else {
    Write-Warning "Validation Failed - see log output"
    $ValidStatus="Failed"
    $ValidMessage="Environment Validation Failed and the deployment is Failed"
      } 
SetDeploymentStatus $ValidStatus $ValidMessage

#Start the cloudlabs agent service 
CloudlabsManualAgent Start 


Unregister-ScheduledTask -TaskName "Setup" -Confirm:$false
Stop-Transcript
