@echo Off&COLOR 0B&setlocal enabledelayedexpansion
set Options=%1
IF /I !Options!==ProgramName (
    set ProgramName=%~2
    title !ProgramName!
)
OPENFILES>NUL 2>&1
IF "!ERRORLEVEL!"=="1" goto GetAdmin
::====================================================================================
cls
set Install_Mode=%2
set CrackActivation=%3
set DATARestore=%4
set AnyDeskRestore=%5
set PCName=%6
set WindowsLicense=%7
::====================================================================================
IF /I !Options!==RE-Install_Optimize (
    IF /I !Install_Mode!==Normal_Install (
        IF /I !DATARestore!==DATARestore (
            call :RestoreUserData
        )
        IF /I !AnyDeskRestore!==AnyDeskRestore (
            robocopy "D:\Backup\AnyDesk" "!ProgramData!\AnyDesk" /mir /mt:128 /r:10 /w:3
        )
    )
    call :Install
    IF /I !Install_Mode! NEQ Normal_Install (
        call :Zack_Normal_Install
    )
    goto END
) else IF /I !Options!==mpv_PlayKit_Update (
    call :mpvUpdate
    pause
) else IF /I !Options!==mpv_PlayKit_Backup (
    call :mpvBackup
    pause
) else IF /I !Options!==DATABackup (
    call :DATABackup
    pause
) else IF /I !Options!==Zack_DATABackup (
    call :Zack_DATABackup
    pause
)
exit

::====================================UI優化=========================================
:Install

DISM /Online /Add-Capability /CapabilityName:WMIC
REG add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability /v TimeStampInterval /f /t REG_DWORD /d 0
REG add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management" /v DisablePagingExecutive /f /t REG_DWORD /d 1
REG add HKLM\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides /v 735209102 /t REG_DWORD /d 1 /f
REG add HKLM\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides /v 1853569164 /t REG_DWORD /d 1 /f
REG add HKLM\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides /v 156965516 /t REG_DWORD /d 1 /f
schtasks /delete /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /f
schtasks /delete /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /f
schtasks /delete /tn "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /f
schtasks /delete /tn "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /f
schtasks /delete /tn "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /f
schtasks /delete /tn "Microsoft\Windows\Windows Defender\Windows Defender Verification" /f
schtasks /change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /disable
wmic.exe /namespace:\\root\default Path SystemRestore Call Disable C:\
bcdedit /set {bootmgr} timeout 0
SC config SysMain start= disabled
SC config DusmSvc start= disabled
SC config Spooler start= disabled
sc config CryptSvc start= disabled
sc config stisvc start= disabled
sc config WerSvc start= disabled
sc config ShellHWDetection start= disabled
sc config iphlpsvc start= disabled
sc config TrkWks start= disabled
sc config WdiServiceHost start= disabled
sc config WdiSystemHost start= disabled
sc config DPS start= disabled
sc config CscService start= disabled
!windir!\System32\OneDriveSetup.exe /uninstall
echo.
echo.
echo UI優化完成

::==================================Install==========================================

For %%P In (%~dp0..\Setup\VisualCppRedistAIO\*.*) do (
    call "%%P" /y
)
For %%P In (%~dp0..\Setup\Inno\*.*) do (
    call "%%P" /silent
)
For %%P In (%~dp0..\Setup\MSI\*.*) do (
    call "%%P" /passive /norestart
)
For %%P In (%~dp0..\Setup\NSIS\*.*) do (
    call "%%P" /S
)
For %%P In (%~dp0..\Setup\*.exe) do (
    start /min %%P
)
::==================================CrackActivation=====================================

regedit /s %~dp0\winrar-Settings.reg
IF /I !CrackActivation!==CrackActivation (    
    echo RAR registration data>"!ProgramFiles!\WinRAR\rarreg.key"
    echo SeVeN>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo Unlimited Company License>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo UID=000de082d4cb7aeb3e71>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo 64122122503e71057c0ffe5fed5dcbb0032f2d3c5fd42bb05edfe0>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo 6501b129e6e067e3819160fce6cb5ffde62890079861be57638717>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo 7131ced835ed65cc743d9777f2ea71a8e32c7e593cf66794343565>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo b41bcf56929486b8bcdac33d50ecf77399603fc518f2701b607304>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo 9b712761e333304a99485f38f292bc89b78036ec4c0faa35b6c3d6>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo df05d84217aef4abd0b675d3309b94f4be9c9cae1734784060e0c7>>"!ProgramFiles!\WinRAR\rarreg.key"
    echo ef6e1deace43f1671ef3ef6d863944c13f3fc13a20f21488793187>>"!ProgramFiles!\WinRAR\rarreg.key"
    IF not exist "!ProgramFiles!\Microsoft Office" (
        echo.
        echo 檢測到未安裝Office請先安裝
        pause
    )
    IF /I !WindowsLicense!==Windows已啟用 (
        powershell -Command "& ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook"
    ) else ( 
        powershell -Command "& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID /Ohook"
    )
    
)

