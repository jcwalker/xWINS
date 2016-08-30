#netsh.exe wins add partner server=10.0.0.4 type=1

function Get-WinsReplicationPartner
{
    [CmdletBinding()]
    Param
    (
        [System.string]$Partner
    )

    $replicationPartner = @()
    $winsCurrentConfig = Invoke-Netsh -ArgumentList 'WINS dump' |
        Where-Object {$_ -match 'partner server'} |
            Where-Object {$_ -match $Partner}
    
    if(!$winsCurrentConfig)
    {
        throw $($LocalizedData.PartnerNotFound) -f $Partner
    }

    foreach ($index in $winsCurrentConfig)
    {
        $split = $index -split ' '

        $replicationPartner += [pscustomobject]@{
            ServerIP = $split[2]
            Partner = ($split[5] -split '=')[-1]
            Type = ($split[6] -split '=')[-1]
        }
    }

    if ($replicationPartner.type -contains 0 -and $replicationPartner.Type -contains 1)
    {
        $typeResult = 'PushPull'
    }
    elseIf ($replicationPartner.Type -contains 0)
    {
        $typeResult = 'Pull'
    }
    elseIf ($replicationPartner.Type -contains 1)
    {
         $typeResult = 'Push'
    }

    [pscustomobject]@{
        ServerIp = $replicationPartner[0].ServerIP
        Partner  = $replicationPartner[0].Partner
        Type     = $typeResult
    }

}

Function Invoke-Netsh
{
    [CmdletBinding()]
    param
    (
        [System.String]$ArgumentList
    )
    
    $netshOutPut = [system.IO.Path]::GetTempFileName()
    Start-Process -FilePath netsh.exe -ArgumentList $ArgumentList -Wait -NoNewWindow -ErrorAction Stop -RedirectStandardOutput $netshOutPut
    Get-Content $netshOutPut
}

function Add-WinsReplicationPartner
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $Partner,

        [System.String]
        $Type
    )
    
    $typeconversion = @{
        Push = 0
        Pull = 1
        PushPull = 2
    }

    $typeEnum = $typeconversion[$Type]

    $ArgumentList = "WINS Server 127.0.0.1 add partner server=$partner type=$typeEnum"

    Invoke-Netsh -ArgumentList $ArgumentList
}

function Remove-WinsReplicationPartner
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $Partner,

        [System.String]
        $Type
    )
    
    $typeconversion = @{
        Push = 0
        Pull = 1
        PushPull = 2
    }
        
    $typeEnum = $typeconversion[$Type]

    if($type)
    {
      $ArgumentList = "WINS Server 127.0.0.1 Delete partner server=$partner Type=$typeEnum"
    }
    else
    {
        $ArgumentList = "WINS Server 127.0.0.1 Delete partner server=$partner"
    }

    Invoke-Netsh -ArgumentList $ArgumentList
}
