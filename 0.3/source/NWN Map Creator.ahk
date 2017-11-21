;==================================================
;  NWN 1 - Server PW-Randomizer
;  Author: Tobias Wirth (dunahan@schwerterkueste.de)
;==================================================
; v 0.1 (First Steps)
; shows Gui, 1: menu and a list box and some content
; builds map
; v 0.2
; building gui for options
;===============================
VERSION := "0.3"
;===============================

#NoTrayIcon
#NoEnv                  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force

;========================================--------------------------------==========
;                                                Function Includes
;========================================--------------------------------==========
#include pmcfunx.ahk

;========================================--------------------------------==========
;                                                Persistent Variables
;========================================--------------------------------==========
EXE := A_WorkingDir . "\NWN Map Creator.exe"

;========================================--------------------------------==========
;                                                Main Scripts
;========================================--------------------------------==========
Main:
  GoSub ReadFromConfig
  
  ; Set up Gui, 1: 1 style
  Gui, 1: Color, D4D0C8
  Gui, 1: Font, c000000 9, MS Sans SerIf
  
  ; Set up menu  
  Menu, MyMenu, Add, ReloadIni, ReloadIni
  Menu, MyMenu, Add, Options, Options
  If (DEBUG = 1)
  {
    Menu, MyMenu, Add, CheckUpdates, CheckUpdates
    
    If (%ExpertsMode% == 0)
      Menu, MyMenu, Add, ExpertsMode
    Else
      Menu, MyMenu, Add, X-ExpertsMode
  }
  
  Menu, MyMenu, Add, ShowAbout, ShowAbout
  Gui, 1: Menu, MyMenu
  
  Gui, 1: Add, Text, x10  y10 w70  h20 gAccount, Account
  Gui, 1: Add, Text, x+10 y10 w110 h20, Player Name
  Gui, 1: Add, Text, x+10 y10 w170 h20, Area Name
  Gui, 1: Add, Text, x+10 y10 w70  h20, Area ResRef
  Gui, 1: Add, Text, x+10 y10 w90  h20, Area Tag
  
  IniRead, PlayerLoop, %TRACK_INI%, ActiveAccounts, 00, 0
  Gui1YLoop := 30
  Loop, %PlayerLoop%
  {
    If (A_Index <= 9)
      Row := 0 A_Index
    Else
      Row := A_Index
    
    If (DEBUG == 1)
      MsgBox Rows to scan: %Row%
    
    IniRead, Acc, %TRACK_INI%, ActiveAccounts, %Row%, ERROR
    IniRead, PlayerName, %TRACK_INI%, %Acc%, PlayerName, ERROR
    IniRead, AreaName, %TRACK_INI%, %Acc%, AreaName, ERROR
    IniRead, AreaResRef, %TRACK_INI%, %Acc%, AreaResRef, ERROR
    IniRead, AreaTag, %TRACK_INI%, %Acc%, AreaTag, ERROR
    
    Gui, 1: Add, Text, x10  y%Gui1YLoop% w70  h20, %Acc%
    Gui, 1: Add, Text, x+10 y%Gui1YLoop% w110 h20 cBlue gPlayerName, %PlayerName%
    Gui, 1: Add, Text, x+10 y%Gui1YLoop% w170 h20, %AreaName%
    Gui, 1: Add, Text, x+10 y%Gui1YLoop% w70  h20 cBlue gAreaResRef, %AreaResRef%
    Gui, 1: Add, Text, x+10 y%Gui1YLoop% w90  h20, %AreaTag%
    
    Gui1YLoop := Gui1YLoop + 25
  }
  
  Gui, 1: Submit, NoHide
  
  hGui := WinExist()
  Gui, 1: Font, c000000 9, MS Sans SerIf
  Gui, 1: +E0x80000000
  
  Gui, 1: Show
  Gui, 1: Show, center autosize, NWN Player Map Locator  ;No translations needed!
  ;Gui, 1: Show, center w600 h150, NWN Player Map Locator
  WinSet, exstyle, -0x80000, NWN Player Map Locator   ;No translations needed!
  EmptyMem()
Return

;========================================--------------------------------==========
;                                                Sub Routines
;========================================--------------------------------==========

ReloadIni:
  Run, %EXE%
  GoSub, GuiClose
Return

