#!REQUEST INFO////////////////////////////////////////////////////////////////////////////////////////////////////////////////
$textpass1 = $false
while ($textPass1 -ne $textPass2)
{
    if ($err -eq $true)
    {
        write-host "Error: The passwords do not match." -BackgroundColor white -foregroundcolor Black
        $err = $false
    }

    $adminPass1 = Read-Host -Prompt "Set password for local administrator account" -AsSecureString
    $BSTR1 = ` [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPass1)
    $textPass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR1) #transforming string from secureString to normal string

    $adminPass2 = Read-Host -Prompt "Confirm password" -AsSecureString
    $BSTR2 = ` [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPass2)
    $textPass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)

    $err = $true
}

$compName = read-host "Enter a name for this computer in the format 'GroupAdvisior-RoomNumber'"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)

$baseSoftware = 'Google Chrome', 'FireFox', 'Microsoft Office', 'Symantec', 'Spirion' #add 'Adobe Acrobat 2017' at some point if possible
$title = 'Software Install'
$resultInstall = @()

foreach ($i in $baseSoftware)
{
    $message = "Do you want $i to be installed?"
    $resultInstall += $host.ui.PromptForChoice($title, $message, $options, 1) #1 indicates yes; and is default answer
}



#WINDOWS UPDATE//////////////////////////////////////////////////////////////////////////////////////////////////
try
{
    #TEST each line to figure out which line needs an acceptall argument
    Install-Module PSWindowsUpdate
    Get-Command –module PSWindowsUpdate
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
    Get-WUInstall –MicrosoftUpdate –AcceptAll
    #"NuGet Provider is required to continue" just answer yes; will work if connected to internet and only required
    #for running windows updates through PowerShell
    #obv if not connected to internet then cannot download windows updates anyway
}
catch
{
    write-host "An error occurred when trying to install Windows Updates, likely that there is no internet connection."
     -BackgroundColor white -foregroundcolor Black
}
finally
{



#!COMPUTER MANAGEMENT/////////////////////////////////////////////////////////////////////////////////////////////////////////
$adminAccount = get-localuser -name "Administrator"
$adminAccount | set-localuser -Password $adminPass1
$adminAccount | Enable-LocalUser
$adminAccount | Set-LocalUser -PasswordNeverExpires 0



#!CHANGE NETWORK DNS SETTINGS/////////////////////////////////////////////////////////////////////////////////////////////////
$DNSAddresses = "165.91.176.17", "165.91.176.18", "165.91.176.19", "128.194.254.1", "128.194.254.2"
Get-NetAdapter -name "Ethernet" | Set-DnsClientServerAddress -ServerAddresses $DNSAddresses



#!CHANGE COMPUTER NAME AND ADD TO CHEMISTRY DOMAIN////////////////////////////////////////////////////////////////////////////
add-computer -computername $env:computername -domainname chem.tamu.edu -newname $compName -Credential netID



#INSTALL BASELINE PROGRAMS///////////////////////////////////////////////////////////////////////////////////////////////////
$driveLetter = gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | %{$_.deviceid}
if ($resultInstall[0] -eq 1)
{
    if ([Environment]::Is64BitOperatingSystem)
    {
        Start-Process -FilePath "$($driveLetter)\GoogleChromeEnterpriseBundle64.zip\Installers\GoogleChromeStandaloneEnterprise64.msi" -ArgumentList "/quiet" -wait #works
    }
    else
    {
        Start-Process -FilePath "$($driveLetter)\GoogleChromeEnterpriseBundle.zip\Installers\GoogleChromeStandaloneEnterprise.msi" -ArgumentList "/passive" -wait #works
    }
}
if ($resultInstall[1] -eq 1)
{
    Start-Process -FilePath "$($driveLetter)\Firefox Setup 68.0" -ArgumentList "/s" -wait #works
}
if ($resultInstall[2] -eq 1)
{
    if ([Environment]::Is64BitOperatingSystem) #not silent bc having difficulty and you dont have to click thru anything anyway #works
    {
        Start-Process -FilePath "$($driveLetter)\Symantec\SEP_WIN64BIT\setup.exe" -wait
    }
    else
    {
        Start-Process -FilePath "$($driveLetter)\Symantec\SEP_WIN32BIT\setup.exe" -wait
    }
}
if ($resultInstall[3] -eq 1)
{
    if ([Environment]::Is64BitOperatingSystem)
    {
        copy-item "$($driveLetter)\Office2019" -destination "C:\" -recurse
        Start-Process -FilePath "C:\Office2019\Install Office 2019.cmd" -wait #works
        remove-item -path C:\Office2019 -force
    }
    else
    {
        Start-Process -FilePath "$($driveLetter)\Office2016\32-bit\SW_DVD5_Office_Professional_Plus_2016_W32_English_MLF_X20-41353\setup.exe" -verb runas -wait #works
        #customized in Updates folder to run silently
    }
}
if ($resultInstall[4] -eq 1)
{
    Start-Process -FilePath "$($driveLetter)\Spirion-Windows-Installer.msi" -ArgumentList "/quiet" -wait #test
}




write-host "Setup complete. Please make sure Windows Updates, Microsoft Office, etc. are finished installing before restarting the computer."
}
