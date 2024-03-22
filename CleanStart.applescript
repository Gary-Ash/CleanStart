#!/usr/bin/env osascript
(*****************************************************************************************
 * CleanStart.applescript
 *
 * Clean start my system with of my favorite apps running and ready! 
 *
 * Author   :  Gary Ash <gary.ash@icloud.com>
 * Created  :  17-Sep-2022  2:19pm
 * Modified :  21-Mar-2024  8:29pm
 *
 * Copyright © 2020-2024 By Gee Dbl A All rights reserved.
 ****************************************************************************************)

global appsList
set appsList to {Â
	"Bartender 5", Â
	"PasteBot", Â
	"SnippetsLab", Â
	"Alfred 5", Â
	"Dash", Â
	"Moom", Â
	"Slack", Â
	"ColorSnapper2", Â
	"Mona", Â
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

repeat with theapp in appsList
	try
		repeat while application theapp is not running
			tell application theapp to launch
			delay 0.01
		end repeat
	end try
end repeat

delay 5

(*****************************************************************************************
 * clean up Keyboard Maestro
 ****************************************************************************************)
try
	tell application "Keyboard Maestro" to quit
end try
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
 * ColorSnapper setup
 ****************************************************************************************)
try
	tell application "System Events" to tell process "ColorSnapper2"
		set frontmost to true
		tell application "ColorSnapper2" to activate
		key code 53
	end tell
end try
delay 0.1

(*****************************************************************************************
 * try to deal with occasional problem that Alfred has connecting to iCloud by
 * quitting, pausing and re-launching it
 ****************************************************************************************)
repeat while true
	tell application "System Events" to tell process "Alfred"
		if exists button "Quit" of window 1 then
			click button "Quit" of window 1
			
			set userLibraryFolder to path to library folder from user domain
			tell application "Finder"
				reopen
				activate
				set iCloudDriveFolder to folder "Data" of folder "iCloud Drive" of folder "Mobile Documents" of userLibraryFolder
				set target of Finder window 1 to iCloudDriveFolder
				select item named "Alfred.alfredpreferences" in Finder window 1
				tell application "System Events" to tell process "Finder"
					set _selection to value of attribute "AXFocusedUIElement"
					tell _selection to perform action "AXShowMenu"
					delay 0.2
					keystroke "Download Now"
					keystroke return
					delay 55
					tell application "Alfred 5" to launch
				end tell
			end tell
		else
			exit repeat
		end if
	end tell
end repeat

(*****************************************************************************************
 * try to deal with occasional problem that SnippetsLab has connecting to iCloud by
 * quitting, pausing and re-launching it
 ****************************************************************************************)
tell application "System Events" to tell process "SnippetsLab"
	if exists button "OK" of sheet 1 of window 1 then
		click button "OK" of sheet 1 of window 1
		tell application "SnippetsLab" to quit
		delay 1
		tell application "SnippetsLab" to launch
	end if
	
	tell application "System Events" to tell process "SnippetsLab"
		delay 1
		tell application "SnippetsLab" to activate
		keystroke "w" using {command down}
	end tell
end tell


tell application "Keyboard Maestro" to quit
(*****************************************************************************************
 * make sure the Desktop has focus, previous version always let a window in focus and I'd
 * end up closing it mistake
 ****************************************************************************************)
tell application "Finder" to activate

(*****************************************************************************************
 * clean up Finder windows
 ****************************************************************************************)
tell application "Finder"
	repeat with w in (get every Finder window)
		activate w
		tell application "System Events" to tell process "Finder"
			keystroke "a" using {command down}
			delay 0.05
			key code 123
			keystroke "a" using {command down, option down}
			delay 0.05
		end tell
	end repeat
	
	set desktopBounds to bounds of window of desktop
	set w to round (((item 3 of desktopBounds) - 1100) / 2) rounding as taught in school
	set h to round (((item 4 of desktopBounds) - 1000) / 2) rounding as taught in school
	set finderBounds to {w, h, 1100 + w, 1000 + h}
	
	try
		set (bounds of window 1) to finderBounds
	on error
		make new Finder window to home
	end try
	set (bounds of window 1) to finderBounds
	close every window
	
	tell application "System Events" to tell process "Finder"
		click menu item "Clear Menu" of menu of menu item "Recent Items" of menu of menu bar item 1 of menu bar 1
		click menu item "Clear Menu" of menu of menu item "Recent Folders" of menu of menu bar item "Go" of menu bar 1
	end tell
end tell

(*****************************************************************************************
 * setup Mona
 ****************************************************************************************)
if application "Mona" is running then
	delay 5
	
	try
		repeat 4 times
			tell application "Mona" to activate
			tell application "System Events" to tell process "Mona"
				click menu item "Refresh" of menu 1 of menu bar item "File" of menu bar 1
				key code 126 using {command down}
			end tell
			delay 0.05
		end repeat
	end try
end if

(*****************************************************************************************
 * Slack setup
 ****************************************************************************************)
if application "Slack" is running then
	try
		tell application "Slack" to activate
		delay 0.4
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

tell application "Finder" to activate
tell application "System Events"
	repeat 4 times
		click group 1 of scroll area 1 of application process "Finder"
	end repeat
end tell

(******************************************************************************************
 * close any open windows
 *****************************************************************************************)
activate application "Finder"
tell application "System Events"
	set visible of processes where name is not "Finder" to false
end tell
tell application "Finder" to set collapsed of windows to true
activate application "Mona"

(******************************************************************************************
 * Clean up the Mona window
 *****************************************************************************************)
tell application "System Events" to tell process "Mona"
	click menu item "Close" of menu 1 of menu bar item "File" of menu bar 1
	delay 0.1
	
	click menu item "New Window" of menu 1 of menu bar item "File" of menu bar 1
	delay 0.1
end tell

(******************************************************************************************
 * start SSH agent
 *****************************************************************************************)
do shell script "ssh-agent -s;ssh-add  --apple-load-keychain"

(******************************************************************************************
 * shutdown iTerm if it's running
 *****************************************************************************************)
try
	tell application "iTerm"
		quit
	end tell
end try

set volume output volume 50
delay 0.1

tell application "Finder" to quit
delay 2
launch application "Finder"

