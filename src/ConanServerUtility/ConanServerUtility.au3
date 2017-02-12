#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\resources\favicon.ico
#AutoIt3Wrapper_Outfile=..\..\build\ConanServerUtility_x86_v2.7.exe
#AutoIt3Wrapper_Outfile_x64=..\..\build\ConanServerUtility_x64_v2.7.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=By Dateranoth - Feburary 11, 2017
#AutoIt3Wrapper_Res_Description=Utility for Running Conan Server
#AutoIt3Wrapper_Res_Fileversion=2.7.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Dateranoth @ https://gamercide.com
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;Originally written by Dateranoth for use
;by https://gamercide.com on their server
;Distributed Under GNU GENERAL PUBLIC LICENSE

Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
#include <Date.au3>
#include <Process.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>

Global $mNextCheck = _NowCalc()
Global $timeCheck1 = _NowCalc()
Global $timeCheck2 = _NowCalc
Global $sFile = ""
Global $Server_EXE = "ConanSandboxServer-Win64-Test.exe"
Global $PIDFile = @ScriptDir & "\ConanServerUtility_lastpid_tmp"
Global $hWndFile = @ScriptDir & "\ConanServerUtility_lasthwnd_tmp"
Global $logFile = @ScriptDir & "\ConanServerUtility.log"
Global $logStartTime = _NowCalc()
Global $iniFile = @ScriptDir & "\ConanServerUtility.ini"
Global $iniFail = 0

If FileExists($PIDFile) Then
	Global $ConanPID = FileRead($PIDFile)
Else
	Global $ConanPID = "0"
EndIf
If FileExists($hWndFile) Then
	Global $ConanhWnd = HWnd(FileRead($hWndFile))
Else
	Global $ConanhWnd = "0"
EndIf
FileWriteLine($logFile, _NowCalc() & " ConanServerUtility Script Started")

