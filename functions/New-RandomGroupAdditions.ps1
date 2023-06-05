Function New-RandomGroupAdditions {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false,
            Position = 1,
            HelpMessage = 'Supply a result from get-aduser -filter *')]
            [Object[]]$UserList,
        [Parameter(Mandatory = $false,
            Position = 2,
            HelpMessage = 'Supply a result from Get-ADGroup -Filter { GroupCategory -eq "Security" -and GroupScope -eq "Global"  } -Properties isCriticalSystemObject')]
            [Object[]]$GroupList,
        [Parameter(Mandatory = $false,
            Position = 3,
            HelpMessage = 'Supply a result from Get-ADGroup -Filter { GroupScope -eq "domainlocal"  } -Properties isCriticalSystemObject')]
            [Object[]]$LocalGroupList,
        [Parameter(Mandatory = $false,
            Position = 4,
            HelpMessage = 'Supply a result from Get-ADComputer -f *')]
            [Object[]]$CompList
    )

    #region: Parameter processing
    if (!$PSBoundParameters.ContainsKey('UserList')){
        $AllUsers = Get-ADUser -Filter *
    } else {
        $AllUsers = $UserList
    }
    if (!$PSBoundParameters.ContainsKey('GroupList')){
        $AllGroups = Get-ADGroup -Filter { GroupCategory -eq "Security" -and GroupScope -eq "Global"  } -Properties isCriticalSystemObject
    } else {
        $AllGroups = $GroupList
    }
    if (!$PSBoundParameters.ContainsKey('LocalGroupList')){
        $AllGroupsLocal = Get-ADGroup -Filter { GroupScope -eq "domainlocal"  } -Properties isCriticalSystemObject
    } else {
        $AllGroupsLocal = $LocalGroupList
    }
    if (!$PSBoundParameters.ContainsKey('CompList')){
        $AllComps = Get-ADComputer -Filter *
    } else {
        $AllComps = $CompList
    }
    #endregion
    
    #Pick X number of random users
    $UsersInGroupCount = [math]::Round($AllUsers.count * .8) #need to round to int. need to check this works
    $GroupsInGroupCount = [math]::Round($AllGroups.count * .2)
    $CompsInGroupCount = [math]::Round($AllComps.count * .1)

    $AddUsersToGroups = Get-Random -Count $UsersInGroupCount -InputObject $AllUsers
    $AllGroupsFiltered = $AllGroups | Where-Object -Property iscriticalsystemobject -ne $true

    #add a large number of users to a large number of non critical groups
    foreach ($user in $AddUsersToGroups){
        $n = 0
        while ($n -le (1..10 | Get-Random)) {
            $randogroup = $AllGroupsFiltered | Get-Random
            try {
                Add-ADGroupMember -Identity $randogroup -Members $user
            } catch {}
            $n++
        }
    }

    #add a few people to a small number of critical groups
    $AllGroupsCrit = $AllGroups | Where-Object {
        $_.iscriticalsystemobject -eq $true -and
        $_.Name -ne "Domain Users" -and 
        $_.Name -ne "Domain Guests" -and
        $_.Name -ne "Domain Computers"
    }
    
    $AllGroupsCrit | ForEach-Object {
        try {
            # Add Critical Group Members
            Add-ADGroupMember -Identity $_ -Members (Get-Random -Count (2..5 | Get-Random) -InputObject $AllUsers)
            # Add Critical Group to Groups
            $n = 0
            while ($n -le (1..3 | Get-Random)) {
                $randogroup = $AllGroupsFiltered | Get-Random
                try {
                    Add-ADGroupMember -Identity $randogroup -Members $_
                } catch {}
                $n++
            } 
        } catch {}
    }

    #add a few people to a small number of critical local groups
    $AllGroupsLocal | ForEach-Object {
        try {
            Add-ADGroupMember -Identity $_ -Members (Get-Random -Count (1..3 | Get-Random) -InputObject $AllUsers)
        } catch {}
    }

    #Nest some groups in groups
    $AddGroupstoGroups = Get-Random -Count $GroupsInGroupCount -InputObject $AllGroupsFiltered

    foreach ($group in $AddGroupstoGroups){
        #get how many groups
        $n = 0
        while ($n -le (1..2 | Get-Random)) {
            $randogroup = $AllGroupsFiltered | Get-Random
            #add to group
            try {
                Add-ADGroupMember -Identity $randogroup -Members $group
            } catch {}
            $n++
        }
    }

    $addcompstoGroups = @()
    $addcompstogroups = Get-Random -Count $compsInGroupCount -InputObject $AllComps

    foreach ($comp in $addcompstogroups){
        $n = 0
        while ($n -le (1..5 | Get-Random)){
            $randomgroup = $AllGroupsFiltered | Get-Random
            try {
                Add-ADGroupMember -Identity $randomgroup -Members $comp
            } catch {}
            $n++
        }
    }
}