Account:
  IniRead, Accounts, %TRACK_INI%
  
  MsgBox, %Accounts% 
Return

PlayerName:
  If A_GuiEvent = DoubleClick
  {
    MouseGetPos, , , , PlayerNameControl, 1                     ; gets the control under mouse
    StringTrimLeft, StaticNbr, PlayerNameControl, 6             ; gets number of control
    ControlGetText, ResPlayerNameControl, %PlayerNameControl%   ; gets the text of Player Name
    
    Temp := StaticNbr+1
    ControlGetText, ResAreaNameControl, Static%Temp%            ; gets the text of AreaName
    Temp := StaticNbr+2
    ControlGetText, ResAreaResRefControl, Static%Temp%          ; gets the text of AreaResRef
    
    GoSub MapBuild
  }
Return

AreaResRef:
  If A_GuiEvent = DoubleClick
  {
    MouseGetPos, , , , AreaResRefControl, 1                     ; gets the control under mouse
    StringTrimLeft, StaticNbr, AreaResRefControl, 6             ; gets number of control
    ControlGetText, ResAreaResRefControl, %AreaResRefControl%   ; gets the text of AreaResRef
    
    Temp := StaticNbr-1
    ControlGetText, ResAreaNameControl, Static%Temp%            ; gets the text of AreaName
    Temp := StaticNbr-2
    ControlGetText, ResPlayerNameControl, Static%Temp%          ; gets the text of Player Name
    
    GoSub MapBuild
  }
Return

