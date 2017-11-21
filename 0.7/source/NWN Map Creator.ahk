;==================================================
;  NWN 1 - Server PW-Randomizer
;  Author: Tobias Wirth (dunahan@schwerterkueste.de)
;==================================================
; v 0.1 (First Steps)
; shows Gui, 1: menu and a list box and some content
; builds map
; v 0.2
; building gui for options
; v 0.3 and 0.4
; done some math, adding info on the other way from
; playertrack.ini
;===============================
VERSION := "0.7"
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
FacX := 32
FacY := 32
Gui1LoopY := 30
Gui1LoopX := 10

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
    Menu, MyMenu, Add, CheckUpdates, CheckUpdates
  
  If (%ExpertsMode% == 0)
    Menu, MyMenu, Add, More
  Else
    Menu, MyMenu, Add, X-More
  
  Menu, MyMenu, Add, ShowAbout, ShowAbout
  Gui, 1: Menu, MyMenu
  
  ; BuildUp Player List
  If (PlayerMap == 1)
  {
    Gui, 1: Add, Text, x10  y10 w70  h20, Account
    Gui, 1: Add, Text, x+10 y10 w110 h20, Player Name
    Gui, 1: Add, Text, x+10 y10 w170 h20, Area Name
    Gui, 1: Add, Text, x+10 y10 w70  h20, Area ResRef
    Gui, 1: Add, Text, x+10 y10 w90  h20, Area Tag
    
    Accounts := BuildPlayerCache(TRACK_INI)
    Active := Accounts
    
    Loop, Parse, Active, |,
    {
      IniRead, PlayerName, %TRACK_INI%, %A_LoopField%, PlayerName, ""
      IniRead, AreaName, %TRACK_INI%, %A_LoopField%, AreaName, ""
      IniRead, AreaResRef, %TRACK_INI%, %A_LoopField%, AreaResRef, ""
      IniRead, AreaTag, %TRACK_INI%, %A_LoopField%, AreaTag, ""
      
      Gui, 1: Add, Text, x10  y%Gui1LoopY% w70  h20, %A_LoopField%
      Gui, 1: Add, Text, x+10 y%Gui1LoopY% w110 h20 cBlue gPlayerName, %PlayerName%
      Gui, 1: Add, Text, x+10 y%Gui1LoopY% w170 h20, %AreaName%
      Gui, 1: Add, Text, x+10 y%Gui1LoopY% w70  h20 cBlue gMapResRef, %AreaResRef%
      Gui, 1: Add, Text, x+10 y%Gui1LoopY% w90  h20, %AreaTag%
      
      Gui1LoopY := Gui1LoopY + 25
    }
    MainWin = (PlayersMode)
  }
  
  ; BuildUp Critter Map List
  If (CritterMap == 1)
  {
    If (CRITTER_INI = "")
      CRITTER_INI := AREA_INI
    
    IniRead, CritterMapArray, %CRITTER_INI%
    CritterMapToken := StrReplace(CritterMapArray, "`n", "|", MapNbr)
    Rows := Round(MapNbr/GuiRow)
    
    Gui, 1: Add, Text, x10  y10 w300 h20, %MapNbr% Maps with Critters/NPC's and %Rows%+1 per row
    
    MapsListed := 0
    Loop, Parse, CritterMapToken, |,
    {
      Gui, 1: Add, Text, x%Gui1LoopX% y%Gui1LoopY% w70 h20 cBlue gMapResRef, %A_LoopField%
      
      MapsListed := MapsListed+1
      Gui1LoopY := Gui1LoopY + 25
      
      If (MapsListed > Rows)
      {
        Gui1LoopX := Gui1LoopX + 100
        Gui1LoopY := 30
        MapsListed := 0
      }
    }
    MainWin = (CritterssMode)
  }
  
  ; BuildUp Placeable Map List
  If (PlaceableMap == 1)
  {
    If (PLC_INI = "")
      PLC_INI := AREA_INI
    
    IniRead, PlaceableMapArray, %PLC_INI%
    PlaceableMapToken := StrReplace(PlaceableMapArray, "`n", "|", MapNbr)
    Rows := Round(MapNbr/GuiRow)
    
    Gui, 1: Add, Text, x10  y10 w300 h20, %MapNbr% Maps with Placeables's and %Rows%+1 per row
    
    MapsListed := 0
    Loop, Parse, PlaceableMapToken, |,
    {
      Gui, 1: Add, Text, x%Gui1LoopX% y%Gui1LoopY% w70 h20 cBlue gMapResRef, %A_LoopField%
      
      MapsListed := MapsListed+1
      Gui1LoopY := Gui1LoopY + 25
      
      If (MapsListed > Rows)
      {
        Gui1LoopX := Gui1LoopX + 100
        Gui1LoopY := 30
        MapsListed := 0
      }
    }
    MainWin = (PlaceablesMode)
  }
  
  Gui, 1: Submit, NoHide
  
  hGui := WinExist()
  Gui, 1: Font, c000000 9, MS Sans SerIf
  Gui, 1: +E0x80000000
  
  ; persistent location of main window
  If (MWCX < 0 OR MWCY < 0)
  {
    MWCX := 512
    MWCY := 327
  }
  
  Gui, 1: Show
  Gui, 1: Show, x%MWCX% y%MWCY% autosize, NWN Player Map Locator %MainWin% ;No translations needed!
  ;Gui, 1: Show, center w600 h600, NWN Player Map Locator
  WinSet, ExStyle, -0x80000, NWN Player Map Locator %MainWin%  ;No translations needed!
  
  WinGetPos, WinGui1X, WinGui1Y, , , NWN Player Map Locator %MainWin%
  
  ; control the main window, if it was moved
  Loop
  {
    Sleep, 3500
    WinGetPos, WinGuiNew1X, WinGuiNew1Y, , , NWN Player Map Locator %MainWin%
    
    If (WinGuiNew1X <> WinGui1X OR WinGuiNew1Y <> WinGui1Y)
    {
      If (WinGuiNew1X > 0 OR WinGuiNew1Y > 0)
      {
        IniWrite, %WinGuiNew1X%, config.ini, Main, MWCX
        IniWrite, %WinGuiNew1Y%, config.ini, Main, MWCY
      }
    }
    ;break
  }
  
  EmptyMem()
