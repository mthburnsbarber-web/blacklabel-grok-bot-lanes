# Apply-WindowsRebrand-20260922.ps1
# Founder locks (2026-09-22): SalesSwipe / Brandlit / CoGuide — DISPLAY NAMES ONLY.
# Do NOT change Identity Name / Package Family Name / com.blacklabel.* bundle IDs.
# Do NOT invent entitlements / paywall / product fields.
# Run on michaelscomp as: powershell -ExecutionPolicy Bypass -File .\Apply-WindowsRebrand-20260922.ps1

$ErrorActionPreference = 'Continue'
$root = 'C:\Users\michael\blacklabel'
$circuit = Join-Path $root 'Circuit-Converted'
$notes = Join-Path $root 'notes'
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$log = @()
function Log([string]$m) { $script:log += $m; Write-Host $m }

Log "# WINDOWS REBRAND APPLY — $stamp ET"
Log "Host: $env:COMPUTERNAME"

$trees = @(
  @{ Name='SalesSwipe'; Path=(Join-Path $circuit 'BlackLabelRealEstate-windows'); New='SalesSwipe'; Old=@('Black Label Real Estate','SwipeSales','REAL ESTATE','Real Estate') },
  @{ Name='Brandlit'; Path=(Join-Path $circuit 'BlackLabelMarketing-windows'); New='Brandlit'; Old=@('Black Label Marketing','MARKETING') },
  @{ Name='CoGuide'; Path=(Join-Path $circuit 'BlackLabelAcademy-windows'); New='CoGuide'; Old=@('Black Label Academy','ACADEMY') }
)

# Also probe alternate Academy path names
$academyAlts = @(
  (Join-Path $circuit 'BlackLabelAcademy-windows'),
  (Join-Path $circuit 'CoGuide-windows'),
  (Join-Path $root 'repos\BlackLabelAcademy'),
  (Get-ChildItem (Join-Path $root 'repos') -Directory -Filter '*Academy*' -EA SilentlyContinue | Select-Object -ExpandProperty FullName)
) | Where-Object { $_ } | Select-Object -Unique

Log ''
Log '## 1. Inventory (before)'
foreach ($t in $trees) {
  $exists = Test-Path $t.Path
  Log ("- {0}: {1} exists={2}" -f $t.Name, $t.Path, $exists)
  if (-not $exists) { continue }
  $hits = @()
  Get-ChildItem $t.Path -Recurse -File -Include *.swift,*.plist,yml,*.yaml,*.cs,*.xaml,*.appxmanifest,Package.appxmanifest,*.wxs,*.wixproj,*.json,*.html,*.js,*.md -EA SilentlyContinue |
    ForEach-Object {
      try {
        $c = Get-Content -LiteralPath $_.FullName -Raw -EA Stop
        foreach ($o in $t.Old) {
          if ($c -match [regex]::Escape($o)) { $hits += ("{0} :: {1}" -f $_.FullName.Substring($t.Path.Length), $o) }
        }
      } catch {}
    }
  Log ("  hit files (display-ish): {0}" -f $hits.Count)
  $hits | Select-Object -First 40 | ForEach-Object { Log ("    $_") }
}

function Safe-ReplaceDisplay([string]$file, [hashtable]$map) {
  # Never touch Identity Name / bundle id tokens
  $raw = [IO.File]::ReadAllText($file)
  $orig = $raw
  # Skip pure identity / package family files' Identity Name attributes — we only touch DisplayName / ProductName / titles
  foreach ($k in $map.Keys) {
    $raw = $raw.Replace($k, $map[$k])
  }
  # Revert accidental identity mutations if any slipped
  $raw = $raw -replace 'Name="SalesSwipe"', 'Name="PARTNER-CENTER-PLACEHOLDER.BlackLabelRealEstate"' # too broad — skip
  if ($raw -ne $orig) {
    # Guard: never rewrite com.blacklabel.* or MichaelBarber.BlackLabel*
    if ($orig -match 'com\.blacklabel\.' -and ($raw -notmatch 'com\.blacklabel\.')) {
      Log "SKIP identity risk: $file"
      return $false
    }
    [IO.File]::WriteAllText($file, $raw)
    return $true
  }
  return $false
}

Log ''
Log '## 2. Apply display renames (targeted)'

