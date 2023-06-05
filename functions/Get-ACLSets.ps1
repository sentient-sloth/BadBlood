function Get-ACLSets {
    # Attribute reference: https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adls/4f7e79ad-4606-4642-9b56-45061fab4e12
    [PSCustomObject]@{
        FullControl = [PSCustomObject]@{
            All = [PSCustomObject]@{
                "ADRights" = "GenericAll";
                "ObjectType" = "All";
                "InheritanceType" = "Descendents";
                "InheritedObjType" = "All"
            }
            Users = [PSCustomObject]@{
                "ADRights" = "GenericAll"
                "ObjectType" = "All"
                "InheritanceType" = "Descendents"
                "InheritedObjType" = "User"
            }
            Computers = [PSCustomObject]@{
                "ADRights" = "GenericAll"
                "ObjectType" = "All"
                "InheritanceType" = "Descendents"
                "InheritedObjType" = "Computer"
            }
            Groups = [PSCustomObject]@{
                "ADRights" = "GenericAll"
                "ObjectType" = "All"
                "InheritanceType" = "Descendents"
                "InheritedObjType" = "Group"
            }
        }
        UserControl = [PSCustomObject]@{
            Create = [PSCustomObject]@{
                "ADRights"         = "CreateChild"
                "ObjectType"       = "User"
                "InheritanceType"  = "Descendents"
                "InheritedObjType" = "All"
            }
            Delete = [PSCustomObject]@{
                "ADRights"        = "DeleteChild"
                "ObjectType"      = "User"
                "InheritanceType" = "Descendents"
                "InheritedObjType"= "All"
            }
            Rename = @(
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "Obj-Dist-Name" # ldap: distinguishedName
                    "InheritanceType"  = "Descendents"
                    "InheritedObjType" = "User"
                }
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "RDN" # ldap: name
                    "InheritanceType"  = "Descendents"
                    "InheritedObjType" = "User"
                }
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "Common-Name" # ldap: cn
                    "InheritanceType"  = "Descendents"
                    "InheritedObjType" = "User"
                }
            )
            AmendUAC = [PSCustomObject]@{
                "ADRights"         = "WriteProperty,ReadProperty"
                "ObjectType"       = "User-Account-Control"
                "InheritanceType"  = "Descendents"
                "InheritedObjType" = "User"
            }
            ResetPassword = @(
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "User-Force-Change-Password"
                    "InheritanceType"  = "Descendents"
                    "InheritedObjType" = "User"
                }
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "User-Change-Password"
                    "InheritanceType"  = "Descendents"
                    "InheritedObjType" = "User"
                }
            )
        }
    }
}