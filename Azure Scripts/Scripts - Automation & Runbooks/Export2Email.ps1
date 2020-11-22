$servers = Get-Content C:\scripts\dailychecks\serverlist.txt
$collection = $()
foreach ($server in $servers) {
    $status = @{ "ServerName" = $server; "TimeStamp" = (Get-Date -f s) }
    if (Test-Connection $server -Count 1 -ea 0 -Quiet) { 
        $status["Results"] = "Up"
    } 
    else { 
        $status["Results"] = "Down" 
    }
    New-Object -TypeName PSObject -Property $status -OutVariable serverStatus
    $collection += $serverStatus

}
$collection |   ConvertTo-Html   -body "<H2>Find The Following Details</H2>" | Out-File c:\serverstatus.html



$body = [System.IO.File]::ReadAllText("c:\serverstatus.html")
$MailMessage = @{ 
    To          = $to
    From        = $from
    Subject     = "some subjcet" 
    Body        = "$body" 
    Smtpserver  = 'smtp servr'
    ErrorAction = "SilentlyContinue" 
}
Send-MailMessage @MailMessage -bodyashtml