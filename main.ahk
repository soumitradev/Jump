#Persistent
#WinActivateForce
#NoEnv
#SingleInstance Force
SetControlDelay, 0
Setworkingdir %A_ScriptDir%

;===== Global Settings =====
iniWidth := 800					;initial width of gui
font = Roboto Mono
limit := findLimit(iniWidth)	;number of characters user can type before exceeding the width of the gui
guiWidth := iniWidth + 13*2		; 13 is the unreduceable left-margin spacing between gui and text
IniRead, workingDir, settings.ini, settings, workingDir
;===========================

;===== Tray Menu =====
Menu, Tray, NoStandard
Menu, Tray, Tip, Jump
Menu, Tray, Add, Jump, main
Menu, Tray, Add,
Menu, Tray, Add, Run at Startup, startup
Menu, Tray, Add
Menu, Tray, Add, Quit, quit
Menu, Tray, Default, Jump
;=====================



;===== GUI creation =====
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow
GuiHwnd := WinExist()
Gui, Color, 000000
Gui, Font, s11, %font% ;Set a large font size (32-point).
Gui, Add, Text, vMyText cWhite w%iniWidth% center, ;can put LEFT, CENTER, or RIGHT for text alignment
Winset, Transparent, 150
Gui, Submit
;========================

;===== Main Code =====
#Enter::
    WinGetActiveTitle, prevActive
    Gosub, main
return

main:
    Gui, Show, w%guiWidth%
	Gui, Add, Text, cWhite w%iniWidth% center,
    str =
    breakLoop := false
    goSub, enter			;entrance animation
    loop
    {
	    Gosub,inputChar		;input a character and show it on the GUI
	    if breakLoop
		    break
    }
    GoSub, evaluate		;evaluate inputted %str% and take action
    GoSub, exit			;exit animation
return

evaluate:
	if str = exit
		GoSub, quit
	IniRead, lookupLabel, settings.ini, lookups, %str%
	if lookupLabel != ERROR
	{
	    IniRead, argsNeeded, settings.ini, takesArgs, %str%
        if argsNeeded = false
        {
            Run %lookupLabel%, %workingDir%, UseErrorLevel	;quotes are used incase the input has spaces, so it is not treated as more than one parameter
			if ErrorLevel = ERROR
				GoSub, luError
			
        } else if argsNeeded = copy 
        {
            GoSub showLabel
            clipboard := str
            str = copied
            GuiControl,, MyText, %str%
            sleep 600
            GoSub, exit
        } else {
            GoSub showLabel
		    GoSub inputLookup

            
            Run %str%, %workingDir%, UseErrorLevel
			if ErrorLevel = ERROR
				GoSub, luError
        }
	}
	else
	{
        GuiControl,, MyText, ???
        sleep 400
        GoSub, exit
	}	
	goSub, exit
	
return

;===== Subroutines and Function(s) =====
inputChar:
	Input, char, L1 M,{enter}{space}{backspace}	;input a single character in %char%
	length := StrLen(char)
	if length = 0					;if true, the user has pressed one of the escape characters
	{
		if GetKeyState("Backspace","P")
			goSub, Backspace
		else						;a.k.a the user pressed enter, or space
			breakLoop := true
	}	
	
	charNumber := Asc(char)			;this returns whatever ascii # goes to the character in %char%
	
	if charNumber = 27 				;if the character is the ESC key
	{
		goSub, exit
	}
	
	else if charNumber = 22			;control-v			this section performs as paste from %clipboard%
	{
		str := str . clipboard
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			;if the clipboard causes the string to exceed the original limit
			;	aka if str>limit and (str-clipboard)<limit
			;if the clipboard simply addes to the extension past the original limit
			;	aka if str>limit and (str-clipboard)>limit
			if (StrLen(str)-StrLen(clipboard)) < limit			;pasting caused the string to exceed original %limit% (which never changes)
				theNumberOfOverFlowingCharacters := StrLen(str)-limit
			else if (StrLen(str)-StrLen(clipboard)) > limit		;pasting caused the string to add to the extension of the %limit%
				theNumberOfOverFlowingCharacters := StrLen(clipboard)
			loop %theNumberOfOverFlowingCharacters%
				GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
	}
	
	else if charNumber = 21				;control-U
	{
		str := str . "_"
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
		;check if activated lookup if char = space
	}
	else if charNumber = 3				;control-C		this section puts %str% in the clipboard and exits	
	{
		clipboard := str
		str = copied
		GuiControl,, MyText, %str%
		sleep 600
		GoSub, exit
	}
	
	else if charNumber > 31				;if the user inputted a normal character (all the nonsensical control characters are below 37)
	{
		str := str . char
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
	}
return

backspace:
	StringTrimRight, str, str, 1	;remove a character from the right side of %str%
	GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
	if StrLen(str) >= limit
		GoSub, decrementWidth
