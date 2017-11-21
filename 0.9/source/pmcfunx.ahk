;===========================================
; Neverwinter Nights player map creator
; pmcfunx.ahk
; Author: Alundaio
; took ini/color functions for map-generator
;===========================================
;Updated Zip/Unzip and EmptyMem() functions for AHK_L

PROCESS_NAME := "NWN Map Creator"

;===========================================================-------------------------===========
;                                                                ReadLanguage()     <----------*****
;===========================================================-------------------------===========
ReadLanguage() {
  Global
/*
    IniRead, IniLangChoosen, language.ini, Languages, Choosen, ENGLISH
    
    IniRead, LogInAsDMText, language.ini, %IniLangChoosen%, LogInAsDMText, DM
    
    IniRead, CheckUpdateText, language.ini, %IniLangChoosen%, CheckUpdateText, Check for updates
    IniRead, ShowAboutText, language.ini, %IniLangChoosen%, ShowAboutText, About
*/
  Return
}
;===========================================================-------------------------===========
;                                                                ReadDCLConfig()     <----------*****
;===========================================================-------------------------===========
ReadConfig() {
  Global
    ;Main
    IniRead, VERSION, config.ini, Main, VERSION, 1
    IniRead, ExpertsMode, config.ini, Main, ExpertsMode, 0
    IniRead, DEBUG, config.ini, Main, DEBUG, 0
    
    IniRead, MWCX, config.ini, Main, MWCX, 510
    IniRead, MWCY, config.ini, Main, MWCY, 325
    IniRead, CWCX, config.ini, Main, CWCX, 875
    IniRead, CWCY, config.ini, Main, CWCY, 420
    
    IniRead, GuiRow, config.ini, Main, GuiRow, 10
    IniRead, SpawnsEnabled, config.ini, Main, SpawnsEnabled, 0
    
    ;Languages
    IniRead, Options, config.ini, Languages, Options, ENGLISH|GERMAN|
    IniRead, Choosen, config.ini, Languages, Choosen, ENGLISH
    
    ; Gui Options
    IniRead, FONT_STYLE, config.ini, Gui Options, Font_Style, 9
    IniRead, FONT_TYPE, config.ini, Gui Options, Font_Type, MS Sans SerIf
    IniRead, FONT_COLOR, config.ini, Gui Options, Font_Color, 000000
    IniRead, BACKGROUND_COLOR, config.ini, Gui Options, Background_Color, D4D0C8
    
    ;Options
    IniRead, NWN_DIR, config.ini, Main, NWN_DIR, C:\GOG Games\NWN Diamond
    IniRead, MAP_DIR, config.ini, Main, MAP_DIR, %A_WorkingDir%\maps
    IniRead, TRACK_INI, config.ini, Main, TRACK_INI, playertrack.ini
    
    IniRead, PlayerMap, config.ini, Main, PlayerMap, 1
    IniRead, CritterMap, config.ini, Main, CritterMap, 0
    IniRead, PlaceableMap, config.ini, Main, PlaceableMap, 0
    
    IniRead, CRITTER_INI, config.ini, Main, CRITTER_INI, C:\GOG Games\NWN Diamond
    IniRead, PLC_INI, config.ini, Main, PLC_INI, %A_Space%
    IniRead, AREA_INI, config.ini, Main, AREA_INI, C:\GOG Games\NWN Diamond
    
    ;Set Version
    IniWrite, %VERSION%, config.ini, Main, VERSION
  Return
}
;===========================================================-------------------------===========
;                                                                CreateDCLConfig()     <----------*****
;===========================================================-------------------------===========
CreateConfig() {
  Global
    ;Main
    IniWrite, %VERSION%, config.ini, Main, VERSION
    IniWrite, 0, config.ini, Main, ExpertsMode
    
    IniWrite, 510, config.ini, Main, MWCX
    IniWrite, 325, config.ini, Main, MWCY
    
    IniWrite, 8, config.ini, Main, GuiRow
    IniWrite, 0, config.ini, Main, SpawnsEnabled
    
    ;Languages
    IniWrite, ENGLISH|GERMAN, config.ini, Languages, Options
    IniWrite, ENGLISH, config.ini, Languages, Choosen
    
    ;Gui Options
    IniWrite, 9, config.ini, Gui Options, Font_Style
    IniWrite, MS Sans Serif, config.ini, Gui Options, Font_Type
    IniWrite, 000000, config.ini, Gui Options, Font_Color
    IniWrite, D4D0C8, config.ini, Gui Options, Background_Color
    
    ;Options
    IniWrite, C:\GOG Games\NWN Diamond, config.ini, Main, NWN_DIR
    IniWrite, %A_WorkingDir%\maps, config.ini, Main, MAP_DIR
    IniWrite, playertrack.ini, config.ini, Main, TRACK_INI
    
    IniWrite, 1, config.ini, Main, PlayerMap
    IniWrite, 0, config.ini, Main, CritterMap
    IniWrite, 0, config.ini, Main, PlaceableMap
    
    IniWrite, C:\GOG Games\NWN Diamond, config.ini, Main, CRITTER_INI
    IniWrite, %A_Space%, config.ini, Main, PLC_INI
    IniWrite, C:\GOG Games\NWN Diamond, config.ini, Main, AREA_INI
  Return
}
;============================================================-------------------------===========
;                                                                Read_Nwnplayer(Type) ===========
;============================================================-------------------------===========
Read_Nwnplayer() {
  Global
    ;IniRead, DMPassword, %NWN_DIR%\nwnplayer.ini, Server Options, DMPassword
    ;IniRead, ServerAdminPassword, %NWN_DIR%\nwnplayer.ini, Server Options, ServerAdminPassword
    ;IniRead, PlayerPassword, %NWN_DIR%\nwnplayer.ini, Server Options, PlayerPassword
    
    
  Return
}
;===========================================================-------------------------===========
;                                                             Dlg_Color(color,hGui)  <----------*****
;===========================================================-------------------------===========
Dlg_Color(ByRef Color, hGui=0){ 
  ;covert from rgb
    clr := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF)

    VarSetCapacity(CHOOSECOLOR, 0x24, 0), VarSetCapacity(CUSTOM, 64, 0)
     ,NumPut(0x24,    CHOOSECOLOR, 0)      ; DWORD lStructSize 
     ,NumPut(hGui,    CHOOSECOLOR, 4)      ; HWND hwndOwner (makes dialog "modal"). 
     ,NumPut(clr,    CHOOSECOLOR, 12)     ; clr.rgbResult 
     ,NumPut(&CUSTOM,  CHOOSECOLOR, 16)     ; COLORREF *lpCustColors
     ,NumPut(0x00000103,CHOOSECOLOR, 20)     ; Flag: CC_ANYCOLOR || CC_RGBINIT 

    nRC := DllCall("comdlg32\ChooseColorA", str, CHOOSECOLOR)  ; Display the dialog. 
    If (errorlevel <> 0) || (nRC = 0) 
       Return  false 

    clr := NumGet(CHOOSECOLOR, 12) 

    oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 

    ;convert to rgb 
    Color := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16) 
    StringTrimLeft, Color, Color, 2 
    Loop, % 6-strlen(Color) 
    Color=0%Color% 
    Color=%Color% 
    SetFormat, integer, %oldFormat% 
  Return true

}
;===================================================================-------------------------------------------===========
;                                                                    Dlg_Font(font,style,color,boolean,hGui)   <----------*****
;===================================================================-------------------------------------------===========
Dlg_Font(ByRef Name, ByRef Style, ByRef Color, Effects=true, hGui=0) {
   LogPixels := DllCall("GetDeviceCaps", "uint", DllCall("GetDC", "uint", hGui), "uint", 90)  ;LOGPIXELSY
   VarSetCapacity(LOGFONT, 128, 0)

   Effects := 0x041 + (Effects ? 0x100 : 0)  ;CF_EFFECTS = 0x100, CF_SCREENFONTS=1, CF_INITTOLOGFONTSTRUCT = 0x40

   ;set initial name
   DllCall("RtlMoveMemory", "uint", &LOGFONT+28, "Uint", &Name, "Uint", 32)

   ;convert from rgb  
   clr := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF) 

   ;set intial data
   If InStr(Style, "bold")
      NumPut(700, LOGFONT, 16)

   If InStr(Style, "italic")
      NumPut(255, LOGFONT, 20, 1)

   If InStr(Style, "underline")
      NumPut(1, LOGFONT, 21, 1)
   
   If InStr(Style, "strikeout")
      NumPut(1, LOGFONT, 22, 1)

   If RegExMatch(Style, "s[1-9][0-9]*", s){
      StringTrimLeft, s, s, 1      
      s := -DllCall("MulDiv", "int", s, "int", LogPixels, "int", 72)
      NumPut(s, LOGFONT, 0, "Int")      ; set size
   }
   else  NumPut(16, LOGFONT, 0)         ; set default size

   VarSetCapacity(CHOOSEFONT, 60, 0)
    ,NumPut(60,     CHOOSEFONT, 0)    ; DWORD lStructSize
    ,NumPut(hGui,    CHOOSEFONT, 4)    ; HWND hwndOwner (makes dialog "modal").
    ,NumPut(&LOGFONT,CHOOSEFONT, 12)  ; LPLOGFONT lpLogFont
    ,NumPut(Effects, CHOOSEFONT, 20)  
    ,NumPut(clr,   CHOOSEFONT, 24)  ; rgbColors

   r := DllCall("comdlg32\ChooseFontA", "uint", &CHOOSEFONT)  ; Display the dialog.
   If !r
      Return false

  ;font name
  VarSetCapacity(Name, 32)
  DllCall("RtlMoveMemory", "str", Name, "Uint", &LOGFONT + 28, "Uint", 32)
  Style := "s" NumGet(CHOOSEFONT, 16) // 10

  ;color
  old := A_FormatInteger
  SetFormat, integer, hex                      ; Show RGB color extracted below in hex format.
  Color := NumGet(CHOOSEFONT, 24)
  SetFormat, integer, %old%

  ;styles
  Style =
  VarSetCapacity(s, 3)
  DllCall("RtlMoveMemory", "str", s, "Uint", &LOGFONT + 20, "Uint", 3)

  If NumGet(LOGFONT, 16) >= 700
    Style .= "bold "

  If NumGet(LOGFONT, 20, "UChar")
      Style .= "italic "
   
  If NumGet(LOGFONT, 21, "UChar")
      Style .= "underline "

  If NumGet(LOGFONT, 22, "UChar")
      Style .= "strikeout "

  s := NumGet(LOGFONT, 0, "Int")
  Style .= "s" Abs(DllCall("MulDiv", "int", abs(s), "int", 72, "int", LogPixels))

 ;convert to rgb 
  oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 

    Color := (Color & 0xff00) + ((Color & 0xff0000) >> 16) + ((Color & 0xff) << 16) 
    StringTrimLeft, Color, Color, 2 
    Loop, % 6-strlen(Color) 
    Color=0%Color% 
    Color=%Color% 
    SetFormat, integer, %oldFormat% 

   Return 1
}
;============================================================-------------------------===========
;                                                                Zip/Unzip
;============================================================-------------------------===========
/*
Original from Shajul
Zip/Unzip file(s)/folder(s)/wildcard pattern files
Requires: Autohotkey_L, Windows > XP
URL: http://www.autohotkey.com/forum/viewtopic.php?t=65401
Credits: Sean for original idea
*/
; -----------   THE FUNCTIONS   -------------------------------------
CreateZipFile(sZip) {
  Header1 := "PK" . Chr(5) . Chr(6)
  VarSetCapacity(Header2, 18, 0)
  file := FileOpen(sZip,"w")
  file.Write(Header1)
  file.RawWrite(Header2,18)
  file.close()
}
Zip(FilesToZip, sZip) {
  If Not FileExist(sZip)
    CreateZipFile(sZip)

  psh := ComObjCreate( "Shell.Application" )
  pzip := psh.Namespace( sZip )

  If InStr(FileExist(FilesToZip), "D")
    FilesToZip .= SubStr(FilesToZip,0)="\" ? "*.*" : "\*.*"

  Loop,%FilesToZip%,1
  {
    zipped++
    ToolTip Zipping %A_LoopFileName% ..
    pzip.CopyHere( A_LoopFileLongPath, 4|16 )

    Loop
    {
      done := pzip.items().count
      If done = %zipped%
        break
    }

    done := -1
  }
  ;ToolTip
}
Unz(sZip, sUnz) {
  fso := ComObjCreate("Scripting.FileSystemObject")
  
  If Not fso.FolderExists(sUnz)  ;http://www.autohotkey.com/forum/viewtopic.php?p=402574
         fso.CreateFolder(sUnz)
  
  psh  := ComObjCreate("Shell.Application")
  zippedItems := psh.Namespace( sZip ).items().count
  psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
  
  Loop
  {
    sleep 50

    unzippedItems := psh.Namespace( sUnz ).items().count
    
    ToolTip Unzipping in progress... %unzippedItems%/%zippedItems%

    IfEqual,zippedItems,%unzippedItems%
      break
  }
  ;ToolTip
}
; -----------   END FUNCTIONS   -------------------------------------

