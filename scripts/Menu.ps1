# scripts/Menu.ps1
# WPF graphical tool selection window.
# Dot-source this file, then call Show-ToolMenu.

function Show-ToolMenu {
    param(
        [Parameter(Mandatory)] [array]  $Catalog,
        [Parameter(Mandatory)] [string] $WsbProfile
    )

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase

    # Build item state list
    $items = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($tool in $Catalog) {
        $sel = if ($WsbProfile -eq 'work') { $tool.DefaultWork } else { $tool.DefaultPersonal }
        $items.Add([PSCustomObject]@{ Tool = $tool; Selected = $sel })
    }
    $categories = @($Catalog | ForEach-Object { $_.Category } | Select-Object -Unique)

    # ── XAML ─────────────────────────────────────────────────────────────────────
    [xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WorkStation Builder" Height="750" Width="1050"
        MinHeight="500" MinWidth="700"
        WindowStartupLocation="CenterScreen"
        Background="#1e1e2e">
  <Window.Resources>

    <Style TargetType="CheckBox">
      <Setter Property="Foreground" Value="#cdd6f4"/>
      <Setter Property="BorderBrush" Value="#585b70"/>
      <Setter Property="Margin" Value="0,2,0,2"/>
      <Setter Property="Padding" Value="8,0,0,0"/>
      <Setter Property="FontFamily" Value="Consolas"/>
      <Setter Property="VerticalContentAlignment" Value="Top"/>
    </Style>

    <Style TargetType="Button">
      <Setter Property="Background" Value="#313244"/>
      <Setter Property="Foreground" Value="#cdd6f4"/>
      <Setter Property="BorderBrush" Value="#45475a"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="18,7"/>
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
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- Header -->
    <Border Grid.Row="0" Background="#181825" Padding="24,14">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Image x:Name="HeaderLogo" Grid.Column="0" Width="48" Height="48"
               Margin="0,0,16,0" VerticalAlignment="Center"
               RenderOptions.BitmapScalingMode="HighQuality"/>
        <StackPanel Grid.Column="1">
          <TextBlock Text="WorkStation Builder" FontFamily="Consolas"
                     FontSize="20" FontWeight="Bold" Foreground="#cba6f7"/>
          <TextBlock Text="Check boxes to select tools, then click Install Selected."
                     FontFamily="Consolas" FontSize="12" Foreground="#585b70" Margin="0,4,0,0"/>
        </StackPanel>
        <Border Grid.Column="2" Background="#313244" CornerRadius="6"
                Padding="14,8" VerticalAlignment="Center">
          <StackPanel Orientation="Horizontal">
            <TextBlock Text="Profile: " FontFamily="Consolas" FontSize="12"
                       Foreground="#585b70" VerticalAlignment="Center"/>
            <TextBlock x:Name="ProfileLabel" FontFamily="Consolas" FontSize="12"
                       FontWeight="Bold" Foreground="#a6e3a1" VerticalAlignment="Center"/>
          </StackPanel>
        </Border>
      </Grid>
    </Border>

    <!-- Search bar -->
    <Border Grid.Row="1" Background="#1e1e2e" Padding="24,8,24,4">
      <Grid>
        <TextBox x:Name="SearchBox"/>
        <TextBlock x:Name="SearchHint"
                   Text="  Search by name, category, or description..."
                   FontFamily="Consolas" FontSize="13" Foreground="#45475a"
                   IsHitTestVisible="False" VerticalAlignment="Center"/>
      </Grid>
    </Border>

    <!-- Tool list -->
    <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" Background="#1e1e2e">
      <StackPanel x:Name="ToolsPanel" Margin="24,8,24,16"/>
    </ScrollViewer>

    <!-- Footer -->
    <Border Grid.Row="3" Background="#181825" BorderBrush="#313244"
            BorderThickness="0,1,0,0" Padding="24,10">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
          <TextBlock Text="Selected: " FontFamily="Consolas" FontSize="13" Foreground="#585b70"/>
          <TextBlock x:Name="SelectedCount" Text="0" FontFamily="Consolas"
                     FontSize="13" FontWeight="Bold" Foreground="#a6e3a1"/>
          <TextBlock x:Name="TotalCount" Text=" / 0" FontFamily="Consolas"
                     FontSize="13" Foreground="#585b70"/>
          <TextBlock Text="    * = notes    ! = manual install"
                     FontFamily="Consolas" FontSize="11" Foreground="#45475a" VerticalAlignment="Center"/>
        </StackPanel>
        <StackPanel Grid.Column="1" Orientation="Horizontal">
          <Button x:Name="BtnAll"     Content="Select All"      Margin="0,0,8,0"/>
          <Button x:Name="BtnNone"    Content="Clear All"       Margin="0,0,8,0"/>
          <Button x:Name="BtnCancel"  Content="Cancel"          Margin="0,0,8,0"/>
          <Button x:Name="BtnInstall" Content="Install Selected"
                  Background="#a6e3a1" Foreground="#1e1e2e"
                  FontWeight="Bold"    BorderBrush="#a6e3a1"/>
        </StackPanel>
      </Grid>
    </Border>
  </Grid>
</Window>
'@

    $reader = [System.Xml.XmlNodeReader]::new($xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)

    # Named control references
    $toolsPanel    = $window.FindName('ToolsPanel')
    $searchBox     = $window.FindName('SearchBox')
    $searchHint    = $window.FindName('SearchHint')
    $profileLabel  = $window.FindName('ProfileLabel')
    $btnAll        = $window.FindName('BtnAll')
    $btnNone       = $window.FindName('BtnNone')
    $btnCancel     = $window.FindName('BtnCancel')
    $btnInstall    = $window.FindName('BtnInstall')

    # Script-scope so event handler closures can reach them
    $script:wsbCount  = $window.FindName('SelectedCount')
    $script:wsbTotal  = $window.FindName('TotalCount')
    $script:wsbBoxes  = [System.Collections.Generic.List[PSCustomObject]]::new()
    $script:wsbCats   = $categories
    $script:wsbPanel  = $toolsPanel
    $script:wsbHint   = $searchHint
    $script:wsbWindow = $window

    $script:wsbTotal.Text = " / $($items.Count)"
    $profileLabel.Text    = $WsbProfile.ToUpper()

    # Load CB logo from CDN — sets header image + title bar icon (silently skipped if unreachable)
    $headerLogo = $window.FindName('HeaderLogo')
    try {
        $wc    = [System.Net.WebClient]::new()
        $bytes = $wc.DownloadData('https://cdn.chrisbmn.com/static/favicon/favicon-96x96.png')
        $ms    = [System.IO.MemoryStream]::new($bytes)
        # PngBitmapDecoder with PreservePixelFormat keeps the alpha channel intact
        $bmp   = [System.Windows.Media.Imaging.PngBitmapDecoder]::new(
                     $ms,
                     [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,
                     [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                 ).Frames[0]
        $headerLogo.Source = $bmp
        $window.Icon       = $bmp
    } catch { }

    $conv = [System.Windows.Media.BrushConverter]::new()

    function Update-WsbCount {
        $n = ($script:wsbBoxes | Where-Object { $_.CB.IsChecked }).Count
        $script:wsbCount.Text = "$n"
    }

    # ── Build tool rows ──────────────────────────────────────────────────────────
    foreach ($cat in $categories) {
        $catItems = $items | Where-Object { $_.Tool.Category -eq $cat }

        # Category label
        $catLabel            = [System.Windows.Controls.TextBlock]::new()
        $catLabel.Text       = $cat.ToUpper()
        $catLabel.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
        $catLabel.FontSize   = 11
        $catLabel.FontWeight = [System.Windows.FontWeights]::Bold
        $catLabel.Foreground = $conv.ConvertFromString('#f38ba8')
        $catLabel.Margin     = [System.Windows.Thickness]::new(0, 20, 0, 4)
        $catLabel.Tag        = "cat:$cat"
        $toolsPanel.Children.Add($catLabel)

        $sep            = [System.Windows.Controls.Separator]::new()
        $sep.Background = $conv.ConvertFromString('#313244')
        $sep.Margin     = [System.Windows.Thickness]::new(0, 0, 0, 6)
        $sep.Tag        = "cat:$cat"
        $toolsPanel.Children.Add($sep)

        foreach ($item in $catItems) {
            # Row wrapper — Tag is the searchable text
            $rowBorder        = [System.Windows.Controls.Border]::new()
            $rowBorder.Margin = [System.Windows.Thickness]::new(0, 1, 0, 1)
            $rowBorder.Tag    = "$($item.Tool.Name) $($item.Tool.Description) $($item.Tool.Category)"

            $cb           = [System.Windows.Controls.CheckBox]::new()
            $cb.IsChecked = $item.Selected

            # Inner stack: name line + description line
            $inner = [System.Windows.Controls.StackPanel]::new()

            # Line 1: tool name + manager tag (+ notes marker)
            $nameRow             = [System.Windows.Controls.StackPanel]::new()
            $nameRow.Orientation = [System.Windows.Controls.Orientation]::Horizontal

            $nameBlock            = [System.Windows.Controls.TextBlock]::new()
            $nameBlock.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
            $nameBlock.FontSize   = 13
            $nameBlock.Text       = $item.Tool.Name

            $mgrBlock            = [System.Windows.Controls.TextBlock]::new()
            $mgrBlock.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
            $mgrBlock.FontSize   = 11
            $mgrBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $mgrBlock.Margin     = [System.Windows.Thickness]::new(8, 0, 0, 0)

            if ($item.Tool.Manager -eq 'manual') {
                $nameBlock.Foreground = $conv.ConvertFromString('#585b70')
                $mgrBlock.Text        = '[manual !]'
                $mgrBlock.Foreground  = $conv.ConvertFromString('#f9e2af')
            } else {
                $nameBlock.Foreground = $conv.ConvertFromString('#cdd6f4')
                $mgrBlock.Text        = "[$($item.Tool.Manager)]"
                $mgrBlock.Foreground  = $conv.ConvertFromString('#45475a')
            }

            $nameRow.Children.Add($nameBlock)
            $nameRow.Children.Add($mgrBlock)

            if ($item.Tool.Notes) {
                $noteTag                   = [System.Windows.Controls.TextBlock]::new()
                $noteTag.FontFamily        = [System.Windows.Media.FontFamily]::new('Consolas')
                $noteTag.FontSize          = 11
                $noteTag.Text              = '  *'
                $noteTag.Foreground        = $conv.ConvertFromString('#f9e2af')
                $noteTag.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
                $noteTag.ToolTip           = $item.Tool.Notes
                $nameRow.Children.Add($noteTag)
            }
            $inner.Children.Add($nameRow)

            # Line 2: description (smaller, muted)
            if ($item.Tool.Description) {
                $descBlock              = [System.Windows.Controls.TextBlock]::new()
                $descBlock.FontFamily   = [System.Windows.Media.FontFamily]::new('Consolas')
                $descBlock.FontSize     = 11
                $descBlock.Text         = $item.Tool.Description
                $descBlock.Foreground   = $conv.ConvertFromString('#585b70')
                $descBlock.TextWrapping = [System.Windows.TextWrapping]::Wrap
                $descBlock.Margin       = [System.Windows.Thickness]::new(0, 2, 0, 4)
                $inner.Children.Add($descBlock)
            }

            $cb.Content      = $inner
            $rowBorder.Child = $cb
            $toolsPanel.Children.Add($rowBorder)

            $cb.Add_Checked({ Update-WsbCount })
            $cb.Add_Unchecked({ Update-WsbCount })

            $script:wsbBoxes.Add([PSCustomObject]@{ Item = $item; CB = $cb; Row = $rowBorder })
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

        # Hide category headers when all their tools are filtered out
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

    if ($window.Tag -ne 'install') { return @() }
    return ($script:wsbBoxes | Where-Object { $_.CB.IsChecked } | ForEach-Object { $_.Item.Tool })
}
