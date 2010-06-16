; Script generated by the HM NIS Edit Script Wizard.

!addPluginDir "nsis_plugins"

; Use the 7zip-like compressor
SetCompress force
SetCompressor /SOLID /FINAL lzma


!include "springsettings.nsh"
!include "LogicLib.nsh"
!include "Sections.nsh"
!include "WordFunc.nsh"
!insertmacro VersionCompare

; HM NIS Edit Wizard helper defines
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\SpringClient.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "graphics\InstallerIcon.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "graphics\SideBanner.bmp"
;!define MUI_COMPONENTSPAGE_SMALLDESC ;puts description on the bottom, but much shorter.
!define MUI_COMPONENTSPAGE_TEXT_TOP "Some of these components must be downloaded during the install process."


; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Licensepage
!insertmacro MUI_PAGE_LICENSE "..\doc\gpl-2.0.txt"

; Components page
!insertmacro MUI_PAGE_COMPONENTS

; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page

!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\docs\main.html"
!define MUI_FINISHPAGE_RUN "$INSTDIR\springsettings.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Configure ${PRODUCT_NAME} settings now"
!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} version ${PRODUCT_VERSION} has been successfully installed or updated from a previous version.  You should configure Spring settings now if this is a fresh installation.  If you did not install spring to C:\Program Files\Spring you will need to point the settings program to the install location."

!define MUI_FINISHPAGE_LINK "The ${PRODUCT_NAME} website"
!define MUI_FINISHPAGE_LINK_LOCATION ${PRODUCT_WEB_SITE}
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

!define SP_OUTSUFFIX1 ""

; if present this should hold defines with custom mingwlibs location, etc.
!include /NONFATAL "custom_defines.nsi"


OutFile "${SP_BASENAME}${SP_OUTSUFFIX1}.exe"
InstallDir "$PROGRAMFILES\Spring"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
;ShowInstDetails show ;fix graphical glitch
;ShowUnInstDetails show ;fix graphical glitch

!include "include\echo.nsh"
!include "include\fileassoc.nsh"
!include "include\fileExistChecks.nsh"
!include "include\checkrunning.nsh"
!include "include\aiHelpers.nsh"


Function .onInit

	${!echonow} ""
	${!echonow} "Base dir:   <engine-source-root>/installer/"

	; Set default values for undefined vars
	!ifndef CONTENT_DIR
		!define CONTENT_DIR "..\cont"
	!endif
	${!defineifdirexists} CONTENT_DIR_EXISTS "${CONTENT_DIR}"
	!ifndef CONTENT_DIR_EXISTS
		!error "Could not find the content dir at '${CONTENT_DIR}', try setting CONTENT_DIR manually."
		!undef CONTENT_DIR_EXISTS
	!endif
	${!echonow} "Using CONTENT_DIR:   ${CONTENT_DIR}"

	!ifndef DOC_DIR
		!define DOC_DIR "..\doc"
	!endif
	${!defineifdirexists} DOC_DIR_EXISTS "${DOC_DIR}"
	!ifndef DOC_DIR_EXISTS
		!error "Could not find the documentation dir at '${DOC_DIR}', try setting DOC_DIR manually."
		!undef DOC_DIR_EXISTS
	!endif
	${!echonow} "Using DOC_DIR:       ${DOC_DIR}"

	!ifndef MINGWLIBS_DIR
		!define MINGWLIBS_DIR "..\mingwlibs"
	!endif
	${!defineifdirexists} MINGWLIBS_DIR_EXISTS "${MINGWLIBS_DIR}"
	!ifndef MINGWLIBS_DIR_EXISTS
		!error "Could not find the MinGW libraries dir at '${MINGWLIBS_DIR}', try setting MINGWLIBS_DIR manually."
		!undef MINGWLIBS_DIR_EXISTS
	!endif
	${!echonow} "Using MINGWLIBS_DIR: ${MINGWLIBS_DIR}"

	!ifndef BUILD_DIR
		!ifndef DIST_DIR
			!error "Neither BUILD_DIR nor DIST_DIR are defined. Define only one of the two, depending on whether you want to generate the installer from the install- or the build-directory."
		!endif
		${!defineifdirexists} DIST_DIR_EXISTS "${DIST_DIR}"
		!ifndef DIST_DIR_EXISTS
			!error "Could not find the distribution dir at '${DIST_DIR}'. Make sure you defined DIST_DIR correctly."
			!undef DIST_DIR_EXISTS
		!endif
		${!echonow} "Using DIST_DIR:      ${DIST_DIR}"
		!define BUILD_OR_DIST_DIR "${DIST_DIR}"
	!endif
	!ifdef BUILD_DIR
		!ifdef DIST_DIR
			!error "Both BUILD_DIR and DIST_DIR are defined. Define only one of the two, depending on whether you want to generate the installer from the install- or the build-directory."
		!endif
		${!defineifdirexists} BUILD_DIR_EXISTS "${BUILD_DIR}"
		!ifndef BUILD_DIR_EXISTS
			!error "Could not find the build dir at '${BUILD_DIR}'. Make sure you defined BUILD_DIR correctly."
			!undef BUILD_DIR_EXISTS
		!endif
		${!echonow} "Using BUILD_DIR:     ${BUILD_DIR}"
		; This allows us to easily use build products from an out of source build,
		; without the need to run 'make install'
		!define USE_BUILD_DIR
		!define BUILD_OR_DIST_DIR "${BUILD_DIR}"
	!endif

	${!echonow} ""

	!ifndef TEST_BUILD
		; check if we need to exit some processes which may be using unitsync
		call CheckTASClientRunning
		call CheckSpringDownloaderRunning
		call CheckCADownloaderRunning
		call CheckSpringLobbyRunning
		call CheckSpringSettingsRunning
	!endif

	; The core cannot be deselected
	${IfNot} ${FileExists} "$INSTDIR\spring.exe"
		!insertmacro SetSectionFlag 0 16 ; make the core section read only
	${EndIf}
