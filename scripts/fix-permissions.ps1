
$path = "C:\ProgramData\docker\volumes\";
$goodACL = get-acl (join-path $path d1d43f459c5436ce39c8f821ff0d89329b9fcdaf337f6b13071451ca84827d90);
Get-ChildItem -Path $path | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-4)} | ForEach-Object {
    $goodACL | set-acl -path $_.FullName
    rmdir $_.FullName -Recurse
}