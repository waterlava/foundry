$Quality = Read-Host -Prompt "Please input the quality (between 0 and 100, the default is 80)"
If(-not($Quality) -or -not($Quality -in 0..100)){$Quality = "80"}
Write-Output "Quality: $Quality"
$OutputLocation = Read-Host -Prompt "Where would you like to save the webp files? (Please write a valid path, default is Desktop)"
If(-not($OutputLocation)){$OutputLocation = ([environment]::getfolderpath("Desktop"))}
Set-Location $OutputLocation -ErrorAction SilentlyContinue -ErrorVariable ProcessError;
If ($ProcessError) {
    Write-Output 'Invalid output path! Exiting...'
    Start-Sleep -s 5
    exit
}
Write-Output "Output location: $OutputLocation"
mkdir "Webp" -ErrorAction SilentlyContinue
Write-Output "Choose files to convert..."
[System.Reflection.Assembly]::LoadWithPartialName('System.windows.forms')|Out-Null
$OFD = New-Object System.Windows.Forms.OpenFileDialog
$OFD.Multiselect = $True
$OFD.Filter = 'Images (*.png;*.jpeg;*.gif;*.jpg;*.bmp;*.tiff;*.tif)|*.png;*.jpeg;*.gif;*.jpg;*.bmp;*.tiff;*.tif'
$OFD.ShowDialog() | out-null
Set-Location "C:\Program Files\libwebp-1.1.0-windows-x64\bin"
& .\cwebp.exe | out-null
for ($i = 0; $i -lt $OFD.Filenames.count; $i++) {
    $InputImage="`""+$OFD.Filenames[$i]+"`""
    $Output=$OutputLocation+"\Webp\"+[System.IO.Path]::GetFileNameWithoutExtension($OFD.Filenames[$i])+".webp"
    .\cwebp -q "$Quality" "$InputImage" -o "$Output" -progress -quiet
    Clear-Variable InputImage
    $p = $i/$OFD.Filenames.count*100
    Write-Progress -Activity "Converting to webp" -Status "$p% Complete:" -PercentComplete $p -CurrentOperation ([System.IO.Path]::GetFileName($OFD.Filenames[$i]))
}
Write-Output "Done."