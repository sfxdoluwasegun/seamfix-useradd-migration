Param(
    [string]$tower_url="192.168.8.26:9443",
    [string]$host_config_key="75486d34136c9de0965db8869ceaabc5",
    [string]$job_template_id=13
)


add-type @"
   using System.Net;
   using System.Security.Cryptography.X509Certificates;
   public class TrustAllCertsPolicy : ICertificatePolicy {
       public bool CheckValidationResult(
           ServicePoint srvPoint, X509Certificate certificate,
           WebRequest request, int certificateProblem) {
           return true;
       }
   }
"@
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
Set-StrictMode -Version 2
$ErrorActionPreference = "Stop"

If(-not $tower_url -or -not $host_config_key -or -not $job_template_id)
{
    Write-Host "Requests server configuration from Ansible Tower"
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) <server address>[:server port] <host config key> <job template id>"
    Write-Host "Example: $($MyInvocation.MyCommand.Name) example.towerhost.net 44d7507f2ead49af5fca80aa18fd24bc 38"
    Exit 1
}

$retry_attempts = 1
$attempt = 0

$data = @{
    host_config_key=$host_config_key
}

While ($attempt -lt $retry_attempts) {
    Try {
        $resp = Invoke-WebRequest -Method POST -Body $data -Uri https://$tower_url/api/v2/job_templates/$job_template_id/callback/ -UseBasicParsing
        If($resp.StatusCode -eq 201) {
            Exit 0
        }
    }
    Catch {
        $ex = $_
        $attempt++
        Write-Host "$($ex.Exception) received... retrying in 1 minute (Attempt $attempt)"
    }
    Start-Sleep -Seconds 60
}
Exit 1