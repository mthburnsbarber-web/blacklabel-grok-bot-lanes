# Apply MagicalAuthView into BlackLabelMarketing Windows tree + build.
# Run ON michaelscomp. No Partner Center. No Mac Ace 87.
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding $false

$Pkg = 'C:\Users\michael\blacklabel\notes\windows-magical-20260922'
if (-not (Test-Path (Join-Path $Pkg 'marketing\MagicalAuthView.cs'))) {
  $alt = Join-Path (Split-Path $PSScriptRoot -Parent) ''
  if (Test-Path (Join-Path $alt 'marketing\MagicalAuthView.cs')) { $Pkg = $alt }
}
$BL = 'C:\Users\michael\blacklabel'
$candidates = @(
  (Join-Path $BL 'repos\BlackLabelMarketing\.claude\worktrees\windows-full-build-20260808\windows'),
  (Join-Path $BL 'repos\BlackLabelMarketing\windows'),
  (Join-Path $BL 'worktrees\BlackLabelMarketing-windows')
)
$Win = $null
foreach ($c in $candidates) {
  if (Test-Path (Join-Path $c 'src\BlackLabelMarketing.App')) { $Win = $c; break }
}
if (-not $Win) { throw "BlackLabelMarketing Windows tree not found under $BL" }

$Views = Join-Path $Win 'src\BlackLabelMarketing.App\Views'
$AppProj = Join-Path $Win 'src\BlackLabelMarketing.App'
$Main = Join-Path $AppProj 'MainWindow.xaml.cs'
$TestsDir = Join-Path $Win 'tests\BlackLabelMarketing.Core.Tests'

Write-Host "Package: $Pkg"
Write-Host "Windows: $Win"

New-Item -ItemType Directory -Force -Path $Views | Out-Null
Copy-Item (Join-Path $Pkg 'marketing\MagicalAuthView.cs') (Join-Path $Views 'MagicalAuthView.cs') -Force
Write-Host "Copied MagicalAuthView.cs → $Views"

if (Test-Path $TestsDir) {
  Copy-Item (Join-Path $Pkg 'marketing\MagicalAuthViewTests.cs') (Join-Path $TestsDir 'MagicalAuthViewTests.cs') -Force
  Write-Host "Copied MagicalAuthViewTests.cs"
}

# --- Wire MainWindow cold-open ---
if (-not (Test-Path $Main)) { throw "MainWindow.xaml.cs missing: $Main" }
$mainText = [System.IO.File]::ReadAllText($Main)
$changed = $false

