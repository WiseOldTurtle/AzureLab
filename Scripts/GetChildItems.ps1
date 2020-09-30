

## You can also use gci (which is shorter way of writing Get-ChildItem)

## $Folder | Measure-Object -Property Length -sum

## Get Child Item variable where you put the FolderName of target folder in it.
$Folder = "Get-ChildItem C:\Windows"

## Shorter version of the command with the initial part added to round up the Decimal Places
"{0:N2} MB" -f ((gci C:\Windows | measure Length -s).sum / 1Mb)

 Get-ChildItem c:\ -r -ErrorAction SilentlyContinue | sort -descending -property length | select -first 10 name, Length