MapBuild:
  GoSub ReadFromConfig
  
  Gui, 1: +disabled
  Gui, 2: +owner1
  Gui, 2: +LastFound
  hGui := WinExist()
  
  ; Set up Gui, 2 style
  Gui, 2: Color, %BACKGROUND_COLOR%
  Gui, 2: Font, c%Font_COLOR% %Font_STYLE%, %Font_TYPE%
  
  ; add map picture
  PicX := 10  ; Starting position for pic
  PicY := 10  ; 
  Gui, 2: Add, Picture, x%PicX% y%PicY% vMap, %MAP_DIR%\%ResAreaResRefControl%.png
  
  ; get the map and its size, ex. 128x128
  GuiControlGet, Map, 2:Pos
  FacX := 32
  FacY := 32
  
  ; calculate max size for picture, needed for display debug-messages
  MapPosX := MapX+MapW+10 ; ex. 10+128+10 = 148
  MapPosY := MapY+MapH+10 ;     10+128+10 = 148
  
  ; calculate grid-size
  MapGridX := MapW//FacX  ; ex.  128//32 = 4
  MapGridY := MapH//FacY
  
  ; build up grid for debug
  If (DEBUG == 1)
  {
    Gui, 2: Add, Text, x%MapPosX% y%PicY%, Width: %MapW%  Heigth: %MapH%`nPosMapX: %MapX% PosMapY: %MapY%`nMapGridX: %MapGridX% MapGridY: %MapGridY%
    MapXn := MapX
    Loop, %MapGridX%
    {
      Gui, 2: Add, Picture, x%MapXn% y%PicY% +BackgroundTrans, %A_WorkingDir%\icons\MapGrid.png
      Gui, 2: Add, Picture, x%MapXn% y%PicY% +BackgroundTrans, %A_WorkingDir%\icons\MapGridMarker.png
      MapXn := MapXn+32
    }
    
    MapXn := MapX
    PicY := PicY+32
    Loop, %MapGridX%
    {
      Gui, 2: Add, Picture, x%MapXn% y%PicY% +BackgroundTrans, %A_WorkingDir%\icons\MapGrid.png
      Gui, 2: Add, Picture, x%MapXn% y%PicY% +BackgroundTrans, %A_WorkingDir%\icons\MapGridMarker.png
      MapXn := MapXn+32
    }
    
    MapXn := MapX
    PicY := PicY+32
    Loop, %MapGridX%
    {
      Gui, 2: Add, Picture, x%MapXn% y%PicY% +BackgroundTrans, %A_WorkingDir%\icons\MapGrid.png
      Gui, 2: Add, Picture, x%MapXn% y%PicY% +BackgroundTrans, %A_WorkingDir%\icons\MapGridMarker.png
      MapXn := MapXn+32
    }
    
    MapXn := MapX
    PicY := PicY+32
    Loop, %MapGridX%
    {
      Gui, 2: Add, Picture, x%MapXn% y%PicY% +BackgroundTrans, %A_WorkingDir%\icons\MapGrid.png
      Gui, 2: Add, Picture, x%MapXn% y%PicY% +BackgroundTrans, %A_WorkingDir%\icons\MapGridMarker.png
      MapXn := MapXn+32
    }
  }
  
  ; loop through playerlist, are more players in this map? then list them
  IniRead, PlayerLoop, %TRACK_INI%, ActiveAccounts, 00, 0
  FirstChar := 0
  
  Loop, %PlayerLoop%
  {
    If (A_Index <= 9)
      Row := 0 A_Index
    Else
      Row := A_Index
    
    IniRead, Acc, %TRACK_INI%, ActiveAccounts, %Row%, ERROR
    IniRead, AreaResRef, %TRACK_INI%, %Acc%, AreaResRef, ERROR
    IniRead, PlayerName, %TRACK_INI%, %Acc%, PlayerName, ERROR
    
    ; is this area filled with players?
    If (AreaResRef == ResAreaResRefControl)
    ;If (PlayerName == ResPlayerNameControl)
    {
      ;IniRead, PlayerName, %TRACK_INI%, %Acc%, PlayerName, ERROR
      IniRead, LocX, %TRACK_INI%, %Acc%, LocX, 0
      IniRead, LocY, %TRACK_INI%, %Acc%, LocY, 0
      
      LocX := Round(LocX)
      LocY := Round(LocY)
      
      PriX := LocX
      PriY := LocY
      
      LocX := (LocX / 10) * FacX  ; for 14 it should now be 1,4, multiplied with map factor
      LocY := (LocY / 10) * FacY  ; for 15 it should now be 1,5, multiplied with map factor
      
      PosY :=  MapH-LocX  ; round to next number, so 44.8 should be 45. subtract that from the high of the picture to get the right coordinate
      PosX :=       LocY  ; round to next number, 48 would be 48. nothing to round up to
      
      PosX :=  Round(PosX)
      PosY :=  Round(PosY)
      
      ; is there only one player so do it only once
      If (FirstChar < 0)
      {
        Gui, 2: Add, Text,            w110 h20 gHighlightPlayer, %PlayerName%       ; more players here?
        Gui, 2: Add, Text, x+10 y%MapPosY% h20, (%PriX%/%PriY%) | (%PosX%/%PosY%)
        
        Gui, 2: Add, Picture, x%PosX% y%PosY% +BackgroundTrans, %A_WorkingDir%\icons\MapPinNWN.png
        
        FirstChar := 1
      }
      
      ; else do it more then once
      Else
      {
        Gui, 2: Add, Text, x10  y%MapPosY% w110 h20 gHighlightPlayer, %PlayerName%  ; more players here?
        Gui, 2: Add, Text, x+10 y%MapPosY%      h20, (%PriX%/%PriY%) | (%PosX%/%PosY%)
        
        Gui, 2: Add, Picture, x%PosX% y%PosY% +BackgroundTrans, %A_WorkingDir%\icons\MapPinNWN.png
        
        MapPosY := MapPosY+25
      }
    }
  }
  
  Gui, 2: Show
  Gui, 2: Show, autosize center, %ResAreaNameControl%
  WinSet, exstyle, -0x80000, MapBuilder
  
  Winset, Redraw
  EmptyMem()
Return