FunctionEnd


Function GetDotNETVersion
	Push $0 ; Create variable 0 (version number).
	Push $1 ; Create variable 1 (error).

	; Request the version number from the Microsoft .NET Runtime Execution Engine DLL
	System::Call "mscoree::GetCORVersion(w .r0, i ${NSIS_MAX_STRLEN}, *i) i .r1 ?u"

	; If error, set "not found" as the top element of the stack. Otherwise, set the version number.
	StrCmp $1 "error" 0 +2 ; If variable 1 is equal to "error", continue, otherwise skip the next couple of lines.
	StrCpy $0 "not found"
	Pop $1 ; Remove variable 1 (error).
	Exch $0 ; Place variable  0 (version number) on top of the stack.
FunctionEnd

Function NoDotNet
	MessageBox MB_YESNO \
			"The .NET runtime library is not installed. v2.0 or newer is required for SpringDownloader. Do you wish to download and install it?" \
			IDYES true IDNO false
	true:
		inetc::get "http://springrts.com/dl/dotnetfx.exe" "$INSTDIR\dotnetfx.exe"
		ExecWait "$INSTDIR\dotnetfx.exe"
		Delete   "$INSTDIR\dotnetfx.exe"
		Goto next
	false:
	next:
FunctionEnd

Function OldDotNet
	MessageBox MB_YESNO \
			".NET runtime library v2.0 or newer is required for SpringDownloader. You have $0. Do you wish to download and install it?" \
			IDYES true IDNO false
	true:
		inetc::get \
				"http://springrts.com/dl/dotnetfx.exe" "$INSTDIR\dotnetfx.exe"
		ExecWait "$INSTDIR\dotnetfx.exe"
		Delete   "$INSTDIR\dotnetfx.exe"
		Goto next
	false:
	next:
FunctionEnd


SectionGroup /e "!Engine"
	Section "Main application (req)" SEC_MAIN

		!define INSTALL
			${!echonow} "Processing: main"
			!include "sections\main.nsh"
			${!echonow} "Processing: luaui"
			!include "sections\luaui.nsh"
		!undef INSTALL
	SectionEnd

	${!defineiffileexists} GML_BUILD_EXISTS "${BUILD_OR_DIST_DIR}\spring-mt.exe"
	!ifdef GML_BUILD_EXISTS
		Section "GML (multi-threaded)" SEC_GML
			${!echonow} "Processing: spring-mt.exe"
			SetOutPath "$INSTDIR"
			SetOverWrite on
			File "${BUILD_OR_DIST_DIR}\spring-mt.exe"
		SectionEnd
		!undef GML_BUILD_EXISTS
	!endif
