function Set-RandomPermissions {
    param (
        [Parameter(Mandatory = $false,
        HelpMessage = 'Supply output from Get-ADDomain')]
        [int]
        $AssignmentCount = 1,
        [Parameter(Mandatory,
        HelpMessage = 'Set of objects to randomly assign additional permissions (e.g. users, computers or groups)')]
        $AssigneePool,
        [Parameter(Mandatory,
        HelpMessage = 'Set of objects to randomly apply permissions to (e.g. OUs, users or computers)')]
        $AssignToPool
    )
    
    # Import required functions
    if (-Not (Get-Command | Where-Object Name -eq 'Get-ACLSets')){
        . .\Get-ACLSets.ps1
    }
    if (-Not (Get-Command | Where-Object Name -eq 'Set-CustomACL')){
        . .\Set-CustomACL.ps1
    }
    
    $ACLSets = Get-ACLSets
    $i = 0
    
    $Results = while ($i -lt $AssignmentCount){
        # Get a random permission set
        $PrimarySet = ($ACLSets.PSObject.Properties | Get-Random)
        $ACLSet = ($PrimarySet.Value.PSObject.Properties | Get-Random)
        # Which account to assign and where
        $Assignee = $AssigneePool | Get-Random
        $AssignTo = ($AssignToPool | Get-Random).distinguishedName
        
        try {
            Set-CustomACL -Assignee $Assignee -Path $AssignTo -ACLSet $ACLSet.Value -EA Stop
        } catch {
            Write-Host "  [x] Error while executing Set-CustomACL" -ForegroundColor Yellow
        }
        $i++
    }
    return $Results
}