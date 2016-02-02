function Get-SQLVersion
{
    <#
    .SYNOPSIS 
    Obtains information from a computer about the version of SQL installed.

    .DESCRIPTION
    Obtains information from a computer about the version of SQL installed and reports back information in user friendly manner.

    .PARAMETER Computername
    Specifies the SQL Server database server name.

    .PARAMETER SQLServer
    Specifies the SQL Server database instance name.

    .EXAMPLE
    C:\PS> Get-SQLVersion -SQLServer .

    ServicePack    : RTM
    VersionNumber  : 12.0.2269.0
    DisplayName    : SQL Server 2014 RTM Developer Edition (64-bit) 12.0.2269.0
    Version        : Developer Edition (64-bit)
    Name           : SQL Server 2014
    PSComputerName : MyServer
    RunspaceId     : 3d01b2fb-8e07-48f4-b63c-2ea8ddfff719

    .LINK
    http://www.powershell.amsterdam/2016/01/14/reporting-sql-server-version-information/
    #>
      
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'SQL Server database server name')] [string] $Computername = $env:COMPUTERNAME,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'SQL Server database instance name')] [string] $SQLServer
    )
    
    Process
    {
        Invoke-Command -ComputerName $Computername -ScriptBlock {
            $SQLquery = "SELECT SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition')"
            $SqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection
            $SqlConnection.ConnectionString = "Server=$using:SQLServer;Database=Master;Integrated Security=SSPI;"
            $SqlCmd = New-Object -TypeName System.Data.SqlClient.SqlCommand
            $SqlCmd.CommandText = $SQLquery
            $SqlCmd.Connection = $SqlConnection
            $SqlAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter
            $SqlAdapter.SelectCommand = $SqlCmd

            $DataSet = New-Object -TypeName System.Data.DataSet
            $nSet = $SqlAdapter.Fill($DataSet)
            $SqlConnection.Close()
            $Tables = $DataSet.Tables
            $arrayVersion = ($($Tables.Column1).Split('.'))
            [string] $SQLVersionNumber = "$($arrayVersion[0]).$($arrayVersion[1])"

            Switch -Wildcard ($SQLVersionNumber) {
                '13.0*'
                {
                    $versionName = 'SQL Server 2016'
                }
                '12.0*'
                {
                    $versionName = 'SQL Server 2014'
                }
                '11.0*'
                {
                    $versionName = 'SQL Server 2012'
                }
                '10.50*'
                {
                    $versionName = 'SQL Server 2008 R2'
                }
                '10.0*'
                {
                    $versionName = 'SQL Server 2008'
                }
                '9.0*'
                {
                    $versionName = 'SQL Server 2005'
                }
                '8.0*'
                {
                    $versionName = 'SQL Server 2000'
                }
                '7.0*'
                {
                    $versionName = 'SQL Server'
                }

            }

            $hash = @{
                DisplayName   = "$versionName $($Tables.Column2) $($Tables.Column3) $($Tables.Column1)"
                Name          = $versionName
                Version       = $Tables.Column3
                ServicePack   = $Tables.Column2
                VersionNumber = $Tables.Column1
            }

            New-Object -TypeName PSobject -Property $hash
        }
    }
}