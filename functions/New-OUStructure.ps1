
function New-OUStructure {
    param (
        $CSVPrefixes
    )
    
    function New-CustomOU ($Name, $Path, $Description=''){
        if (Test-Path "AD:/$Path"){
            $OUPath = "OU=$Name,$Path"
            if (-Not (Test-Path "AD:/$OUPath")){
                $params = @{
                    Name        = $Name
                    Path        = $Path
                    Description = $Description
                }
                New-ADOrganizationalUnit @params -ProtectedFromAccidentalDeletion:$false
                Write-Host "  [$([char]0x2713)] Created Top Level OU: $OUPath" -ForegroundColor DarkGreen
            } else {
                Write-Host "  [*] Top Level OU already exists: $OUPath" -ForegroundColor DarkGray
            }
        } else {
            Write-Host "[x] Warning: Provide Path is invalid!" -ForegroundColor Yellow
        }
    }
    
    $TopLevelOUs = @('Admin', 'Tier 1','Tier 2','Stage', 'Quarantine', 'Grouper-Groups', 'People','Testing') 
    $AdminSubOUs = @('Tier 0', 'Tier 1', 'Tier 2', 'Staging') 
    $AdminobjectOUs = @('Accounts', 'Servers', 'Devices', 'Permissions','Roles')
    $ObjectSubOUs = @('ServiceAccounts', 'Groups', 'Devices','Test')
    $CsvList = Import-Csv $CSVPrefixes
    
    $DN = (Get-ADDomain).distinguishedname
    #=============================================
    #ROUND:1
    #Create Top Level OUS
    #=============================================
    Write-host "[>] Creating Tiered OU Structure" -ForegroundColor DarkCyan
    foreach ($Name in $TopLevelOUs) {
        New-CustomOU -Name $Name -Path $DN
        #=====================================================================================
        #ROUND:2
        #Create First level Down Sub OUs in Privileged Access, and Provisioned Users
        #=====================================================================================
        $FullDN = "OU=$Name,$DN"
        if ($Name -eq $TopLevelOUs[0]) {
            foreach ($AdminSubOU in $AdminSubOUs) {
                New-CustomOU -Name $AdminSubOU -Path $FullDN
                if ($AdminSubOU -ne "Staging") {
                    foreach ($AdminobjectOU in $AdminobjectOUs) {
                        #add name together
                        $adminOUPrefix = switch ($AdminSubOU){
                            'Tier 0' {"T0-"}
                            'Tier 1' {"T1-"}
                            'Tier 2' {"T2-"}
                        }
                        $AdminObjectOUCombo = $adminOUPrefix + $AdminobjectOU
                        New-CustomOU -Name $AdminObjectOUCombo -Path "OU=$AdminSubOU,$FullDN"
                    }
                }
            }
        } elseif (($Name -eq 'Tier 1') -or ($Name -eq 'Tier 2') -or ($Name -eq 'Stage')) {
            $FullDN = "OU=$Name,$DN"
            foreach ($OU in $CsvList) {
                New-CustomOU -Name $ou.name -Path $FullDN
                $CsvDN = "OU=$($ou.name),$FullDN"
                foreach ($ObjectSubOU in $ObjectSubOUs) {
                    New-CustomOU -Name $ObjectSubOU -Path $CsvDN
                }
            }
        } elseif (($Name -eq 'People')) {
            $FullDN = "OU=$Name,$DN"
            foreach ($OU in $CsvList) {
                New-CustomOU -Name $OU.name -Path $FullDN -Description $OU.description
            }
        }
    }
}