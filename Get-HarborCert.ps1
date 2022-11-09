$HarborURL = [Net.WebRequest]::Create("https://harborFQDNHere")
$CertPath = "C:\temp\CertNameHere.cer"
try 
	{ 
	$HarborURL.GetResponse() 
	} 
catch 
	{
	Write-Host "An error occurred." -BackgroundColor Black -ForegroundColor Red
	Write-Host $_.ScriptStackTrace	-BackgroundColor Black -ForegroundColor Red
	Write-Host $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
	$ErrorTraceCaught = $_.ScriptStackTrace
	$ErrorMessageOut = $_.Exception.Message
	}
$Webcert = $HarborURL.ServicePoint.Certificate
$Rawcert = $Webcert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)
set-content -value $Rawcert -encoding byte -path "$CertPath"
$CertContent = Get-Content -raw $CertPath -Encoding Byte
$certout = [Convert]::ToBase64String($CertContent)
Write-Host "Your Base64 Cert Is:" -BackgroundColor Black -ForegroundColor Yellow
Write-Host "-----BEGIN CERTIFICATE-----" -BackgroundColor Black -ForegroundColor Green
Write-Host $certout -BackgroundColor Black -ForegroundColor Green
Write-Host "-----END CERTIFICATE-----" -BackgroundColor Black -ForegroundColor Green
