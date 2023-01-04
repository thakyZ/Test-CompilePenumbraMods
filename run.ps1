param(
  # Filter the mods to copy via this text.
  [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $False, HelpMessage = "Filter the mods to copy via this text.")]
  [string]
  $Name,
  # The mod name to compile into.
  [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $False, HelpMessage = "The mod name to compile into.")]
  [string]
  $OutputName = $null,
  # The mod authors.
  [Parameter(Mandatory = $False, Position = 2, ValueFromPipeline = $False, HelpMessage = "The mod authors.")]
  [string]
  $Author,
  # The mod version.
  [Parameter(Mandatory = $False, Position = 3, ValueFromPipeline = $False, HelpMessage = "The mod version.")]
  [string]
  $Version,
  # The mod website.
  [Parameter(Mandatory = $False, Position = 4, ValueFromPipeline = $False, HelpMessage = "The mod website.")]
  [string]
  $Website,
  # The mod tags.
  [Parameter(Mandatory = $False, Position = 5, ValueFromPipeline = $False, HelpMessage = "The mod tags.")]
  [string[]]
  $Tags,
  # The mod description in a string.
  [Parameter(Mandatory = $False, Position = 6, ValueFromPipeline = $False, HelpMessage = "The mod description in a string.")]
  [string]
  $Desctiption = $null,
  # The mod description in a file.
  [Parameter(Mandatory = $False, Position = 7, ValueFromPipeline = $False, HelpMessage = "The mod description in a file.")]
  [string]
  $DesctiptionPath = $null
)

$Match = ".+$($Name).+";

Copy-Item -Recurse -LiteralPath (Get-ChildItem -Path "$($PWD)\..\Penumbra" | Sort-Object -Property LastWriteTimeUtc | Where-Object { $_.BaseName -match $Match } ) -Destination "$($PWD)\..\Temp\";

$ModCompiledName = "Temp";

if ($null -ne $OutputName) {
  $ModCompiledName = (Read-Host -Prompt "Compiled Mod Name:")
}
else {
  $ModCompiledName = $OutputName;
}

$MatchFileName = "$($Name)[-_]"

Get-ChildItem -Path "$($PWD)" | Where-Object { $_.Name -ne "$($ModCompiledName)" } | ForEach-Object { Copy-Item -LiteralPath $_.Name -Destination "$($PWD)\$($ModCompiledName)\$(($_.Name -replace $MatchFileName, '').Split('-') -join '\')" }

$PathNameRegex = "$($PWD)\\$($ModCompiledName -replace "/([[\]])/gi", '\$1')\\";

$ModCompiledDir = (New-Item -ItemType Directory -Path "$($PWD)\$($ModCompiledName)");

$Items = (Get-ChildItem -LiteralPath "$($PWD)\$($ModCompiledName)" -Recurse -Depth 4 -File -Include "*.json")

$Items | ForEach-Object {

  $OptionName = $_.Directory.Name;

  $PathName = (($_.Directory.FullName -replace $PathNameRegex, '').Split('\') -join '\');

  $ParentName = $_.Directory.Parent.Name;

  if ($_.BaseName -eq "default_mod") {

    if (-not (Test-Path -LiteralPath "$($ModCompiledDir)\group_$($ParentName).json")) {

      Copy-Item -LiteralPath "$($PWD)\..\group_soup.json" -Destination "$($ModCompiledDir)\group_$($ParentName).json";

      $json = (Get-Content -LiteralPath "$($ModCompiledDir)\group_$($ParentName).json" | ConvertFrom-Json -Depth 5);

      $json.Name = "$($ParentName)";

      $json | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath "$($ModCompiledDir)\group_$($ParentName).json";

    }

    $oldJson = (Get-Content -LiteralPath $_.FullName | ConvertFrom-Json -Depth 5);

    $json = (Get-Content -LiteralPath "$($ModCompiledDir)\group_$($ParentName).json" | ConvertFrom-Json -Depth 5);

    $new = New-Object -TypeName PsObject -Property @{
      Name          = $OptionName;
      Priority      = 0;
      Files         = @{};
      FileSwaps     = @{};
      Manipulations = @()
    };

    $ht2 = @{};

    $oldJson.Files.psobject.properties | ForEach-Object {
      $ht2[$_.Name] = $_.Value
    }

    $ht2.Keys | ForEach-Object {
      $_temp = $ht2[$_];
      $ht2[$_] = "$($PathName)\$($_temp)"
    }

    $new.Files = $ht2;

    $new.FileSwaps = @{};

    $new.Manipulations = @();

    $json.Options += $new;

    $json | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath "$($ModCompiledDir)\group_$($ParentName).json";

  }

}

Copy-Item -LiteralPath "$($PWD)\..\default_mod.json" -Destination "$($ModCompiledDir)\default_mod.json";

Copy-Item -LiteralPath "$($PWD)\..\meta.json" -Destination "$($ModCompiledDir)\meta.json";

$MetaJson = (Get-Content -LiteralPath "$($PWD)\..\Temp\meta.json" | ConvertFrom-Json -Depth 5)

$MetaJson.Name = "$($ModCompiledName)";
$MetaJson.Author = "$($Author)";
$MetaJson.Version = "$($Version)";
$MetaJson.Website = "$($Website)";
$MetaJson.Tags = $Tags;

if ($null -ne $DescriptionPath) {
  $MetaJson.Description = "$($Desctiption)";
}
elseif (($null -ne $DescriptionPath) -and (Test-Path -LiteralPath $DesctiptionPath -PathType Leaf)) {
  $MetaJson.Description = ((Get-Content -LiteralPath $DesctiptionPath) -replace '\n', '\\n');
}
else {
  $MetaJson.Description = "";
}

$MetaJson | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath "$($ModCompiledDir)\meta.json";

function Sync-InternalOption() {
  param(
    [psobject]
    $File
  )

  Get-ChildItem -LiteralPath $File.FullName -Recurse -Include "*.json" | ForEach-Object {
    if (($_.BaseName -eq "meta") -or ($_.BaseName -eq "default_mod")) {
      Remove-Item -LiteralPath $_.FullName;
    }
  }
}

Get-ChildItem -LiteralPath "$($ModCompiledDir)" -Directory | ForEach-Object { Sync-InternalOption -File $_ }

Exit $LASTEXITCODE;