# Precise replacements per product (safer than blanket map)
$jobs = @(
  @{
    Roots = @((Join-Path $circuit 'BlackLabelRealEstate-windows'), (Join-Path $root 'repos\BlackLabelRealEstate'))
    Map = [ordered]@{
      'CFBundleDisplayName: "Black Label Real Estate"' = 'CFBundleDisplayName: "SalesSwipe"'
      '<string>Black Label Real Estate</string>' = '<string>SalesSwipe</string>'
      '<DisplayName>Black Label Real Estate</DisplayName>' = '<DisplayName>SalesSwipe</DisplayName>'
      'DisplayName="Black Label Real Estate"' = 'DisplayName="SalesSwipe"'
      'PRODUCT_NAME: "Black Label Real Estate"' = 'PRODUCT_NAME: "SalesSwipe"'
      '"productName": "Black Label Real Estate"' = '"productName": "SalesSwipe"'
      '<title>Black Label Real Estate</title>' = '<title>SalesSwipe</title>'
      'Text = "REAL ESTATE"' = 'Text = "SALESWIPE"'
      'Text = "Real Estate"' = 'Text = "SalesSwipe"'
      # SwipeSales→SalesSwipe handled below for display-only contexts
    }
  }
  @{
    Roots = @((Join-Path $circuit 'BlackLabelMarketing-windows'), (Join-Path $root 'repos\BlackLabelMarketing'))
    Map = [ordered]@{
      'CFBundleDisplayName: "Black Label Marketing"' = 'CFBundleDisplayName: "Brandlit"'
      '<string>Black Label Marketing</string>' = '<string>Brandlit</string>'
      '<DisplayName>Black Label Marketing</DisplayName>' = '<DisplayName>Brandlit</DisplayName>'
      'DisplayName="Black Label Marketing"' = 'DisplayName="Brandlit"'
      'PRODUCT_NAME: "Black Label Marketing"' = 'PRODUCT_NAME: "Brandlit"'
      '"productName": "Black Label Marketing"' = '"productName": "Brandlit"'
      'Text = "MARKETING"' = 'Text = "BRANDLIT"'
      'fallback ? value! : "Black Label Marketing"' = 'fallback ? value! : "Brandlit"'
      ': "Black Label Marketing"' = ': "Brandlit"'
    }
  }
  @{
    Roots = @((Join-Path $circuit 'BlackLabelAcademy-windows')) + $academyAlts
    Map = [ordered]@{
      'CFBundleDisplayName: "Black Label Academy"' = 'CFBundleDisplayName: "CoGuide"'
      '<string>Black Label Academy</string>' = '<string>CoGuide</string>'
      '<DisplayName>Black Label Academy</DisplayName>' = '<DisplayName>CoGuide</DisplayName>'
      'DisplayName="Black Label Academy"' = 'DisplayName="CoGuide"'
      'PRODUCT_NAME: "Black Label Academy"' = 'PRODUCT_NAME: "CoGuide"'
      '"productName": "Black Label Academy"' = '"productName": "CoGuide"'
      "title: 'Black Label Academy'" = "title: 'CoGuide'"
      'Text = "ACADEMY"' = 'Text = "COGUIDE"'
      ': "Black Label Academy"' = ': "CoGuide"'
    }
  }
)

$changed = @()

# Public lock: SalesSwipe not SwipeSales — only in display/title/ProductName contexts
$swipeFixRoots = @(
  (Join-Path $circuit 'BlackLabelRealEstate-windows'),
  (Join-Path $root 'repos\BlackLabelRealEstate')
)
foreach ($r in $swipeFixRoots) {
  if (-not (Test-Path $r)) { continue }
  Get-ChildItem $r -Recurse -File -Include *.swift,*.plist,*.yml,*.cs,*.xaml,*.appxmanifest,Package.appxmanifest,*.json,*.html,*.js -EA SilentlyContinue | ForEach-Object {
    $raw = [IO.File]::ReadAllText($_.FullName)
    if ($raw -notmatch 'SwipeSales') { return }
    $fixed = $raw
    $fixed = $fixed -replace 'CFBundleDisplayName:\s*"SwipeSales"', 'CFBundleDisplayName: "SalesSwipe"'
    $fixed = $fixed -replace '<DisplayName>SwipeSales</DisplayName>', '<DisplayName>SalesSwipe</DisplayName>'
    $fixed = $fixed -replace 'DisplayName="SwipeSales"', 'DisplayName="SalesSwipe"'
    $fixed = $fixed -replace '"productName":\s*"SwipeSales"', '"productName": "SalesSwipe"'
    $fixed = $fixed -replace '<title>SwipeSales</title>', '<title>SalesSwipe</title>'
    $fixed = $fixed -replace 'Text = "SWIPESALES"', 'Text = "SALESWIPE"'
    $fixed = $fixed -replace 'Text = "SwipeSales"', 'Text = "SalesSwipe"'
    if ($fixed -ne $raw) { [IO.File]::WriteAllText($_.FullName, $fixed); $changed += $_.FullName; Log "SWIPESALES→SALESWIPE $($_.FullName)" }
  }
}

