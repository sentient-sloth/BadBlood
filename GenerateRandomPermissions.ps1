#import scripts
function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
$scriptPath = Get-ScriptDirectory
$basescriptPath = split-path -Path $scriptPath -Parent

#import ACL function files
$ACLScriptspath = (Join-Path $basescriptPath 'functions\ACLs')

$Files = Get-ChildItem $ACLScriptspath -Name "*permissions.ps1"
    foreach ($File in $Files){
    . $File.FullName
    }

Function New-PermissionSet {
    $Permissions = @()
    $row = @()
    
    #===================================================================
    #Full Control PERMISSIONS
    $FunctionSet = "Full Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet; ObjectType = 'all'; Apply = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet; ObjectType = 'user'; Apply = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet; ObjectType = 'group'; Apply = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet; ObjectType = 'computer'; Apply = 'FALSE'}
    
    #===================================================================
    #USER PERMISSIONS
    $FunctionSet = "User Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateUserAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteUserAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameUserAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DisableUserAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'UnlockUserAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'EnableDisabledUserAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetUserPasswords';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ForcePasswordChangeAtLogon';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyUserGroupMembership';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyUserProperties';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DenyModifyLogonScript';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DenySetUserSPN';APPLY = 'FALSE'}
    
    #END USER PERMISSIONS 
    #===================================================================
    #COMPUTER PERMISSIONS
    $FunctionSet = "Computer Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateComputerAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteComputerAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameComputerAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DisableComputerAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'EnableDisabledComputerAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyComputerProperties';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetComputerAccount';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyComputerGroupMembership';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'SetComputerSPN';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReadComputerTPMBitLockerInfo';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReadComputerAdmPwd';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetComputerAdmPwd';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DomainJoinComputers';APPLY = 'FALSE'}
    #END COMPUTER PERMISSIONS
    #===================================================================
    #GROUP PERMISSIONS
    $FunctionSet = "Group Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateGroup';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteGroup';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameGroup';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupProperties';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupMembership';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupGroupMembership';APPLY = 'FALSE'}
    
    #END GROUP PERMISSIONS
    #===================================================================
    #OU PERMISSIONS
    $FunctionSet = "OU Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateOU';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteOU';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameOU';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyOUProperties';APPLY = 'FALSE'}
    #END OU PERMISSIONS
    #===================================================================
    # GPO PERMISSIONS
    $FunctionSet = "OU Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'LinkGPO';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'GenerateRsopPlanning';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'GenerateRsopLogging';APPLY = 'FALSE'}
    #END GPO PERMISSIONS
    #===================================================================
    # PRINTER PERMISSIONS
    $FunctionSet = "Printer Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreatePrintQueue';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeletePrintQueue';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenamePrintQueue';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyPrintQueueProperties';APPLY = 'FALSE'}
    #END PRINTER PERMISSIONS
    #===================================================================
    # Replication  PERMISSIONS
    $FunctionSet = "Replication Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ManageReplicationTopology';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReplicatingDirectoryChanges';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReplicatingDirectoryChangesAll';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReplicatingDirectoryChangesInFilteredSet';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReplicationSynchronization';APPLY = 'FALSE'}
    #END Replication PERMISSIONS
    #===================================================================
    # Site and Subnet  PERMISSIONS
    $FunctionSet = "Site and Subnet Control Permissions"
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateSiteObjects';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteSiteObjects';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifySiteProperties';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateSubnetObjects';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteSubnetObjects';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifySubnetProperties';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateSiteLinkObjects';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteSiteLinkObjects';APPLY = 'FALSE'}
    $row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifySiteLinkProperties';APPLY = 'FALSE'}
    
    #===========================================
    #ADD ALL PARAMETERS TO $PERMISSIONS
    $Permissions += $row
    $permissions
    $permINT = 1..100|get-random 
    if($permint -gt 25){#if gt this number, assign random permissions
    $howmanypermissions = 1..60|get-random
    $p = 1
    do{$randoperm = 0..(($permissions.count)-1)|Get-random
        $permissions[$randoperm].APPLY = 'TRUE'
        $p++
    }while($P -le $howmanypermissions)
    }
    $permissions
}

$PermissionsToOUMapping = @{}
$PermissionsToOUMapping.Add('User','ServiceAccounts')
$PermissionsToOUMapping.Add('Computer','Devices')
$PermissionsToOUMapping.Add('Group','Groups')
$PermissionsToOUMapping.Add('OU','OU') #this mapping doesnt entirely matter since on line 94 OU permissions are applied directly to the OU containing the affiliate code
$PermissionsToOUMapping.Add('Printer', 'Devices')
#=============================================
#BEGIN MAKING GROUPS AND SETTING ACLS
$Domain = Get-ADDomain
$setdc = $Domain.pdcemulator
$dn = $Domain.distinguishedname
$AllOUs = Get-ADOrganizationalUnit -Filter *
$allUsers = Get-ADObject -LDAPFilter '(&(objectClass=user)(objectCategory=person))' -ResultSetSize 2500 -Server $setdc

