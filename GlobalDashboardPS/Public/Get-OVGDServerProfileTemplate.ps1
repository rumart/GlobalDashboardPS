function Get-OVGDServerProfileTemplate {
    <#
        .SYNOPSIS
            Retrieves the Server profile templates connected to the Global Dashboard instance
        .DESCRIPTION
            This function will retrieve the Server profile templates on the specified Global Dashboard instance
        .NOTES
            Info
            Author : Rudi Martinsen / Intility AS
            Date : 25/03-2019
            Version : 0.5.0
            Revised : 25/04-2019
            Changelog:
            0.5.0 -- Reworked output
            0.4.0 -- Changed Entity parameter to Id, adding Name alias
            0.3.0 -- Added support for querying and changed warning when result is bigger than count
            0.2.2 -- Fixed bug in help text and added link
            0.2.1 -- Added help text
            0.2.0 -- Added count param
        .LINK
            https://github.com/rumart/GlobalDashboardPS
        .LINK
            https://developer.hpe.com/blog/accessing-the-hpe-oneview-global-dashboard-api
        .LINK
            https://rudimartinsen.com/2019/04/23/hpe-oneview-global-dashboard-powershell-module/
        .PARAMETER Server
            The Global Dashboard to retrieve Server Profile Templates from
        .PARAMETER Id
            The Id of the Server Profile Template to retrieve
        .PARAMETER TemplateName
            Filter on the Name of the Server Profile Template to retrieve. Note that we search for an exact match
        .PARAMETER Appliance
            Filter on the Appliance of the Server Profile Template to retrieve. Note that we search for an exact match
        .PARAMETER Status
            Filter on the Status of the Server Profile Template to retrieve. Note that we search for an exact match
        .PARAMETER State
            Filter on State of the Server Profile Template to retrieve. Note that we search for an exact match
        .PARAMETER UserQuery
            Query string used for full text search
        .PARAMETER Count
            The count of profile templates to retrieve, defaults to 25
        .EXAMPLE
            PS C:\> Get-OVGDServerProfileTemplate

            Retrieves all Server Profile Templates connected to the Global Dashboard instance
        .EXAMPLE
            PS C:\> Get-OVGDServerProfileTemplate -Id xxxxxxxx-xxxx-xxxx-xxxx-54e195f27f36

            Retrieves the specific Server Profile Template with the specified ID
    #>
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="Id")]
        [Parameter(ParameterSetName="Query")]
        $Server = $Global:OVGDPSServer,
        [Parameter(ParameterSetName="Id")]
        [alias("Entity")]
        $Id,
        [Parameter(ParameterSetName="Query")]
        [alias("Name")]
        $TemplateName,
        [Parameter(ParameterSetName="Query")]
        $Appliance,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet("OK","Warning","Critical","Disabled","Unknown")]
        $Status,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet("Normal","CreateFailed","UpdateFailed","Unknown")]
        $State,
        [Parameter(ParameterSetName="Query")]
        $UserQuery,
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="Query")]
        $Count = 25
    )

    begin {
        $ResourceType = "server-profile-templates"
    }

    process {
        $Resource = BuildPath -Resource $ResourceType -Entity $Id
        $Query = "count=$Count"
        $searchFilters = @()
        $txtSearchFilters = @()
        
        if($TemplateName){
            $searchFilters += 'name EQ "' + $TemplateName + '"'
        }

        if($Appliance){
            $searchFilters += 'applianceName EQ "' + $Appliance + '"'
        }

        if($Status){
            $searchFilters += 'status EQ "' + $Status + '"'
        }

        if($State){
            $searchFilters += 'state EQ "' + $State + '"'
        }

        if($UserQuery){
            $txtSearchFilters += "$UserQuery"
        }

        if($searchFilters){
            $filterQry = $searchFilters -join " AND "
            $Query += '&query="' + $filterQry + '"'
        }

        if($txtSearchFilters){
            $filterQry = $txtSearchFilters -join " AND "
            $Query += '&userQuery="' + $filterQry + '"'
        }

        $result = Invoke-OVGDRequest -Resource $Resource -Query $Query #-Verbose

        Write-Verbose "Got $($result.count) number of results"

        if ($result.Count -lt $result.Total ) {
            Write-Warning "The result has been paged. Total number of results is: $($result.total)"
        }
        
        if($result.Count -ge 1){
            Write-Verbose "Found $($result.total) number of results"
            $output = $result.members
        }
        elseif($result.Count -eq 0){
            return $null
        }
        elseif($result.category -eq $ResourceType){
            $output = $result
        }
        else{
            return $result
        }
        
        if($Output){
            $output = Add-OVGDTypeName -TypeName "GlobalDashboardPS.OVGDServerProfileTemplate" -Object $output
            return $output
        }
    }

    end {
    }
}