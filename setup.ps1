param(
  [int]
  $Part = 0
)

#if ($Path -eq 0) {
$Root = "$($PWD)";

Expand-Archive -Path "$($PWD)\Penumbra.zip" -DestinationPath "$($PWD)\Penumbra";

New-Item -ItemType Directory -Path "$($PWD)\Temp" >$null;

Move-Item -Path "$($PWD)\run.ps1" -Destination "$($PWD)\Temp\run.ps1";

Set-Location -Path "$($PWD)\Temp";
#  $ExitCode = $LASTEXITCODE;

#  if ($ExitCode -eq 0) {
#    Write-Host -Object "Success!";
#    Exit 0;
#  }
#  else {
#    Write-Host -Object "Failed!";
#    Write-Host -Object "ExitCode: $($ExitCode)";
#    Exit 1;
#  }

#  Exit -1;
#}
& "$($PWD)\run.ps1" -Name "NierSage[\-_]" -OutputName "`[Dekken`] Neir_Sage" -Version "1.0.0" -Website "" -Tags @() -Description "";
#if ($Part -eq 1) {
Compress-Archive -Path (Get-ChildItem -LiteralPath "$($PWD)\Tesp\[Dekken] Neir_Sage") -DestinationPath "$($Root)\`[Dekken`] Neir_Sage.zip";

Set-Location -Path "$($Root)";

Rename-Item -Path "[Dekken] Neir_Sage.zip" -NewName "[Dekken] Neir_Sage.pmp";
$ExitCode = $LASTEXITCODE;

if ($ExitCode -eq 0) {
  Write-Host -Object "Success!";
  Exit 0;
}
else {
  Write-Host -Object "Failed!";
  Write-Host -Object "ExitCode: $($ExitCode)";
  Exit 1;
}

Exit -1;
#}