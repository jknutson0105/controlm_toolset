#! /bin/pwsh
param ([int] $myversion=9, [int] $myrelease=20, [int] $fixpack)
#NOTE: Do not forget to change the versions
# This is to run as see if the user isLocalAdmin
# Comment next line if no debug information is required
Set-PSDebug -Trace 1

#From <https://www.red-gate.com/simple-talk/sysadmin/powershell/how-to-use-parameters-in-powershell/>
#param ([int] $myversion=9, [int] $myrelease=20, [int] $fixpack)

If($isWindows) {
    $outpath = $env:TEMP+"\padev_current.exe"
    $thisOS = "Windows"
    $thisArch="windows_x86_64"
    $thisExt=".exe"
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if(-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        write-host "This needs to be executed by an administrator. Exiting (rc=99)."
        exit 99
    }
}

If($isLinux) {
    $outpath = "/tmp/padev_current.exe"
    $thisOS = "Unix"
    $thisArch="Linux-x86_64"
    $thisExt="_INSTALL.BIN"
}

if ($fixpack -eq $null) {
    write-host "Please enter a fix pack. Assuming $myversion.$myrelease. Exiting (rc=42)."
    exit 42
} else {
    $fix = "{0:d3}" -f $fixpack
    $file_to_download="PADEV.$myversion.0.$myrelease.$fixpack"+"_"+$thisArch+$thisExt
    $url = "https://controlm-appdev.s3-us-west-2.amazonaws.com/release/v"+$myversion+"."+$myrelease+"."+$fix+"/output/"+$thisOS+"/"+$file_to_download
        #https://controlm-appdev.s3-us-west-2.amazonaws.com/release/v9.20.200/output/Windows/PADEV.9.0.20.200_windows_x86_64.exe
    write-host "Downloading from $url"
    Invoke-WebRequest -Uri $url -OutFile $outpath -SkipCertificateCheck
    write-host "Downloaded from $url"
    chmod 755 $outpath
    write-host "Starting installation of $outpath"
    Start-Process -Wait -Filepath "$outpath" -ArgumentList "-s -v"
    write-host "Completed installation of $outpath"
    <# comments
        multilines
        # Start-Process -Filepath "$outpath" -ArgumentList "-s -v" -wait
    #>
}
# Debuggone
Set-PSDebug -Trace 0
exit 0