;============================================================-------------------------===========
;                                                                Empty Memory for performances
;============================================================-------------------------===========
EmptyMem(PID="main") {
  pid:=(pid=%PROCESS_NAME%) ? DllCall("GetCurrentProcessId") : pid
  h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
  DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
  DllCall("CloseHandle", "Int", h)
}
;============================================================-------------------------===========
;                                                                Token functions
;============================================================-------------------------===========
/* Data from INI
    [CHOOSEN]
    DCLanguagesOptions=ENGLISH|GERMAN|
    DCLanguagesChoosen=GERMAN
*/

; counts the tokens within the haystack
GetTokenCount(haystack, delim="`|") {
  StringReplace, haystack, haystack, %delim%, %delim%, UseErrorLevel ;use ErrorLevel for counting

  return ErrorLevel
}
; gets the position of the specified token in the array
GetTokenPosition(haystack, needle, delim="`|") {
  ; Initialize counter to keep track of our position in the string.
  position := 0

  ; parse the haystack, token by token
  Loop, Parse, haystack, %delim%
  {
    position++  ; counter added by one

    If (A_LoopField == needle)  ; if actual token is the needle
      result := position  ; set position as result 
  }
  ; finally return the result
  return result 
}

;build player token
BuildPlayerCache(PathToIniFile) {
  IniRead, Accounts, %PathToIniFile%
  Accounts := StrReplace(Accounts, "`n", "|")
  Active := Accounts
  
  Loop, Parse, Accounts, |,
  {
    IniRead, Tracking, %PathToIniFile%, %A_LoopField%, Tracking, 0
    
    If (Tracking == 0)
      StringReplace, Active, Active, %A_LoopField%|
  }
  
  return %Active%
}