HighlightPlayer:
  If A_GuiEvent = DoubleClick
  {
    GoSub ReadFromConfig
    
    MouseGetPos, , , , MapPlayerControl, 1                    ; gets the control under mouse
    StringTrimLeft, MapStaticNbr, MapPlayerControl, 6         ; gets number of control
    ControlGetText, ResMapPlayerControl, %MapPlayerControl%   ; gets the text of Player Name
    
    IniRead, PlayerLoop, %TRACK_INI%, ActiveAccounts, 00, 0
    Loop, %PlayerLoop%
    {
      If (A_Index <= 9)
        Row := 0 A_Index
      Else
        Row := A_Index
      
      IniRead, Acc, %TRACK_INI%, ActiveAccounts, %Row%, ERROR
      IniRead, PlayerName, %TRACK_INI%, %Acc%, PlayerName, ERROR
      
      If (ResMapPlayerControl == PlayerName)
      {
        IniRead, LocX, %TRACK_INI%, %Acc%, LocX, 0
        IniRead, LocY, %TRACK_INI%, %Acc%, LocY, 0
        
        LocX := Round(LocX)
        LocY := Round(LocY)
        
        PriX := LocX
        PriY := LocY
        
        ; get the map and its size, ex. 128x128
        GuiControlGet, Map, 2:Pos
        FacX := 32
        FacY := 32
        
        LocX := (LocX / 10) * FacX  ; for 14 it should now be 1,4, multiplied with map factor
        LocY := (LocY / 10) * FacY  ; for 15 it should now be 1,5, multiplied with map factor
        
        PosY :=  MapH-LocX  ; round to next number, so 44.8 should be 45. subtract that from the high of the picture to get the right coordinate
        PosX :=       LocY  ; round to next number, 48 would be 48. nothing to round up to
        
        PosY :=  Round(PosY)  ; round to next number, so 44.8 should be 45. subtract that from the high of the picture to get the right coordinate
        PosX :=  Round(PosX)  ; round to next number, 48 would be 48. nothing to round up to
        
        If (DEBUG == 1)
          ResultMapLoop = %PlayerName% (%PriX%/%PriY%)
        
        ToolTip, %PlayerName%, PosX, PosY
        SetTimer, RemoveToolTip, 5000
      }
    }
    
    If (DEBUG == 1)
      MsgBox, %MapPlayerControl%  %MapStaticNbr%  %ResMapPlayerControl%  %ResultMapLoop%
  }
Return

RemoveToolTip:
  SetTimer, RemoveToolTip, Off
  ToolTip
return

Options:
  GoSub ReadFromConfig
  
  Gui, 1: +disabled
  Gui, 3: +owner1
  Gui, 3: +LastFound
  hGui := WinExist()
  
  ; Set up Gui, 3 style
  Gui, 3: Color, %BACKGROUND_COLOR%
  Gui, 3: Font, c%Font_COLOR% %Font_STYLE%, %Font_TYPE%
  
  Gui, 3: Add, Button, x10 y72 w75 h25 g3GuiSubmit, Ok
  Gui, 3: Add, Button, x88 y72 w75 h25 g3GuiClose, Cancel
  
  ; Style and Languages
  Gui, 3: Add, GroupBox, x10 y2 w180 h65, Style and Languages
  LangPos := GetTokenPosition(Options, Choosen)
  Gui, 3: Add, Button, x20 y17 w75 h20 gSelectFont, GuiFont
  Gui, 3: Add, Button, x103 y17 w75 h20 gSelectOptionsColor, GuiOptions  
  Gui, 3: Add, DDL, x20 y40 w160 vChangeLangVar gChangeLang Choose%LangPos%, %Options%
  
  ; Browse to Directories
  Gui, 3: Add, GroupBox, x188 y2 w290 h85, Directories
  Gui, 3: Add, Text, x202 y25 w60 h20, NWW Files:
  Gui, 3: Add, Edit, x262 y22 w160 h20 vNWN_DIR, %NWN_DIR%
  Gui, 3: Add, Button, x425 y22 w45 h20 gBrowseGameDirectory, Browse
  
  Gui, 3: Add, Text, x202 y45 w60 h20, MiniMaps:
  Gui, 3: Add, Edit, x262 y42 w160 h20 vMAP_DIR, %MAP_DIR%
  Gui, 3: Add, Button, x425 y42 w45 h20 gBrowseMapDirectory, Browse
  
  Gui, 3: Add, Text, x202 y65 w60 h20, Playertrack:
  Gui, 3: Add, Edit, x262 y62 w160 h20 vTRACK_INI, %TRACK_INI%
  Gui, 3: Add, Button, x425 y62 w45 h20 gBrowseTrackIni, Browse
  
  If (ExpertsMode == 1)
  {
    Gui, 3: Add, Text, x20 y100 w400 h80, Expert-Mode activated :-)`nNothing to show yet :-(`nPlanned to implement GFF File reading and create maps out of *.are-files
  }
  
  Gui, 3: Show
  Gui, 3: Show, autosize center, Options
  WinSet, exstyle, -0x80000, Options
  
  Winset, Redraw
  EmptyMem()
Return

ChangeLang:
  Gui, 3: Submit, NoHide
  IniWrite, %ChangeLangVar%, config.ini, Languages, Choosen