foreach ($job in $jobs) {
  foreach ($r in ($job.Roots | Select-Object -Unique)) {
    if (-not (Test-Path $r)) { Log "skip missing root $r"; continue }
    Get-ChildItem $r -Recurse -File -Include *.swift,*.plist,*.yml,*.yaml,*.cs,*.xaml,*.appxmanifest,Package.appxmanifest,*.wxs,*.json,*.html,*.js -EA SilentlyContinue |
      ForEach-Object {
        $path = $_.FullName
        # Skip Store Identity Name fields by excluding files that only hold identity — still OK to edit DisplayName in same file
        $raw = [IO.File]::ReadAllText($path)
        $orig = $raw
        foreach ($k in $job.Map.Keys) { $raw = $raw.Replace([string]$k, [string]$job.Map[$k]) }
        # Never mutate Identity Name= or Package Family / bundle ids
        if ($raw -match 'Identity[\s\S]{0,200}Name="SalesSwipe"' -or $raw -match 'Identity[\s\S]{0,200}Name="Brandlit"' -or $raw -match 'Identity[\s\S]{0,200}Name="CoGuide"') {
          Log "GUARD: refused Identity Name mutation in $path"
          return
        }
        if ($raw -ne $orig) {
          # Ensure com.blacklabel still present if it was
          if (($orig -match 'com\.blacklabel\.') -and ($raw -notmatch 'com\.blacklabel\.')) {
            Log "GUARD: refused bundle-id wipe in $path"
          } else {
            [IO.File]::WriteAllText($path, $raw)
            $changed += $path
            Log "CHANGED $path"
          }
        }
      }
  }
}

Log ''
Log ("## 3. Files changed: {0}" -f $changed.Count)

Log ''
Log '## 4. swift build -Xswiftc -DCIRCUIT_WINDOWS_SIM (Circuit cores)'
$buildResults = @()
foreach ($t in $trees) {
  $pkg = Join-Path $t.Path 'Package.swift'
  if (-not (Test-Path $pkg)) {
    Log ("BUILD SKIP {0}: no Package.swift at {1}" -f $t.Name, $t.Path)
    $buildResults += [pscustomobject]@{ App=$t.Name; Exit=-1; Note='no Package.swift' }
    continue
  }
  Push-Location $t.Path
  try {
    Log ("BUILD START {0} in {1}" -f $t.Name, $t.Path)
    & swift build -Xswiftc -DCIRCUIT_WINDOWS_SIM 2>&1 | Tee-Object -Variable bout | Out-Null
    $code = $LASTEXITCODE
    Log ("BUILD EXIT {0} = {1}" -f $t.Name, $code)
    $buildResults += [pscustomobject]@{ App=$t.Name; Exit=$code; Note=(($bout | Select-Object -Last 5) -join ' | ') }
  } catch {
    Log ("BUILD ERROR {0}: {1}" -f $t.Name, $_)
    $buildResults += [pscustomobject]@{ App=$t.Name; Exit=99; Note="$_" }
  } finally { Pop-Location }
}

Log ''
Log '## 5. Build summary'
$buildResults | ForEach-Object { Log ("- {0}: exit={1} ({2})" -f $_.App, $_.Exit, $_.Note) }

$out = Join-Path $notes 'WINDOWS-REBRAND-BUILDABLE-20260922.md'
$log -join "`n" | Set-Content -Path $out -Encoding UTF8
Log "Wrote $out"

# Mirror into BlackLabel-Team STATE if present
$state = Join-Path $root 'BlackLabel-Team\STATE\demo-day-20260922'
if (Test-Path (Split-Path $state -Parent)) {
  New-Item -ItemType Directory -Force -Path $state | Out-Null
  Copy-Item $out (Join-Path $state 'WINDOWS-REBRAND-BUILDABLE-20260922.md') -Force
  Log "Mirrored STATE demo-day receipt"
}

Write-Host "DONE. changed=$($changed.Count)"
