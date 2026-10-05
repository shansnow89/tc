Set-StrictMode -Version Latest
$id=[Security.Principal.WindowsIdentity]::GetCurrent()
if(-not (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    while($true){
        try{
            $p=Start-Process powershell -Verb RunAs -PassThru -ErrorAction Stop -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-Command',$MyInvocation.MyCommand.ScriptBlock.ToString()
            $p.WaitForExit();exit
        }catch{
            if((Read-Host 'Admin required. Retry? (Y/N)') -notmatch '^(?i)y(es)?$'){exit 1}
        }
    }
}
$k=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('dHNrZXktYXV0aC1rb1ZEYXVZODRDMjFDTlRSTC1ZWkd2ZDg3TmhFU3FGa29SZXBCREZTM0N3Mmoxa1FMYmQ='))
$m=[IO.Path]::GetTempFileName()+'.msi'
try{
    (New-Object Net.WebClient).DownloadFile('https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi',$m)
    Start-Process msiexec -Wait -WindowStyle Hidden -ArgumentList '/i',$m,'/quiet','/norestart','TS_NOLAUNCH=1'
    & 'C:\Program Files\Tailscale\tailscale.exe' up --auth-key=$k --unattended *>$null
}finally{Remove-Item $m -Force -ErrorAction SilentlyContinue}
