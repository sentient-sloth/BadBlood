################################
#Create Computer Objects
################################
function New-CustomADComputer {
    <#
        .SYNOPSIS
            Creates a Computer Object in an active directory environment based on random data
        
        .DESCRIPTION
            Starting with the root container this tool randomly places users in the domain.
        
        .PARAMETER Domain
            The stored value of get-addomain is used for this.  It is used to call the PDC and other items in the domain
        
        .PARAMETER OUList
            The stored value of get-adorganizationalunit -filter *.  This is used to place Computers in random locations.

        .PARAMETER UserList
            The stored value of get-aduser -filter *.  This is used to put random ownership on computers.
        
        .PARAMETER ScriptDir
            The location of the script.  Pulling this into a parameter to attempt to speed up processing.
        
        .EXAMPLE
            
        .NOTES
            Unless required by applicable law or agreed to in writing, software
            distributed under the License is distributed on an "AS IS" BASIS,
            WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
            See the License for the specific language governing permissions and
            limitations under the License.
            
            Author's blog: https://www.secframe.com
    #>
    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory = $false,
            Position = 1,
            HelpMessage = 'Supply a result from get-addomain')]
            [Object[]]$Domain,
        [Parameter(Mandatory = $false,
            Position = 2,
            HelpMessage = 'Supply a result from get-adorganizationalunit -filter *')]
            [Object[]]$OUList,
        [Parameter(Mandatory = $false,
            Position = 3,
            HelpMessage = 'Supply a result from get-aduser -filter *')]
            [Object[]]$UserList,
        [Parameter(Mandatory = $false,
            Position = 4,
            HelpMessage = 'Supply the script directory for where this script is stored')]
            [string]$ScriptDir
    )
    
    #region: parameter parsing
    if (!$PSBoundParameters.ContainsKey('Domain')){
        if ($args[0]){
            $SetDC = $args[0].PDCEmulator
            $DNRoot = $args[0].DistinguishedName
        } else {
            Write-Host "  [x] No Domain Specified!" -ForegroundColor Yellow
            return
        }
    } else {
        $SetDC = $Domain.PDCEmulator
        $DNRoot = $Domain.DistinguishedName
    }
    
    if (!$PSBoundParameters.ContainsKey('OUList')){
        if ($args[1]){
            $OUsAll = $args[1]
        } else{
            $OUsAll = Get-ADObject -Filter {objectclass -eq 'organizationalunit'} -ResultSetSize 300
        }
    } else {
        $OUsAll = $OUList
    }
    
    if (!$PSBoundParameters.ContainsKey('UserList')){
        if($args[1]){
            $UserList = $args[2]
        } else{
            $UserList = Get-ADUser -ResultSetSize 2500 -Server $SetDC -Filter * 
        }
    } else {
        $UserList = $UserList
    }
    
    if (!$PSBoundParameters.ContainsKey('ScriptDir')){
        if ($args[2]){
            $scriptpath = $args[2]
        } else {
            $ScriptPath = "$((Get-Location).path)\reference-files\"
        }
    } else {
        $ScriptPath = $ScriptDir
    }
    #endregion
    
    $CSVPrefixes = Import-Csv (Join-Path $ScriptPath '3lettercodes.csv')
    $OSOptions = Import-Csv (Join-Path $ScriptPath 'OSVersionTable.csv')
    $OwnerInfo = Get-Random $UserList

    #region: Computer Prefixes
    $CompNamePrefix1 = (Get-Random $CSVPrefixes).name
    
    #WorkstationorServer 0 (workstation) prefix name workflow
    $WorkstationOrServer = 0,1 | Get-Random #work = 0, server = 1
    $WorkstationType = 0..2 | Get-Random # desktop = 0 , laptop = 1, vm = 2
    if($WorkstationOrServer -eq 0){
        $CompNamePrefix2 = switch ($WorkstationType){
            0 {"WWKS"}
            1 {"WLPT"}
            2 {"WVIR"}
        }
    } else {
        $CompNamePrefix2 = 'S'
        $ServerApplication = 0,1,2,3,4,5 | Get-Random
        $CompNamePrefix3 = switch ($ServerApplication){
            0 {"APPS"}
            1 {"WEBS"}
            2 {"DBAS"}
            3 {"SECS"}
            4 {"CTRX"}
            5 {"HYPV"}
        }
    }
    $CompNamePrefixFull = $CompNamePrefix1 + $CompNamePrefix2 + $CompNamePrefix3
    $cnSearch = "$CompNamePrefixFull*"
    #endregion

    #Set OU Location
    if ($WorkstationOrServer -eq 0){
        if($WorkstationType -eq 0){ #desktop workflow
            $OULocation = "OU=Desktops,OU=Technology,$DNRoot"
            if (Test-Path "AD:/$OULocation"){
                Get-ADOrganizationalUnit $OULocation
            } else {
                $OUlocation = "OU=Admin,$($Domain.DistinguishedName)"
            }
        } elseif ($WorkstationType -eq 1){ #laptop workflow
            $OUlocation = 'OU=Laptops,OU=Technology,' + $DNRoot
            if (Test-Path "AD:/$OULocation"){
                Get-ADOrganizationalUnit $OUlocation
            } else {
                $OUlocation = "OU=Admin,$($Domain.DistinguishedName)"
            }
        } else {
            $OUlocation = "OU=Desktops,OU=Technology,$DNRoot"
            if (Test-Path "AD:/$OULocation"){
                Get-ADOrganizationalUnit $OULocation
            } else {
                $OUlocation = "OU=Admin,$($Domain.DistinguishedName)"
            }
        }
    } else {
        $OUlocation = (Get-Random $OUsAll).distinguishedname
    }
    
    $Comps = Get-ADComputer -server $SetDC -Filter {(name -like $cnsearch) -and (name -notlike "*9999*")} |
        Select-Object 'Name' | Sort-Object 'Name'
    
    # Set computer name
    if (-Not $Comps){
        $Suffix = 1000000
        $CompName = $CompNamePrefixFull + [string]$Suffix
    } else {
        $LastComp = $Comps[($comps.count - 1)].Name
        $Suffix = [int32]([regex]::Match($LastComp, '.+(\d{7})').Groups[1].Value) + 1
        $CompName = $CompNamePrefixFull + [string]$Suffix
    }
    
    # Set computer OS
    $OSPct = 1..100 | Get-Random
    $OSInfo = switch ($OSPct){
        {1..60 -contains $OSPct}   {$OSOptions | Where-Object OperatingSystem -match 'Windows [\dX]' | Get-Random}
        {61..90 -contains $OSPct}  {$OSOptions | Where-Object OperatingSystem -match 'Windows Server' | Get-Random}
        {91..100 -contains $OSPct} {$OSOptions | Where-Object OperatingSystem -notmatch 'Windows' | Get-Random}
    }
    if ($OSInfo.OperatingSystem -match 'Windows'){
        $SPNs = "HOST/$CompName", "HOST/$CompName.$($Domain.DNSRoot)"
    } else {
        $SPNs = $null
    }

    try {
        $NewCompParams = @{
            Server                     = $SetDC
            Name                       = $CompName
            DisplayName                = $CompName
            Path                       = $OULocation
            ManagedBy                  = $OwnerInfo.DistinguishedName
            OperatingSystem            = $OSInfo.OperatingSystem
            OperatingSystemServicePack = $OSInfo.OperatingSystemServicePack
            OperatingSystemVersion     = $OSInfo.OperatingSystemVersion
            ServicePrincipalNames      = $SPNs
            Enabled                    = $true
        }
        New-ADComputer @NewCompParams -EV NewCompErr
    } catch {
        Write-Host "  [x] Failed to create computer: $CompName"
        Write-Host $NewCompErr
    }
}
