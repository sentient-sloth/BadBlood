# Functions for setting ACL's on AD objects
function Set-CustomACL {
    param (
        [Parameter(Mandatory)]
        $Assignee, 
        [Parameter(Mandatory)]
        $Path,
        [Parameter(Mandatory)]
        $ACLSet
    )
    
    # Ensure ACLSet contains the required properties
    $RequiredProps = 'ADRights','InheritanceType','InheritedObjType','ObjectType'
    foreach ($Prop in $RequiredProps){
        if (-Not ($ACLSet | Get-Member -MemberType NoteProperty) -contains $Prop){
            Write-Host "[x] Provided ACLSet does not contain required property: $Prop" -ForegroundColor Yellow
            return
        }
    }
    
    #Generate hash table of schema attributes (inc. extended)
    if (-Not $AttributeMap){
        $AttributeMap = @{}
        $LookupParams = @{
            SearchBase = (Get-ADRootDSE).schemaNamingContext
            LDAPFilter = '(schemaIDGUID=*)'
            Properties = 'name', 'schemaIDGUID'
        }
        Get-ADObject @LookupParams | ForEach-Object {$AttributeMap.add($_.name,[System.GUID]$_.schemaIDGUID)}
        $ExtendedParams = @{
            SearchBase = "CN=Extended-Rights,$((Get-ADRootDSE).configurationNamingContext)"
            LDAPFilter = '(objectClass=controlAccessRight)'
            Properties = 'name', 'rightsGUID'
        }
        Get-ADObject @ExtendedParams | ForEach-Object {
            if (!($AttributeMap.ContainsKey($_.name))){
                $AttributeMap.add($_.name,[System.GUID]$_.rightsGUID)
            }
        }
    }
    
    # TODO: Add check to ensure $Object is an AD Object, not a string and contains a SID!
    if ($Assignee.GetType().Name -eq 'ADObject' -and ($Assignee.ObjectSid)){
        $AssigneeSID = [System.Security.Principal.SecurityIdentifier]::new($Assignee.objectsid)
    } elseif ($Assignee.GetType().Name -match '^ADUser$|^ADComputer$|^ADGroup$'){
        $AssigneeSID = [System.Security.Principal.SecurityIdentifier]::new($Assignee.SID)
    } else {
        Write-Host "  [x] Invalid Assignee! Requires ADUser or ADObject type with SID ($($Assignee.GetType().Name))" -ForegroundColor Yellow
        return
    }
    $ObjAcl = Get-ACL "AD:/$Path"
    
    # Ensure no empty rows in ACLSet (json import issue)
    $ACLSet = $ACLSet | ForEach-Object {if ($null -ne $_){$_}}
    
    foreach ($Row in $ACLSet){
        # ObjectType can be an object or an object property, defaults to all
        if (($Row.ObjectType -eq 'all') -or (-Not $Row.ObjectType)){
            $ObjectTypeGuid ='00000000-0000-0000-0000-000000000000'
        } elseif ($Row.ObjectType) {
            $ObjectTypeGuid = $AttributeMap[$Row.ObjectType]
        }
        
        # InheritedObjectType can only be an object (not a property), defaults to all
        if (($Row.InheritedObjType -eq 'all') -or (-Not $Row.InheritedObjType)){
            $InheritedObjTypeGuid ='00000000-0000-0000-0000-000000000000'
        } elseif ($Row.InheritedObjType) {
            $InheritedObjTypeGuid = $AttributeMap[$Row.InheritedObjType]
        }
        
        # Construct new Access Control Entry
        $ACE = [System.DirectoryServices.ActiveDirectoryAccessRule]::new(
            $AssigneeSID,
            $Row.ADRights,
            'Allow',
            $ObjectTypeGuid,
            $Row.inheritanceType,
            $InheritedObjTypeGuid
        )
        $ObjAcl.AddAccessRule($ACE)
        
        $AssignmentSet = [PSCustomObject]@{
            Assignee     = $Assignee.Name
            AssignedTo   = $Path
            Permissions  = $Row.ADRights
            ObjectType   = $Row.ObjectType
            InheritObj   = $Row.InheritedObjType
            InheritType  = $Row.inheritanceType
        }
        
        try {
            Set-Acl -AclObject $ObjAcl  -Path "AD:/$Path" -EA Stop
            Write-Host ("  [$([char]0x2713)] '$($Assignee.Name)' Granted $($Row.ADRights) permissions on OU '$Path'") -ForegroundColor DarkGreen
            return $AssignmentSet
        } catch {
            Write-Host ("  [x] Unable to set requested ACL!") -ForegroundColor Yellow
        }
    }
}
