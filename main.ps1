function displayUI {
    param (

    )
    $displayLines = @(
        ('Name: {0}' -f $saveData.player.name),
        ('Gold: {0}G' -f $saveData.player.money),
        ("S: open [S]hop`r`nE: [E]quipment`r`nQ: [Q]uit game"),
        ('inputKey: {0}' -f $inputKey),
        ('(illegalKey): {0}' -f $illegalKey),
        ('(keyType): {0}' -f $keyType),
        ('confirmedInput: {0}' -f $confirmedInput),
        ('transition state: {0}' -f $saveData.transition.state)
    )
    
    [Int]$windowWidth = 32

    $splitCRLF = { $Args[0] -split "`r`n" }
    $splitWindowWidth = { ($Args[0].Length -gt $windowWidth )?($Args[0] -split "(.{$($windowWidth)})" -ne ''):$Args[0] }
    $paddingLine = { '|{0}|' -f $Args[0].PadLeft($windowWidth) }
    
    $displayLines.ForEach{&$splitCRLF $_}.ForEach{&$splitWindowWidth $_}.ForEach{&$paddingLine $_} -Join "`r`n" | Write-Host
}

function transitionScene {
    param (
        [Char]$key
    )

    if ( $key -ne $nowTransitionKey ) {
        $saveData.transition.key = $key
        switch ( $key ) {
            S   { $saveData.transition.state = 'Shop' }
            E   { $saveData.transition.state = 'Equipment' }
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

function saveGame {
    param (
        [String]$name
    )
    $saveData | ConvertTo-Json | Set-Content -Path "./save_$name.json"
}

Clear-Host
$name = $null
$inputKey = $null
$confirmedInput = $null
$illegalKey = $null
$saveData = $null

Write-Host 'type your name'
$name = Read-Host

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
        $key = [console]::ReadKey($true)
        if ($key.Key -eq [ConsoleKey]::Enter) {
            $confirmedInput = $inputKey ; $inputKey = ''
        } elseif ($key.Key -eq [ConsoleKey]::Backspace) {
            if (($KeyLength = $inputKey.Length - 1) -ge 0) {
                $inputKey = $inputKey.Substring(0, $KeyLength)
            }
        } elseif ($key.Key -in [ConsoleKey]::D0..[ConsoleKey]::D9) {
            $inputKey += $key.KeyChar
            transitionScene $Key.KeyChar
        } elseif ($key.Key -in [ConsoleKey]::a..[ConsoleKey]::z) {
            $inputKey += $key.KeyChar
            transitionScene $Key.KeyChar
        } else {
            $illegalKey = '{0} ({1})' -f $key.KeyChar, $key.Key.value__
        }
        $keyType = "`r`n{0}`r`n({1})" -f $key.Modifiers, $key.GetType()
    }

    $Key = $null
    Clear-Host
    displayUI
    Start-Sleep -Milliseconds 100
}