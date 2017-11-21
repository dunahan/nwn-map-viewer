;=========================
;  NWN 1 - Server PW-Randomizer
;  Author: Tobias Wirth (dunahan@schwerterkueste.de)
;=========================
; v 0.9
; done some comments in script, calculation of coords from nwn to
; pixel is done by new implemented function
; 
;================
VERSION := "0.9"
;================

#NoTrayIcon
#NoEnv                  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force

;====================--------------------------------=====
;                                                Function Includes
;====================--------------------------------=====
#include pmcfunx.ahk

;====================--------------------------------=====
;                                                Persistent Variables
;====================--------------------------------=====
EXE := A_WorkingDir . "\NWN Map Creator.exe"
FacX := 32
FacY := 32
Gui1LoopY := 30
Gui1LoopX := 10

;====================--------------------------------=====
;                                                Main Scripts
;====================--------------------------------=====
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
  
  ; de-/activate more options for experienced users
  If (%ExpertsMode% = 0)
    Menu, MyMenu, Add, More
  Else
    Menu, MyMenu, Add, X-More
  
  Menu, MyMenu, Add, ShowAbout, ShowAbout
  Gui, 1: Menu, MyMenu
  
  ; BuildUp Player List
  If (PlayerMap = 1)
  {
    ; show upper row
    Gui, 1: Add, Text, x10  y10 w70  h20, Account
    Gui, 1: Add, Text, x+10 y10 w110 h20, Player Name
    Gui, 1: Add, Text, x+10 y10 w170 h20, Area Name
    Gui, 1: Add, Text, x+10 y10 w70  h20, Area ResRef
    Gui, 1: Add, Text, x+10 y10 w90  h20, Area Tag
    
    ; read through ini to build up player-cache
    Active := BuildPlayerCache(TRACK_INI)
    
    ; loop through player cache and list them
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
      
      ; go to next row
      Gui1LoopY := Gui1LoopY + 25
    }
    
    ; set name of window 
    MainWin = (PlayersMode)
  }
  
  ; BuildUp Critter Map List
  If (CritterMap = 1)
  {
    ; if no extra critter-list is specified then take the area-list
    If (CRITTER_INI = "")
      CRITTER_INI := AREA_INI
    
    ; build up critter cache
    IniRead, CritterMapArray, %CRITTER_INI%
    ; calculate the columns needed
    CritterMapToken := StrReplace(CritterMapArray, "`n", "|", MapNbr)
    Rows := Round(MapNbr/GuiRow)
    
    ; show first comment about how many maps and critters/npcs are used
    Gui, 1: Add, Text, x10  y10 w300 h20, %MapNbr% Maps with Critters/NPC's and %Rows%+1 per row
    
    ; first map
    MapsListed := 0
    ; loop through critter cache and build up map list
    Loop, Parse, CritterMapToken, |,
    {
      ; list map and connect it with it picture
      Gui, 1: Add, Text, x%Gui1LoopX% y%Gui1LoopY% w70 h20 cBlue gMapResRef, %A_LoopField%
      
      ; add up maps listened and go to next row
      MapsListed := MapsListed+1
      Gui1LoopY := Gui1LoopY + 25
      
      ; if the maximum maps per row are builded go to next column
      If (MapsListed > Rows)
      {
        Gui1LoopX := Gui1LoopX + 100
        Gui1LoopY := 30
        MapsListed := 0
      }
    }
    ; show window name
    MainWin = (CritterssMode)
  }
  
  ; BuildUp Placeable Map List, similar to critter list
  If (PlaceableMap = 1)
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
  
  ; submit all variables to memory so the are accessable to the program
  Gui, 1: Submit, NoHide
  
  ; set window-id to specified var, so it is accessable too
  hGui1 := WinExist()
  Gui, 1: Font, c000000 9, MS Sans SerIf
  Gui, 1: +E0x80000000
  
  ; persistent location of main window
  ; if those saved coordinates are false, set them to a normal state
  If (MWCX < 0 OR MWCY < 0)
  {
    MWCX := 512
    MWCY := 327
  }
  
  ; detect multi monitoring, so if switched to only one, this could be detected and corrected
  SysGet, MonitorCount, MonitorCount
  SysGet, MonitorPrimary, MonitorPrimary
  
  If (DEBUG = 1)
    MsgBox, Monitor Count:`t%MonitorCount%`nPrimary Monitor:`t%MonitorPrimary%
  
  ; loop through all monitors and build up max. coordinates
  Loop, %MonitorCount%
  {
    SysGet, MonitorName, MonitorName, %A_Index%
    SysGet, Monitor, Monitor, %A_Index%
    SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
    
    Mon%A_Index%  := Monitor
    MonR%A_Index% := MonitorWorkAreaRight
    MonB%A_Index% := MonitorWorkAreaBottom
    
    If (DEBUG = 1)
      MsgBox, Monitor:`t#%A_Index%`nName:`t%MonitorName%`nLeft:`t%MonitorLeft% (%MonitorWorkAreaLeft% work)`nTop:`t%MonitorTop% (%MonitorWorkAreaTop% work)`nRight:`t%MonitorRight% (%MonitorWorkAreaRight% work)`nBottom:`t%MonitorBottom% (%MonitorWorkAreaBottom% work)
  }
  
  ; if only one monitor is available and the window coordinates are
  ; way out of hell, set them to a normal state
  If (MonitorCount = 1)
  {
    If (MWCX > MonR1)
      MWCX := 512
    
    If (MWCY > MonB1)
      MWCY := 327
  }
  
  ; show up main window
  Gui, 1: Show, x%MWCX% y%MWCY% autosize, NWN Player Map Locator %MainWin% ;No translations needed!
  WinSet, ExStyle, -0x80000, NWN Player Map Locator %MainWin%  ;No translations needed!
  WinGet, MainWin
  
  ; get position of main window so we can save its location (not bad for multi monitoring)
  WinGetPos, WinGui1X, WinGui1Y, , , NWN Player Map Locator %MainWin%
  EmptyMem()
  
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
Return

