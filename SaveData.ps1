. ./enums.ps1

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