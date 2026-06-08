# scripts/Menu.ps1
# WPF graphical tool selection window.
# Dot-source this file, then call Show-ToolMenu.

function Show-ToolMenu {
    param(
        [Parameter(Mandatory)] [array] $Catalog
    )

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase

    # Build item state list — nothing pre-selected; user picks what they want.
    $items = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($tool in $Catalog) {
        $items.Add([PSCustomObject]@{ Tool = $tool; Selected = $false })
    }
    $categories = @($Catalog | ForEach-Object { $_.Category } | Select-Object -Unique)

    # ── XAML ─────────────────────────────────────────────────────────────────────
    [xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WorkStation Builder" Height="820" Width="1300"
        MinHeight="560" MinWidth="900"
        WindowStartupLocation="CenterScreen"
        Background="#1e1e2e">
  <Window.Resources>

    <Style TargetType="CheckBox">
      <Setter Property="Foreground" Value="#cdd6f4"/>
      <Setter Property="BorderBrush" Value="#585b70"/>
      <Setter Property="Margin" Value="0,3,16,3"/>
      <Setter Property="Padding" Value="8,0,0,0"/>
      <Setter Property="FontFamily" Value="Consolas"/>
      <Setter Property="VerticalContentAlignment" Value="Center"/>
    </Style>

    <Style TargetType="Button">
      <Setter Property="Background" Value="#313244"/>
      <Setter Property="Foreground" Value="#cdd6f4"/>
      <Setter Property="BorderBrush" Value="#45475a"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="14,8"/>
      <Setter Property="FontFamily" Value="Consolas"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="4"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="TextBox">
      <Setter Property="Background" Value="#313244"/>
      <Setter Property="Foreground" Value="#cdd6f4"/>
      <Setter Property="BorderBrush" Value="#45475a"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="10,6"/>
      <Setter Property="FontFamily" Value="Consolas"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="CaretBrush" Value="#cdd6f4"/>
    </Style>

  </Window.Resources>
  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
    </Grid.RowDefinitions>

    <!-- Header -->
    <Border Grid.Row="0" Background="#181825" Padding="24,14">
      <StackPanel Orientation="Horizontal">
        <Image x:Name="HeaderLogo" Width="40" Height="40" Margin="0,0,14,0"
               VerticalAlignment="Center" RenderOptions.BitmapScalingMode="HighQuality"/>
        <StackPanel VerticalAlignment="Center">
          <TextBlock Text="WorkStation Builder" FontFamily="Consolas"
                     FontSize="20" FontWeight="Bold" Foreground="#cba6f7"/>
          <TextBlock Text="Check boxes to select tools, then click Install Selected."
                     FontFamily="Consolas" FontSize="12" Foreground="#585b70" Margin="0,4,0,0"/>
        </StackPanel>
      </StackPanel>
    </Border>

    <!-- Body: sidebar + tool grid -->
    <Grid Grid.Row="1">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="240"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>

      <!-- Sidebar -->
      <Border Grid.Column="0" Background="#181825" Padding="18"
              BorderBrush="#313244" BorderThickness="0,0,1,0">
        <DockPanel LastChildFill="False">
          <StackPanel DockPanel.Dock="Bottom">
            <Button x:Name="BtnInstall" Content="Install Selected"
                    Background="#a6e3a1" Foreground="#1e1e2e" FontWeight="Bold"
                    BorderBrush="#a6e3a1" Margin="0,0,0,8" HorizontalAlignment="Stretch"/>
            <Button x:Name="BtnCancel" Content="Cancel" HorizontalAlignment="Stretch"/>
          </StackPanel>

          <StackPanel DockPanel.Dock="Top">
          <TextBlock Text="SEARCH" FontFamily="Consolas" FontSize="11" FontWeight="Bold"
                     Foreground="#f38ba8" Margin="0,0,0,6"/>
          <Grid Margin="0,0,0,20">
            <TextBox x:Name="SearchBox"/>
            <TextBlock x:Name="SearchHint"
                       Text="  name, category, description..."
                       FontFamily="Consolas" FontSize="12" Foreground="#45475a"
                       IsHitTestVisible="False" VerticalAlignment="Center"/>
          </Grid>

          <TextBlock Text="SELECTION" FontFamily="Consolas" FontSize="11" FontWeight="Bold"
                     Foreground="#f38ba8" Margin="0,0,0,6"/>
          <Button x:Name="BtnAll"  Content="Select All" Margin="0,0,0,8" HorizontalAlignment="Stretch"/>
          <Button x:Name="BtnNone" Content="Clear All"  Margin="0,0,0,20" HorizontalAlignment="Stretch"/>

          <Border Background="#313244" CornerRadius="6" Padding="12,10" Margin="0,0,0,20">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
              <TextBlock Text="Selected: " FontFamily="Consolas" FontSize="13" Foreground="#585b70"/>
              <TextBlock x:Name="SelectedCount" Text="0" FontFamily="Consolas"
                         FontSize="13" FontWeight="Bold" Foreground="#a6e3a1"/>
              <TextBlock x:Name="TotalCount" Text=" / 0" FontFamily="Consolas"
                         FontSize="13" Foreground="#585b70"/>
            </StackPanel>
          </Border>

          <TextBlock Text="* = notes (hover)&#10;! = manual install"
                     FontFamily="Consolas" FontSize="11" Foreground="#45475a"
                     TextWrapping="Wrap" Margin="0,0,0,20"/>
          </StackPanel>
        </DockPanel>
      </Border>

      <!-- Tool grid -->
      <ScrollViewer Grid.Column="1" VerticalScrollBarVisibility="Auto" Background="#1e1e2e">
        <StackPanel x:Name="ToolsPanel" Margin="24,16,16,16"/>
      </ScrollViewer>
    </Grid>
  </Grid>
</Window>
'@

    $reader = [System.Xml.XmlNodeReader]::new($xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)

    # Named control references
    $toolsPanel = $window.FindName('ToolsPanel')
    $searchBox  = $window.FindName('SearchBox')
    $searchHint = $window.FindName('SearchHint')
    $btnAll     = $window.FindName('BtnAll')
    $btnNone    = $window.FindName('BtnNone')
    $btnCancel  = $window.FindName('BtnCancel')
    $btnInstall = $window.FindName('BtnInstall')

    # Script-scope so event handler closures can reach them
    $script:wsbCount  = $window.FindName('SelectedCount')
    $script:wsbTotal  = $window.FindName('TotalCount')
    $script:wsbBoxes  = [System.Collections.Generic.List[PSCustomObject]]::new()
    $script:wsbCats   = $categories
    $script:wsbPanel  = $toolsPanel
    $script:wsbHint   = $searchHint
    $script:wsbWindow = $window

    $script:wsbTotal.Text = " / $($items.Count)"

    # Load CB logo from CDN — sets header image + title bar icon (silently skipped if unreachable)
    $headerLogo = $window.FindName('HeaderLogo')
    try {
        $wc    = [System.Net.WebClient]::new()
        $bytes = $wc.DownloadData('https://cdn.chrisbmn.com/static/favicon/favicon-96x96.png')
        $ms    = [System.IO.MemoryStream]::new($bytes)
        $src   = [System.Windows.Media.Imaging.PngBitmapDecoder]::new(
                     $ms,
                     [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,
                     [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                 ).Frames[0]
        # Convert to Pbgra32 (premultiplied BGRA) so WPF composites transparent pixels correctly
        $bmp = [System.Windows.Media.Imaging.FormatConvertedBitmap]::new(
                   $src,
                   [System.Windows.Media.PixelFormats]::Pbgra32,
                   $null, 0
               )
        $bmp.Freeze()
        $headerLogo.Source = $bmp
        $window.Icon       = $bmp
    } catch { }

    $conv = [System.Windows.Media.BrushConverter]::new()

    function Update-WsbCount {
        $n = ($script:wsbBoxes | Where-Object { $_.CB.IsChecked }).Count
        $script:wsbCount.Text = "$n"
    }

    # ── Build tool grid — one wrapping row of checkboxes per category ────────────
    foreach ($cat in $categories) {
        $catItems = $items | Where-Object { $_.Tool.Category -eq $cat }

        # Category label
        $catLabel            = [System.Windows.Controls.TextBlock]::new()
        $catLabel.Text       = $cat.ToUpper()
        $catLabel.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
        $catLabel.FontSize   = 11
        $catLabel.FontWeight = [System.Windows.FontWeights]::Bold
        $catLabel.Foreground = $conv.ConvertFromString('#f38ba8')
        $catLabel.Margin     = [System.Windows.Thickness]::new(0, 16, 0, 4)
        $catLabel.Tag        = "cat:$cat"
        [void]$toolsPanel.Children.Add($catLabel)

        $sep            = [System.Windows.Controls.Separator]::new()
        $sep.Background = $conv.ConvertFromString('#313244')
        $sep.Margin     = [System.Windows.Thickness]::new(0, 0, 16, 6)
        $sep.Tag        = "cat:$cat"
        [void]$toolsPanel.Children.Add($sep)

        $wrap      = [System.Windows.Controls.WrapPanel]::new()
        $wrap.Tag  = "cat:$cat"
        $wrap.Margin = [System.Windows.Thickness]::new(0, 0, 0, 4)
        [void]$toolsPanel.Children.Add($wrap)

        foreach ($item in $catItems) {
            $cb           = [System.Windows.Controls.CheckBox]::new()
            $cb.IsChecked = $item.Selected
            $cb.Width     = 230
            $cb.Tag       = "$($item.Tool.Name) $($item.Tool.Description) $($item.Tool.Category)"

            $label             = [System.Windows.Controls.TextBlock]::new()
            $label.FontFamily  = [System.Windows.Media.FontFamily]::new('Consolas')
            $label.FontSize    = 13
            $label.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis

            $isManual = $item.Tool.Manager -eq 'manual'
            $label.Text       = if ($isManual) { "$($item.Tool.Name) !" } else { $item.Tool.Name }
            $label.Foreground = if ($isManual) { $conv.ConvertFromString('#f9e2af') } else { $conv.ConvertFromString('#cdd6f4') }

            # Tooltip carries the detail that no longer fits inline — description, manager, notes
            $tooltipLines = [System.Collections.Generic.List[string]]::new()
            if ($item.Tool.Description) { [void]$tooltipLines.Add($item.Tool.Description) }
            $tooltipLines.Add("Manager: $($item.Tool.Manager)")
            if ($item.Tool.Notes) { [void]$tooltipLines.Add("Note: $($item.Tool.Notes)") }
            $cb.ToolTip = [string]::Join("`n", $tooltipLines)

            $cb.Content = $label
            [void]$wrap.Children.Add($cb)

            $cb.Add_Checked({ Update-WsbCount })
            $cb.Add_Unchecked({ Update-WsbCount })

            $script:wsbBoxes.Add([PSCustomObject]@{ Item = $item; CB = $cb; Row = $cb })
        }
    }

    Update-WsbCount

    # ── Search handler ───────────────────────────────────────────────────────────
    $searchBox.Add_TextChanged({
        $q = $this.Text.Trim().ToLower()

        $script:wsbHint.Visibility = if ($q -eq '') {
            [System.Windows.Visibility]::Visible
        } else {
            [System.Windows.Visibility]::Collapsed
        }

        foreach ($e in $script:wsbBoxes) {
            $match = $q -eq '' -or $e.Row.Tag.ToString().ToLower().Contains($q)
            $e.Row.Visibility = if ($match) {
                [System.Windows.Visibility]::Visible
            } else {
                [System.Windows.Visibility]::Collapsed
            }
        }

        # Hide category headers (and their wrap panel) when all their tools are filtered out
        foreach ($cat in $script:wsbCats) {
            $anyVisible = ($script:wsbBoxes | Where-Object {
                $_.Item.Tool.Category -eq $cat -and
                $_.Row.Visibility -eq [System.Windows.Visibility]::Visible
            }).Count -gt 0
            $vis = if ($anyVisible) {
                [System.Windows.Visibility]::Visible
            } else {
                [System.Windows.Visibility]::Collapsed
            }
            foreach ($child in $script:wsbPanel.Children) {
                if ($child.Tag -eq "cat:$cat") { $child.Visibility = $vis }
            }
        }
    })

    # ── Button handlers ──────────────────────────────────────────────────────────
    $btnAll.Add_Click({
        foreach ($e in $script:wsbBoxes) { $e.CB.IsChecked = $true }
    })
    $btnNone.Add_Click({
        foreach ($e in $script:wsbBoxes) { $e.CB.IsChecked = $false }
    })
    $btnCancel.Add_Click({
        $script:wsbWindow.Tag = 'cancel'
        $script:wsbWindow.Close()
    })
    $btnInstall.Add_Click({
        $script:wsbWindow.Tag = 'install'
        $script:wsbWindow.Close()
    })

    $null = $window.ShowDialog()

    if ($window.Tag -ne 'install') { return $null }
    return ($script:wsbBoxes | Where-Object { $_.CB.IsChecked } | ForEach-Object { $_.Item.Tool })
}
