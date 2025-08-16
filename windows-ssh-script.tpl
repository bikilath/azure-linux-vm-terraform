Add-Content -Path "C:\Users\bikit\.ssh\config" -Value @"
Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
"@
