enum SceneTypes {
    Home = 0
    Shop = 100
    Equipment = 200
}

enum KeyTypes {
    H = 0
    S = 100
    E = 200
}

class Unit {
    [Name]$Name
    [Money]$Money
}

class Name {
    [String]$Name
}

class Money {
    [Int]$Money
}

class SaveData {
    [String]$Name
    [Int]$Money
    [hashtable]$Item
    [hashtable]$Equipment
    [SceneTypes]$State

    SaveData() { $this.Init(@{}) }
    SaveData([hashtable]$Properties) { $this.Init($Properties) }
    SaveData([String]$name) { $this.Init(@{Name = $name}) }
    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
}

class WindowData {
    [String[]]$SceneLines
    [Int]$WindowWidth
    [ConsoleKeyInfo]$Key
    [String]$InputKeys
    [String]$ConfirmedInput
    [Boolean]$DevMode

    WindowData() { $this.Init(@{}) }
    WindowData([hashtable]$Properties) { $this.Init($Properties) }
    WindowData([Int]$windowWidth) { $this.Init(@{WindowWidth = $windowWidth}) }
    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
}

function displayUI {
    param (
        [String[]]$sceneLines,
        [ConsoleKeyInfo]$key
    )
    $window.sceneLines = @(
        ('Name: {0}' -f $saveData.Name),
        ('Gold: {0}G' -f $saveData.Money),
        ("S: open [S]hop`r`nE: [E]quipment`r`nQ: [Q]uit game"),
        ('transition state: {0}' -f $saveData.State)
    )
    
    if ( $null -ne $sceneLines ) { $window.SceneLines += $sceneLines }
    if ( $window.DevMode ) { $window.SceneLines += (developScene $key) }

    $splitCRLF = { $Args[0] -split "`r`n" }
    $splitWindowWidth = { ($Args[0].Length -gt $window.WindowWidth )?($Args[0] -split "(.{$($window.WindowWidth)})" -ne ''):$Args[0] }
    $paddingLine = { '|{0}|' -f $Args[0].PadLeft($window.WindowWidth) }
    
    $window.SceneLines | % {&$splitCRLF $_} | % {&$splitWindowWidth $_} | % {&$paddingLine $_} | Write-Host
}

function transitionScene {
    param (
        [ConsoleKeyInfo]$key
    )

    switch ( $key.KeyChar ) {
        S   { $saveData.State = [SceneTypes]'Shop' }
        E   { $saveData.State = [SceneTypes]'Equipment' }
        D   { $window.DevMode = !$window.DevMode }
        Q   { quitGameScene }
        Default {}
    }
}

function shopScene {

}

function quitGameScene {
    $saveData.State = [SceneTypes]'Home'
    saveGame $saveData.Name
    exit
}

function developScene {
    param (
        [ConsoleKeyInfo]$key
    )

    return @(
        ('inputKey: {0} ({1}), Modifiers: {2} ({3})' -f $key.KeyChar, $key.Key.value__, $key.Modifiers, $key.Modifiers.value__)
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
$saveData = $null

$window = [WindowData]::new(@{WindowWidth = 48 ; DevMode = $false})

Write-Host 'type your name'
$name = Read-Host


if ( Test-Path "./save_$name.json" ) {
    [hashtable]$loadJson = Get-Content -Path "./save_$name.json" -Raw | ConvertFrom-Json -AsHashtable
    try {
        $saveData = [SaveData]::new($loadJson)
    } catch {
        $saveData = [SaveData]::new($name)
    }
} else {
    New-Item -Path "./save_$name.json" -Type File | Out-Null
    $saveData = [SaveData]::new($name)
    saveGame $name
}

while ($true) {
    $saveData.Money += 1

    if ([console]::KeyAvailable) {
        $window.Key = [console]::ReadKey($true)
        if ($window.Key.Key -eq [ConsoleKey]::Enter) {
            $window.ConfirmedInput = $window.InputKeys
            $window.InputKeys = $null
        } elseif ($window.Key.Key -eq [ConsoleKey]::Backspace) {
            if (($KeyLength = $window.InputKeys.Length - 1) -ge 0) {
                $window.InputKeys = $window.InputKeys.Substring(0, $KeyLength)
            }
        } elseif ($window.Key.Key -in [ConsoleKey]::D0..[ConsoleKey]::D9) {
            $window.InputKeys += $window.Key.KeyChar
        } elseif ($window.Key.Key -in [ConsoleKey]::a..[ConsoleKey]::z) {
            $window.InputKeys += $window.Key.KeyChar
        } else {
        }
        [String[]]$sceneLines = transitionScene $window.Key
    }

    Clear-Host
    displayUI $sceneLines $window.Key
    Start-Sleep -Milliseconds 100
}