;User Variables
Func ReadUini()
	Local $iniCheck = ""
	Local $aChar[3]
	For $i = 1 To 13
		$aChar[0] = Chr(Random(97, 122, 1)) ;a-z
		$aChar[1] = Chr(Random(48, 57, 1)) ;0-9
		$iniCheck &= $aChar[Random(0, 1, 1)]
	Next

	Global $BindIP = IniRead($iniFile, "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", $iniCheck)
	Global $g_IP = IniRead($iniFile, "Game Server IP", "ListenIP", $iniCheck)
	Global $GamePort = IniRead($iniFile, "Game Server Port", "GamePort", $iniCheck)
	Global $QueryPort = IniRead($iniFile, "Steam Query Port", "QueryPort", $iniCheck)
	Global $ServerName = IniRead($iniFile, "Server Name", "ServerName", $iniCheck)
	Global $ServerPass = IniRead($iniFile, "Server Password", "ServerPass", $iniCheck)
	Global $AdminPass = IniRead($iniFile, "Admin Password", "AdminPass", $iniCheck)
	Global $MaxPlayers = IniRead($iniFile, "Max Players", "MaxPlayers", $iniCheck)
	Global $serverdir = IniRead($iniFile, "Server Directory. NO TRAILING SLASH", "serverdir", $iniCheck)
	Global $UseSteamCMD = IniRead($iniFile, "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", $iniCheck)
	Global $steamcmddir = IniRead($iniFile, "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", $iniCheck)
	Global $validategame = IniRead($iniFile, "Validate Files Every Time SteamCMD Runs? yes/no", "validategame", $iniCheck)
	Global $UseRemoteRestart = IniRead($iniFile, "Use Remote Restart ?yes/no", "UseRemoteRestart", $iniCheck)
	Global $g_Port = IniRead($iniFile, "Remote Restart Port", "ListenPort", $iniCheck)
	Global $RestartCode = IniRead($iniFile, "Remote Restart Password", "RestartCode", $iniCheck)
	Global $RestartDaily = IniRead($iniFile, "Restart Server Daily? yes/no", "RestartDaily", $iniCheck)
	Global $CheckForUpdate = IniRead($iniFile, "Check for Update Every X Minutes? yes/no", "CheckForUpdate", $iniCheck)
	Global $UpdateInterval = IniRead($iniFile, "Update Check Interval in Minutes 05-59", "UpdateInterval", $iniCheck)
	Global $HotHour1 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour1", $iniCheck)
	Global $HotHour2 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour2", $iniCheck)
	Global $HotHour3 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour3", $iniCheck)
	Global $HotHour4 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour4", $iniCheck)
	Global $HotHour5 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour5", $iniCheck)
	Global $HotHour6 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour6", $iniCheck)
	Global $HotMin = IniRead($iniFile, "Daily Restart Minute? 00-59", "HotMin", $iniCheck)
	Global $ExMem = IniRead($iniFile, "Excessive Memory Amount?", "ExMem", $iniCheck)
	Global $ExMemRestart = IniRead($iniFile, "Restart On Excessive Memory Use? yes/no", "ExMemRestart", $iniCheck)
	Global $SteamFix = IniRead($iniFile, "Running Server with Steam Open? (yes/no)", "SteamFix", $iniCheck)
	Global $logRotate = IniRead($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logRotate", $iniCheck)
	Global $logQuantity = IniRead($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logQuantity", $iniCheck)
	Global $logHoursBetweenRotate = IniRead($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logHoursBetweenRotate", $iniCheck)

	If $iniCheck = $BindIP Then
		$BindIP = "yes"
		$iniFail += 1
	EndIf
	If $iniCheck = $g_IP Then
		$g_IP = "127.0.0.1"
		$iniFail += 1
	EndIf
	If $iniCheck = $GamePort Then
		$GamePort = "7777"
		$iniFail += 1
	EndIf
	If $iniCheck = $QueryPort Then
		$QueryPort = "27015"
		$iniFail += 1
	EndIf
	If $iniCheck = $ServerName Then
		$ServerName = "Conan Server Utility Server"
		$iniFail += 1
	EndIf
	If $iniCheck = $ServerPass Then
		$ServerPass = ""
		$iniFail += 1
	EndIf
	If $iniCheck = $AdminPass Then
		$AdminPass &= "_noHASHsymbol"
		$iniFail += 1
	EndIf
	If $iniCheck = $MaxPlayers Then
		$MaxPlayers = "20"
		$iniFail += 1
	EndIf
	If $iniCheck = $serverdir Then
		$serverdir = "C:\Game_Servers\Conan_Exiles_Server"
		$iniFail += 1
	EndIf
	If $iniCheck = $UseSteamCMD Then
		$UseSteamCMD = "yes"
		$iniFail += 1
	EndIf
	If $iniCheck = $steamcmddir Then
		$steamcmddir = "C:\Game_Servers\SteamCMD"
		$iniFail += 1
	EndIf
	If $iniCheck = $validategame Then
		$validategame = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $UseRemoteRestart Then
		$UseRemoteRestart = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $g_Port Then
		$g_Port = "57520"
		$iniFail += 1
	EndIf
	If $iniCheck = $RestartCode Then
		$RestartCode &= "_yourcode"
		$iniFail += 1
	EndIf
	If $iniCheck = $RestartDaily Then
		$RestartDaily = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $CheckForUpdate Then
		$CheckForUpdate = "yes"
		$iniFail += 1
	ElseIf $CheckForUpdate = "yes" And $UseSteamCMD <> "yes" Then
		$CheckForUpdate = "no"
		FileWriteLine($logFile, _NowCalc() & " SteamCMD disabled. Disabling CheckForUpdate. Update will not work without SteamCMD to update it!")
	EndIf
	If $iniCheck = $UpdateInterval Then
		$UpdateInterval = "15"
		$iniFail += 1
	ElseIf $UpdateInterval < 5 Then
		$UpdateInterval = 5
	EndIf
	If $iniCheck = $HotHour1 Then
		$HotHour1 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour2 Then
		$HotHour2 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour3 Then
		$HotHour3 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour4 Then
		$HotHour4 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour5 Then
		$HotHour5 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour6 Then
		$HotHour6 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotMin Then
		$HotMin = "01"
		$iniFail += 1
	EndIf
	If $iniCheck = $ExMem Then
		$ExMem = "6000000000"
		$iniFail += 1
	EndIf
	If $iniCheck = $ExMemRestart Then
		$ExMemRestart = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $SteamFix Then
		$SteamFix = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $logRotate Then
		$logRotate = "yes"
		$iniFail += 1
	EndIf
	If $iniCheck = $logQuantity Then
		$logQuantity = "10"
		$iniFail += 1
	EndIf
	If $iniCheck = $logHoursBetweenRotate Then
		$logHoursBetweenRotate = "24"
		$iniFail += 1
	ElseIf $logHoursBetweenRotate < 1 Then
		$logHoursBetweenRotate = 1
	EndIf
	If $iniFail > 0 Then
		iniFileCheck()
	EndIf
EndFunc   ;==>ReadUini

Func iniFileCheck()
	If FileExists($iniFile) Then
		Local $aMyDate, $aMyTime
		_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
		Local $iniDate = StringFormat("%04i.%02i.%02i.%02i%02i", $aMyDate[1], $aMyDate[2], $aMyDate[3], $aMyTime[1], $aMyTime[2])
		FileMove($iniFile, $iniFile & "_" & $iniDate & ".bak", 1)
		UpdateIni()
		MsgBox(4096, "INI MISMATCH", "Found " & $iniFail & " Missing Variables" & @CRLF & @CRLF & "Backup created and all existing settings transfered to new INI." & @CRLF & @CRLF & "Modify INI and restart.")
		Exit
	Else
		UpdateIni()
		MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
		Exit
	EndIf
EndFunc   ;==>iniFileCheck

Func UpdateIni()
	IniWrite($iniFile, "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", $BindIP)
	IniWrite($iniFile, "Game Server IP", "ListenIP", $g_IP)
	IniWrite($iniFile, "Game Server Port", "GamePort", $GamePort)
	IniWrite($iniFile, "Steam Query Port", "QueryPort", $QueryPort)
	IniWrite($iniFile, "Server Name", "ServerName", $ServerName)
	IniWrite($iniFile, "Server Password", "ServerPass", $ServerPass)
	IniWrite($iniFile, "Admin Password", "AdminPass", $AdminPass)
	IniWrite($iniFile, "Max Players", "MaxPlayers", $MaxPlayers)
	IniWrite($iniFile, "Server Directory. NO TRAILING SLASH", "serverdir", $serverdir)
	IniWrite($iniFile, "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", $UseSteamCMD)
	IniWrite($iniFile, "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", $steamcmddir)
	IniWrite($iniFile, "Validate Files Every Time SteamCMD Runs? yes/no", "validategame", $validategame)
	IniWrite($iniFile, "Use Remote Restart ?yes/no", "UseRemoteRestart", $UseRemoteRestart)
	IniWrite($iniFile, "Remote Restart Port", "ListenPort", $g_Port)
	IniWrite($iniFile, "Remote Restart Password", "RestartCode", $RestartCode)
	IniWrite($iniFile, "Restart Server Daily? yes/no", "RestartDaily", $RestartDaily)
	IniWrite($iniFile, "Check for Update Every X Minutes? yes/no", "CheckForUpdate", $CheckForUpdate)
	IniWrite($iniFile, "Update Check Interval in Minutes 05-59", "UpdateInterval", $UpdateInterval)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour1", $HotHour1)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour2", $HotHour2)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour3", $HotHour3)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour4", $HotHour4)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour5", $HotHour5)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour6", $HotHour6)
	IniWrite($iniFile, "Daily Restart Minute? 00-59", "HotMin", $HotMin)
	IniWrite($iniFile, "Excessive Memory Amount?", "ExMem", $ExMem)
	IniWrite($iniFile, "Restart On Excessive Memory Use? yes/no", "ExMemRestart", $ExMemRestart)
	IniWrite($iniFile, "Running Server with Steam Open? (yes/no)", "SteamFix", $SteamFix)
	IniWrite($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logRotate", $logRotate)
	IniWrite($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logQuantity", $logQuantity)
	IniWrite($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logHoursBetweenRotate", $logHoursBetweenRotate)
EndFunc   ;==>UpdateIni

Func Gamercide()
	If @exitMethod <> 1 Then
		$Shutdown = MsgBox(4100, "Shut Down?", "Do you wish to shutdown Server " & $ServerName & "? (PID: " & $ConanPID & ")", 60)
		If $Shutdown = 6 Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Shutdown - Intiated by User when closing ConanServerUtility Script")
			CloseServer()
		EndIf
		MsgBox(4096, "Thanks for using our Application", "Please visit us at https://gamercide.com", 2)
		FileWriteLine($logFile, _NowCalc() & " ConanServerUtility Stopped by User")
	Else
		FileWriteLine($logFile, _NowCalc() & " ConanServerUtility Stopped")
	EndIf
	If $UseRemoteRestart = "yes" Then
		TCPShutdown()
	EndIf
	Exit
EndFunc   ;==>Gamercide

Func CloseServer()
	If WinExists($ConanhWnd) Then
		ControlSend($ConanhWnd, "", "", "I" & @CR)
		ControlSend($ConanhWnd, "", "", "I" & @CR)
		ControlSend($ConanhWnd, "", "", "^C")
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Window Found - Sending Ctrl+C for Clean Shutdown")
		WinWaitClose($ConanhWnd, "", 60)
	EndIf
	If ProcessExists($ConanPID) Then
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Did not Shut Down Properly. Killing Process")
		ProcessClose($ConanPID)
	EndIf
	If FileExists($PIDFile) Then
		FileDelete($PIDFile)
	EndIf
	If FileExists($hWndFile) Then
		FileDelete($hWndFile)
	EndIf
EndFunc   ;==>CloseServer

Func RotateLogs()
	For $i = $logQuantity To 1 Step -1
		ConsoleWrite($logFile & $i)
		ConsoleWrite(@CRLF)
		If FileExists($logFile & $i) Then
			FileMove($logFile & $i, $logFile & ($i + 1), 1)
		EndIf
	Next
	If FileExists($logFile & ($logQuantity + 1)) Then
		FileDelete($logFile & ($logQuantity + 1))
	EndIf
	If FileExists($logFile) Then
		FileMove($logFile, $logFile & "1", 1)
		FileWriteLine($logFile, _NowCalc() & " Log Files Rotated")
	EndIf
EndFunc   ;==>RotateLogs

Func GetRSS()
	Local $oXML = ObjCreate("Microsoft.XMLHTTP")
	$oXML.Open("GET", "http://steamcommunity.com/games/440900/rss/", 0)
	$oXML.Send

	$sFile = _TempFile(@ScriptDir, '~', '.xml')
	FileWrite($sFile, $oXML.responseText)
EndFunc   ;==>GetRSS

Func ParseRSS()
	$sXML = $sFile
	Local $oXML = ObjCreate("Microsoft.XMLDOM")
	$oXML.Load($sXML)
	Local $oNames = $oXML.selectNodes("//rss/channel/item/title")
	Local $aMyDate, $aMyTime
	_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
	Local $cDate = "PATCH " & StringFormat("%02i.%02i.%04i", $aMyDate[3], $aMyDate[2], $aMyDate[1])
	Local $cFile = @ScriptDir & "\ConanServerUtility_LastUpdate.txt"
	For $oName In $oNames

		If StringRegExp($oName.text, "(?i)" & $cDate & "(?i)") Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] - Update released today. Is the server up to date?")
			If FileRead($cFile) = $oName.text Then
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] - Server is Up to Date")
				ExitLoop
			Else
				FileDelete($cFile)
				FileWrite($cFile, $oName.text)
				If ProcessExists($ConanPID) Then
					FileWriteLine($logFile, _NowCalc() & " [" & $oName.text & "] Restart [" & $ServerName & " (PID: " & $ConanPID & ")] - Server is Out of Date - Requested by ConanServerUtility Script")
					CloseServer()
				EndIf
				ExitLoop
			EndIf
		EndIf
	Next
EndFunc   ;==>ParseRSS

Func UpdateCheck()
	FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] - Update Check Starting. Will Log if Update Found.")
	GetRSS()
	ParseRSS()
	If FileExists($sFile) Then
		FileDelete($sFile)
	EndIf
