# Script to Convert Setting File from MT4 to MT5 for Investment Castle EA
# Drag and Drop file in Windows Forms and press button
#
# Autor: Ulises Cune (@Ulises2k)
# v2.0


#######################CONSOLE################################################################
Function Get-IniFile ($file) {
    $ini = [ordered]@{}
    switch -regex -file $file {
        "^\s*(.+?)\s*=\s*(.*)$" {
            $name, $value = $matches[1..2]
            # skip comments that start with semicolon:
            if (!($name.StartsWith(";"))) {
                if ($value.Contains('||') ) {
                    $ini[$name] = $value.Split('||')[0]
                    continue
                }
                else {
                    $ini[$name] = $value
                    continue
                }
            }
        }
    }
    $ini
}

function Set-OrAddIniValue {
    Param(
        [string]$FilePath,
        [hashtable]$keyValueList
    )

    $content = Get-Content $FilePath
    $keyValueList.GetEnumerator() | ForEach-Object {
        if ($content -match "^$($_.Key)\s*=") {
            $content = $content -replace "$($_.Key)\s*=(.*)", "$($_.Key)=$($_.Value)"
        }
        else {
            $content += "$($_.Key)=$($_.Value)"
        }
    }

    $content | Set-Content $FilePath
}


function ConvertPriceMT4toMT5 ([string]$value, [string]$file) {
    #Close Price = 0 => 1
    #Open Price = 1 => 2
    #High Price = 2 => 3
    #Low Price = 3 => 4
    #Median Price = 4 => 5
    #Tipical Price = 5 => 6
    #Weighted Price = 6 => 7
    $inifile = Get-IniFile($file)
    $rvalue = [int]$inifile[$value]
    $rvalue = $rvalue + 1
    Set-OrAddIniValue -FilePath $file  -keyValueList @{
        $value = [string]$rvalue
    }
}

function ConvertBoolMT4toMT5 ([string]$value, [string]$file) {
    $inifile = Get-IniFile($file)
    if([string]$inifile[$value] -eq "0"){
        $value = "false"
    }else {
        $value = "true"
    }
}

function ReplaceDefaultsValueMT4toMT5 ([string]$file) {
    #Remove and Replace
    (Get-Content $file).Replace("0.00000000", "0") | Set-Content $file
    (Get-Content $file).Replace("0.01000000", "0.01") | Set-Content $file
    (Get-Content $file).Replace("0.10000000", "0.1") | Set-Content $file
    (Get-Content $file).Replace("1.00000000", "1") | Set-Content $file
    (Get-Content $file).Replace(".00000000", "") | Set-Content $file
}



function MainConvert2MT5 ([string]$filePath) {

    $Destino = (Get-Item $filePath).BaseName + "-MT5.set"
    $Destino1 = (Get-Item $filePath).BaseName + "-1-MT5.set"
    $Destino2 = (Get-Item $filePath).BaseName + "-2-MT5.set"
    $Destino3 = (Get-Item $filePath).BaseName + "-3-MT5.set"
    $CurrentDir = Split-Path -Path "$filePath"
    Copy-Item "$filePath" -Destination "$CurrentDir\$Destino"

    ReplaceDefaultsValueMT4toMT5 -file "$CurrentDir\$Destino"

    Get-Content "$CurrentDir\$Destino" | Select-String -pattern ',F=' -notmatch | Out-File "$CurrentDir\$Destino1"
    Get-Content "$CurrentDir\$Destino1" | Select-String -pattern ',1=' -notmatch | Out-File "$CurrentDir\$Destino2"
    Get-Content "$CurrentDir\$Destino2" | Select-String -pattern ',2=' -notmatch | Out-File "$CurrentDir\$Destino3"
    Get-Content "$CurrentDir\$Destino3" | Select-String -pattern ',3=' -notmatch | Out-File "$CurrentDir\$Destino"
    Remove-Item "$CurrentDir\$Destino1"
    Remove-Item "$CurrentDir\$Destino2"
    Remove-Item "$CurrentDir\$Destino3"

    $Destino = "$CurrentDir\$Destino"

    # Convert to Boolean
    ConvertBoolMT4toMT5 -value "Use_External_Indicators" -file $Destino
    ConvertBoolMT4toMT5 -value "TradesAllwedOnSameBar" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Trades" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Buy" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Sell" -file $Destino
    ConvertBoolMT4toMT5 -value "ManageManualOrders" -file $Destino
    ConvertBoolMT4toMT5 -value "RecoveryLossOfCloseOnNewSupportResistance" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Martingale" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Opposite_Martingale" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_OppositeMartingale_In_Indicator_Direction" -file $Destino
    ConvertBoolMT4toMT5 -value "ShowOppositeTradeStartComment" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_VolatilityBased_OppositeMartingale_StartTradeNumber" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Reversed_Martingale" -file $Destino
    ConvertBoolMT4toMT5 -value "Instant_Entry_After_Hit_TP" -file $Destino
    ConvertBoolMT4toMT5 -value "Recover_ClosedLossOnReversal" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Drawdown_Reduction" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_EquityStop_Notification" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_MA_Filter" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_ADX_Filter" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_RSI_Filter" -file $Destino
    ConvertBoolMT4toMT5 -value "UseTimeFilter" -file $Destino
    ConvertBoolMT4toMT5 -value "UseSydney" -file $Destino
    ConvertBoolMT4toMT5 -value "UseTokyo" -file $Destino
    ConvertBoolMT4toMT5 -value "UseLondon" -file $Destino
    ConvertBoolMT4toMT5 -value "UseNewYork" -file $Destino
    ConvertBoolMT4toMT5 -value "UseFridayExit" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_News_Filter" -file $Destino
    ConvertBoolMT4toMT5 -value "High_Impact" -file $Destino
    ConvertBoolMT4toMT5 -value "Medium_Impact" -file $Destino
    ConvertBoolMT4toMT5 -value "Low_Impact" -file $Destino
    ConvertBoolMT4toMT5 -value "CloseTradesBeforeNews_RecoverAfterNews" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Breakeven" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_TrailingStop" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_DailyProfitNotification" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_DisableTradeOnDailyProfit" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Entry_Alert" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Entry_Notification" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Dashboard" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_ManualEntry_Dashboard" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_Show_SLTP_Lines" -file $Destino
    ConvertBoolMT4toMT5 -value "Use_ShowClosedProfitLoss" -file $Destino

    #Add news values MT5 v4.0
    Add-Content -Path $Destino -Value "Volatility_MaximumTrendLevel=80"
    Add-Content -Path $Destino -Value "Volatility_MiddleTrendLevel=50"
    Add-Content -Path $Destino -Value "Volatility_FlatLevel=30"
    Add-Content -Path $Destino -Value "Use_News_Filter_Backtest=false"
    Add-Content -Path $Destino -Value "CheckCurrentSymbolNewsOnly=true"

    #Convert Array price
    ConvertPriceMT4toMT5 -value "RSI_Apply" -file $Destino

    Write-Output "Successfully Converted"
}