;====================--------------------------------=====
;                                                Sub Routines
;====================--------------------------------=====

Account:
  MsgBox, Nothing to test
Return

PlayerName:
  ; if we clicked a name (mostly in blue) get those data for me
  If A_GuiEvent = DoubleClick
  {
    MouseGetPos, , , , PlayerNameControl, 1                     ; gets the control under mouse
    StringTrimLeft, StaticNbr, PlayerNameControl, 6             ; gets number of control
    ControlGetText, ResPlayerNameControl, %PlayerNameControl%   ; gets the text of Player Name
    
    Temp := StaticNbr+1
    ControlGetText, ResAreaNameControl, Static%Temp%            ; gets the text of AreaName
    Temp := StaticNbr+2
    ControlGetText, ResAreaResRefControl, Static%Temp%          ; gets the text of AreaResRef
    
    ; with those data's go to building a map
    GoSub MapBuild
  }
Return

MapResRef:
  ; same as clicking on a name
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
  ; read some data for configurations
  GoSub ReadFromConfig
  
  ; disable gui1 (main window) and set this window (map) as primary
  Gui, 1: +disabled
  Gui, 2: +owner1
  Gui, 2: +LastFound
  hGui2 := WinExist()
  
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
  
  If (DEBUG = 1)
    Gui, 2: Add, Text, x%MapPosX% y%PicY%, Width: %MapW%  Heigth: %MapH%`nPosMapX: %MapX% PosMapY: %MapY%`nMapGridX: %MapGridX% MapGridY: %MapGridY%
  
  ; build up area transitions cache
  IniRead, Triggers, %AREA_INI%, %ResAreaResRefControl%
  Triggers := StrReplace(Triggers, "name", "name", TriggersNbr)
  ctdControl := DEBUG
  
  ; create those collected area triggers/doors on the map picture
  Loop, %TriggersNbr%
  {
    ; read those coordinates
    IniRead, Tri%A_Index%X, %AREA_INI%, %ResAreaResRefControl%, loc%A_Index%x, 0
    IniRead, Tri%A_Index%Y, %AREA_INI%, %ResAreaResRefControl%, loc%A_Index%y, 0
    IniRead, cld%A_Index%, %AREA_INI%, %ResAreaResRefControl%, cld%A_Index%, 0
    
    If (DEBUG = 1)
    {
      DebTriX := Round(Tri%A_Index%X)
      DebTriY := Round(Tri%A_Index%Y)
    }
    
    ; calculate the coordinates from nwn to pixel on map
    TriX := Tri%A_Index%X
    TriY := Tri%A_Index%Y
    cld := cld%A_Index%
    
    Result := CalMapCoords(TriX, TriY, MapH, FacX, FacY)
    ResultArray := StrSplit(Result, "|")
    TriX := ResultArray[1]
    TriY := ResultArray[2]
    
    If (DEBUG = 1)
      MsgBox, Loopings: %Triggers%`nNbr: %A_Index%`nReal: %DebTriX%|%DebTriY%`nCoords: x%TriX%|y%TriY%
    
    ; add transition/door
    If (cld = 0)
      Gui, 2: Add, Picture, x%TriX% y%TriY% +BackgroundTrans, %A_WorkingDir%\icons\MapTransitionOpen.png  ; if useable
    Else
      Gui, 2: Add, Picture, x%TriX% y%TriY% +BackgroundTrans, %A_WorkingDir%\icons\MapTransitionClose.png ; if not useable
    ctdControl := ctdControl+1
  }
  
  ; BuildUp PlayerPins
  If (PlayerMap = 1)
  {
    ; loop through playerlist, are more players in this map? then list them
    Active := BuildPlayerCache(TRACK_INI)
    PlyPos := 10
    counted := 0
    
    Loop, Parse, Active, |,
    {
      IniRead, PlayerName, %TRACK_INI%, %A_LoopField%, PlayerName, ""
      IniRead, AreaResRef, %TRACK_INI%, %A_LoopField%, AreaResRef, ""
      
      ; is this area filled with players?
      If (AreaResRef = ResAreaResRefControl)
      {
        IniRead, LocX, %TRACK_INI%, %A_LoopField%, LocX, 0
        IniRead, LocY, %TRACK_INI%, %A_LoopField%, LocY, 0
        
        ; save coor of nwn to another var
        NwnX := Round(LocX)
        NwnY := Round(LocY)
        
        ; calculate nwn coords to pixel
        Result := CalMapCoords(LocX, LocY, MapH, FacX, FacY)
        ResultArray := StrSplit(Result, "|")
        PosX := ResultArray[1]
        PosY := ResultArray[2]
        
        ; build up Players List
        Gui, 2: Add, Text, x%PlyPos%  y%MapPosY% h20 gHighlightPlayer, %PlayerName%
        Gui, 2: Add, Text, x+10 y%MapPosY% h20, (%NwnX%|%NwnY%) ;| (%PosX%|%PosY%)
        ctdControl := ctdControl+2
        
        ; set MapPin visible
        Gui, 2: Add, Picture, x%PosX% y%PosY% +BackgroundTrans gHighlightPin, %A_WorkingDir%\icons\MapPlayerPinNWN.png
        HighlightPin_%ctdControl% := PlayerName
        
        ; if too many players are listened, get to the next row
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
    ; set windows name to area name
    IniRead, WindowsName, %AREA_INI%, %ResAreaResRefControl%, map, %ResAreaResRefControl%
    Result = 
    ResultArray = 
  }
  
  If (CritterMap = 1)
  {
    ; if no extra critter-list is specified then take the area-list
    If (CRITTER_INI = "")
      CRITTER_INI := AREA_INI
    
    ; set gui2 as owner of gui3 and gui4
    Gui, 3: +owner2
    Gui, 4: +owner2
    
    ; Set up Gui, 3 style
    Gui, 3: Color, %BACKGROUND_COLOR%
    Gui, 3: Font, c%Font_COLOR% %Font_STYLE%, %Font_TYPE%
    
    ; Set up Gui, 4 style
    Gui, 4: Color, %BACKGROUND_COLOR%
    Gui, 4: Font, c%Font_COLOR% %Font_STYLE%, %Font_TYPE%
    
    ; build up critter cache
    IniRead, CritterMapArray, %CRITTER_INI%
    CritterMapToken := StrReplace(CritterMapArray, "`n", "|")
    
    ; set starting values for building up map
    MapPosYGui3 := 10
    MapPosY := MapPosYGui3
    CritX := 10
    counted := 0
    
    ; build up Critters List
    Loop, Parse, CritterMapToken, |,
    {
      ; if the looping data equals the map choosen
      IfEqual, A_LoopField, %ResAreaResRefControl%
      {
        ; read all data from this map
        IniRead, Found, %CRITTER_INI%, %A_LoopField%
        
        ; loop through this data
        Loop, Parse, Found, `n,
        {
          ; format data to an readable array
          Result := StrReplace(A_LoopField, "=", "|")
          ResultArray := StrSplit(Result, "|")
          
          ; get the spawnconditions from this array
          Spawn :=  ResultArray[1]
          
          ; get all data from spawning waypoints
          IfInString, Spawn, spawnpoint
          {
            Spawn := SpawnPointName(Spawn)
            
            Name := ResultArray[2]
            
            If (Name != "")
            {
              HighlightPin_%ctdControl% := Name
              
              CriX := Round(ResultArray[4])
              CriY := Round(ResultArray[5])
              
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
            
            ; calculate coordinates from data to pixels
            ResultCoor := CalMapCoords(CriX, CriY, MapH, FacX, FacY)
            ResultCoorArray := StrSplit(ResultCoor, "|")
            CrtX := ResultCoorArray[1]
            CrtY := ResultCoorArray[2]
            
            ; build up already visible waypoints from module
            Gui, 3: Add, Text, x%CritX% y%MapPosY% h20 gHighlightPlayer, %Spawn% %Name% (%CriX%|%CriY%)`nCond: Spawn %SpwNb% every %Cycle%s  %SpwAl% %SpwGr% %SpwRW% %SpwPC%
            
            ; set MapPin visible
            Gui, 2: Add, Picture, x%CrtX% y%CrtY% +BackgroundTrans gHighlightPin, %A_WorkingDir%\icons\MapCritterPinNWN.png
            ctdControl := ctdControl+1
            
            ; if list data is exeeding column size, go to next row
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
    
    ; set windows name to area name
    IniRead, WindowsName, %AREA_INI%, %ResAreaResRefControl%, map, %ResAreaResRefControl%
    WindowsName = %WindowsName% (%ResAreaResRefControl%)
    
    ; clear all used vars (saving memory and against access probs)
    Result := ""
    ResultCoor := ""
    ResultArray := ""
    ResultCoorArray := ""
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
  
  If (PlaceableMap = 1)
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
              PlcX := Round(ResultArray[4])
              PlcY := Round(ResultArray[5])
              
              ; calculate coordinates from data to pixels
              ResultCoor := CalMapCoords(PlcX, PlcY, MapH, FacX, FacY)
              ResultCoorArray := StrSplit(ResultCoor, "|")
              PlpX := ResultCoorArray[1]
              PlpY := ResultCoorArray[2]
              
              ; add placeable data to list
              Gui, 2: Add, Text, x%PlcaX% y%MapPosY% h20 gHighlightPlayer, %Name% (%PlcX%|%PlcY%)
              ctdControl := ctdControl+1
              
              ; set MapPin visible
              Gui, 2: Add, Picture, x%PlpX% y%PlpY% +BackgroundTrans gHighlightPin, %A_WorkingDir%\icons\MapPlcPinNWN.png
              HighlightPin_%ctdControl% := Name
              
              ; if counted placeeables exeed column, switch to next row
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
    
    ; set windows name to area name
    IniRead, WindowsName, %AREA_INI%, %ResAreaResRefControl%, map, %ResAreaResRefControl%
    WindowsName = %WindowsName% (%ResAreaResRefControl%)
    
    ; clear all used vars
    Result := ""
    ResultCoor := ""
    ResultArray := ""
    ResultCoorArray := ""
    Name := ""
    PlcX := ""
    PlcY := ""
    PlpX := ""
    PlpY := ""
    counted := ""
  }
  
  ; set windows style to tools
  Gui, 2: +ToolWindow
  
  ; if saved location of tool window is not available (reset, newer installation and so on)
  ; set window to center
  If (CWCX < 0 OR CWCY < 0)
    Gui, 2: Show, center autosize, %WindowsName%
  Else
    Gui, 2: Show, x%CWCX% y%CWCY% autosize, %WindowsName%
  
  WinGet, BuildedMap
  
  ; look if critterlist of map has been moved
  If (CritterMap = 1)
  {
    WinGetPos, WinGui2X, WinGui2Y, WinGui2W, , %WindowsName%
    WinGui3PosX := WinGui2X + WinGui2W + 10
    WinGui3PosY := WinGui2Y
    
    If (DEBUG = 1)
      Gui, 3: Add, Text, , %WinGui2X%, %WinGui2Y%, %WinGui2W%, %WindowsName%
    
    Gui, 3: +ToolWindow
    Gui, 3: Show, x%WinGui3PosX% y%WinGui3PosY% autosize, CritterList
    WinGet, CritterWindow
    
    If (SpawnsEnabled = 1)
    {
      WinGetPos, WinGui2X, WinGui2Y, WinGui2W, , %WindowsName%
      WinGui4X := WinGui2X-156
      
      CRITTERPAL = %A_WorkingDir%\creaturepalcus.ini
      IniRead, Factions, %CRITTERPAL%
      Factions := StrReplace(Factions, "`n", "|")
      Gui, 4: Add, DDL, x5 y5 w125 vCFaction gCFaction, %Factions%
      Gui, 4: Add, DDL, hwndDDL_ID x5 y30 w125 vNameResult gSpawnResRef
      
      If (DEBUG = 1)
      {
        Gui, 4: Add, Text, x5 y55 vCritter, Spawning Critter
        Gui, 4: Add, Text, x5 y70 vResRef, ResRef of Critter
      }
      
      IniRead, Temp, %CRITTERPAL%, %CFaction%
      Temp := StrReplace(Temp, "`n", "|")
      
      Gui, 4: +ToolWindow
      
      If (DEBUG = 1)
        Gui, 4: Show, x%WinGui4X% y%WinGui2Y% w138 h100, SpawnThem
      Else
        Gui, 4: Show, x%WinGui4X% y%WinGui2Y% autosize, SpawnThem
        
      WinGet, SpawnWindow
    }
    
    Loop {
      Sleep, 20
      WinGetPos, WinGui3X, WinGui3Y, , , CritterList
      
      If (WinGui3PosX <> WinGui3X OR WinGui3PosY <> WinGui3Y)
      {
        WinGetPos, WinGui2NewX, WinGui2NewY, WinGui2NewW, , %WindowsName%
        IniWrite, %WinGui2NewX%, config.ini, Main, CWCX
        IniWrite, %WinGui2NewY%, config.ini, Main, CWCY
        
        WinGui3NewPosX := WinGui2NewX + WinGui2NewW + 10
        WinGui3NewPosY := WinGui2NewY
        
        WinGui4NewPosX := WinGui2NewX - 151
        WinGui4NewPosY := WinGui2NewY
        WinMove, CritterList, , %WinGui3NewPosX%, %WinGui3NewPosY%
        WinMove, SpawnThem, , %WinGui4NewPosX%, %WinGui4NewPosY%
      }
      
      ;break
    }
  }
  
  WinSet, ExStyle, +0x200000, CrittersList
  WinSet, ExStyle, +0x200000, SpawnThem
  WinSet, ExStyle, -0x80000, %WindowsName%
  Winset, Redraw
  EmptyMem()
  
Return

CFaction:
  SendMessage, 0x014E, -1, 0,, ahk_id %DDL_ID%  ;clears first choosen spawn from list
  GuiControl, , NameResult, |                   ;clears the ddlist fully
  
  NAMERES1 := ""
  Result1 := ""
  
  Gui, 4: Submit, NoHide
  
  If (DEBUG = 1)
    MsgBox, Submitting: %CFaction%
  
  IniRead, Temp, %CRITTERPAL%, %CFaction%
  Temp := StrReplace(Temp, "`n", "|")
  
  Loop, Parse, Temp, |,
  {
    IfInString, A_LoopField, NAME=
    {
      If (A_LoopField != "NAME=") ; if no name for the creature is available, dont put it in list
      {
        Result1 := StrReplace(A_LoopField, "NAME=", "")
        NAMERES1 = %NAMERES1%|%Result1%
      }
    }
    
    IfInString, A_LoopField, RESREF=
    {
      If (A_LoopField != "RESREF=") ; if no name for the creature is available, dont put it in list
      {
        Result2 := StrReplace(A_LoopField, "RESREF=", "")
        NAMERES2 = %NAMERES2%|%Result2%
      }
    }
  }
  
  StringTrimLeft, NAMERES1, NAMERES1, 1
  StringTrimLeft, NAMERES2, NAMERES2, 1
  
  If (DEBUG = 1)
    MsgBox, Result(s) Submitting: %NAMERES1%`nResult(s) Submitting: %NAMERES2%
  
  GuiControl, , NameResult, %NAMERES1%
Return

SpawnResRef:
  Gui, 4: Submit, NoHide
  
  GetPos := GetTokenPosition(NAMERES1, NameResult)
  ;ResRefResult := ""
  
  Loop, Parse, NAMERES2, |
  {
    If (A_Index = GetPos)
      ResRefResult := A_LoopField
  }
  
  If (DEBUG = 1)
  {
    MsgBox, Spawning %NameResult% with ResRef %ResRefResult%
    
    GuiControl, , Critter, Spawning: %NameResult%
    GuiControl, , ResRef, ResRef: %ResRefResult%
  }
  
  MsgBox, For spawning %NameResult%, click on map.
  
  WinActivate, BuildedMap
  
  GoSub SpawningClick
Return:

SpawningClick:
  
  
  
  ;Loop
  ;{
  ;  Sleep, 20
  ;  
  ;  If A_GuiEvent = DoubleClick
  ;  {
  ;    MouseGetPos, SpawnLocX, SpawnLocY, SpawnWindow, SpawnMapControl     ; stores the location
  ;    
  ;    If (BuildedMap = SpawnWindow)
  ;    {
  ;      MsgBox, Have you normal clicked?`nX-Coords: %SpawnLocX%`nY-Coords: %SpawnLocY%`nWindow-ID: %SpawnWindow%`nControl: %SpawnMapControl%`nMap: %ResAreaResRefControl%
  ;      
  ;      
  ;    }
  ;  }
  ;}
  
  
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
    
    If (PlayerMap = 1)
    {
      Active := BuildPlayerCache(TRACK_INI)
      
      
      Loop, Parse, Active, |,
      {
        IniRead, Name, %TRACK_INI%, %A_LoopField%, PlayerName, ""
        
        If (ResMapControl = Name)
        {
          IniRead, LocX, %TRACK_INI%, %A_LoopField%, LocX, 0
          IniRead, LocY, %TRACK_INI%, %A_LoopField%, LocY, 0
          
          ResName := Name
        }
      }
      Name := ResName
    }
    
    If (CritterMap = 1)
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
    
    If (PlaceableMap = 1)
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
    
    If (CritterMap = 1)
      PosX := PosX - (WinGui2W + 10)
    
    If (DEBUG = 1)
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
  Gui, 6: +owner1
  Gui, 6: +LastFound
  hGui6 := WinExist()
  
  ; Set up Gui, 6 style
  Gui, 6: Color, %BACKGROUND_COLOR%
  Gui, 6: Font, c%Font_COLOR% %Font_STYLE%, %Font_TYPE%
  
  Gui, 6: Add, Button, x10 y72 w75 h25 g6GuiSubmit, Ok
  Gui, 6: Add, Button, x88 y72 w75 h25 g6GuiClose, Cancel
  
  ; Style and Languages
  Gui, 6: Add, GroupBox, x10 y2 w180 h65, Style and Languages
  LangPos := GetTokenPosition(Options, Choosen)
  Gui, 6: Add, Button, x20 y17 w75 h20 gSelectFont, GuiFont
  Gui, 6: Add, Button, x103 y17 w75 h20 gSelectOptionsColor, GuiOptions  
  Gui, 6: Add, DDL, x20 y40 w160 vChangeLang Choose%LangPos%, %Options%
  
  ; Browse to Directories
  If (ExpertsMode = 1)
  {
    Gui, 6: Add, GroupBox, x188 y2 w290 h165, Directories
    
    Gui, 6: Add, Text, x202 y85 w60 h20, Map mode:
    Gui, 6: Add, Radio, x262 y85 w60 vMapModeGroup Checked%PlayerMap% vPlayerMap, Player
    Gui, 6: Add, Radio, x322 y85 w60 vMapModeGroup Checked%CritterMap% vCritterMap, Critter
    Gui, 6: Add, Radio, x382 y85 vMapModeGroup Checked%PlaceableMap% vPlaceableMap, Placeable
    
    Gui, 6: Add, Text, x202 y105 w60 h20, NWW Files:
    Gui, 6: Add, Edit, x262 y102 w160 h20 vNWN_DIR, %NWN_DIR%
    Gui, 6: Add, Button, x425 y102 w45 h20 gBrowseGameDirectory, Browse
    
    Gui, 6: Add, Text, x202 y145 w60 h20, Critterdata:
    Gui, 6: Add, Edit, x262 y142 w160 h20 vCRITTER_INI, %CRITTER_INI%
    Gui, 6: Add, Button, x425 y142 w45 h20 gBrowseCritkIni, Browse
    
    Gui, 6: Add, Text, x202 y125 w60 h20, Placeabledata:
    Gui, 6: Add, Edit, x262 y122 w160 h20 vPLC_INI, %PLC_INI%
    Gui, 6: Add, Button, x425 y122 w45 h20 gBrowsePlcIni, Browse
    
    Gui, 6: Add, GroupBox, x10 y100 w180 h67, GuiOptions
    Gui, 6: Add, Text, x20 y120 w60 h20, Rows in Gui:
    Gui, 6: Add, Edit, x85 y117 w60 h20 vGuiRow, %GuiRow%
    
    If (SpawnsEnabled = 1)
      Gui, 6: Add, Checkbox, x20 y140 h20 vSpawnsEnabled checked, Spawning enabled
    Else
      Gui, 6: Add, Checkbox, x20 y140 h20 vSpawnsEnabled, Spawning disabled
  }
  Else
  {
    Gui, 6: Add, GroupBox, x188 y2 w290 h85, Directories
  }
  
  Gui, 6: Add, Text, x202 y25 w60 h20, Areadata:
  Gui, 6: Add, Edit, x262 y22 w160 h20 vAREA_INI, %AREA_INI%
  Gui, 6: Add, Button, x425 y22 w45 h20 gBrowseAreaIni, Browse
  
  Gui, 6: Add, Text, x202 y45 w60 h20, MiniMaps:
  Gui, 6: Add, Edit, x262 y42 w160 h20 vMAP_DIR, %MAP_DIR%
  Gui, 6: Add, Button, x425 y42 w45 h20 gBrowseMapDirectory, Browse
  
  Gui, 6: Add, Text, x202 y65 w60 h20, Playertrack:
  Gui, 6: Add, Edit, x262 y62 w160 h20 vTRACK_INI, %TRACK_INI%
  Gui, 6: Add, Button, x425 y62 w45 h20 gBrowseTrackIni, Browse
  
  Gui, 6: Show, autosize center, Options
  WinSet, ExStyle, -0x80000, Options
  WinGet, OptionsWindow
  
  Winset, Redraw
  EmptyMem()
