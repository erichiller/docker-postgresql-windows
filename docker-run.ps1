Start-Service PostgreSQL ; Get-EventLog -LogName System -After (Get-Date).AddHours(-1) | Format-List ; $idx = (get-eventlog -LogName System -Newest 1).Index ; while($true){ start-sleep -Seconds 1 ; $idx2 = (Get-EventLog -LogName System -newest 1).index ; get-eventlog -logname system -newest ($idx2 - $idx) | Sort-Object index | Format-List ; $idx = $idx2 ; } ;