# scripts/Menu.ps1
# Interactive tool selection checklist.
# Dot-source this file, then call Show-ToolMenu.

function Show-ToolMenu {
    param(
        [Parameter(Mandatory)] [array]  $Catalog,
        [Parameter(Mandatory)] [string] $Profile   # 'work' or 'personal'
    )

    # Build mutable state list from catalog
    $items = [System.Collections.Generic.List[PSCustomObject]]::new()
    $n = 1
    foreach ($tool in $Catalog) {
        $selected = if ($Profile -eq 'work') { $tool.DefaultWork } else { $tool.DefaultPersonal }
        $items.Add([PSCustomObject]@{
            Number   = $n
            Tool     = $tool
            Selected = $selected
        })
        $n++
    }

    $managerLabel = @{
        winget    = 'winget'
        choco     = 'choco '
        scoop     = 'scoop '
        psgallery = 'psgal '
        feature   = 'feat  '
        manual    = 'manual'
    }

    while ($true) {
        Clear-Host

        Write-Host ""
        Write-Host "  ================================================================" -ForegroundColor DarkGray
        Write-Host "   WORKSTATION BUILDER  " -ForegroundColor Cyan -NoNewline
        Write-Host ">>  " -ForegroundColor DarkGray -NoNewline
        Write-Host "Tool Selection" -ForegroundColor Yellow -NoNewline
        Write-Host "  ($Profile profile)" -ForegroundColor DarkGray
        Write-Host "  ================================================================" -ForegroundColor DarkGray
        Write-Host ""

        # Derive category order from catalog (first-appearance order)
        $categoryOrder = [System.Collections.Generic.List[string]]::new()
        foreach ($item in $items) {
            if (-not $categoryOrder.Contains($item.Tool.Category)) {
                $categoryOrder.Add($item.Tool.Category)
            }
        }

        foreach ($cat in $categoryOrder) {
            $catItems = $items | Where-Object { $_.Tool.Category -eq $cat }
            Write-Host "  $($cat.ToUpper())" -ForegroundColor Yellow
            foreach ($item in $catItems) {
                $numStr  = $item.Number.ToString().PadLeft(3)
                $mgr     = $managerLabel[$item.Tool.Manager]

                if ($item.Tool.Manager -eq 'manual') {
                    # Manual tools shown differently — always skipped by auto-install
                    $check      = '[!]'
                    $checkColor = 'DarkYellow'
                    $nameColor  = 'DarkGray'
                } elseif ($item.Selected) {
                    $check      = '[x]'
                    $checkColor = 'Green'
                    $nameColor  = 'White'
                } else {
                    $check      = '[ ]'
                    $checkColor = 'DarkGray'
                    $nameColor  = 'DarkGray'
                }

                $hasNote = $item.Tool.Notes -and $item.Tool.Notes -ne ''
                $noteMark = if ($hasNote) { '*' } else { ' ' }

                Write-Host "  " -NoNewline
                Write-Host $check -ForegroundColor $checkColor -NoNewline
                Write-Host " $numStr  " -ForegroundColor DarkGray -NoNewline
                Write-Host "$($item.Tool.Name.PadRight(36))" -ForegroundColor $nameColor -NoNewline
                Write-Host " $mgr" -ForegroundColor DarkGray -NoNewline
                Write-Host " $noteMark" -ForegroundColor DarkYellow
            }
            Write-Host ""
        }

        $selectedCount = ($items | Where-Object { $_.Selected }).Count
        $manualCount   = ($items | Where-Object { $_.Tool.Manager -eq 'manual' -and $_.Selected }).Count

        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "  [x] = will install   [!] = manual (link shown after run)   * = has notes" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Selected: " -ForegroundColor DarkGray -NoNewline
        Write-Host "$selectedCount" -ForegroundColor Cyan -NoNewline
        Write-Host " / $($items.Count)   " -ForegroundColor DarkGray -NoNewline
        if ($manualCount -gt 0) {
            Write-Host "($manualCount manual)" -ForegroundColor DarkYellow -NoNewline
        }
        Write-Host ""
        Write-Host ""
        Write-Host "  Commands: " -ForegroundColor DarkGray -NoNewline
        Write-Host "A" -ForegroundColor Cyan -NoNewline
        Write-Host "=all  " -ForegroundColor DarkGray -NoNewline
        Write-Host "N" -ForegroundColor Cyan -NoNewline
        Write-Host "=none  " -ForegroundColor DarkGray -NoNewline
        Write-Host "D" -ForegroundColor Green -NoNewline
        Write-Host "=done/install  " -ForegroundColor DarkGray -NoNewline
        Write-Host "?" -ForegroundColor Cyan -NoNewline
        Write-Host "=show notes" -ForegroundColor DarkGray
        Write-Host "  Toggle tools by typing their numbers (e.g. " -ForegroundColor DarkGray -NoNewline
        Write-Host "3 6 12" -ForegroundColor Cyan -NoNewline
        Write-Host ")" -ForegroundColor DarkGray
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        $raw = Read-Host "  >"

        $raw = $raw.Trim()
        if ($raw -eq '') { continue }

        switch -Regex ($raw.ToUpper()) {
            '^D$' { break }

            '^A$' {
                foreach ($item in $items) {
                    if ($item.Tool.Manager -ne 'manual') { $item.Selected = $true }
                }
                continue
            }

            '^N$' {
                foreach ($item in $items) { $item.Selected = $false }
                continue
            }

            '^\?$' {
                # Show notes for all tools that have them
                Clear-Host
                Write-Host ""
                Write-Host "  TOOL NOTES" -ForegroundColor Yellow
                Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
                $noteItems = $items | Where-Object { $_.Tool.Notes -and $_.Tool.Notes -ne '' }
                if ($noteItems.Count -eq 0) {
                    Write-Host "  No notes." -ForegroundColor DarkGray
                } else {
                    foreach ($item in $noteItems) {
                        Write-Host "  $($item.Number.ToString().PadLeft(3))  " -ForegroundColor DarkGray -NoNewline
                        Write-Host "$($item.Tool.Name)" -ForegroundColor White
                        Write-Host "       $($item.Tool.Notes)" -ForegroundColor DarkYellow
                        Write-Host ""
                    }
                }
                Write-Host "  Press any key to return..." -ForegroundColor DarkGray
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                continue
            }

            default {
                # Parse space-separated numbers
                $nums = $raw -split '\s+' | ForEach-Object {
                    $parsed = 0
                    if ([int]::TryParse($_, [ref]$parsed)) { $parsed } else { $null }
                } | Where-Object { $_ -ne $null }

                foreach ($num in $nums) {
                    $match = $items | Where-Object { $_.Number -eq $num }
                    if ($match) {
                        if ($match.Tool.Manager -eq 'manual') {
                            # Manual tools: always show selected (for the links summary), but warn
                            $match.Selected = -not $match.Selected
                        } else {
                            $match.Selected = -not $match.Selected
                        }
                    } else {
                        Write-Host "  No tool with number $num." -ForegroundColor DarkYellow
                        Start-Sleep -Milliseconds 800
                    }
                }
                continue
            }
        }

        # Only reach here via 'D' — exit the loop
        break
    }

    return ($items | Where-Object { $_.Selected } | ForEach-Object { $_.Tool })
}