EndFunc   ;==>UpdateCheck

Func _TCP_Server_ClientIP($hSocket)
	Local $pSocketAddress, $aReturn
	$pSocketAddress = DllStructCreate("short;ushort;uint;char[8]")
	$aReturn = DllCall("ws2_32.dll", "int", "getpeername", "int", $hSocket, "ptr", DllStructGetPtr($pSocketAddress), "int*", DllStructGetSize($pSocketAddress))
	If @error Or $aReturn[0] <> 0 Then Return $hSocket
	$aReturn = DllCall("ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($pSocketAddress, 3))
	If @error Then Return $hSocket
	$pSocketAddress = 0
	Return $aReturn[0]
EndFunc   ;==>_TCP_Server_ClientIP

OnAutoItExitRegister("Gamercide")
ReadUini()

If $UseSteamCMD = "yes" Then
	Local $sFileExists = FileExists($steamcmddir & "\steamcmd.exe")
	If $sFileExists = 0 Then
		MsgBox(0x0, "SteamCMD Not Found", "Could not find steamcmd.exe at " & $steamcmddir)
		Exit
	EndIf
	Local $sManifestExists = FileExists($steamcmddir & "\steamapps\appmanifest_443030.acf")
	If $sManifestExists = 1 Then
		Local $manifestFound = MsgBox(4100, "Warning", "Install manifest found at " & $steamcmddir & "\steamapps\appmanifest_443030.acf" & @CRLF & @CRLF & "Suggest moving file to " & _
				$serverdir & "\steamapps\appmanifest_443030.acf before running SteamCMD" & @CRLF & @CRLF & "Would you like to Exit Now?", 20)
		If $manifestFound = 6 Then
			Exit
		EndIf
	EndIf
Else
	Local $cFileExists = FileExists($serverdir & "\ConanSandboxServer.exe")
	If $cFileExists = 0 Then
		MsgBox(0x0, "Conan Server Not Found", "Could not find ConanSandboxServer.exe at " & $serverdir)
		Exit
	EndIf
EndIf


If $UseRemoteRestart = "yes" Then
	; Start The TCP Services
	TCPStartup()
	Local $MainSocket = TCPListen($g_IP, $g_Port, 100)
	If $MainSocket = -1 Then
		MsgBox(0x0, "TCP Error", "Could not bind to [" & $g_IP & "] Check server IP or disable Remote Restart in INI")
		FileWriteLine($logFile, _NowCalc() & " Remote Restart Enabled. Could not bind to "& $g_IP &":"& $g_Port)
		Exit
	Else
		FileWriteLine($logFile, _NowCalc() & " Remote Restart Enabled. Listening for Restart Request at "& $g_IP &":"& $g_Port)
	Endif
EndIf

While True
	If $UseRemoteRestart = "yes" Then
		Local $ConnectedSocket = TCPAccept($MainSocket)
		If $ConnectedSocket >= 0 Then
			$Count = 0
			While $Count < 30
				$RECV = TCPRecv($ConnectedSocket, 512)
				$PassCompare = StringCompare($RECV, $RestartCode, 1)
				If $PassCompare = 0 Then
					If ProcessExists($ConanPID) Then
						Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
						Local $MEM = ProcessGetStats($ConanPID, 0)
						FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] --Work Memory:" & $MEM[0] & " --Peak Memory:" & $MEM[1] & " - Restart Requested by Remote Host: " & $IP)
						CloseServer()
						Sleep(10000)
						ExitLoop
					EndIf
				Else
					Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
					FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] - Restart ATTEMPT by Remote Host: " & $IP & " WRONG PASSWORD: " & $RECV)
					ExitLoop
				EndIf
				$Count += 1
				Sleep(1000)
			WEnd
			If $ConnectedSocket <> -1 Then TCPCloseSocket($ConnectedSocket)
		EndIf
	EndIf


	If Not ProcessExists($ConanPID) Then
		If $UseSteamCMD = "yes" Then
			If $validategame = "yes" Then
				FileWriteLine($logFile, _NowCalc() & " Running SteamCMD with validate. [steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 validate +quit]")
				RunWait("" & $steamcmddir & "\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 validate +quit")
			Else
				FileWriteLine($logFile, _NowCalc() & " Running SteamCMD without validate. [steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 +quit]")
				RunWait("" & $steamcmddir & "\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 +quit")
			EndIf
		EndIf
		If $CheckForUpdate = "yes" Then
			UpdateCheck()
		EndIf
		If $BindIP = "no" Then
			$ConanPID = Run("" & $serverdir & "\ConanSandbox\Binaries\Win64\" & $Server_EXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log")
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Started [" & $Server_EXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
		Else
			$ConanPID = Run("" & $serverdir & "\ConanSandbox\Binaries\Win64\" & $Server_EXE & "ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log")
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Started [" & $Server_EXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
		EndIf
		$ConanhWnd = WinGetHandle(WinWait("" & $serverdir & "", "", 70))
		If $SteamFix = "yes" Then
			WinWait("" & $Server_EXE & " - Entry Point Not Found", "", 5)
			If WinExists("" & $Server_EXE & " - Entry Point Not Found") Then
				ControlSend("" & $Server_EXE & " - Entry Point Not Found", "", "", "{enter}")
			EndIf
			WinWait("" & $Server_EXE & " - Entry Point Not Found", "", 5)
			If WinExists("" & $Server_EXE & " - Entry Point Not Found") Then
				ControlSend("" & $Server_EXE & " - Entry Point Not Found", "", "", "{enter}")
			EndIf
		EndIf
		If FileExists($PIDFile) Then
			FileDelete($PIDFile)
		EndIf
		If FileExists($hWndFile) Then
			FileDelete($hWndFile)
		EndIf
		FileWrite($PIDFile, $ConanPID)
		FileWrite($hWndFile, String($ConanhWnd))
		FileSetAttrib($PIDFile, "+HT")
		FileSetAttrib($hWndFile, "+HT")
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Window Handle Found: " & $ConanhWnd)
	ElseIf ((_DateDiff('n', $timeCheck1, _NowCalc())) >= 5) Then
		Local $MEM = ProcessGetStats($ConanPID, 0)
		If $MEM[0] > $ExMem And $ExMemRestart = "no" Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] --Work Memory:" & $MEM[0] & " --Peak Memory:" & $MEM[1])
		ElseIf $MEM[0] > $ExMem And $ExMemRestart = "yes" Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] --Work Memory:" & $MEM[0] & " --Peak Memory:" & $MEM[1] & " Excessive Memory Use - Restart Requested by ConanServerUtility Script")
			CloseServer()
		EndIf
		$timeCheck1 = _NowCalc()
	EndIf

	If ((@HOUR = $HotHour1 Or @HOUR = $HotHour2 Or @HOUR = $HotHour3 Or @HOUR = $HotHour4 Or @HOUR = $HotHour5 Or @HOUR = $HotHour6) And @MIN = $HotMin And $RestartDaily = "yes" And ((_DateDiff('h', $timeCheck2, _NowCalc())) >= 1)) Then
		If ProcessExists($ConanPID) Then
			Local $MEM = ProcessGetStats($ConanPID, 0)
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] --Work Memory:" & $MEM[0] & " --Peak Memory:" & $MEM[1] & " - Daily Restart Requested by ConanServerUtility Script")
			CloseServer()
		EndIf
		$timeCheck2 = _NowCalc()
	EndIf

	If ($CheckForUpdate = "yes") And ((_DateDiff('n', $mNextCheck, _NowCalc())) >= $UpdateInterval) Then
		UpdateCheck()
		$mNextCheck = _NowCalc()
	EndIf

	If ($logRotate = "yes") And ((_DateDiff('h', $logStartTime, _NowCalc())) >= 1) Then
		If Not FileExists($logFile) Then
			FileWriteLine($logFile, $logStartTime & " Log File Created")
		EndIf
		Local $logFileTime = FileGetTime($logFile, 1)
		Local $logTimeSinceCreation = _DateDiff('h', $logFileTime[0] & "/" & $logFileTime[1] & "/" & $logFileTime[2] & " " & $logFileTime[3] & ":" & $logFileTime[4] & ":" & $logFileTime[5], _NowCalc())
		If $logTimeSinceCreation >= $logHoursBetweenRotate Then
			RotateLogs()
		EndIf
		$logStartTime = _NowCalc()
	EndIf

	Sleep(500)
WEnd
