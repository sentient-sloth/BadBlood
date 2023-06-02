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
      Position = 2,
      HelpMessage = 'Number of Groups to create')]
   [int32]$GroupCount = 500,
   [Parameter(Mandatory = $false,
      Position = 3,
      HelpMessage = 'Number of Computer accounts to create')]
   [int32]$ComputerCount = 500,
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

$basescriptPath = Get-ScriptDirectory
$ReferenceFiles = Join-Path $basescriptPath 'reference-files'
$Domain = Get-ADDomain

# Import functions
foreach ($function in (Get-ChildItem -File -Recurse (Join-Path $basescriptPath 'functions'))){
    . $function.FullName
}

# LAPS STUFF
if ($PSBoundParameters.ContainsKey('InstallLAPS')){
    .($basescriptPath + '\AD_LAPS_Install\InstallLAPSSchema.ps1')
}

#region: OU Structure Creation
if ($PSBoundParameters.ContainsKey('SkipOuCreation') -eq $false){
  Write-Host "[>] Creating OU Structure" -ForegroundColor Cyan
  New-OUStructure -CSVPrefixes (Join-Path $ReferenceFiles '3lettercodes.csv')
}
#endregion

#region: User Creation
$OUsAll = Get-ADOrganizationalUnit -filter *
Write-Host "[>] Creating AD User Accounts" -ForegroundColor Cyan
do {
  $x++
  New-CustomADUser -Domain $Domain -OUList $OUsAll -ScriptDir $ReferenceFiles
  if (($UserCount -gt 20) -and (-Not ($x % [math]::Floor(($UserCount / 10))))){
    Write-Host "  [>] Accounts created: $x of $UserCount" -ForegroundColor DarkGray    
  }
} while ($x -lt $UserCount)
#endregion

#region: Group Creation
$AllUsers = Get-ADUser -Filter *
Write-Host "[>] Creating AD Groups" -ForegroundColor Cyan
$x = 0
do {
    $x++
    New-CustomADGroup -Domain $Domain -OUList $ousAll -UserList $AllUsers -ScriptDir $ReferenceFiles
    if (($GroupCount -gt 20) -and (-Not ($x % [math]::Floor(($GroupCount / 10))))){
        Write-Host "  [>] Accounts created: $x of $GroupCount" -ForegroundColor DarkGray    
    }
} while ($x -lt $GroupCount)

$Grouplist = Get-ADGroup -Filter { GroupCategory -eq "Security" -and GroupScope -eq "Global" } -Properties isCriticalSystemObject
$LocalGroupList = Get-ADGroup -Filter { GroupScope -eq "domainlocal" } -Properties isCriticalSystemObject
#endregion

#region: Computer Creation
Write-Host "[>] Creating Computer Accounts" -ForegroundColor Cyan
$x = 0
do {
    $x++
    New-CustomADComputer -Domain $Domain -OUList $OUsAll -UserList $AllUsers -ScriptDir $ReferenceFiles
    if (($ComputerCount -gt 20) -and (-Not ($x % [math]::Floor(($ComputerCount / 10))))){
        Write-Host "  [>] Accounts created: $x of $ComputerCount" -ForegroundColor DarkGray    
    }
} while ($x -lt $ComputerCount)

$Complist = Get-ADComputer -filter *
#endregion

#region: Additional Chaos
# Permission Creation of ACLs
Write-Host "[>] Creating Permissions on Domain" -ForegroundColor Cyan
.($basescriptPath + '\GenerateRandomPermissions.ps1')

# Nesting of objects
Write-Host "Nesting objects into groups on Domain" -ForegroundColor Cyan
New-RandomGroupAdditions -Domain $Domain -Userlist $AllUsers -GroupList $Grouplist -LocalGroupList $LocalGroupList -complist $Complist

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