return


incrementWidth:
	guiWidth := guiWidth+10
	iniWidth := iniWidth+10
	Gui, Show, w%guiWidth% xCenter	;add xCenter if you want the box to be recentered for each resize
	GuiControl, Move, MyText, W%iniWidth%
return

decrementWidth:
	guiWidth := guiWidth-10
	iniWidth := iniWidth-10
	Gui, Show, w%guiWidth% xCenter	;add xCenter if you want the box to be recentered for each resize
	GuiControl, Move, MyText, W%iniWidth%
return

enter:
	Gui, Show, y-50 			;show window off-screenl
	WinGetPos,,,,height, A	 	;store GUI height (last parameter is the gui's title)
	Y := -height
	Gui, Show, xCenter y%Y% w%guiWidth%, %A_ScriptFullPath%	;position GUI just above top border
	increment := 10
	while Y < -increment		;increment gui into position
	{
		Y := Y + increment
		Gui, Show, y%Y%
		sleep 20
	}
	Gui, Show, y0 NoActivate
return

exit:
	Gosub, hide
exit

findLimit(iniWidth) {
	if (iniWidth/10 - round(iniWidth/10)) = 0
	{
		return iniWidth/10
	}
	else
	{
		return iniWidth/10 + 1
	}
}
showLabel:
	lookupkey := str				;error proccessing
	str := lookupLabel
	GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
return

hide:
    Y := 0
	while Y > (0-height)
	{
		Y := Y - 10
		Gui, Show, y%Y% NoActivate
		sleep 20
	}
	GuiControl,, MyText,
	Gui, Cancel
	iniWidth := 800
	limit := findLimit(iniWidth)
    guiWidth := iniWidth + 13*2	
	Gui, Show, w%guiWidth% xCenter	;add xCenter if you want the box to be recentered for each resize
	GuiControl, Move, MyText, W%iniWidth%
    WinActivate, %prevActive%
return

quit:
	WinGetPos,,gui_y,,, ahk_id %GuiHwnd%
	if(y > 0) {
		Gosub, exit
	}
ExitApp


inputChar4Lookup:
	Input, char, L1 M,{enter}{backspace}	;input a single character in %char%
	length := StrLen(char)
	if length = 0					;if true, the user has pressed enter, because enter is the escape character for the "Input" command
	{
		if GetKeyState("Backspace","P")
			goSub, Backspace
		else {
			StringRight, lookup, str, StrLen(str) - StrLen(lookupLabel)	;remove the label from %str% and output to %lookup%
			breakLoop := true
			Goto, end_of_subroutine
		}
	}	
	;msgbox You pressed %char%
	;Asc("")					;this would return 27 and corresponds to the ESC key
	charNumber := Asc(char)			;this returns whatever ascii # goes to the character in %char%
	
	if charNumber = 27 				;if the character is the ESC key
		goSub, exit
	
	else if charNumber = 22			;control-v			this section performs as paste from %clipboard%
	{
		str := str . clipboard
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			if StrLen(clipboard)>1000
			{	msgbox, clipboard is too large
				exitApp
			}
			
			if (StrLen(str)-StrLen(clipboard)) < limit			;pasting caused the string to exceed original %limit% (%limit% never changes after initial creation)
				theNumberOfOverFlowingCharacters := StrLen(str)-limit
			else if (StrLen(str)-StrLen(clipboard)) > limit		;pasting caused the string to add to the extension of the %limit%
				theNumberOfOverFlowingCharacters := StrLen(clipboard)
			loop %theNumberOfOverFlowingCharacters%
				GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
	}
    
	else if charNumber = 3				;control-C		this section puts %str% in the clipboard and exits	
	{
		clipboard := str
		str = copied
		GuiControl,, MyText, %str%
		sleep 600
		GoSub, exit
	}
	
	else if charNumber < 31
	{
		goSub, end_of_subroutine
	}
	
	else
	{
		str := str . char
		if StrLen(str) > limit			;if user's input is longer than the gui. (width of a Courier character = 8pixels)
		{	
			GoSub, incrementWidth
		}
		GuiControl,, MyText, %str% 		;updates the gui so change is seen immediately
		;check if activated lookup if char = space
	}
	end_of_subroutine:
return

inputLookup:
	breakLoop := false
	loop
	{
		GoSub inputChar4Lookup
		if breakLoop
			break
	}
return

luError:
	MsgBox, Command resulted in an error
	goSub, exit
return

startup:
Menu,Tray,Togglecheck,Run At Startup
IfExist, %a_startup%/Wofi.lnk
	FileDelete,%a_startup%/Wofi`.lnk
else
	FileCreateShortcut,%A_ScriptFullPath%,%A_Startup%/Wofi.lnk
return