::====================================================================================
call :mpvUpdate
IF not exist "!ProgramFiles!\Google\Chrome" (
    IF exist !temp!\Google_Chrome rd /s /q !temp!\Google_Chrome
    md !temp!\Google_Chrome
    echo Set o=CreateObject^("MSXML2.XMLHTTP"^):Set a=CreateObject^("ADODB.Stream"^):Set f=Createobject^("Scripting.FileSystemObject"^):o.open "GET", "https://dl.google.com/chrome/install/chrome_installer.exe", 0:o.send^(^):If o.Status=200 Then >!temp!\Google_Chrome\Install.vbs 
    echo a.Open:a.Type=1:a.Write o.ResponseBody:a.Position=0 >>!temp!\Google_Chrome\Install.vbs 
    echo a.SaveToFile "!temp!\Google_Chrome\Install.exe" >>!temp!\Google_Chrome/Install.vbs
    echo End if >>!temp!\Google_Chrome/Install.vbs
    cscript //b !temp!\Google_Chrome/Install.vbs
    call !temp!\Google_Chrome\Install.exe
    rd /s /q !temp!\Google_Chrome
)
xcopy /s /y %~dp0\windir !windir!
echo.
echo.
echo 程式安裝完成

::====================================UX優化=========================================

REG add HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\Parameters /v srvcomment /t REG_SZ /d !PCName! /f
REG add HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName /v ComputerName /t REG_SZ /d !PCName! /f
REG add HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName /v ComputerName /t REG_SZ /d !PCName! /f
REG add HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters /v "NV Hostname" /t REG_SZ /d !PCName! /f
REG add HKLM\System\CurrentControlSet\Services\Tcpip\Parameters /v Hostname /t REG_SZ /d !PCName! /f
REG add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarAl /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarDa /t REG_DWORD /d 0 /f
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowTaskViewButton /t REG_DWORD /d 0 /f
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSecondsInSystemClock /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v ColorPrevalence /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarGlomLevel /t REG_DWORD /d 2 /f
REG add HKCU\Software\Microsoft\Office\16.0\Excel\Security\ProtectedView /v DisableAttachmentsInPV /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Office\16.0\Excel\Security\ProtectedView /v DisableInternetFilesInPV /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Office\16.0\Excel\Security\ProtectedView /v DisableUnsafeLocationsInPV /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Office\16.0\Word\Security\ProtectedView /v DisableAttachmentsInPV /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Office\16.0\Word\Security\ProtectedView /v DisableInternetFilesInPV /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Office\16.0\Word\Security\ProtectedView /v DisableUnsafeLocationsInPV /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Office\16.0\PowerPoint\Security\ProtectedView /v DisableAttachmentsInPV /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Office\16.0\PowerPoint\Security\ProtectedView /v DisableInternetFilesInPV /t REG_DWORD /d 1 /f
REG add HKCU\Software\Microsoft\Office\16.0\PowerPoint\Security\ProtectedView /v DisableUnsafeLocationsInPV /t REG_DWORD /d 1 /f
REG add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowHibernateOption /t REG_DWORD /d 1 /f
REG add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowSleepOption /t REG_DWORD /d 0 /f
REG add HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB /v ACSettingIndex /t REG_DWORD /d 2 /f
REG add "HKCU\Software\Microsoft\Windows Photo Viewer\Viewer" /v BackgroundColor /t REG_DWORD /d 4278190080 /f
REG add HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32 /ve /f
REG add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /d !windir!\system32\imageres.dll,197 /t reg_sz /f 
REG add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 77 /d !windir!\system32\imageres.dll,197 /t reg_sz /f 
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges\Range1" /v "*" /t REG_DWORD /d 1 /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges\Range1" /v ":Range" /t REG_SZ /d "192.168.*.*" /f
REG ADD "HKCU\Software\Microsoft\Command Processor" /v DisableUNCCheck /t REG_DWORD /d 1 /f
attrib -s -r -h !LocalAppData!\iconcache.db
del /f /q !LocalAppData!\iconcache.db  
NetSh advfirewall set allprofiles state off
powercfg /x monitor-timeout-ac 15
powercfg /x -standby-timeout-ac 0
powercfg /x -disk-timeout-ac 0
call %~dp0\SystemVisualEffects.exe
IF /I !Install_Mode! NEQ Zack_Install (
    regedit /s %~dp0\PotPlayerMini64.reg
)
IF /I !Install_Mode! NEQ Zack_Normal_Install (
    xcopy /s /y %~dp0\Themes !windir!\Resources\Themes
    start !windir!\Resources\Themes\Anime.theme
    timeout /t 3 /nobreak
    taskkill /im systemsettings.exe /f
)
echo.
echo.
echo UX優化完成
goto :eof

