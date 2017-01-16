
#Persistent
#NoEnv
OnExit, GuiClose

;///////////////////////////////////////////////////////////////////////////////
;Configuration
;///////////////////////////////////////////////////////////////////////////////
    
;Use the Joystick Test Script to find desired joyNum and axes letters.
;https://autohotkey.com/docs/scripts/JoystickTest.htm
    
;X Y Z R U V

joyNum := "1"
axisRoll := "X"
axisPitch := "Y"
axisYaw := "R"
axisThrust := "U"

;Set window position and title.

windowX := "100"
windowY := "100"
windowTitle := "Joystick-Overlay"

;///////////////////////////////////////////////////////////////////////////////

Gui, Show, W200 H200 X%windowX% Y%windowY%, %windowTitle%

W:=200
H:=200

SetTimer, Disp, off
DllCall("DeleteObject", "UInt", hPen)
DllCall("DeleteObject", "UInt", hPen2)
hPen := DllCall("CreatePen", "UInt", 0, "UInt", 1, "UInt", 0xffccff)	;background
hPen2 := DllCall("CreatePen", "UInt", 0, "UInt", 0, "UInt", 0)	;axes and cursors
hBrush := DllCall("CreateSolidBrush", "UInt", 0xffccff, "Ptr")	;background
DllCall("ReleaseDC", "UInt", htx, "UInt", hdcMem)
hdcWin := DllCall("GetDC", "UPtr", hwnd:=WinExist(windowTitle))
hdcMem := DllCall("CreateCompatibleDC", "UPtr", hdcWin, "UPtr")
hbm := DllCall("CreateCompatibleBitmap", "UPtr", hdcWin, "int", W, "int", H, "UPtr")
hbmO := DllCall("SelectObject", "uint", hdcMem, "uint", hbm)
DllCall("SetROP2", "UInt", hdcMem, "UInt", 0x04)	;hex for SRCOPY mix mode

;update rate ~60Hz
SetTimer, Disp, 16
return

;draw and update loop
Disp:
;draw rect to wipe
	DllCall("SelectObject", "UInt", hdcMem, "UInt", hPen)	;select pen
	DllCall("SelectObject", "UInt", hdcMem, "UInt", hBrush)	;select brush
	DllCall("Rectangle", "UInt", hdcMem, "int", 0 , "int", 0, "int", W, "int", H)

;draw referece
	DllCall("SelectObject", "uint", hdcMem, "uint", hPen2)
	DllCall("MoveToEx", "UInt", hdcMem, "int", 0, "int", 99, "UInt", NULL)
	DllCall("LineTo", "UInt", hdcMem, "int", W, "int", 99)
	DllCall("MoveToEx", "UInt", hdcMem, "int", 99, "int", 0, "UInt", NULL)
	DllCall("LineTo", "UInt", hdcMem, "int", 99, "int", H)

;read axes
	x := GetKeyState(joyNum "Joy" axisRoll) * 2
	y := GetKeyState(joyNum "Joy" axisPitch) * 2
	r := GetKeyState(joyNum "Joy" axisYaw) * 2
	u := GetKeyState(joyNum "Joy" axisThrust) * 2

;draw pitch/roll
	DllCall("MoveToEx", "UInt", hdcMem, "int", x-4, "int", y, "UInt", NULL)
	DllCall("LineTo", "UInt", hdcMem, "int", x+5, "int", y)
	DllCall("MoveToEx", "UInt", hdcMem, "int", x, "int", y-4, "UInt", NULL)
	DllCall("LineTo", "UInt", hdcMem, "int", x, "int", y+5)

;draw yaw
	DllCall("MoveToEx", "UInt", hdcMem, "int", W-6, "int", r, "UInt", NULL)
	DllCall("LineTo", "UInt", hdcMem, "int", W, "int", r)

;draw thrust
	DllCall("MoveToEx", "UInt", hdcMem, "int", u, "int", H-6, "UInt", NULL)
	DllCall("LineTo", "UInt", hdcMem, "int", u, "int", H)

;update screen
	DllCall("BitBlt", "uint", hdcWin, "int", 0, "int", 0, "int", W, "int", H, "uint", hdcMem, "int", 0, "int", 0, "uint", 0xCC0020)	;hex code for SRCOPY raster-op code
	return
	
ExitSub:
GuiClose:
	DllCall("DeleteObject", "Ptr", hPen)
	DllCall("DeleteObject", "Ptr", hPen2)
	DllCall("DeleteObject", "Ptr", hBrush)
	DllCall("DeleteObject", "Ptr", hbm)
	DllCall("DeleteObject", "Ptr", hbmO)
	DllCall("DeleteDC", "Ptr", hdcMem)
	DllCall("ReleaseDC", "Ptr", hwnd, "UInt", hdcWin)
	ExitApp
