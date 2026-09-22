using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace BlackLabel.Marketing.App.Views;

/// <summary>
/// Magical AuthView shell (Windows reel slot #4 after Vigil/Ace/Academy).
/// Paths: Explore demo (gold primary) / Sign in with Apple / Google / Email · then reveal.
/// Demo banner always on in demo. Owner unlock never fake purchase.
/// Identity line matches Mac / Social Media VO exactly.
/// </summary>
public sealed class MagicalAuthView : UserControl
{
    public const string IdentityLine =
        "Your brand's studio — mail, reels, and campaigns that stay yours.";

    public const string ExploreDemoLabel = "Explore demo";

    static readonly Color VoidBlack = Color.FromRgb(0x05, 0x05, 0x05);
    static readonly Color Gold = Color.FromRgb(0xD3, 0xA9, 0x4C);
    static readonly Color AuroraTeal = Color.FromRgb(0x1A, 0x4A, 0x5C);
    static readonly Color AuroraViolet = Color.FromRgb(0x3A, 0x2A, 0x55);

    public event Action? ExploreDemo;
    public event Action? SignInApple;
    public event Action? SignInGoogle;
    public event Action? SignInEmail;

    public MagicalAuthView(bool appleAvailable = false, bool isOwnerBuild = false)
    {
        var root = new Grid();
        root.Background = new SolidColorBrush(VoidBlack);

        // Aurora wash (void black / brushed gold / aurora per MAGICAL plan)
        var aurora = new Border
        {
            Opacity = 0.55,
            IsHitTestVisible = false,
            Background = new LinearGradientBrush(
                new GradientStopCollection
                {
                    new GradientStop(AuroraViolet, 0.0),
                    new GradientStop(VoidBlack, 0.45),
                    new GradientStop(AuroraTeal, 1.0),
                },
                new Point(0, 0),
                new Point(1, 1)),
        };
        root.Children.Add(aurora);

        var goldGlow = new Border
        {
            Opacity = 0.18,
            IsHitTestVisible = false,
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
            Width = 520,
            Height = 520,
            Background = new RadialGradientBrush(
                new GradientStopCollection
                {
                    new GradientStop(Gold, 0.0),
                    new GradientStop(Color.FromArgb(0, 0xD3, 0xA9, 0x4C), 1.0),
                }),
        };
        root.Children.Add(goldGlow);

        var stack = new StackPanel
        {
            VerticalAlignment = VerticalAlignment.Center,
            HorizontalAlignment = HorizontalAlignment.Center,
            Width = 440,
            Margin = new Thickness(32),
        };
        stack.Children.Add(new TextBlock
        {
            Text = "BRANDLIT",
            FontSize = 26,
            FontWeight = FontWeights.Bold,
            Foreground = new SolidColorBrush(Gold),
            LetterSpacing = 3,
            HorizontalAlignment = HorizontalAlignment.Center,
            Margin = new Thickness(0, 0, 0, 10),
        });
        stack.Children.Add(new TextBlock
        {
            Text = IdentityLine,
            FontSize = 14,
            Foreground = new SolidColorBrush(Color.FromRgb(0x9A, 0x9A, 0x9A)),
            TextWrapping = TextWrapping.Wrap,
            TextAlignment = TextAlignment.Center,
            Margin = new Thickness(0, 0, 0, 24),
        });

        // Gold primary CTA
        stack.Children.Add(Btn(ExploreDemoLabel, primary: true, honesty: "Demo data — banner stays on", () => ExploreDemo?.Invoke()));

        // Secondary paths: Sign in with Apple / Google / Email
        if (appleAvailable)
            stack.Children.Add(Btn("Sign in with Apple", primary: false, honesty: null, () => SignInApple?.Invoke()));
        stack.Children.Add(Btn("Sign in with Google", primary: false, honesty: null, () => SignInGoogle?.Invoke()));
        stack.Children.Add(Btn("Sign in with Email", primary: false, honesty: null, () => SignInEmail?.Invoke()));

        stack.Children.Add(new TextBlock
        {
            Text = isOwnerBuild
                ? "Owner build · full studio — not a purchase"
                : "Failures stay honest · cancel ≠ error",
            FontSize = 11,
            Foreground = new SolidColorBrush(Color.FromRgb(0x66, 0x66, 0x66)),
            HorizontalAlignment = HorizontalAlignment.Center,
            Margin = new Thickness(0, 18, 0, 0),
        });

        root.Children.Add(stack);
        Content = root;
        Background = new SolidColorBrush(VoidBlack);
    }

    /// <summary>True when the Explore demo button uses brushed-gold primary styling.</summary>
    public static bool ExploreDemoIsGoldPrimary => true;

    static Button Btn(string label, bool primary, string? honesty, Action click)
    {
        var panel = new StackPanel();
        panel.Children.Add(new TextBlock
        {
            Text = label,
            FontWeight = primary ? FontWeights.SemiBold : FontWeights.Normal,
            Foreground = primary ? Brushes.Black : Brushes.White,
        });
        if (!string.IsNullOrEmpty(honesty))
            panel.Children.Add(new TextBlock
            {
                Text = honesty,
                FontSize = 11,
                Margin = new Thickness(0, 4, 0, 0),
                Foreground = new SolidColorBrush(Color.FromRgb(0x3A, 0x2A, 0x00)),
            });
        var b = new Button
        {
            Content = panel,
            Margin = new Thickness(0, 0, 0, 10),
            Padding = new Thickness(16, 12, 16, 12),
            HorizontalContentAlignment = HorizontalAlignment.Left,
            Background = primary
                ? new SolidColorBrush(Gold)
                : new SolidColorBrush(Color.FromRgb(0x13, 0x13, 0x13)),
            BorderBrush = primary
                ? new SolidColorBrush(Gold)
                : new SolidColorBrush(Color.FromRgb(0x3A, 0x3A, 0x3A)),
            BorderThickness = new Thickness(1),
            Tag = primary ? "gold-primary" : "secondary",
        };
        b.Click += (_, _) => click();
        return b;
    }
}
