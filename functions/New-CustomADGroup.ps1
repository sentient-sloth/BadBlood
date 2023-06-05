Function New-CustomADGroup {
    <#
        .SYNOPSIS
            Creates a Group in an active directory environment based on random data
        
        .DESCRIPTION
            Starting with the root container this tool randomly places users in the domain.
        
        .PARAMETER Domain
            The stored value of get-addomain is used for this.  It is used to call the PDC and other items in the domain
        
        .PARAMETER OUList
            The stored value of get-adorganizationalunit -filter *.  This is used to place users in random locations.

        .PARAMETER UserList
            The stored value of get-aduser -filter *.  This is used to place make random users owners/managers of groups.
        
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
    
    #region: Pamameter checks
    if (!$PSBoundParameters.ContainsKey('Domain')){
        if($args[0]){
            $setDC = $args[0].pdcemulator
        } else {
            $setDC = (Get-ADDomain).pdcemulator
        }
    } else {
        $setDC = $Domain.pdcemulator
    }
    if (!$PSBoundParameters.ContainsKey('OUList')){
        if($args[1]){
            $OUsAll = $args[1]
        }
        else{
            $OUsAll = get-adobject -Filter {objectclass -eq 'organizationalunit'} -ResultSetSize 300
        }
    } else {
        $OUsAll = $OUList
    }
    
    if (!$PSBoundParameters.ContainsKey('UserList')){
        if($args[1]){
            $UserList = $args[2]
        } else {
            $UserList = get-aduser -ResultSetSize 2500 -Server $setDC -Filter * 
        }
    } else {
        $UserList = $UserList
    }
    
    if (!$PSBoundParameters.ContainsKey('ScriptDir')){
        if ($args[2]){
            $groupscriptPath = $args[2]
        } else {
            $groupscriptPath = "$((Get-Location).path)\AD_Groups_Create\"
        }
    } else {
        $groupscriptPath = $ScriptDir
    }
    #endregion
    
    $ownerinfo = Get-Random $userlist
    
    $ouLocation = (Get-Random $OUsAll).distinguishedname

    $Groupnameprefix = ($ownerinfo.samaccountname).substring(0,2) 
    try {
        $Application = (Get-Content ($groupscriptPath + '\hotmail.txt') | Get-Random).substring(0,9)
    } catch {
        $Application = (Get-Content ($groupscriptPath + '\hotmail.txt') | Get-Random).substring(0,3)
    }
    $functionint = 1..100 | Get-Random  
    if ($functionint -le 25){
        $function = 'admingroup'
    } else {
        $function = 'distlist'
    }
    $GroupNameFull = $Groupnameprefix + '-'+$Application+ '-'+$Function
    
    $i = 1
    $checkAcct = $null
    while ($null -ne $checkAcct) {
        try {
            $checkAcct = Get-ADGroup $GroupNameFull
        } catch {
            $GroupNameFull = $GroupNameFull + $i 
        }
        $i++
    }

    try {
        $GroupParams = @{
            Server        = $SetDC
            Description   = $Description
            Name          = $GroupNameFull
            Path          = $ouLocation
            GroupCategory = 'Security'
            GroupScope    = 'Global'
            ManagedBy     = $ownerinfo.distinguishedname
        }
        New-ADGroup @GroupParams
    } catch {}
}