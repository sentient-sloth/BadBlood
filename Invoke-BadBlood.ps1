<#
    .Synopsis
       Generates users, groups, OUs, computers in an active directory domain.  Then places ACLs on random OUs
    .DESCRIPTION
       This tool is for research purposes and training only.  Intended only for personal use.  This adds a large number of objects into a domain, and should never be  run in production.
    .EXAMPLE
       There are currently no parameters for the tool.  Simply run the ps1 as a DA and it begins. Follow the prompts and type 'badblood' when appropriate and the tool runs.
    .OUTPUTS
       [String]
    .NOTES
       Written by David Rowe, Blog secframe.com
       Twitter : @davidprowe
       I take no responsibility for any issues caused by this script.  I am not responsible if this gets run in a production domain. 
      Thanks HuskyHacks for user/group/computer count modifications.  I moved them to parameters so that this tool can be called in a more rapid fashion.
    .FUNCTIONALITY
       Adds a ton of stuff into a domain.  Adds Users, Groups, OUs, Computers, and a vast amount of ACLs in a domain.
    .LINK
       http://www.secframe.com/badblood
   
    #>
[CmdletBinding()]
    
param
(
   [Parameter(Mandatory = $false,
      Position = 1,
      HelpMessage = 'Number of User accounts to create')]
   [Int32]$UserCount = 2500,
   [Parameter(Mandatory = $false,
      Position = 3,
      HelpMessage = 'Number of Computer accounts to create')]
   [int32]$ComputerCount = 500,
   [Parameter(Mandatory = $false,
      Position = 2,
      HelpMessage = 'Number of Groups to create')]
   [int32]$GroupCount = 500,
   [Parameter(Mandatory = $false,
      Position = 4,
      HelpMessage = 'Skip OU creation if you already complete')]
   [switch]$SkipOuCreation,
   [Parameter(Mandatory = $false,
      Position = 5,
      HelpMessage = 'Install LAPS dependencies if required')]
   [switch]$InstallLAPS
)
function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}

$BaseScriptPath = Get-ScriptDirectory
$ReferenceFiles = Join-Path $BaseScriptPath 'reference-files'
$Domain = Get-ADDomain

# Import functions
foreach ($function in (Get-ChildItem -File -Recurse (Join-Path $BaseScriptPath 'functions'))){
    . $function.FullName
}

#region: OU Structure Creation
if ($PSBoundParameters.ContainsKey('SkipOuCreation') -eq $false){
  Write-Host "[>] Creating OU Structure" -ForegroundColor Cyan
  New-OUStructure -CSVPrefixes (Join-Path $ReferenceFiles '3lettercodes.csv')
} else {
    Write-Host "[>] Skipping OU Structure Creation" -ForegroundColor DarkGray
}
#endregion

#region: User Creation
$OUsAll = Get-ADOrganizationalUnit -filter *
if ($UserCount -gt 0){
    Write-Host "[>] Creating User Accounts" -ForegroundColor Cyan
    do {
    $x++
    New-CustomADUser -Domain $Domain -OUList $OUsAll -ScriptDir $ReferenceFiles
    if (($UserCount -gt 20) -and (-Not ($x % [math]::Floor(($UserCount / 10))))){
        Write-Host "  [>] Accounts created: $x of $UserCount" -ForegroundColor DarkGray    
    }
    } while ($x -lt $UserCount)
} else {
    Write-Host "[>] Skipping User Account Creation" -ForegroundColor DarkGray
}
#endregion

#region: Computer Creation
if ($ComputerCount -gt 0){
    Write-Host "[>] Creating Computer Accounts" -ForegroundColor Cyan
    $x = 0
    do {
        $x++
        New-CustomADComputer -Domain $Domain -OUList $OUsAll -UserList $AllUsers -ScriptDir $ReferenceFiles
        if (($ComputerCount -gt 20) -and (-Not ($x % [math]::Floor(($ComputerCount / 10))))){
            Write-Host "  [>] Accounts created: $x of $ComputerCount" -ForegroundColor DarkGray    
        }
    } while ($x -lt $ComputerCount)
} else {
    Write-Host "[>] Skipping Computer Account Creation" -ForegroundColor DarkGray
}
#endregion

#region: Group Creation
$AllUsers = Get-ADUser -Filter *
if ($GroupCount -gt 0){
    Write-Host "[>] Creating Groups" -ForegroundColor Cyan
    $x = 0
    do {
        $x++
        New-CustomADGroup -Domain $Domain -OUList $OUsAll -UserList $AllUsers -ScriptDir $ReferenceFiles
        if (($GroupCount -gt 20) -and (-Not ($x % [math]::Floor(($GroupCount / 10))))){
            Write-Host "  [>] Accounts created: $x of $GroupCount" -ForegroundColor DarkGray    
        }
    } while ($x -lt $GroupCount)
} else {
    Write-Host "[>] Skipping Group Creation" -ForegroundColor DarkGray
}
#endregion

#region: Additional Chaos
# Create random selection of ACL assignments
Write-Host "[>] Setting random permissions" -ForegroundColor Cyan
$CompList = Get-ADComputer -filter *
$GroupList = Get-ADGroup -Filter { GroupCategory -eq "Security" -and GroupScope -eq "Global" } -Properties isCriticalSystemObject

$AssigneePools = $AllUsers,$GroupList,$CompList
$PermissionsConfigured = foreach ($Pool in $AssigneePools){
    Set-RandomPermissions -AssignmentCount 10 -AssigneePool $Pool -AssignToPool $OUsAll
}

if ($PermissionsConfigured){
    $TimeStamp = Get-Date -Format 'yyyyMMddHHmm_'
    $PermissionsConfigured | Export-Csv (Join-Path $BaseScriptPath "$($TimeStamp)Permissions-Configured.csv")
}

# Nesting of objects
Write-Host "[>] Nesting Objects into Groups" -ForegroundColor Cyan
$LocalGroupList = Get-ADGroup -Filter { GroupScope -eq "domainlocal" } -Properties isCriticalSystemObject
New-RandomGroupAdditions -Userlist $AllUsers -GroupList $GroupList -LocalGroupList $LocalGroupList -CompList $CompList

# SPN Generation
Write-Host "[>] Adding random SPNs to a few User and Computer Objects" -ForegroundColor Cyan
New-CustomSPNs -SPNCount 50

# AS-REP Roasting
Write-Host "[>] Adding AS-REP for a few users" -ForegroundColor Cyan
$ASREPCount = [Math]::Ceiling($AllUsers.count * .05)
$ASREPUsers = @()
$asrep = 1
do {
  $ASREPUsers += Get-Random $AllUsers
  $asrep++
} while ($asrep -le $ASREPCount)

# No Pre-Auth Required
Set-PreAuthNotRqd -UserList $ASREPUsers

#endregion

<# Sections to work on if required
# LAPS STUFF
if ($PSBoundParameters.ContainsKey('InstallLAPS')){
    .($BaseScriptPath + '\AD_LAPS_Install\InstallLAPSSchema.ps1')
}
#>