using Xunit;

namespace BlackLabel.Marketing.Core.Tests;

/// <summary>
/// Source-contract tests for MagicalAuthView cold-open (identity + gold Explore demo).
/// Loads the App Views .cs without instantiating WPF.
/// </summary>
public sealed class MagicalAuthViewTests
{
    private static string LoadMagicalAuthSource()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir != null)
        {
            var candidate = Path.Combine(dir.FullName, "src", "BlackLabelMarketing.App", "Views", "MagicalAuthView.cs");
            if (File.Exists(candidate)) return File.ReadAllText(candidate);
            dir = dir.Parent;
        }
        throw new FileNotFoundException("MagicalAuthView.cs not found from " + AppContext.BaseDirectory);
    }

    [Fact]
    public void IdentityLine_MatchesMacSocialMediaVoExactly()
    {
        var src = LoadMagicalAuthSource();
        Assert.Contains(
            "Your brand's studio — mail, reels, and campaigns that stay yours.",
            src,
            StringComparison.Ordinal);
    }

    [Fact]
    public void ExploreDemo_IsGoldPrimaryCta()
    {
        var src = LoadMagicalAuthSource();
        Assert.Contains("Explore demo", src, StringComparison.Ordinal);
        Assert.Contains("ExploreDemoLabel", src, StringComparison.Ordinal);
        Assert.Contains("ExploreDemoIsGoldPrimary", src, StringComparison.Ordinal);
        // Primary button uses brushed gold #D3A94C
        Assert.Contains("0xD3, 0xA9, 0x4C", src, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("Btn(ExploreDemoLabel, primary: true", src, StringComparison.Ordinal);
    }

    [Fact]
    public void SecondaryPaths_AppleGoogleEmail()
    {
        var src = LoadMagicalAuthSource();
        Assert.Contains("Sign in with Apple", src, StringComparison.Ordinal);
        Assert.Contains("Sign in with Google", src, StringComparison.Ordinal);
        Assert.Contains("Sign in with Email", src, StringComparison.Ordinal);
    }

    [Fact]
    public void Honesty_DemoBannerAndOwnerUnlockNotPurchase()
    {
        var src = LoadMagicalAuthSource();
        Assert.Contains("Demo data — banner stays on", src, StringComparison.Ordinal);
        Assert.Contains("not a purchase", src, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("Buy now", src, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("StoreKit", src, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void Visual_VoidBlackBrushedGoldAurora()
    {
        var src = LoadMagicalAuthSource();
        Assert.Contains("0x05, 0x05, 0x05", src, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("Aurora", src, StringComparison.Ordinal);
        Assert.Contains("LinearGradientBrush", src, StringComparison.Ordinal);
    }

    [Fact]
    public void MainWindow_WiresMagicalAuthWhenPresent()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        string? main = null;
        while (dir != null)
        {
            var candidate = Path.Combine(dir.FullName, "src", "BlackLabelMarketing.App", "MainWindow.xaml.cs");
            if (File.Exists(candidate)) { main = File.ReadAllText(candidate); break; }
            dir = dir.Parent;
        }
        Assert.NotNull(main);
        Assert.Contains("MagicalAuthView", main!, StringComparison.Ordinal);
    }
}
