$winsProperties = @()
$winsProperties += New-xDscResourceProperty -Name Partner -Type String -Attribute Key -Description "IP address of the WINS replication partner."
$winsProperties += New-xDscResourceProperty -Name Type -Type String -Attribute Required -ValidateSet "Push","Pull","PushPull" -Description "Indicates the type of partner to add: 0-Pull, 1-Push, 2-Both (default)."
$winsProperties += New-xDscResourceProperty -Name Ensure -Type String -Attribute Required -ValidateSet "Present","Absent" -Description "Specifies to either add or remote the partner."

$winsParameters = @{
    Name = 'MSFT_xWinsReplicationPartner'
    Property = $winsProperties
    FriendlyName = 'xWinsReplicationPartner'
    ModuleName = 'xWINS'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @winsParameters
