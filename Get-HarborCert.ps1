# ===================Variables===================
# Prompt Input For Harbor FQDN
Write-Host "Enter The Harbor Fully Qualified Domain Name: https://harborFQDNHere" -BackgroundColor Black -ForegroundColor Yellow
$HarborFQDN = Read-Host
[Uri]$HarborURI = "$HarborFQDN"
$HarborURIHostName = $HarborURI.DNSSafeHost
$WebCert = "C:\temp\$HarborURIHostName.cer" # must end in .cer
$PemFormatCert = "C:\temp\$HarborURIHostName.pem" # must end in .pem

#====================Execute=====================
[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::DefaultConnectionLimit = 1024

try 
	{ 
		$HarborWebConnect = [Net.WebRequest]::Create("$HarborFQDN")
		$HarborWebConnect.GetResponse()
		$Webcert = $HarborWebConnect.ServicePoint.Certificate
		[byte[]]$Rawcert = $Webcert.Export('Cert')
		set-content -value $Rawcert -encoding byte -path "$WebCert"
		certutil -f -encode $WebCert $PemFormatCert
		$CertContent = Get-Content -raw -Path $PemFormatCert -Encoding Byte
		$certb64 = [Convert]::ToBase64String($CertContent)
		Write-Host "Your Base64 Cert Is:" -BackgroundColor Black -ForegroundColor Yellow
		Write-Host $certb64 -BackgroundColor Black -ForegroundColor Cyan
	} 
catch 
	{
		Write-Host "An error occurred." -BackgroundColor Black -ForegroundColor Red
		Write-Host $_.ScriptStackTrace	-BackgroundColor Black -ForegroundColor Red
		Write-Host $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
		$ErrorTraceCaught = $_.ScriptStackTrace
		$ErrorMessageOut = $_.Exception.Message
	}
finally
	{
		$HarborWebConnect.close
	}