Return

3GuiSubmit:
  Gui, 3: Submit, NoHide
  
  ;-----write to Config.ini
  IniWrite, %NWN_DIR%, config.ini, Main, NWN_DIR
  IniWrite, %MAP_DIR%, config.ini, Main, MAP_DIR
  IniWrite, %TRACK_INI%, config.ini, Main, TRACK_INI
  
  Run, %EXE%
  GoSub, GuiClose
Return

; read configs
ReadFromConfig:
  ReadLanguage()
  
  IfExist, config.ini
  {
    ReadConfig()
  }
  Else
  {
    BACKGROUND_COLOR = D4D0C8  ;set default bkg color If ini doesn't exist
    CreateConfig()
  }

  Read_Nwnplayer()
Return

SelectOptionsColor:
  IniRead, BACKGROUND_COLOR, config.ini, Gui Options, Background_Color, D4D0C8
  
  If Dlg_Color(color := "0x" . OPTIONS_BKG_COLOR, hGui)
  {
    IniWrite, %Color%, config.ini, Gui Options, Background_Color
  }
Return

SelectFont:
  IniRead, Font_STYLE, config.ini, Gui Options, Font_Style, 9
  IniRead, Font_TYPE, config.ini, Gui Options, Font_Type, MS Sans SerIf
  IniRead, Font_COLOR, config.ini, Gui Options, Font_Color, 000000
  
  If Dlg_Font( Font:=Font_TYPE, style:=Font_STYLE, color:= "0x" . Font_COLOR, true, hGui)
  {
    IniWrite, %style%, config.ini, Gui Options, Font_Style
    IniWrite, %Font%, config.ini, Gui Options, Font_Type
    IniWrite, %Color%, config.ini, Gui Options, Font_Color
  }
Return

BrowseGameDirectory:
  FileSelectFolder, OutputVar, , 3
  If OutputVar !=
  {
    GuiControl, , NWN_DIR, %OutputVar%
    NWN_DIR = %OutputVar%
  }
Return

BrowseMapDirectory:
  FileSelectFolder, OutputVar, , 3
  If OutputVar !=
  {
    GuiControl, , MAP_DIR, %OutputVar%
    MAP_DIR = %OutputVar%
  }
Return

BrowseTrackIni:
  FileSelectFile, SelectedFile, 3, %MAP_DIR%, Open a file, Playertrack (*.ini)
  If SelectedFile =
  MsgBox, MsgBoxBrowseFile
  Else
  {
    GuiControl, , TRACK_INI, %SelectedFile%
    TRACK_INI = %SelectedFile%
  }
Return

ShowAbout:
  MsgBox NWN Map Creator v%VERSION%`nAuthor: dunahan@schwerterkueste.de`n`nWhats new in this version?`n
         - Creates list out of ini-file (with nwnx_systemdata2)`n
         - Linked players with map and shows map with player locations
Return

CheckUpdates:
  MsgBox CheckUpdates
Return

ExpertsMode:
  If NewName <> X-ExpertsMode
  {
    OldName = ExpertsMode
    NewName = X-ExpertsMode
    
    IniWrite, 1, config.ini, Main, ExpertsMode
    
  }
  Else
  {
    OldName = X-ExpertsMode
    NewName = ExpertsMode
    
    IniWrite, 0, config.ini, Main, ExpertsMode
    
  }
  Menu, MyMenu, Rename, %OldName%, %NewName%
Return

X-ExpertsMode:
  If NewName <> ExpertsMode
  {
    OldName = X-ExpertsMode
    NewName = ExpertsMode
    
    IniWrite, 0, config.ini, Main, ExpertsMode
    
  }
  Else
  {
    OldName = ExpertsMode
    NewName = X-ExpertsMode
    
    IniWrite, 1, config.ini, Main, ExpertsMode
    
  }
  Menu, MyMenu, Rename, %OldName%, %NewName%
Return

2GuiClose:
2GuiEscape: 
  Gui, 1:-Disabled ; Re-enable the main window (must be done prior to the next step).
  Gui, 2: Destroy
Return

3GuiClose:
3GuiEscape: 
  Gui, 1:-Disabled ; Re-enable the main window (must be done prior to the next step).
  Gui, 3: Destroy
Return

; Ends app and destroys program
GuiClose:
  ExitApp