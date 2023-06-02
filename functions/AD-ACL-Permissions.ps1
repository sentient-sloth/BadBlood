# Functions for setting ACL's on AD objects
function Set-ACLFullControl {
    param (
        $Object, 
        $Path, 
        [Parameter(Mandatory)]
        [ValidateSet('all','user','group','computer')]
        $Type, 
        $InheritanceType
    )
    $objSID = New-Object System.Security.Principal.SecurityIdentifier $object.SID
    $objAcl = Get-ACL $Path
    if ($Type -eq 'all'){
        $PermScope ='00000000-0000-0000-0000-000000000000'
    } else {
        $PermScope = $guidmap[$Type]
    }
    $objAcl.AddAccessRule(
        (
            New-Object System.DirectoryServices.ActiveDirectoryAccessRule $objSID,
            'GenericAll',
            'Allow',
            '00000000-0000-0000-0000-000000000000',
            $inheritanceType,
            $PermScope
        )
    )
    try {
        Set-Acl -AclObject $objAcl  -path $path 
    } catch {
        Write-Host -ForegroundColor Red ("ERROR: Unable to grant the group " + $object.Name + " Full Control permissions")
    }
    if(!$error) {
        Write-Host -ForegroundColor Green ("INFORMATION: Granted the group " + $object.Name + " Full Control permissions on the OU " + $objOU)
    }
}