::================================Zack_Normal_Install====================================
:Zack_Normal_Install

IF /I !DATARestore!==DATARestore call :RestoreZackData
IF /I !AnyDeskRestore!==AnyDeskRestore (
    robocopy "D:\Backup\AnyDesk\!PCName!" "!ProgramData!\AnyDesk" /mir /mt:128 /r:10 /w:3
)
For %%P In (%~dp0..\Zack\Setup\Inno\*.*) do (
    call "%%P" /silent
)
For %%P In (%~dp0..\Zack\Setup\NSIS\*.*) do (
    call "%%P" /S
)
For %%P In (%~dp0..\Setup\MSI\*.*) do (
    call "%%P" /passive /norestart
)
IF /I !Install_Mode!==Zack_Install (
    call :Zack_Install
)
goto :eof

::==================================Zack_Install==========================================
:Zack_Install

For %%P In (%~dp0..\Zack\Setup\*.exe) do (
    start %%P
)
for /f "delims=" %%F in ('dir /ad /b "%~dp0..\Zack\ProgramFiles"') do (
    set FolderName=%%F
    robocopy "%~dp0..\Zack\ProgramFiles\!FolderName!" "!ProgramFiles!\!FolderName!" /mir /mt:128 /r:10 /w:3
    takeown /r /d y /f "!ProgramFiles!\!FolderName!" 
    icacls "!ProgramFiles!\!FolderName!" /t /grant administrators:F
)
for /f "delims=" %%F in ('dir /ad /b "%~dp0..\Zack\C"') do (
    set FolderName=%%F
    robocopy "%~dp0..\Zack\C\!FolderName!" "C:\!FolderName!" /mir /mt:128 /r:10 /w:3
    takeown /r /d y /f "C:\!FolderName!" 
    icacls "C:\!FolderName!" /t /grant administrators:F
)
xcopy /s /y %~dp0..\Zack\Desktop C:\Users\!Username!\Desktop
xcopy /s /y %~dp0..\Zack\AppData !AppData!
regedit /s %~dp0..\Zack\ZackPotPlayerMini64.reg
start /d "!ProgramFiles!\Locale Emulator" LEInstaller.exe
goto :eof

::===================================DATABackup=======================================
:DATABackup

set /P AnyDeskBackup=AnyDesk Backup? (輸入Y/N繼續):
robocopy "C:\Users\!Username!\Desktop" "D:\Backup\桌面" /mir /mt:128 /r:10 /w:3
robocopy "C:\Users\!Username!\Downloads" "D:\Backup\下載" /mir /mt:128 /r:10 /w:3
robocopy "C:\Users\!Username!\Documents" "D:\Backup\文件" /mir /mt:128 /r:10 /w:3
robocopy "C:\Users\!Username!\Pictures" "D:\Backup\照片" /mir /mt:128 /r:10 /w:3
robocopy "C:\Users\!Username!\Videos" "D:\Backup\影片" /mir /mt:128 /r:10 /w:3
robocopy "C:\Users\!Username!\Music" "D:\Backup\音樂" /mir /mt:128 /r:10 /w:3
IF /I !AnyDeskBackup!==Y (
    robocopy "!ProgramData!\AnyDesk" "D:\Backup\AnyDesk" /mir /mt:128 /r:10 /w:3
)
goto :eof

::================================mpv_PlayKit_Update====================================
:mpvUpdate

