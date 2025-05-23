#!/usr/bin/env osascript
(*****************************************************************************************
 * CleanStart.applescript
 *
 * Clean start my system with of my favorite apps running and ready! 
 *
 * Author   :  Gary Ash <gary.ash@icloud.com>
 * Created  :  28-Feb-2025  6:44pm
 * Modified :  
 *
 * Copyright � 2024 By Gary Ash All rights reserved.
 ****************************************************************************************)

global appsList
set appsList to {�
	"Bartender 5", �
	"PasteBot", �
	"SnippetsLabLaunchd", �
	"Alfred 5", �
	"Dash", �
	"Mona", �
	"Moom", �
	"Keyboard Maestro Engine"}

(*======================================================================================*)

set volume with output muted
(*****************************************************************************************
 * Ensure the applet has assistive accesss to the system
 ****************************************************************************************)
set haveAssistiveAccess to 0
repeat while haveAssistiveAccess
	try
		tell application "System Events" to tell process "Finder"
			name of every menu of menu bar 1
			set haveAssistiveAccess to 1
		end tell
		
	on error errorMessage number errorNumber
		tell application "System Settings"
			set securityPane to pane id "com.apple.preference.security"
			tell securityPane to reveal anchor "Privacy_Accessibility"
			activate
		end tell
	end try
end repeat

set volume with output muted

tell application "System Events"
	set processList to �
		(name of every process where background only is false) as text
	
	set myFrontMost to name of first item of �
		(processes whose frontmost is true) as text
	
	repeat with processName in processList
		try
			if processName is not equal to myFrontMost then
				do shell script "Killall " & quoted form of processName
			end if
		end try
	end repeat
end tell
delay 0.8

repeat with theapp in appsList
	try
		if application theapp is not running then
			tell application theapp to launch
			repeat while application theapp is not running
				delay 0.1
			end repeat
			
			tell application "System Events"
				set visible of application process theapp to false
			end tell
			
		end if
	end try
end repeat

delay 0.5

(*****************************************************************************************
 * clean up Pastebot
 ****************************************************************************************)
try
	tell application "Pastebot" to quit
	delay 0.1
	tell application "Pastebot" to launch
	
	tell application "System Events" to tell process "Pastebot"
		set frontmost to true
		try
			delay 0.1
			tell application "Pastebot" to activate
			click menu item "Clear Clipboard" of menu 1 of menu bar item "Edit" of menu bar 1
			delay 0.01
			tell application "Pastebot" to activate
			
			keystroke tab
			delay 0.01
			tell application "Pastebot" to activate
			
			keystroke return
		end try
		delay 0.1
		tell application "Pastebot" to activate
		click menu item "Close Window" of menu 1 of menu bar item "File" of menu bar 1
	end tell
end try

(*****************************************************************************************
 * clean up Finder windows
 ****************************************************************************************)
tell application "Finder"
	repeat with w in (get every Finder window)
		try
			activate w
			tell application "System Events" to tell process "Finder"
				keystroke "a" using {command down}
				delay 0.05
				key code 123
				keystroke "a" using {command down, option down}
				delay 0.05
			end tell
		end try
	end repeat
	
	try
		set desktopBounds to bounds of window of desktop
		set w to round (((item 3 of desktopBounds) - 1100) / 2) rounding as taught in school
		set h to round (((item 4 of desktopBounds) - 1000) / 2) rounding as taught in school
		set finderBounds to {w, h, 1100 + w, 1000 + h}
	end try
	
	try
		set (bounds of window 1) to finderBounds
	on error
		make new Finder window to home
	end try
	set (bounds of window 1) to finderBounds
	close every window
	
	try
		tell application "Finder" to activate
		tell application "System Events" to tell process "Finder"
			click menu item "Clear Menu" of menu of menu item "Recent Items" of menu of menu bar item 1 of menu bar 1
			click menu item "Clear Menu" of menu of menu item "Recent Folders" of menu of menu bar item "Go" of menu bar 1
		end tell
	end try
	
	close every window
	
end tell

do shell script "killall Finder"

(*****************************************************************************************
 * Slack setup
 ****************************************************************************************)
if application "Slack" is running then
	try
		tell application "Slack" to activate
		delay 0.1
		tell application "Slack" to activate
		
		try
			tell application "System Events" to tell process "Slack"
				tell application "Slack" to activate
				keystroke "1" using {command down}
				
				delay 0.1
				
				repeat 20 times
					try
						tell application "Slack" to activate
						
						click menu item "All Unreads" of menu 1 of menu bar item "Go" of menu bar 1
						delay 0.01
						tell application "Slack" to activate
						
						repeat 30 times
							tell application "Slack" to activate
							key code 53
							delay 0.01
						end repeat
						delay 0.01
						tell application "Slack" to activate
						click menu item "Select Next Workspace" of menu of menu item "Workspace" of menu of menu bar item "File" of menu bar 1
					end try
				end repeat
				
				delay 0.1
				tell application "Slack" to activate
				keystroke "1" using {command down}
				delay 0.1
				click menu item "Close Window" of menu 1 of menu bar item "File" of menu bar 1
			end tell
		end try
	end try
end if

(******************************************************************************************
 * close any open windows
 *****************************************************************************************)
try
	activate application "Finder"
	tell application "System Events"
		set visible of processes where name is not "Finder" to false
	end tell
	tell application "Finder" to set collapsed of windows to true
end try

(*****************************************************************************************
 * setup Mona
 ****************************************************************************************)
if application "Mona" is running then
	try
		tell application "Mona" to activate
		tell application "System Events" to tell process "Mona"
			click menu item "Refresh" of menu 1 of menu bar item "File" of menu bar 1
			delay 0.2
			
			tell application "Mona" to activate
			key code 126 using {command down}
		end tell
	end try
end if

(******************************************************************************************
 * start SSH agent
 *****************************************************************************************)
set p to do shell script "ps -A"
if p does not contain "ssh-agent" then
	do shell script "ssh-add  --apple-load-keychain"
end if

(******************************************************************************************
 * set system speaker volume
 *****************************************************************************************)
try
	tell application "Finder" to activate
	set volume output volume 40
end try