SpawnPointName(nametochange) {
  if (nametochange = "spawnpoint_hae")
    result = Merchant:
  else if (nametochange = "spawnpoint_rou")
    result = Route:
  else if (nametochange = "spawnpoint_def")
    result = Defender:
  else if (nametochange = "spawnpoint_mon")
    result = Monster:
  else if (nametochange = "spawnpoint_nsc")
    result = NSC:
  else if (nametochange = "spawnpoint_grp")
    result = Group:
  else
    result = ERROR
  return result 
}

CalMapCoords(posx, posy, maph, facx, facy)
{
  resx := Round(posx)         ; round up/down coords
  resy := Round(posy)         ; round up/down coords
  
  resx := (resx / 10) * facx  ; for 14 it should now be 1,4, multiplied with map factor
  resy := (resy / 10) * facy  ; for 15 it should now be 1,5, multiplied with map factor
  
  resx := resx                ; that coordinate should be the same
  resy := (resy-maph)*(-1)    ; here calculate with high and multiply with -1
  
  resx :=  Round(resx)        ; round up/down coords
  resy :=  Round(resy)        ; round up/down coords
  
  result = %resx%|%resy%
  return result
}

GetMonitorIndexFromWindow(windowHandle)
{
  ; Starts with 1.
  monitorIndex := 1

  VarSetCapacity(monitorInfo, 40)
  NumPut(40, monitorInfo)
  
  if (monitorHandle := DllCall("MonitorFromWindow", "uint", windowHandle, "uint", 0x2)) 
    && DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) 
  {
    monitorLeft   := NumGet(monitorInfo,  4, "Int")
    monitorTop    := NumGet(monitorInfo,  8, "Int")
    monitorRight  := NumGet(monitorInfo, 12, "Int")
    monitorBottom := NumGet(monitorInfo, 16, "Int")
    workLeft      := NumGet(monitorInfo, 20, "Int")
    workTop       := NumGet(monitorInfo, 24, "Int")
    workRight     := NumGet(monitorInfo, 28, "Int")
    workBottom    := NumGet(monitorInfo, 32, "Int")
    isPrimary     := NumGet(monitorInfo, 36, "Int") & 1
    
    SysGet, monitorCount, MonitorCount
    
    Loop, %monitorCount%
    {
      SysGet, tempMon, Monitor, %A_Index%
      
      ; Compare location to determine the monitor index.
      if ((monitorLeft = tempMonLeft) and (monitorTop = tempMonTop)
        and (monitorRight = tempMonRight) and (monitorBottom = tempMonBottom))
      {
        monitorIndex := A_Index
        break
      }
    }
  }
  
  return monitorIndex
}