for /f "delims=" %%F in ('dir /ad /b "%~dp0\ProgramFiles"') do (
    set FolderName=%%F
    robocopy "%~dp0\ProgramFiles\!FolderName!" "!ProgramFiles!\!FolderName!" /mir /mt:128 /r:10 /w:3
    takeown /r /d y /f "!ProgramFiles!\!FolderName!" 
    icacls "!ProgramFiles!\!FolderName!" /t /grant administrators:F
)
xcopy /s /y %~dp0\Desktop C:\Users\!Username!\Desktop
goto :eof

::================================mpv_PlayKit_Backup====================================
:mpvBackup

rd /s /q "!ProgramFiles!\mpv_PlayKit\portable_config\_cache"
robocopy "!ProgramFiles!\mpv_PlayKit" "%~dp0ProgramFiles\mpv_PlayKit" /mir /mt:128 /r:10 /w:3
rd /s /q "%~dp0ProgramFiles\mpv_PlayKit\.git"
del /f /q "%~dp0ProgramFiles\mpv_PlayKit\.gitignore"
goto :eof

::==================================ZackDATABackup=====================================
:Zack_DATABackup
set /P AnyDeskBackup=AnyDesk Backup? (輸入Y/N繼續)
IF /I !AnyDeskBackup!==Y (
    robocopy "!ProgramData!\AnyDesk" "D:\Backup\AnyDesk\!computername!" /mir /mt:128 /r:10 /w:3
)
robocopy "C:\Users\!Username!\Desktop" "D:\Backup\桌面" /mir /mt:128 /r:10 /w:3
::robocopy "C:\Users\!Username!\Downloads" "D:\Backup\下載" /mir /mt:128 /r:10 /w:3
::robocopy "C:\Users\!Username!\Documents" "D:\Backup\文件" /mir /mt:128 /r:10 /w:3
::robocopy "C:\Users\!Username!\Pictures" "D:\Backup\照片" /mir /mt:128 /r:10 /w:3
::robocopy "C:\Users\!Username!\Videos" "D:\Backup\影片" /mir /mt:128 /r:10 /w:3
::robocopy "C:\Users\!Username!\Music" "D:\Backup\音樂" /mir /mt:128 /r:10 /w:3
goto :eof

::====================================================================================
:RestoreZackData

start /min robocopy "D:\Backup\桌面" "C:\Users\!Username!\Desktop" /s /mt:128 /r:10 /w:3
::start /min robocopy "D:\Backup\下載" "C:\Users\!Username!\Downloads" /s /mt:128 /r:10 /w:3
::start /min robocopy "D:\Backup\文件" "C:\Users\!Username!\Documents" /s /mt:128 /r:10 /w:3
::start /min robocopy "D:\Backup\照片" "C:\Users\!Username!\Pictures" /s /mt:128 /r:10 /w:3
::start /min robocopy "D:\Backup\影片" "C:\Users\!Username!\Videos" /s /mt:128 /r:10 /w:3
::start /min robocopy "D:\Backup\音樂" "C:\Users\!Username!\Music" /s /mt:128 /r:10 /w:3
goto :eof

::====================================================================================
::RestoreUserData

start /min robocopy "D:\Backup\桌面" "C:\Users\!Username!\Desktop" /s /mt:128 /r:10 /w:3
start /min robocopy "D:\Backup\下載" "C:\Users\!Username!\Downloads" /s /mt:128 /r:10 /w:3
start /min robocopy "D:\Backup\文件" "C:\Users\!Username!\Documents" /s /mt:128 /r:10 /w:3
start /min robocopy "D:\Backup\照片" "C:\Users\!Username!\Pictures" /s /mt:128 /r:10 /w:3
start /min robocopy "D:\Backup\影片" "C:\Users\!Username!\Videos" /s /mt:128 /r:10 /w:3
start /min robocopy "D:\Backup\音樂" "C:\Users\!Username!\Music" /s /mt:128 /r:10 /w:3
goto :eof


::====================================================================================
:END

taskkill /f /im explorer.exe
timeout /t 2 /nobreak
start explorer.exe
pause
goto :eof

::====================================================================================
:GetAdmin

echo Set UAC = CreateObject^("Shell.Application"^) >!temp!\getadmin.vbs
echo UAC.ShellExecute "%~fs0", "", "", "runas", 1 >>!temp!\getadmin.vbs
!temp!\getadmin.vbs
del /f /q !temp!\getadmin.vbs
exit /b

::====================================================================================