SectionGroupEnd


SectionGroup "Multiplayer battlerooms"
	Section "SpringLobby" SEC_SPRINGLOBBY
	!define INSTALL
		${!echonow} "Processing section: springlobby"
		!include "sections\springlobby.nsh"
	!undef INSTALL
	SectionEnd

	Section "Content downloader and fast-join lobby" SEC_SPRINGDOWNLOADER
		!define INSTALL
			${!echonow} "Processing: springDownloader"
			!include "sections\springDownloader.nsh"
		!undef INSTALL
	SectionEnd
SectionGroupEnd


SectionGroup "Multiplayer lobby servers"
	Section "TASServer" SEC_TASSERVER
		!define INSTALL
			${!echonow} "Processing: TASServer"
			!include "sections\tasServer.nsh"
		!undef INSTALL
	SectionEnd
SectionGroupEnd

Section "Desktop shortcuts" SEC_DESKTOP
	${If} ${SectionIsSelected} ${SEC_SPRINGLOBBY}
		${!echonow} "Processing: springlobby shortcut"
		SetOutPath "$INSTDIR"
		CreateShortCut "$DESKTOP\SpringLobby.lnk" "$INSTDIR\springlobby.exe"
	${EndIf}
SectionEnd

SectionGroup "Tools"
	Section "Easy content installation" SEC_ARCHIVEMOVER
		!define INSTALL
			${!echonow} "Processing: archivemover"
			!include "sections\archivemover.nsh"
		!undef INSTALL
	SectionEnd

	Section "Selection Editor" SEC_SELECTIONEDITOR
		!define INSTALL
			${!echonow} "Processing: selectionEditor"
			!include "sections\selectionEditor.nsh"
		!undef INSTALL
	SectionEnd
SectionGroupEnd


Section "Start menu shortcuts" SEC_START
	!define INSTALL
		${!echonow} "Processing: shortcuts"
		!include "sections\shortcuts.nsh"
	!undef INSTALL
SectionEnd


SectionGroup "Skirmish AI plugins (Bots)"
	!insertmacro SkirmishAIInstSection "AAI"
	!insertmacro SkirmishAIInstSection "KAIK"
	!insertmacro SkirmishAIInstSection "RAI"
	!insertmacro SkirmishAIInstSection "E323AI"
SectionGroupEnd


!include "sections\sectiondesc.nsh"

Section -Documentation
	!define INSTALL
		${!echonow} "Processing: docs"
		!include "sections\docs.nsh"
	!undef INSTALL
SectionEnd

Section -Post
	${!echonow} "Processing: Registry entries"
	WriteUninstaller "$INSTDIR\uninst.exe"
	WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\springclient.exe"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\spring.exe"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


Function un.onUninstSuccess
	IfSilent +3
	HideWindow
	MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
	IfSilent +3
	MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
	Abort
FunctionEnd


Section Uninstall
	${!echonow} "Processing: Uninstall"

	!include "sections\main.nsh"

	Delete "$INSTDIR\spring-mt.exe"

	!include "sections\docs.nsh"
	!include "sections\shortcuts.nsh"
	!include "sections\archivemover.nsh"
	!include "sections\springDownloader.nsh"
	!include "sections\tasServer.nsh"
	!insertmacro DeleteSkirmishAI "AAI"
	!insertmacro DeleteSkirmishAI "KAIK"
	!insertmacro DeleteSkirmishAI "RAI"
	!insertmacro DeleteSkirmishAI "E323AI"
	!include "sections\springlobby.nsh"
	!include "sections\luaui.nsh"

	Delete "$DESKTOP\SpringLobby.lnk"

	; All done
	RMDir "$INSTDIR"

	DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
	DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
	SetAutoClose true
SectionEnd
