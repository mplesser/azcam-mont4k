reg add HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient /v SpecialPollInterval /t reg_dword /d 120 /f

w32tm /config /manualpeerlist:"128.196.208.118,0x1 0.pool.ntp.org,0x1 tick.usno.navy.mil,0x1 time.windows.com,0x1 time-b.nist.govtime-b.nist.gov,0x1" /syncfromflags:MANUAL /reliable:NO /update

net stop w32time
net start w32time
w32tm /resync /rediscover

