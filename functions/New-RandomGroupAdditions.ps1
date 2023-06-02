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

    ##BEGIN STUFF
    if (!$PSBoundParameters.ContainsKey('UserList')){
        $allUsers = Get-ADUser -Filter *
    } else {
        $allUsers = $UserList
    }
    if (!$PSBoundParameters.ContainsKey('GroupList')){
        $allGroups = Get-ADGroup -Filter { GroupCategory -eq "Security" -and GroupScope -eq "Global"  } -Properties isCriticalSystemObject
    } else {
        $allGroups = $GroupList
    }
    if (!$PSBoundParameters.ContainsKey('LocalGroupList')){
        $allGroupsLocal = Get-ADGroup -Filter { GroupScope -eq "domainlocal"  } -Properties isCriticalSystemObject
    } else {
        $allGroupsLocal = $LocalGroupList
    }
    if (!$PSBoundParameters.ContainsKey('CompList')){
        $allcomps = Get-ADComputer -Filter *
    } else {
        $allcomps = $CompList
    }
    
    Set-Location 'AD:'

    #Pick X number of random users
    $UsersInGroupCount = [math]::Round($allusers.count * .8) #need to round to int. need to check this works
    $GroupsInGroupCount = [math]::Round($allGroups.count * .2)
    $CompsInGroupCount = [math]::Round($allcomps.count * .1)

    $AddUserstoGroups = Get-Random -Count $UsersInGroupCount -InputObject $allUsers
    $allGroupsFiltered = $allGroups | Where-Object -Property iscriticalsystemobject -ne $true

    #add a large number of users to a large number of non critical groups
    foreach ($user in $AddUserstoGroups){
        #get how many groups
        $num = 1..10 | Get-Random
        $n = 0
        do {
            $randogroup = $allGroupsFiltered | Get-Random
            #add to group
            try{Add-ADGroupMember -Identity $randogroup -Members $user}
            catch{}
            $n++
        } while ($n -le $num)
    }

    #add a few people to a small number of critical groups
    $allGroupsCrit = $allGroups | Where-Object {
            $_.iscriticalsystemobject -eq $true -and
            $_.Name -ne "Domain Users" -and 
            $_.Name -ne "Domain Guests" -and
            $_.Name -ne "Domain Computers"
        }
    $allGroupsCrit | ForEach-Object {
        try {
            Add-ADGroupMember -Identity $_ -Members (Get-Random -Count (2..5 | Get-Random) -InputObject $allUsers)
        } catch {}
    }

    #add a few people to a small number of critical local groups
    $allGroupsLocal | ForEach-Object {
        try{
            Add-ADGroupMember -Identity $_ -Members (Get-Random -Count (1..3 | Get-Random) -InputObject $allUsers)
        }
        catch{}
    }

    #Nest some groups in groups
    $AddGroupstoGroups = Get-Random -Count $GroupsInGroupCount -InputObject $allGroupsFiltered

    foreach ($group in $AddGroupstoGroups){
        #get how many groups
        $num = 1..2 | Get-Random
        $n = 0
        do {
            $randogroup = $allGroupsFiltered | Get-Random
            #add to group
            try {
                Add-ADGroupMember -Identity $randogroup -Members $group
            } catch {}
            $n++
        } while ($n -le $num)
    }

    # add all critical groups to 2-5 other random groups
    $allGroupsCrit | ForEach-Object {
        $num = 1..3 | Get-Random
        $n = 0
        do {
            $randogroup = $allGroupsFiltered|Get-Random
            #add to group
            try {
                Add-ADGroupMember -Identity $randogroup -Members $_
            } catch {}
            $n++
        } while ($n -le $num)
    }

    $addcompstoGroups = @()
    $addcompstogroups = Get-Random -Count $compsInGroupCount -InputObject $allcomps

    foreach ($comp in $addcompstogroups){
        $num = 1..5 | Get-Random
        $n = 0
        do{
            $randomgroup = $allGroupsFiltered | Get-Random
            #add to group
            try {
                Add-ADGroupMember -Identity $randomgroup -Members $comp
            }
            catch {}
            $n++
        } while ($n -le $num)
    }
}
