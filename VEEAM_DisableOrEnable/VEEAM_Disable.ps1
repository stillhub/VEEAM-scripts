# Script that disables list of backups (BackupJobs.csv) on a remote computer running VEEAM.
# Script created by Jared Stillwell
# Version: 1.0

$RemotePC = "HOSTNAME"
$VEEAMUsername = "domain\user"
$EncryptedPassLocation = ".\password1.txt"
$BackupJobs = ".\BackupJobs.csv"

Invoke-Command -ComputerName WINBKP20 -ScriptBlock {

    Add-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

    # When called, creates encrypted password file for server login.
    function EncryptSecPass{
        # File used to store the encrypted string
        $SecretFile1 = $EncryptedPassLocation
        $SecretContent1 = Read-host "Enter password to encrypt"
        ConvertTo-SecureString -String $SecretContent1 -AsPlainText -Force | 
        ConvertFrom-SecureString | 
        Out-File $SecretFile1 -Encoding UTF8
    }

    function ExecuteDisabling{
        $SecretFile1 = $EncryptedPassLocation
        $SecureString1 = ConvertTo-SecureString -String (Get-Content $SecretFile1)
        $Pointer1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString1)
        $SecPassword1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto($Pointer1)
        Disconnect-VBRServer | out-null
        connect-vbrserver -server localhost -user $VEEAMUsername -password $SecPassword1
        Import-Csv -Path $BackupJobs | ForEach-Object {Get-VBRJob -Name $_.'BackupName' | Disable-VBRJob}
    }

    #EncryptSecPass
    ExecuteDisabling

}