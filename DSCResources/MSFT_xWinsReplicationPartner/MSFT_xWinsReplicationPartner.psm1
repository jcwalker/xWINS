function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Partner,

        [parameter(Mandatory = $true)]
        [ValidateSet("Push","Pull","PushPull")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $targetResult = Get-WinsReplicationPartner -Partner $Partner

    if($targetResult)
    {
        $ensureResult = 'Present'
    }
    else
    {
        $ensureResult = 'Absent'
    }
    
    $returnValue = @{
        Partner = $targetResult.Partner
        Type    = $targetResult.Type
        Ensure  = $ensureResult
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Partner,

        [parameter(Mandatory = $true)]
        [ValidateSet("Push","Pull","PushPull")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $targetResult = Get-TargetResource -Partner $Partner -Type $Type -Ensure $Ensure

    if ($Ensure -eq 'Present')
    {
        if ($targetResult.Ensure -ne 'Present')
        {
            Add-WinsReplicationPartner -Partner $Partner -Type $Type
        }
        elseIf($Type -ne $targetResult.Type)
        {
            Remove-WinsReplicationPartner -Partner $Partner
            Add-WinsReplicationPartner -Partner $Partner -Type $Type
        }

    }
    else
    {
        Remove-WinsReplicationPartner -Partner $Partner -Type $Type
    }


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Partner,

        [parameter(Mandatory = $true)]
        [ValidateSet("Push","Pull","PushPull")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $targetResult = Get-TargetResource -Partner $Partner

    if ($targetResult.Ensure -ne $Ensure)
    {
        Write-Verbose "Ensure not in desired state. Expected: $Ensure Actual: ($targetResult.Ensure)"
        return $false
    }

    if ($Ensure -eq 'Present')
    {
        if ($targetResult.Type -ne $Type)
        {
            Write-Verbose "Type not in desired state. Expected: $Type Actual: $($targetResult.Type)"
            return $false
        }
    }

    # if the code made it this far node must be in a desired state
    return $true
}


Export-ModuleMember -Function *-TargetResource