Return

6GuiSubmit:
  Gui, 6: Submit, NoHide
  
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
  IniWrite, %SpawnsEnabled%, config.ini, Main, SpawnsEnabled
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
  
  If (DEBUG = 1)
    MsgBox, %VERSION%`n%ExpertsMode%`n%DEBUG%`n%PlayerMap%`n%CritterMap%`n%PlaceableMap%`n%Options%`n%Choosen%`n%FONT_STYLE%`n%FONT_TYPE%`n%FONT_COLOR%`n%BACKGROUND_COLOR%`n%NWN_DIR%`n%MAP_DIR%`n%TRACK_INI%
Return

SelectOptionsColor:
  IniRead, BACKGROUND_COLOR, config.ini, Gui Options, Background_Color, D4D0C8
  
  If Dlg_Color(color := "0x" . OPTIONS_BKG_COLOR, hGui1)
  {
    IniWrite, %Color%, config.ini, Gui Options, Background_Color
  }
Return

SelectFont:
  IniRead, Font_STYLE, config.ini, Gui Options, Font_Style, 9
  IniRead, Font_TYPE, config.ini, Gui Options, Font_Type, MS Sans SerIf
  IniRead, Font_COLOR, config.ini, Gui Options, Font_Color, 000000
  
  If Dlg_Font( Font:=Font_TYPE, style:=Font_STYLE, color:= "0x" . Font_COLOR, true, hGui1)
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
4GuiClose:
2GuiEscape:
3GuiEscape:
4GuiEscape:
  WinGetPos, WinGui2X, WinGui2Y, , , %WindowsName%
  
  IniWrite, %WinGui2X%, config.ini, Main, CWCX
  IniWrite, %WinGui2Y%, config.ini, Main, CWCY
  
  GoSub RemoveToolTip
  Gui, 1: -Disabled ; Re-enable the main window (must be done prior to the next step).
  Gui, 2: Destroy
  Gui, 3: Destroy
  Gui, 4: Destroy
  
  GoSub, ReloadIni
Return

6GuiClose:
6GuiEscape: 
  GoSub RemoveToolTip
  Gui, 1: -Disabled ; Re-enable the main window (must be done prior to the next step).
  Gui, 6: Destroy
Return

ReloadIni:
  Run, %EXE%
  GoSub, GuiClose
Return

; Ends app, saves location of program and destroys it
GuiClose:
  WinGetPos, WinGuiNew1X, WinGuiNew1Y, , , NWN Player Map Locator %MainWin%
  
  IniWrite, %WinGuiNew1X%, config.ini, Main, MWCX
  IniWrite, %WinGuiNew1Y%, config.ini, Main, MWCY
  
  GoSub RemoveToolTip
  ExitApp