Set-Location 'AD:\'

#region: Create a hashtable to store the GUID value of each schema class and attribute
# NOTE: These are used within the permissions functions and should probably be passed in for clarity
$schemaPath = (Get-ADRootDSE)
$guidmap = @{}
$guidParams = @{
    SearchBase = $schemaPath.SchemaNamingContext
    LDAPFilter = "(schemaidguid=*)"
    Properties = 'lDAPDisplayName','schemaIDGUID'
}
Get-ADObject @guidParams | ForEach-Object {$guidmap[$_.lDAPDisplayName]=[System.GUID]$_.schemaIDGUID}

#Create a hashtable to store the GUID value of each extended right in the forest
$extendedrightsmap = @{}
$extRightsParams = @{
    SearchBase = $schemaPath.ConfigurationNamingContext
    LDAPFilter = "(&(objectclass=controlAccessRight)(rightsguid=*))"
    Properties = 'displayName','rightsGuid'
}
Get-ADObject @extRightsParams | ForEach-Object {$extendedrightsmap[$_.displayName]=[System.GUID]$_.rightsGuid}
#endregion

#region: Apply random permisions to USERS
$permint = 5..100 | get-random
$objwithPerms = @()
$z = 1
do {
    $objwithPerms += $allUsers | Get-Random
    $z++
} while ($z -le $permint)

foreach ($obj in $objwithPerms){
    $Permissions = New-PermissionSet
    $Object = Get-ADUser $obj
    foreach ($Permission in $Permissions){
        if($Permission.Apply -eq 'TRUE'){
            if ($permission.functionset -eq 'Full Control Permissions'){
                $OUorRoot = 1..100 | Get-Random
                if ($OUorRoot -le 3){
                    Set-ACLFullControl -Object $Object -Path $dn -Type $Permission.ObjectType -InheritanceType 'Descendents'
                } else {
                    $OUPicked = $allOUs | Get-Random
                    Set-ACLFullControl -Object $Object -Path $OUPicked -Type $Permission.ObjectType -InheritanceType 'Descendents'
                } # Should add direct object ACL's here too
            }
        }
    }
}
#endregion

#region: Apply random permissions to GROUPS
$AllGroups = get-adgroup -f * -ResultSetSize 2500
<#Pick X number of random groups#>
$permint = 5..100|get-random
$objwithPerms = @()
$z = 1
do{$objwithPerms += $AllGroups|Get-Random
$z++}while($z -le $permint)

    foreach($obj in $objwithPerms){
        $permissions = New-PermissionSet
        $adgroup = get-adgroup $obj
        foreach ($permission in $permissions){
            if($permissions.count -gt 0){ 
            if ($permission.APPLY -eq 'TRUE'){
    #apply directly to OU first choice, apply to computer,group,user second choice
                if($permission.functionset -eq 'Full Control Permissions'){
                  
                    #FullControl 
                    $OUorRootRando = 1..100|get-random
                    if ($OUorRootRando -le 5){#lets do root here
                        iex ($permission.FunctionName + " -objgroup " + '$adgroup' + " -objou " + '$dn' + " -inheritanceType `'Descendents`'")
    
                    }else{
                        $OUPicked = $allOUs|Get-random
                        iex ($permission.FunctionName + " -objgroup " + '$adgroup' + " -objou " + '$OUPicked' + " -inheritanceType `'Descendents`'")
                    }
                }
    }
}
}
}
#endregion

#region: Apply random permissions to COMPUTERS
$AllComputers = get-adcomputer -f * -ResultSetSize 2500
<#Pick X number of random groups#>
$permint = 5..100|get-random
$objwithPerms = @()
$z = 1
do{$objwithPerms += $AllComputers|Get-Random
$z++}while($z -le $permint)

    foreach($obj in $objwithPerms){
        $permissions = New-PermissionSet
        $adgroup = get-adcomputer $obj
        foreach ($permission in $permissions){
            if($permissions.count -gt 0){ 
            if ($permission.APPLY -eq 'TRUE'){
    #apply directly to OU first choice, apply to computer,group,user second choice
                if($permission.functionset -eq 'Full Control Permissions'){
                  
                    #FullControl 
                    $OUorRootRando = 1..100|get-random
                    if ($OUorRootRando -le 5){#lets do root here
                        iex ($permission.FunctionName + " -objgroup " + '$adgroup' + " -objou " + '$dn' + " -inheritanceType `'Descendents`'")
    
                    }else{
                        $OUPicked = $allOUs|Get-random
                        iex ($permission.FunctionName + " -objgroup " + '$adgroup' + " -objou " + '$OUPicked' + " -inheritanceType `'Descendents`'")
                    }
                }
    }
}
}
}
#endregion
