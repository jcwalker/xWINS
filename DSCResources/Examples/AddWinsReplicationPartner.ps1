# Add server with IP 10.0.0.4 as a PushPull WINS replication partner to the local server
configuration Wins
{
    Import-DscResource -ModuleName xWins

    node localhost
    {
        xWinsReplicationPartner AddDC1
        {
            Partner =  '10.0.0.4'
            Type    = 'PushPull'
            Ensure  = 'Present'
        }
    }
}

Wins -OutputPath C:\Wins

Start-DscConfiguration -Path C:\Wins -Wait -Force -Verbose