#######################GUI################################################################
### API Windows Forms ###
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")



### Create form ###
$form = New-Object System.Windows.Forms.Form
$form.Text = "Convert Investment Castle EA MT4 1.7->MT5 4.0"
$form.Size = '512,320'
$form.StartPosition = "CenterScreen"
$form.MinimumSize = $form.Size
$form.MaximizeBox = $False
$form.Topmost = $True


### Define controls ###
$button = New-Object System.Windows.Forms.Button
$button.Location = '5,5'
$button.Size = '75,23'
$button.Width = 120
$button.Text = "Convert to MT5"

$checkbox = New-Object Windows.Forms.Checkbox
$checkbox.Location = '140,8'
$checkbox.AutoSize = $True
$checkbox.Text = "Clear afterwards"

$label = New-Object Windows.Forms.Label
$label.Location = '5,40'
$label.AutoSize = $True
$label.Text = "Drag and Drop files settings MT4 here:"

$listBox = New-Object Windows.Forms.ListBox
$listBox.Location = '5,60'
$listBox.Height = 200
$listBox.Width = 480
$listBox.Anchor = ([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top)
$listBox.IntegralHeight = $False
$listBox.AllowDrop = $True

$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.Text = "Ready"


### Add controls to form ###
$form.SuspendLayout()
$form.Controls.Add($button)
$form.Controls.Add($checkbox)
$form.Controls.Add($label)
$form.Controls.Add($listBox)
$form.Controls.Add($statusBar)
$form.ResumeLayout()


### Write event handlers ###
$button_Click = {
    foreach ($item in $listBox.Items) {
        if (!($i -is [System.IO.DirectoryInfo])) {
            MainConvert2MT5 -file $item
            [System.Windows.Forms.MessageBox]::Show('Successfully convert MT4 to MT5 Investment Castle EA', 'Convert from MT4 to MT5', 0, 64)
        }
    }

    if ($checkbox.Checked -eq $True) {
        $listBox.Items.Clear()
    }

    $statusBar.Text = ("List contains $($listBox.Items.Count) items")
}

$listBox_DragOver = [System.Windows.Forms.DragEventHandler] {
    if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        # $_ = [System.Windows.Forms.DragEventArgs]
        $_.Effect = 'Copy'
    }
    else {
        $_.Effect = 'None'
    }
}

$listBox_DragDrop = [System.Windows.Forms.DragEventHandler] {
    foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
        # $_ = [System.Windows.Forms.DragEventArgs]
        $listBox.Items.Add($filename)
    }
    $statusBar.Text = ("List contains $($listBox.Items.Count) items")
}

$form_FormClosed = {
    try {
        $listBox.remove_Click($button_Click)
        $listBox.remove_DragOver($listBox_DragOver)
        $listBox.remove_DragDrop($listBox_DragDrop)
        $listBox.remove_DragDrop($listBox_DragDrop)
        $form.remove_FormClosed($Form_Cleanup_FormClosed)
    }
    catch [Exception]
    { }
}


### Wire up events ###
$button.Add_Click($button_Click)
$listBox.Add_DragOver($listBox_DragOver)
$listBox.Add_DragDrop($listBox_DragDrop)
$form.Add_FormClosed($form_FormClosed)


#### Show form ###
[void] $form.ShowDialog()
