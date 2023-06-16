function Get-ACLSets {
    # Attribute reference: https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adls/4f7e79ad-4606-4642-9b56-45061fab4e12
    param (
        [Parameter(Mandatory = $false,
        HelpMessage = 'AD ACL Inheritance Type (None, All, Descendants)')]
        [ValidateSet('None','All','Descendants')]
        # None (This Object Only), All (This object and all descendant objects), Descendants (All descendant objects)
        $InheritanceType = 'Descendents' 
    )
    [PSCustomObject]@{
        FullControl = [PSCustomObject]@{
            All = [PSCustomObject]@{
                "ADRights" = "GenericAll";
                "ObjectType" = "All";
                "InheritanceType" = $InheritanceType;
                "InheritedObjType" = "All"
            }
            Users = [PSCustomObject]@{
                "ADRights" = "GenericAll"
                "ObjectType" = "All"
                "InheritanceType" = $InheritanceType
                "InheritedObjType" = "User"
            }
            Computers = [PSCustomObject]@{
                "ADRights" = "GenericAll"
                "ObjectType" = "All"
                "InheritanceType" = $InheritanceType
                "InheritedObjType" = "Computer"
            }
            Groups = [PSCustomObject]@{
                "ADRights" = "GenericAll"
                "ObjectType" = "All"
                "InheritanceType" = $InheritanceType
                "InheritedObjType" = "Group"
            }
        }
        UserControl = [PSCustomObject]@{
            Create = [PSCustomObject]@{
                "ADRights"         = "CreateChild"
                "ObjectType"       = "User"
                "InheritanceType"  = $InheritanceType
                "InheritedObjType" = "All"
            }
            Delete = [PSCustomObject]@{
                "ADRights"        = "DeleteChild"
                "ObjectType"      = "User"
                "InheritanceType" = $InheritanceType
                "InheritedObjType"= "All"
            }
            Modify = [PSCustomObject]@{
                "ADRights"        = "WriteProperty,ReadProperty"
                "ObjectType"      = "All"
                "InheritanceType" = $InheritanceType
                "InheritedObjType"= "User"
            }
            Rename = @(
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "Obj-Dist-Name" # ldap: distinguishedName
                    "InheritanceType"  = $InheritanceType
                    "InheritedObjType" = "User"
                }
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "RDN" # ldap: name
                    "InheritanceType"  = $InheritanceType
                    "InheritedObjType" = "User"
                }
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "Common-Name" # ldap: cn
                    "InheritanceType"  = $InheritanceType
                    "InheritedObjType" = "User"
                }
            )
            AmendUAC = [PSCustomObject]@{ # Covers Enable/Disable etc.
                "ADRights"         = "WriteProperty,ReadProperty"
                "ObjectType"       = "User-Account-Control"
                "InheritanceType"  = $InheritanceType
                "InheritedObjType" = "User"
            }
            ResetPassword = @(
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "User-Force-Change-Password"
                    "InheritanceType"  = $InheritanceType
                    "InheritedObjType" = "User"
                }
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "User-Change-Password"
                    "InheritanceType"  = $InheritanceType
                    "InheritedObjType" = "User"
                }
            )
            UnlockUserAccount = [PSCustomObject]@{
                "ADRights"         = "WriteProperty,ReadProperty"
                "ObjectType"       = "Lockout-Time"
                "InheritanceType"  = $InheritanceType
                "InheritedObjType" = "User"
            }
        }
        ComputerControl = [PSCustomObject]@{
            Create = [PSCustomObject]@{
                "ADRights"         = "CreateChild"
                "ObjectType"       = "Computer"
                "InheritanceType"  = $InheritanceType
                "InheritedObjType" = "All"
            }
            Delete = [PSCustomObject]@{
                "ADRights"        = "DeleteChild"
                "ObjectType"      = "Computer"
                "InheritanceType" = $InheritanceType
                "InheritedObjType"= "All"
            }
            Modify = [PSCustomObject]@{
                "ADRights"        = "WriteProperty,ReadProperty"
                "ObjectType"      = "All"
                "InheritanceType" = $InheritanceType
                "InheritedObjType"= "Computer"
            }
            Rename = @(
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "Obj-Dist-Name" # ldap: distinguishedName
                    "InheritanceType"  = $InheritanceType
                    "InheritedObjType" = "Computer"
                }
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "RDN" # ldap: name
                    "InheritanceType"  = $InheritanceType
                    "InheritedObjType" = "Computer"
                }
                [PSCustomObject]@{
                    "ADRights"         = "WriteProperty,ReadProperty"
                    "ObjectType"       = "Common-Name" # ldap: cn
                    "InheritanceType"  = $InheritanceType
                    "InheritedObjType" = "Computer"
                }
            )
            AmendUAC = [PSCustomObject]@{ # Covers Enable/Disable etc.
                "ADRights"         = "WriteProperty,ReadProperty"
                "ObjectType"       = "User-Account-Control"
                "InheritanceType"  = $InheritanceType
                "InheritedObjType" = "Computer"
            }
        }
    }
}