if ($mainText -notmatch 'MagicalAuthView') {
  # Prefer injecting into EnterApp's caller / constructor show-login path.
  # Pattern A: method ShowLogin / ShowAuth / BuildAuth that returns UIElement
  $wireMarker = '/* MAGICAL_AUTH_WIRE */'
  if ($mainText -match 'private void EnterApp\(') {
    # Insert ShowMagicalColdOpen before first use of login chrome if we find a Loaded/ctor hook.
    $method = @'

    /* MAGICAL_AUTH_WIRE */
    private void ShowMagicalColdOpen()
    {
        var apple = false; // Windows MSI: Apple Sign In residual unless entitlement present
        var owner = false;
        try {
            owner = string.Equals(
                Environment.GetEnvironmentVariable("BLM_OWNER_BUILD"), "1",
                StringComparison.Ordinal);
        } catch { /* ignore */ }
        var magical = new BlackLabel.Marketing.App.Views.MagicalAuthView(apple, owner);
        magical.ExploreDemo += () =>
        {
            // Demo: banner stays on; EnterApp with demo identity (honesty: sample ≠ purchase)
            EnterApp("demo");
        };
        magical.SignInApple += () =>
        {
            MessageBox.Show(
                "Sign in with Apple is a Mac entitlement path. Use Google, Email, or Explore demo on this Windows build.",
                "Black Label Marketing", MessageBoxButton.OK, MessageBoxImage.Information);
        };
        magical.SignInGoogle += () =>
        {
            MessageBox.Show(
                "Google OAuth on Windows is residual — configure client ID later or use Email / Explore demo.",
                "Black Label Marketing", MessageBoxButton.OK, MessageBoxImage.Information);
        };
        magical.SignInEmail += () => ShowClassicEmailAuth();
        // Host magical as the window content / overlay root when available
        if (this.Content is System.Windows.Controls.Grid hostGrid)
        {
            var overlay = new System.Windows.Controls.Border { Child = magical, Background = System.Windows.Media.Brushes.Transparent };
            overlay.Name = "MagicalAuthOverlay";
            hostGrid.Children.Add(overlay);
            System.Windows.Controls.Panel.SetZIndex(overlay, 1000);
        }
        else
        {
            this.Content = magical;
        }
    }

    private void ShowClassicEmailAuth()
    {
        // Fall through to existing email/password chrome if present; else prompt EnterApp flow.
        var overlay = this.Content as System.Windows.FrameworkElement;
        // Remove magical overlay if we replaced Content entirely — caller should re-show login fields.
        MessageBox.Show(
            "Use your local email & password on the classic form, or Explore demo for sample data (banner stays on).",
            "Sign in with Email", MessageBoxButton.OK, MessageBoxImage.Information);
    }

'@
    # Insert method before EnterApp
    $mainText = $mainText -replace '(\r?\n\s*private void EnterApp\()', ($method + '$1')
    $changed = $true

    # Call ShowMagicalColdOpen from constructor end or Loaded if not signed in
    if ($mainText -notmatch 'ShowMagicalColdOpen\(\)') {
      if ($mainText -match 'InitializeComponent\(\);') {
        $mainText = $mainText -replace '(InitializeComponent\(\);)', "`$1`r`n        if (string.IsNullOrWhiteSpace(AppState.Current.SignedInEmail)) ShowMagicalColdOpen();"
        $changed = $true
      } elseif ($mainText -match 'public MainWindow\(') {
        # Append call after constructor body opening is hard; use Loaded
        $mainText = $mainText -replace '(InitializeComponent\(\);)', "`$1`r`n        Loaded += (_, __) => { if (string.IsNullOrWhiteSpace(AppState.Current.SignedInEmail)) ShowMagicalColdOpen(); };"
        $changed = $true
      }
    }

    # AppState may use IsGuest / SignedInEmail instead of IsSignedIn — soften compile
    if ($mainText -match 'IsSignedIn' -and $mainText -notmatch 'bool IsSignedIn') {
      # Prefer existing property names
      if ($mainText -match 'SignedInEmail' -or $mainText -match 'IsGuest') {
        $mainText = $mainText.Replace(
          'if (string.IsNullOrWhiteSpace(AppState.Current.SignedInEmail)) ShowMagicalColdOpen();',
          'if (string.IsNullOrWhiteSpace(AppState.Current.SignedInEmail) && AppState.Current.IsGuest) { /* cold */ } if (string.IsNullOrWhiteSpace(AppState.Current.SignedInEmail)) ShowMagicalColdOpen();')
        # Simpler: always show when no email
        $mainText = $mainText.Replace(
          'if (string.IsNullOrWhiteSpace(AppState.Current.SignedInEmail) && AppState.Current.IsGuest) { /* cold */ } if (string.IsNullOrWhiteSpace(AppState.Current.SignedInEmail)) ShowMagicalColdOpen();',
          'if (string.IsNullOrWhiteSpace(AppState.Current.SignedInEmail)) ShowMagicalColdOpen();')
      }
    }
  } else {
    Write-Warning "EnterApp not found — MagicalAuthView.cs copied; manual wire needed per APPLY.md"
  }
} else {
  Write-Host "MainWindow already references MagicalAuthView"
}

if ($changed) {
  [System.IO.File]::WriteAllText($Main, $mainText, $utf8)
  Write-Host "Patched MainWindow.xaml.cs with MagicalAuth cold-open"
}

# Identity + gold primary source check
$authSrc = Get-Content (Join-Path $Views 'MagicalAuthView.cs') -Raw
$identityOk = $authSrc -match [regex]::Escape("Your brand's studio — mail, reels, and campaigns that stay yours.")
$goldOk = ($authSrc -match 'Explore demo') -and ($authSrc -match '0xD3, 0xA9, 0x4C') -and ($authSrc -match 'primary: true')
Write-Host "Identity exact: $identityOk"
Write-Host "Explore demo gold primary: $goldOk"

# Build App
$csproj = Get-ChildItem $AppProj -Filter '*.csproj' | Select-Object -First 1
if (-not $csproj) { throw "No csproj in $AppProj" }
Write-Host "Building $($csproj.FullName) ..."
dotnet build $csproj.FullName -c Release
$buildExit = $LASTEXITCODE
Write-Host "BUILD_EXIT=$buildExit"

# Optional tests
$testProj = Get-ChildItem (Join-Path $Win 'tests\BlackLabelMarketing.Core.Tests') -Filter '*.csproj' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($testProj) {
  Write-Host "Testing MagicalAuth contracts..."
  dotnet test $testProj.FullName -c Release --filter "FullyQualifiedName~MagicalAuthViewTests" --no-restore 2>&1 | Select-Object -Last 40
}

# Mirror notes
$Notes = Join-Path $BL 'notes'
$State = Join-Path $BL 'BlackLabel-Team\STATE\grok-bot'
New-Item -ItemType Directory -Force -Path $Notes,$State | Out-Null
Copy-Item (Join-Path $Pkg 'notes\*.md') $Notes -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $Pkg 'notes\*.md') $State -Force -ErrorAction SilentlyContinue

Write-Host "DONE Marketing MagicalAuth apply. ExploreDemoIsGoldPrimary=$goldOk BuildExit=$buildExit"
