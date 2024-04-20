if ( Test-Path ./save.json ) {
} else {
    New-Item -Path ./save.json -Type File | Out-Null
}

[hashtable]$save_data = Get-Content -Path ./save.json | ConvertFrom-Json

if ( $null -eq $save_data ) {
    $save_data = @{}
    $save_data['player'] = @{
        name = ''
        money = 0
        items = @{}
        equipment = @{}
        stateTransition = ''
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
        ('confirmedInput: {0}' -f $confirmedInput)
    )
    
    [Int]$windowWidth = 32

    $getBytes = { [System.Text.Encoding]::GetEncoding('Shift-Jis').GetByteCount($Args[0]) }
    $countTwoByteCharacters = { $Args[0].ToCharArray().Where{ (&$getBytes $_) -ne 1}.Count }
    $paddingLine = { $Args[0].PadLeft($windowWidth - (&$countTwoByteCharacters $Args[0])) }
    $splitCRLF = { $Args[0] -split "`r`n" }
    $splitWindowWidth = { (((&$countTwoByteCharacters $Args[0]) + $Args[0].Length) -gt $windowWidth )?($Args[0] -split "(.{$($windowWidth)})" -ne ''):$Args[0] }
    
    $displayLines.ForEach{&$splitCRLF $_}.ForEach{&$splitWindowWidth $_}.ForEach{ '|{0}|' -f (&$paddingLine $_) } -Join "`r`n" | Write-Host
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
        } elseif ($key.Key.value__ -in 65..90) {
            $inputKey += $key.KeyChar
        } else {
            $illegalKey = '{0} ({1})' -f $key.KeyChar, $key.Key.value__
        }
    }
    
    Clear-Host
    displayUI
    Start-Sleep -Milliseconds 100
}