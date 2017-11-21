;==================================================
;  NWN 1 - Server PW-Randomizer
;  Author: Tobias Wirth (dunahan@schwerterkueste.de)
;==================================================
; v 0.1 (First Steps)
; shows Gui, 1: menu and a list box with some content
;===============================
VERSION := "0.1"
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
EXE := A_WorkingDir . "\main.exe"

;========================================--------------------------------==========
;                                                Main Scripts
;========================================--------------------------------==========
Main:
  ; Set up Gui, 1: 1 style
  Gui, 1: Color, D4D0C8
  Gui, 1: Font, c000000 9, MS Sans SerIf
  
  ; Set up menu  
  Menu, MyMenu, Add, Options, Options
  Menu, MyMenu, Add, CheckUpdates, CheckUpdates
  Menu, MyMenu, Add, ShowAbout, ShowAbout
  Gui, 1: Menu, MyMenu
  
  Gui, 1: Add, Text, x10  y10 w70  h20, Account
  Gui, 1: Add, Text, x+10 y10 w110 h20, Player Name
  Gui, 1: Add, Text, x+10 y10 w170 h20, Area Name
  Gui, 1: Add, Text, x+10 y10 w70  h20, Area ResRef
  Gui, 1: Add, Text, x+10 y10 w90  h20, Area Tag
  
  IniRead, PlayerLoop, playertrack.ini, ActiveAccounts, 00, 0  
  Gui1Loop := 30
  Loop, %PlayerLoop%
  {
    If (%A_Index% < 10)
      Row := 0 A_Index
    Else
      Row := A_Index
      
    IniRead, Acc, playertrack.ini, ActiveAccounts, %Row%, ERROR
    IniRead, PlayerName, playertrack.ini, %Acc%, PlayerName, ERROR
    IniRead, AreaName, playertrack.ini, %Acc%, AreaName, ERROR
    IniRead, AreaResRef, playertrack.ini, %Acc%, AreaResRef, ERROR
    IniRead, AreaTag, playertrack.ini, %Acc%, AreaTag, ERROR
    
    Gui, 1: Add, Text, x10  y%Gui1Loop% w70  h20, %Acc%
    Gui, 1: Add, Text, x+10 y%Gui1Loop% w110 h20 cBlue gPlayerName, %PlayerName%
    Gui, 1: Add, Text, x+10 y%Gui1Loop% w170 h20, %AreaName%
    Gui, 1: Add, Text, x+10 y%Gui1Loop% w70  h20 cBlue gAreaResRef, %AreaResRef%
    Gui, 1: Add, Text, x+10 y%Gui1Loop% w90  h20, %AreaTag%
    
    Gui1Loop := Gui1Loop + 25
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
  Gui, +disabled
  Gui, 2: +owner1
  Gui, 2: +LastFound
  hGui := WinExist()
  
  ; Set up Gui, 2 style
  Gui, 2: Color, %BACKGROUND_COLOR%
  Gui, 2: Font, c%Font_COLOR% %Font_STYLE%, %Font_TYPE%
  
  ; add map picture
  Gui, 2: Add, Picture, vMap, %A_WorkingDir%\_schwerterkueste261\%ResAreaResRefControl%.png
  GuiControlGet, Map, 2:Pos
  
  MapPosY := MapY+MapH+6
  
  MapGridX := MapW//32  ; ex.  128//32 = 4
  MapGridY := MapH//32
  
  GridX := MapX
  GridY := MapY
  Loop, %MapGridX%
  {
    Gui, 2: Add, Picture, x%GridX% y6, %A_WorkingDir%\icons\MapGrid.png
    GridX := GridX+32
  }
  
  Loop, %MapGridY%
  {
    Gui, 2: Add, Picture, x10 y%GridY%, %A_WorkingDir%\icons\MapGrid.png
    GridY := GridY+32
  }
  
  ; loop through playerlist, are more players in this map? then list them
  IniRead, PlayerLoop, playertrack.ini, ActiveAccounts, 00, 0
  FirstChar := 0
  Loop, %PlayerLoop%
  {
    If (%A_Index% < 10)
      Row := 0 A_Index
    Else
      Row := A_Index
    
    IniRead, Acc, playertrack.ini, ActiveAccounts, %Row%, ERROR
    IniRead, AreaResRef, playertrack.ini, %Acc%, AreaResRef, ERROR
    
    If (AreaResRef == ResAreaResRefControl)
    {
      IniRead, PlayerName, playertrack.ini, %Acc%, PlayerName, ERROR
      IniRead, LocX, playertrack.ini, %Acc%, LocX, 0
      IniRead, LocY, playertrack.ini, %Acc%, LocY, 0
      
      If (FirstChar < 0)
      {
        IfInString, LocX, .
          StringTrimRight, LocX, LocX, StrLen(LocX)-InStr(LocX, .)+1
        
        IfInString, LocY, .
          StringTrimRight, LocY, LocY, StrLen(LocY)-InStr(LocY, .)+1
        
        Gui, 2: Add, Text,      w110 h20, %PlayerName%  ; more players here?
        Gui, 2: Add, Text, x+10 y%MapPosY% h20, (%LocX%/%LocY%)
        
        PosX := (LocX*MapGridX)-8
        PosY := (LocY*MapGridY)-8
        MsgBox %MapW%`n%MapH%`n`n%PosX%`n%PosY%
        Gui, 2: Add, Picture, x%PosX% y%PosY%, %A_WorkingDir%\icons\MapPinNWN.png
        
        FirstChar := 1
      }
      Else
      {
        IfInString, LocX, .
          StringTrimRight, LocX, LocX, StrLen(LocX)-InStr(LocX, .)+1
        
        IfInString, LocY, .
          StringTrimRight, LocY, LocY, StrLen(LocY)-InStr(LocY, .)+1
        
        Gui, 2: Add, Text, x10  y%MapPosY% w110 h20, %PlayerName%  ; more players here?
        Gui, 2: Add, Text, x+10 y%MapPosY% h20, (%LocX%/%LocY%)
        
        PosX := (LocX*MapGridX)-8
        PosY := (LocY*MapGridY)-8
        MsgBox %MapW%`n%MapH%`n`n%PosX%`n%PosY%
        Gui, 2: Add, Picture, x%PosX% y%PosY%, %A_WorkingDir%\icons\MapPinNWN.png
        
        MapPosY := MapPosY+25
      }
    }
  }
  
  Gui, 2: Show
  Gui, 2: Show, autosize center, %ResAreaNameControl%
  WinSet, exstyle, -0x80000, Options
  
  Winset, Redraw
  EmptyMem()
Return

Options:
  MsgBox Options
Return

ShowAbout:
  MsgBox ShowAbout
Return

CheckUpdates:
  MsgBox CheckUpdates
Return

2GuiClose:
2GuiEscape: 
  Gui, 1:-Disabled ; Re-enable the main window (must be done prior to the next step).
  Gui, 2: Destroy
Return

; Ends app and destroys program
GuiClose:
  ExitApp