Return

;========================================--------------------------------==========
;                                                Sub Routines
;========================================--------------------------------==========

Account:
  MsgBox, Nothing to test
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

MapResRef:
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
  
  ; calculate max size for picture, needed for display debug-messages
  MapPosX := MapX+MapW+10 ; ex. 10+128+10 = 148
  MapPosY := MapY+MapH+10 ;     10+128+10 = 148
  
  ; calculate grid-size
  MapGridX := MapW//FacX  ; ex.  128//32 = 4
  MapGridY := MapH//FacY
  
  If (DEBUG == 1)
    Gui, 2: Add, Text, x%MapPosX% y%PicY%, Width: %MapW%  Heigth: %MapH%`nPosMapX: %MapX% PosMapY: %MapY%`nMapGridX: %MapGridX% MapGridY: %MapGridY%
  
  ; build up area transitions
  IniRead, Triggers, %AREA_INI%, %ResAreaResRefControl%
  Triggers := StrReplace(Triggers, "name", "name", TriggersNbr)
  ctdControl := DEBUG
  
  Loop, %TriggersNbr%
  {
    IniRead, Tri%A_Index%X, %AREA_INI%, %ResAreaResRefControl%, loc%A_Index%x, 0
    IniRead, Tri%A_Index%Y, %AREA_INI%, %ResAreaResRefControl%, loc%A_Index%y, 0
    
    If (DEBUG = 1)
    {
      DebTriX := Round(Tri%A_Index%X)
      DebTriY := Round(Tri%A_Index%Y)
    }
    
    Tri%A_Index%X := Round(Tri%A_Index%X)
    Tri%A_Index%Y := Round(Tri%A_Index%Y)
    
    Tri%A_Index%X := (Tri%A_Index%X / 10) * FacX
    Tri%A_Index%Y := (Tri%A_Index%Y / 10) * FacY
    
    Tri%A_Index%Y := (Tri%A_Index%Y - MapH) * (-1)
    
    Tri%A_Index%X := Round(Tri%A_Index%X)
    Tri%A_Index%Y := Round(Tri%A_Index%Y)
    
    TriX := Tri%A_Index%X
    TriY := Tri%A_Index%Y
    
    If (DEBUG = 1)
      MsgBox, Loopings: %Triggers%`nNbr: %A_Index%`nReal: %DebTriX%|%DebTriY%`nCoords: x%TriX%|y%TriY%
    
    ; add transition
    Gui, 2: Add, Picture, x%TriX% y%TriY% +BackgroundTrans, %A_WorkingDir%\icons\MapTransition.png
    ctdControl := ctdControl+1
  }
  
  ; BuildUp PlayerPins
  If (PlayerMap == 1)
  {
    ; loop through playerlist, are more players in this map? then list them
    Accounts := BuildPlayerCache(TRACK_INI)
    Active := Accounts
    PlyPos := 10
    counted := 0
    
    Loop, Parse, Active, |,
    {
      IniRead, PlayerName, %TRACK_INI%, %A_LoopField%, PlayerName, ""
      IniRead, AreaResRef, %TRACK_INI%, %A_LoopField%, AreaResRef, ""
      
      ; is this area filled with players?
      If (AreaResRef == ResAreaResRefControl)
      {
        IniRead, LocX, %TRACK_INI%, %A_LoopField%, LocX, 0
        IniRead, LocY, %TRACK_INI%, %A_LoopField%, LocY, 0
        
        LocX := Round(LocX)
        LocY := Round(LocY)
        
        NwnX := LocX
        NwnY := LocY
        
        LocX := (LocX / 10) * FacX  ; for 14 it should now be 1,4, multiplied with map factor
        LocY := (LocY / 10) * FacY  ; for 15 it should now be 1,5, multiplied with map factor
        
        PosX := LocX  ; round to next number, so 44.8 should be 45. subtract that from the high of the picture to get the right coordinate
        PosY := (LocY-MapH)*(-1)  ; round to next number, 48 would be 48. nothing to round up to
        
        PosX :=  Round(PosX)
        PosY :=  Round(PosY)
        
        ; build up Players List
        Gui, 2: Add, Text, x%PlyPos%  y%MapPosY% h20 gHighlightPlayer, %PlayerName%
        Gui, 2: Add, Text, x+10 y%MapPosY% h20, (%NwnX%|%NwnY%) ;| (%PosX%|%PosY%)
        ctdControl := ctdControl+2
        
        ; set MapPin visible
        Gui, 2: Add, Picture, x%PosX% y%PosY% +BackgroundTrans gHighlightPin, %A_WorkingDir%\icons\MapPlayerPinNWN.png
        HighlightPin_%ctdControl% := PlayerName
        
        MapPosY := MapPosY+25
        counted := counted+1
        ctdControl := ctdControl+1
        
        If (counted > 5)
        {
          PlyPos := PlyPos+200
          MapPosY := MapY+MapH+10
          counted := 0
        }
      }
    }
    IniRead, WindowsName, %AREA_INI%, %ResAreaResRefControl%, map, %ResAreaResRefControl%
  }
  
  If (CritterMap == 1)
  {
    If (CRITTER_INI = "")
      CRITTER_INI := AREA_INI
    
    Gui, 3: +owner2
    
    ; Set up Gui, 3 style
    Gui, 3: Color, %BACKGROUND_COLOR%
    Gui, 3: Font, c%Font_COLOR% %Font_STYLE%, %Font_TYPE%
    
    IniRead, CritterMapArray, %CRITTER_INI%
    CritterMapToken := StrReplace(CritterMapArray, "`n", "|")
    MapPosYGui3 := 10
    MapPosY := MapPosYGui3
    CritX := 10
    counted := 0
    
    ; build up Critters List
    Loop, Parse, CritterMapToken, |,
    {
      IfEqual, A_LoopField, %ResAreaResRefControl%
      {
        IniRead, Found, %CRITTER_INI%, %A_LoopField%
        
        Loop, Parse, Found, `n,
        {
          Result := StrReplace(A_LoopField, "=", "|")
          ResultArray := StrSplit(Result, "|")
          Spawn :=  ResultArray[1]
          
          IfInString, Spawn, spawnpoint
          {
            Spawn := SpawnPointName(Spawn)
            
            Name := ResultArray[2]
            
            If (Name != "")
            {
              HighlightPin_%ctdControl% := Name
              
              CriX := ResultArray[4]
              CriY := ResultArray[5]
              
              SpawnCons := ResultArray[3]
              Loop, Parse, SpawnCons, _,
              {
                IfInString, A_LoopField, SP
                {
                  Cycle := ((SubStr(A_LoopField, 3)) * 6)
                  
                  If (Cycle < 1)
                    Cycle := 0
                }
                IfInString, A_LoopField, SN
                  SpwNb := StrReplace(SubStr(A_LoopField, 3), "M", "-")
                  
                If (SpwNb < 1)
                  SpwNb := 01
                  
                IfInString, A_LoopField, SA
                  SpwAl := SpawnAll
                IfInString, A_LoopField, SG
                  SpwGr := SpawnGroup
                IfInString, A_LoopField, RW
                  SpwRW := RandomWalk
                IfInString, A_LoopField, PCR
                  SpwPC := OnlyWithPCs
              }
            }
            CriX :=  Round(CriX)
            CriY :=  Round(CriY)
            
            CrtX := (CriX / 10) * FacX  ; for 14 it should now be 1,4, multiplied with map factor
            CrtY := (CriY / 10) * FacY  ; for 15 it should now be 1,5, multiplied with map factor
            
            CrtX := CrtX  ; round to next number, so 44.8 should be 45. subtract that from the high of the picture to get the right coordinate
            CrtY := (CrtY-MapH)*(-1)  ; round to next number, 48 would be 48. nothing to round up to
            
            CrtX :=  Round(CrtX)
            CrtY :=  Round(CrtY)
            
            Gui, 3: Add, Text, x%CritX% y%MapPosY% h20 gHighlightPlayer, %Spawn% %Name% (%CriX%|%CriY%)`nCond: Spawn %SpwNb% every %Cycle%s  %SpwAl% %SpwGr% %SpwRW% %SpwPC%
            
            ; set MapPin visible
            Gui, 2: Add, Picture, x%CrtX% y%CrtY% +BackgroundTrans gHighlightPin, %A_WorkingDir%\icons\MapCritterPinNWN.png
            ctdControl := ctdControl+1
            
            MapPosY := MapPosY+30
            counted := counted+1
            
            If (counted > 24)
            {
              CritX := CritX+200
              MapPosY := MapPosYGui3
              counted := 0
            }
          }
        }
      }
    }
    
    IniRead, WindowsName, %AREA_INI%, %ResAreaResRefControl%, map, %ResAreaResRefControl%
    WindowsName = %WindowsName% (%ResAreaResRefControl%)
    Result = 
    ResultArray = 
    Spawn := ""
    Name :=""
    CriX := ""
    CriY := ""
    CrtX := ""
    CrtY := ""
    SpawnCons := ""
    Cycle := ""
    SpwNb := ""
    SpwAl := ""
    SpwGr := ""
    SpwRW := ""
    SpwPC := ""
    counted := ""
  }
  
  If (PlaceableMap == 1)
  {
    If (PLC_INI = "")
      PLC_INI := AREA_INI
    
    IniRead, PlaceableMapArray, %PLC_INI%
    PlaceableMapToken := StrReplace(PlaceableMapArray, "`n", "|")
    PlcaX := 10
    counted := 0
    
    Loop, Parse, PlaceableMapToken, |,
    {
      IfEqual, A_LoopField, %ResAreaResRefControl%
      {
        IniRead, Found, %PLC_INI%, %A_LoopField%
        
        ; build up Placeable List
        Loop, Parse, Found, `n,
        {
          Result := StrReplace(A_LoopField, "=", "|")
          ResultArray := StrSplit(Result, "|")
          PLC := ResultArray[1]
          Name := ResultArray[3]
          
          IfInString, PLC, res
          {
          If (Name != "")
            {
              PlcX := ResultArray[4]
              PlcY := ResultArray[5]
              
              PlcX :=  Round(PlcX)
              PlcY :=  Round(PlcY)
              
              PlpX := (PlcX / 10) * FacX  ; for 14 it should now be 1,4, multiplied with map factor
              PlpY := (PlcY / 10) * FacY  ; for 15 it should now be 1,5, multiplied with map factor
              
              PlpX := PlpX  ; round to next number, so 44.8 should be 45. subtract that from the high of the picture to get the right coordinate
              PlpY := (PlpY-MapH)*(-1)  ; round to next number, 48 would be 48. nothing to round up to
              
              PlpX :=  Round(PlpX)
              PlpY :=  Round(PlpY)
              
              Gui, 2: Add, Text, x%PlcaX% y%MapPosY% h20 gHighlightPlayer, %Name% (%PlcX%|%PlcY%)
              ctdControl := ctdControl+1
              
              ; set MapPin visible
              Gui, 2: Add, Picture, x%PlpX% y%PlpY% +BackgroundTrans gHighlightPin, %A_WorkingDir%\icons\MapPlcPinNWN.png
              HighlightPin_%ctdControl% := Name
              ctdControl := ctdControl+1
              counted := counted+1
              MapPosY := MapPosY+25
              
              If (counted > 5)
              {
                PlcaX := PlcaX+150
                MapPosY := MapY+MapH+10
                counted := 0
              }
            }
          }
        }
      }
    }
    
    IniRead, WindowsName, %AREA_INI%, %ResAreaResRefControl%, map, %ResAreaResRefControl%
    WindowsName = %WindowsName% (%ResAreaResRefControl%)
    Result := ""
    ResultArray := ""
    Name := ""
    PlcX := ""
    PlcY := ""
    PlpX := ""
    PlpY := ""
    counted := ""
  }
  
  Gui, 2: +ToolWindow
  Gui, 2: Show
  Gui, 2: Show, autosize center, %WindowsName%
  
  ; look if critterlist of map has been moved
  If (CritterMap == 1)
  {
    WinGetPos, WinGui2X, WinGui2Y, WinGui2W, , %WindowsName%
    WinGui3PosX := WinGui2X + WinGui2W + 10
    WinGui3PosY := WinGui2Y
    
    If (DEBUG == 1)
      Gui, 3: Add, Text, , %WinGui2X%, %WinGui2Y%, %WinGui2W%, %WindowsName%
    
    Gui, 3: +ToolWindow
    Gui, 3: Show
    Gui, 3: Show, x%WinGui3PosX% y%WinGui3PosY% autosize, CritterList
    
    Loop {
      Sleep, 20
      WinGetPos, WinGui3X, WinGui3Y, , , CritterList
      
      If (WinGui3PosX <> WinGui3X OR WinGui3PosY <> WinGui3Y)
      {
        WinGetPos, WinGui2NewX, WinGui2NewY, WinGui2NewW, , %WindowsName%
        WinGui3NewPosX := WinGui2NewX + WinGui2NewW + 10
        WinGui3NewPosY := WinGui2NewY
        WinMove, CritterList, , %WinGui3NewPosX%, %WinGui3NewPosY%
      }
      
      ;break
    }
  }
  
  WinSet, ExStyle, +0x200000, CrittersList
  WinSet, ExStyle, -0x80000, %WindowsName%
  Winset, Redraw
  EmptyMem()
Return

HighlightPlayer:
{
  If A_GuiEvent = DoubleClick
  {
    GoSub ReadFromConfig
    
    MouseGetPos, , , , MapControl, 1              ; gets the control under mouse
    StringTrimLeft, MapStaticNbr, MapControl, 6   ; gets number of control
    ControlGetText, ResMapControl, %MapControl%   ; gets the text of Player Name
    
    If (DEBUG = 1)
      MsgBox, Which control: %MapControl%`nNumber: %MapStaticNbr%`nResult: %ResMapControl%
    
    If (PlayerMap == 1)
    {
      Accounts := BuildPlayerCache(TRACK_INI)
      Active := Accounts
      
      Loop, Parse, Active, |,
      {
        IniRead, Name, %TRACK_INI%, %A_LoopField%, PlayerName, ""
        
        If (ResMapControl == Name)
        {
          IniRead, LocX, %TRACK_INI%, %A_LoopField%, LocX, 0
          IniRead, LocY, %TRACK_INI%, %A_LoopField%, LocY, 0
          
          ResName := Name
        }
      }
      Name := ResName
    }
    
    If (CritterMap == 1)
    {
      Result := StrReplace(ResMapControl, ":", "")
      Result := StrReplace(Result, ")", "")
      Result := StrReplace(Result, "(", "")
      Result := StrReplace(Result, A_Space, "|")
      
      ResultArray := StrSplit(Result, "|")
      Name := ResultArray[2]
      LocX := ResultArray[3]
      LocY := ResultArray[4]
      
      Result := ""
    }
    
    If (PlaceableMap == 1)
    {
      Result := StrReplace(ResMapControl, ":", "")
      Result := StrReplace(Result, ")", "")
      Result := StrReplace(Result, "(", "")
      Result := StrReplace(Result, A_Space, "|")
      
      ResultArray := StrSplit(Result, "|")
      Name := ResultArray[1]
      LocX := ResultArray[2]
      LocY := ResultArray[3]
      
      Result := ""
    }
    
    LocX := Round(LocX)
    LocY := Round(LocY)
    
    NwnX := LocX
    NwnY := LocY
    
    ; get the map and its size, ex. 128x128
    GuiControlGet, Map, 2:Pos
    
    LocX := (LocX / 10) * FacX  ; for 14 it should now be 1,4, multiplied with map factor
    LocY := (LocY / 10) * FacY  ; for 15 it should now be 1,5, multiplied with map factor
    
    PosX := LocX  ; round to next number, so 44.8 should be 45. subtract that from the high of the picture to get the right coordinate
    PosY := (LocY-MapH)*(-1)  ; round to next number, 48 would be 48. nothing to round up to
    
    PosX :=  Round(PosX)  ; round to next number, 48 would be 48. nothing to round up to
    PosY :=  Round(PosY)  ; round to next number, so 44.8 should be 45. subtract that from the high of the picture to get the right coordinate
    
    If (CritterMap == 1)
      PosX := PosX - (WinGui2W + 10)
    
    If (DEBUG == 1)
      MsgBox, %Name% (%NwnX%/%NwnY%)`t(%PosY%/%PosX%)
    
    ToolTip, %Name%, PosX, PosY
    SetTimer, RemoveToolTip, 2500
  }
}
Return

HighlightPin:
{
  GoSub ReadFromConfig
  
  MouseGetPos, , , , MapPin, 1                            ; gets the control under mouse
  StringTrimLeft, MapPinStaticNbr, MapPin, 6              ; gets number of control
  MapPinStaticControl = HighlightPin_%MapPinStaticNbr%
  Temp := MapPinStaticNbr-2
  
  Loop, %ctdControl%
  {
    If (Temp <= 0)
    {
      Result := HighlightPin_%DEBUG%
      ToolTip, %Result%
      SetTimer, RemoveToolTip, 2500
      
      If (DEBUG = 0)
        return
    }
    
    Else If (A_Index = Temp)
    {
      Result := HighlightPin_%A_Index%
      ToolTip, %Result%
      SetTimer, RemoveToolTip, 2500
      
      If (DEBUG = 0)
        return
    }
  }
  
  If (DEBUG = 1)
    MsgBox, Counted Controls: %ctdControl%`nMapPin: %MapPin%`nStaicNbr: %MapPinStaticNbr%`nMapPinStaticControl: %MapPinStaticControl%`nTempNbr: %Temp%`nResult: %Result%
}
Return

RemoveToolTip:
  SetTimer, RemoveToolTip, Off
  ToolTip
return

Options:
  GoSub ReadFromConfig
  
  Gui, 1: +disabled
  Gui, 4: +owner1
  Gui, 4: +LastFound
  hGui := WinExist()
  
  ; Set up Gui, 4 style
  Gui, 4: Color, %BACKGROUND_COLOR%
  Gui, 4: Font, c%Font_COLOR% %Font_STYLE%, %Font_TYPE%
  
  Gui, 4: Add, Button, x10 y72 w75 h25 g4GuiSubmit, Ok
  Gui, 4: Add, Button, x88 y72 w75 h25 g4GuiClose, Cancel
  
  ; Style and Languages
  Gui, 4: Add, GroupBox, x10 y2 w180 h65, Style and Languages
  LangPos := GetTokenPosition(Options, Choosen)
  Gui, 4: Add, Button, x20 y17 w75 h20 gSelectFont, GuiFont
  Gui, 4: Add, Button, x103 y17 w75 h20 gSelectOptionsColor, GuiOptions  
  Gui, 4: Add, DDL, x20 y40 w160 vChangeLang Choose%LangPos%, %Options%
  
  ; Browse to Directories
  If (ExpertsMode == 1)
  {
    Gui, 4: Add, GroupBox, x188 y2 w290 h165, Directories
    
    Gui, 4: Add, Text, x202 y85 w60 h20, Map mode:
    Gui, 4: Add, Radio, x262 y85 w60 vMapModeGroup Checked%PlayerMap% vPlayerMap, Player
    Gui, 4: Add, Radio, x322 y85 w60 vMapModeGroup Checked%CritterMap% vCritterMap, Critter
    Gui, 4: Add, Radio, x382 y85 vMapModeGroup Checked%PlaceableMap% vPlaceableMap, Placeable
    
    Gui, 4: Add, Text, x202 y105 w60 h20, NWW Files:
    Gui, 4: Add, Edit, x262 y102 w160 h20 vNWN_DIR, %NWN_DIR%
    Gui, 4: Add, Button, x425 y102 w45 h20 gBrowseGameDirectory, Browse
    
    Gui, 4: Add, Text, x202 y145 w60 h20, Critterdata:
    Gui, 4: Add, Edit, x262 y142 w160 h20 vCRITTER_INI, %CRITTER_INI%
    Gui, 4: Add, Button, x425 y142 w45 h20 gBrowseCritkIni, Browse
    
    Gui, 4: Add, Text, x202 y125 w60 h20, Placeabledata:
    Gui, 4: Add, Edit, x262 y122 w160 h20 vPLC_INI, %PLC_INI%
    Gui, 4: Add, Button, x425 y122 w45 h20 gBrowsePlcIni, Browse
    
    Gui, 4: Add, GroupBox, x10 y100 w180 h67, GuiOptions
    Gui, 4: Add, Text, x15 y125 w60 h20, Rows in Gui:
    Gui, 4: Add, Edit, x80 y122 w60 h20 vGuiRow, %GuiRow%
  }
  Else
  {
    Gui, 4: Add, GroupBox, x188 y2 w290 h85, Directories
  }
  
  Gui, 4: Add, Text, x202 y25 w60 h20, Areadata:
  Gui, 4: Add, Edit, x262 y22 w160 h20 vAREA_INI, %AREA_INI%
  Gui, 4: Add, Button, x425 y22 w45 h20 gBrowseAreaIni, Browse
  
  Gui, 4: Add, Text, x202 y45 w60 h20, MiniMaps:
  Gui, 4: Add, Edit, x262 y42 w160 h20 vMAP_DIR, %MAP_DIR%
  Gui, 4: Add, Button, x425 y42 w45 h20 gBrowseMapDirectory, Browse
  
  Gui, 4: Add, Text, x202 y65 w60 h20, Playertrack:
  Gui, 4: Add, Edit, x262 y62 w160 h20 vTRACK_INI, %TRACK_INI%
  Gui, 4: Add, Button, x425 y62 w45 h20 gBrowseTrackIni, Browse
  
  Gui, 4: Show
  Gui, 4: Show, autosize center, Options
  WinSet, ExStyle, -0x80000, Options
  
  Winset, Redraw
  EmptyMem()
Return

4GuiSubmit:
  Gui, 4: Submit, NoHide
  
  ;-----write to Config.ini
  IniWrite, %NWN_DIR%, config.ini, Main, NWN_DIR
  IniWrite, %MAP_DIR%, config.ini, Main, MAP_DIR
  IniWrite, %TRACK_INI%, config.ini, Main, TRACK_INI
  
  IniWrite, %PlayerMap%, config.ini, Main, PlayerMap
  IniWrite, %CritterMap%, config.ini, Main, CritterMap
  IniWrite, %PlaceableMap%, config.ini, Main, PlaceableMap
  
  IniWrite, %CRITTER_INI%, config.ini, Main, CRITTER_INI
  IniWrite, %PLC_INI%, config.ini, Main, PLC_INI
  IniWrite, %AREA_INI%, config.ini, Main, AREA_INI
  
  IniWrite, %GuiRow%, config.ini, Main, GuiRow
  IniWrite, %ChangeLang%, config.ini, Languages, Choosen
  
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
  
  If (DEBUG == 1)
    MsgBox, %VERSION%`n%ExpertsMode%`n%DEBUG%`n%PlayerMap%`n%CritterMap%`n%PlaceableMap%`n%Options%`n%Choosen%`n%FONT_STYLE%`n%FONT_TYPE%`n%FONT_COLOR%`n%BACKGROUND_COLOR%`n%NWN_DIR%`n%MAP_DIR%`n%TRACK_INI%
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

BrowseCritkIni:
  FileSelectFile, SelectedFile, 3, %MAP_DIR%, Open a file, Critterdata (*.ini)
  If SelectedFile =
  MsgBox, MsgBoxBrowseFile
  Else
  {
    GuiControl, , CRITTER_INI, %SelectedFile%
    CRITTER_INI = %SelectedFile%
  }
Return

BrowsePlcIni:
  FileSelectFile, SelectedFile, 3, %MAP_DIR%, Open a file, Placeabledata (*.ini)
  If SelectedFile =
  MsgBox, MsgBoxBrowseFile
  Else
  {
    GuiControl, , PLC_INI, %SelectedFile%
    PLC_INI = %SelectedFile%
  }
Return

BrowseAreaIni:
  FileSelectFile, SelectedFile, 3, %MAP_DIR%, Open a file, Areadata (*.ini)
  If SelectedFile =
  MsgBox, MsgBoxBrowseFile
  Else
  {
    GuiControl, , AREA_INI, %SelectedFile%
    AREA_INI = %SelectedFile%
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

More:
  If NewName <> X-More
  {
    OldName = More
    NewName = X-More
    
    IniWrite, 1, config.ini, Main, ExpertsMode
  }
  Else
  {
    OldName = X-More
    NewName = More
    
    IniWrite, 0, config.ini, Main, ExpertsMode
    IniWrite, 1, config.ini, Main, PlayerMap
    IniWrite, 0, config.ini, Main, CritterMap
    IniWrite, 0, config.ini, Main, PlaceableMap
  }
  Menu, MyMenu, Rename, %OldName%, %NewName%
Return

X-More:
  If NewName <> More
  {
    OldName = X-More
    NewName = More
    
    IniWrite, 0, config.ini, Main, ExpertsMode
    IniWrite, 1, config.ini, Main, PlayerMap
    IniWrite, 0, config.ini, Main, CritterMap
    IniWrite, 0, config.ini, Main, PlaceableMap
  }
  Else
  {
    OldName = More
    NewName = X-More
    
    IniWrite, 1, config.ini, Main, ExpertsMode
  }
  Menu, MyMenu, Rename, %OldName%, %NewName%
Return

2GuiClose:
3GuiClose:
2GuiEscape:
3GuiEscape:
  GoSub RemoveToolTip
  Gui, 1: -Disabled ; Re-enable the main window (must be done prior to the next step).
  Gui, 2: Destroy
  Gui, 3: Destroy
  
  GoSub, ReloadIni
Return

4GuiClose:
4GuiEscape: 
  GoSub RemoveToolTip
  Gui, 1: -Disabled ; Re-enable the main window (must be done prior to the next step).
  Gui, 4: Destroy
Return

ReloadIni:
  Run, %EXE%
  GoSub, GuiClose
Return

; Ends app and destroys program
GuiClose:
  GoSub RemoveToolTip
  ExitApp