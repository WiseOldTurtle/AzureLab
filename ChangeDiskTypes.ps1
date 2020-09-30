$vmName = "fnazucrpsql1701"
$vault = "KV-ENC-UKS-CD840A207DDB4"
$Drive = "L:"

$kvSecret = Get-AzKeyVaultSecret -VaultName $vault | where { ($_.Tags.MachineName -eq $vmName) -and ($_.ContentType -match 'BEK') -and ($_.Tags.VolumeLetter -eq $Drive) } `
| Sort-Object -Descending -Property Created

$keyVaultSecret = Get-AzKeyVaultSecret -VaultName $vault -Name $kvSecret[0].Tags.DiskEncryptionKeyFileName.Split('.')[0]

#Retrieve keyvault name, secret name and secret version from secret URL
$keyVaultName = $keyVaultSecret.VaultName
$secretName = $keyVaultSecret.Name
$secretVersion = $keyVaultSecret.Version
$kekUrl = $keyVaultSecret.Tags.DiskEncryptionKeyEncryptionKeyURL

$keyVaultSecret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -Version $secretVersion;
$secretBase64 = $keyVaultSecret.SecretValueText;


#Get current logged in user and active directory tenant details
$ctx = Get-AzContext;
$adTenant = $ctx.Tenant.Id;
$currentUser = $ctx.Account.Id

########################################################################################################################
# Initialize ADAL libraries and get authentication context required to make REST API called against KeyVault REST APIs. 
########################################################################################################################

# Set well-known client ID for AzurePowerShell
$clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 
# Set redirect URI for Azure PowerShell
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
# Set Resource URI to Azure Service Management API
$resourceAppIdURI = "https://vault.azure.net"
# Set Authority to Azure AD Tenant
$authority = "https://login.windows.net/$adTenant"
# Create Authentication Context tied to Azure AD Tenant
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
# Acquire token
$platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
$authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters)
#$authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
# Generate auth header 
$authHeader = $authResult.result.CreateAuthorizationHeader()
# Set HTTP request headers to include Authorization header
$headers = @{'x-ms-version' = '2014-08-01'; "Authorization" = $authHeader }

########################################################################################################################
# 1. Retrieve the secret from KeyVault
# 2. If Kek is not NULL, unwrap the secret with Kek by making KeyVault REST API call
# 3. Convert Base64 string to bytes and write to the BEK file
########################################################################################################################

#Call KeyVault REST API to Unwrap 
$jsonObject = @"
    {
        "alg": "RSA-OAEP",
        "value" : "$secretBase64"
    }
"@

$unwrapKeyRequestUrl = $kekUrl + "/unwrapkey?api-version=2015-06-01";
$result = Invoke-RestMethod -Method POST -Uri $unwrapKeyRequestUrl -Headers $headers -Body $jsonObject -ContentType "application/json";

#Convert Base64Url string returned by KeyVault unwrap to Base64 string
$secretBase64Url = $result.value;
$secretBase64 = $secretBase64Url.Replace('-', '+');
$secretBase64 = $secretBase64.Replace('_', '/');
if ($secretBase64.Length % 4 -eq 2) {
    $secretBase64 += '==';
}
elseif ($secretBase64.Length % 4 -eq 3) {
    $secretBase64 += '=';
}



$bekFileBytes = [System.Convert]::FromBase64String($secretBase64);
[System.IO.File]::WriteAllBytes(".\$($secretName).bek", $bekFileBytes);
