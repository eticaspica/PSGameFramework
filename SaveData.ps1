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