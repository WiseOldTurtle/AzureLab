#Set the Parameters for the script
## Keyvault 
## kekname ADEKEK


param (
    [Parameter(Mandatory = $true)]
    [string]
    $keyVaultName,
    [Parameter(Mandatory = $true)]
    [string] 
    $kekName,
    [Parameter(Mandatory = $true)]
    [string]
    $secretName,
    [Parameter(Mandatory = $true)]
    [string]
    $bekFilePath,
    [Parameter(Mandatory = $true)]
    [string] 
    $adTenant
)
# Load ADAL Assemblies. The following script assumes that the Azure PowerShell version you installed is 1.0.0. 
$adal = "${env:ProgramFiles}\WindowsPowerShell\Modules\Az.Accounts\1.0.0\PreloadAssemblies\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$adalforms = "${env:ProgramFiles}\WindowsPowerShell\Modules\Az.Accounts\1.0.0\PreloadAssemblies\Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
[System.Reflection.Assembly]::LoadFrom($adal)
[System.Reflection.Assembly]::LoadFrom($adalforms)

# Set well-known client ID for AzurePowerShell
$clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 
# Set redirect URI for Azure PowerShell
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
# Set Resource URI to Azure Service Management API
$resourceAppIdURI = "https://vault.azure.net"
# Set Authority to Azure AD Tenant
$authority = "https://login.windows.net/$adtenant"
# Create Authentication Context tied to Azure AD Tenant
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
# Acquire token
$platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
$authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters).result
# Generate auth header 
$authHeader = $authResult.CreateAuthorizationHeader()
# Set HTTP request headers to include Authorization header
$headers = @{'x-ms-version' = '2014-08-01'; "Authorization" = $authHeader }

########################################################################################################################
# 1. Retrieve wrapped BEK
# 2. Make KeyVault REST API call to unwrap the BEK
# 3. Convert the Base64Url string returned by KeyVault unwrap to Base64 string 
# 4. Convert Base64 string to bytes and write to the BEK file
########################################################################################################################

#Get wrapped BEK and place it in JSON object to send to KeyVault REST API
$keyVaultSecret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName
$wrappedBekSecretBase64 = $keyVaultSecret.SecretValueText
$jsonObject = @"
{
"alg": "RSA-OAEP",
"value" : "$wrappedBekSecretBase64"
}
"@

#Get KEK Url
$kekUrl = (Get-AzKeyVaultKey -VaultName $keyVaultName -Name $kekName).Key.Kid;
$unwrapKeyRequestUrl = $kekUrl + "/unwrapkey?api-version=2015-06-01";

#Call KeyVault REST API to Unwrap 
$result = Invoke-RestMethod -Method POST -Uri $unwrapKeyRequestUrl -Headers $headers -Body $jsonObject -ContentType "application/json" -Debug

#Convert Base64Url string returned by KeyVault unwrap to Base64 string
$base64UrlBek = $result.value;
$base64Bek = $base64UrlBek.Replace('-', '+');
$base64Bek = $base64Bek.Replace('_', '/');
if ($base64Bek.Length % 4 -eq 2) {
    $base64Bek += '==';
}
elseif ($base64Bek.Length % 4 -eq 3) {
    $base64Bek += '=';
}

#Convert base64 string to bytes and write to BEK file
$bekFileBytes = [System.Convert]::FromBase64String($base64Bek);
[System.IO.File]::WriteAllBytes($bekFilePath, $bekFileBytes)