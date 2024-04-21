function displayUI {
    param (
        [String[]]$sceneLines
    )
    $displayLines = @(
        ('Name: {0}' -f $saveData.player.name),
        ('Gold: {0}G' -f $saveData.player.money),
        ("S: open [S]hop`r`nE: [E]quipment`r`nQ: [Q]uit game"),
        ('transition state: {0}' -f $saveData.transition.state)
    )
    
    if ( $null -ne $sceneLines ) { $displayLines += $sceneLines }
    
    [Int]$windowWidth = 48

    $splitCRLF = { $Args[0] -split "`r`n" }
    $splitWindowWidth = { ($Args[0].Length -gt $windowWidth )?($Args[0] -split "(.{$($windowWidth)})" -ne ''):$Args[0] }
    $paddingLine = { '|{0}|' -f $Args[0].PadLeft($windowWidth) }
    
    $displayLines.ForEach{&$splitCRLF $_}.ForEach{&$splitWindowWidth $_}.ForEach{&$paddingLine $_} -Join "`r`n" | Write-Host
}

function transitionScene {
    param (
        [ConsoleKeyInfo]$key
    )

    if ( $key -ne $nowTransitionKey ) {
        $saveData.transition.key = $key.KeyChar
        switch ( $key.KeyChar ) {
            S   { $saveData.transition.state = 'Shop' }
            E   { $saveData.transition.state = 'Equipment' }
            D   { return (developScene $key) }
            Q   { quitGameScene }
            Default {}
        }
    }
}

function shopScene {

}

function quitGameScene {
    $saveData.transition.key = ''
    saveGame $name
    exit
}

function developScene {
    param (
        [ConsoleKeyInfo]$key
    )

    return @(
        ('inputKey: {0} ({1})' -f $key.KeyChar, $key.Key.value__)
    )
}

function saveGame {
    param (
        [String]$name
    )
    $saveData | ConvertTo-Json | Set-Content -Path "./save_$name.json"
}

Clear-Host
$name = $null
$inputKeys = $null
$confirmedInput = $null
$saveData = $null

Write-Host 'type your name'
$name = Read-Host

class SaveData {
    [String]$Name
    [Int]$Money
    [hashtable]$Item
    [hashtable]$Equipment
    [enum]$State

    SaveData() { this.Init(@{}) }
    SaveData([hashtable]$Properties) { $this.Init($Properties) }
    SaveData([String]$Name) { $this.Init(@{Name = $Name}) }
    [void]Init([hashtable]$Properties) { $Properties.Keys.ForEach{ $this.$Property = $_ } }


}

if ( Test-Path "./save_$name.json" ) {
    [hashtable]$saveData = Get-Content -Path "./save_$name.json" -Raw | ConvertFrom-Json -AsHashtable
} else {
    New-Item -Path "./save_$name.json" -Type File | Out-Null
    $saveData = @{}
    $saveData['player'] = @{
        name = $name
        money = 0
        items = @{}
        equipment = @{}
    }
    $saveData['transition'] = @{
        state = ''
        key = ''
    }
    saveGame $name
}

while ($true) {
    $saveData.player.money += 1

    if ([console]::KeyAvailable) {
        [ConsoleKeyInfo]$key = [console]::ReadKey($true)
        if ($key.Key -eq [ConsoleKey]::Enter) {
            $confirmedInput = $inputKeys
            $inputKeys = $null
        } elseif ($key.Key -eq [ConsoleKey]::Backspace) {
            if (($KeyLength = $inputKeys.Length - 1) -ge 0) {
                $inputKeys = $inputKeys.Substring(0, $KeyLength)
            }
        } elseif ($key.Key -in [ConsoleKey]::D0..[ConsoleKey]::D9) {
            $inputKeys += $key.KeyChar
            [String[]]$sceneLines = transitionScene $keyType
        } elseif ($key.Key -in [ConsoleKey]::a..[ConsoleKey]::z) {
            $inputKeys += $key.KeyChar
            [String[]]$sceneLines = transitionScene $Key
        } else {
        }
    }

    $Key = $null
    Clear-Host
    displayUI $sceneLines
    Start-Sleep -Milliseconds 100
}