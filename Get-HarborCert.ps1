# ===================Variables===================
# Prompt Input For Harbor FQDN
Write-Host "Enter The Harbor Fully Qualified Domain Name: https://harborFQDNHere" -BackgroundColor Black -ForegroundColor Yellow
$HarborFQDN = Read-Host
[Uri]$HarborURL = "$HarborFQDN"
$HarborURLHostName = $HarborURL.DNSSafeHost
$WebCert = "C:\temp\$HarborURLHostName.cer" # must end in .cer
$PemFormatCert = "C:\temp\$HarborURLHostName.pem" # must end in .pem

#====================Execute=====================
[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

try 
	{ 
		$WebConnect = [System.Net.Sockets.TcpClient]::new($HarborURL.Host, $HarborURL.Port)
		$WebSSL = [System.Net.Security.SslStream]::new($WebConnect.GetStream())
		$WebSSL.AuthenticateAsClient($HarborURL.Host)
		$WebSSL.RemoteCertificate
		$sslraw = $WebSSL.RemoteCertificate
		[byte[]]$byteRaw = $sslraw.Export('Cert')
		Set-Content -Path $WebCert -Value $byteRaw -Encoding Byte
		certutil -f -encode $WebCert $PemFormatCert
		$CertContent = Get-Content -raw $PemFormatCert -Encoding Byte
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
		$WebSSL.Dispose()
		$WebConnect.Dispose()
	}
