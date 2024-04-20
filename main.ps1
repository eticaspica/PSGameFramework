if ( Test-Path ./save.json ) {
} else {
    New-Item -Path ./save.json -Type File | Out-Null
}

[hashtable]$save_data = Get-Content -Path ./save.json | ConvertFrom-Json -AsHashtable

if ( $null -eq $save_data ) {
    $save_data = @{}
    $save_data['player'] = @{
        name = ''
        money = 0
        items = @{}
        equipment = @{}
    }
}

if ( $save_data.player.name -eq '' ) {
    Write-Host 'type your name'
    $save_data.player.name = Read-Host
    $save_data | ConvertTo-Json | Set-Content -Path ./save.json
}

function displayUI {
    param (

    )
    $displayLines = @(
        ('Name: {0}' -f $save_data.player.name),
        ('Gold: {0}G' -f $save_data.player.money),
        ("S: open [S]hop`r`nE: [E]quipment`r`nQ: [Q]uit game"),
        ('inputKey: {0}' -f $inputKey),
        ('(illegalKey): {0}' -f $illegalKey),
        ('confirmedInput: {0}' -f $confirmedInput),
        ('transition state: {0}' -f $save_data.transition.state)
    )
    
    [Int]$windowWidth = 32

    $splitCRLF = { $Args[0] -split "`r`n" }
    $splitWindowWidth = { ($Args[0].Length -gt $windowWidth )?($Args[0] -split "(.{$($windowWidth)})" -ne ''):$Args[0] }
    $paddingLine = { '|{0}|' -f $Args[0].PadLeft($windowWidth) }
    
    $displayLines.ForEach{&$splitCRLF $_}.ForEach{&$splitWindowWidth $_}.ForEach{&$paddingLine $_} -Join "`r`n" | Write-Host
}

function transitionScene {
    param (
        [Char]$Key
    )

    if ( $null -ne $save_data.transition ) {
        [String]$nowTransitionKey = $save_data.transition.key
    } else {
        $save_data['transition'] = @{
            key = $Key
            state = ''
        }
    }

    if ( $Key -ne $nowTransitionKey ) {
        switch ( $Key ) {
            S   { $save_data.transition.state = 'Shop' }
            E   { $save_data.transition.state = 'Equipment' }
            Q   { $save_data.transition.state = 'Quit_game' }
            Default {}
        }
        $save_data.transition.key = $Key
    }
}

while ($true) {
    $save_data.player.money += 1

    if ([console]::KeyAvailable) {
        $key = [console]::ReadKey($true)
        if ($key.Key -eq 'Enter') {
            $confirmedInput = $inputKey ; $inputKey = ''
        } elseif ($key.Key -eq 'Backspace') {
            if (($KeyLength = $inputKey.Length - 1) -ge 0) {
                $inputKey = $inputKey.Substring(0, $KeyLength)
            }
        } elseif ($key.Key.value__ -in 48..57) {
            $inputKey += $key.KeyChar
            transitionScene $Key.KeyChar
        } elseif ($key.Key.value__ -in 65..90) {
            $inputKey += $key.KeyChar
            transitionScene $Key.KeyChar
        } else {
            $illegalKey = '{0} ({1})' -f $key.KeyChar, $key.Key.value__
        }
    }

    $Key = $null
    Clear-Host
    displayUI
    Start-Sleep -Milliseconds 100
}