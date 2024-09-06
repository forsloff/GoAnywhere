function New-ArchivesDirectory($name){

    $path = Join-Path -Path "\\forsloff.local\fs\Archives" -ChildPath $name

    if( Test-Path -Path $path ) {
        Write-Host "Exits"
        Exit
    }

    New-Item -Path $path -ItemType Directory

    Disable-NTFSAccessInheritance -Path $path

    # Remove ACL's inherated from the parent directory.
    foreach($remove in @("FORSLOFF\ACL_Archives-List")) {
        try {
            $accesses = Get-NTFSAccess -Path $path -Account $remove
            foreach($access in $accesses) {
                Remove-NTFSAccess -Path $path -Account $remove -AccessRights $access.AccessRights
            }
        } catch {}
    }

    foreach($rights in @('Read', 'Modify')) {

        $group  = "ACL_ARH_{0}-{1}" -f $name, $rights
        $ou     = 'OU=Archives,OU=ACL,OU=FS,OU=Security Groups,OU=Production,DC=FORSLOFF,DC=LOCAL'

        if($rights -eq 'Read'){
            $rights = "ReadAndExecute"
        }

        $object = New-ADGroup -Name $group -SamAccountName $group -Description $path -GroupCategory 'Security' -GroupScope 'Global' -Path $ou -PassThru
        
        Add-NTFSAccess -Path $path -Account $object.SID -AccessRights $rights
    
    }
}