#!/usr/bin/env osascript
(*****************************************************************************************
 * CleanStart.applescript
 *
 * Clean start my system with of my favorite apps running and ready! 
 *
 * Author   :  Gary Ash <gary.ash@icloud.com>
 * Created  :  12-Jun-2020  5:38pm
 * Modified :  27-Feb-2021  4:25pm
 *
 * Copyright © 2020-2021 By Gee Dbl A All rights reserved.
 ****************************************************************************************)

set appsList to {Â
	"PasteBot", Â
	"Twitter", Â
	"SnippetsLab", Â
	"Alfred 4", Â
	"Dash", Â
	"Magnet", Â
	"ColorSnapper2", Â
	"PopHub", Â
	"Default Folder X", Â
	"Keyboard Maestro Engine"}
(*======================================================================================*)

(*****************************************************************************************
 * Ensure the applet has assistive accesss to the system
 ****************************************************************************************)
set haveAssistiveAccess to 0
repeat while haveAssistiveAccess ­ 1
	try
		tell application "System Events" to tell process "Finder"
			name of every menu of menu bar 1
			set haveAssistiveAccess to 1
		end tell
		
	on error errorMessage number errorNumber
		tell application "System Preferences"
			set securityPane to pane id "com.apple.preference.security"
			tell securityPane to reveal anchor "Privacy_Accessibility"
			activate
		end tell
	end try
end repeat


set volume with output muted

repeat with theapp in appsList
	try
		repeat while application theapp is running
			tell application theapp to quit
		end repeat
	end try
end repeat

repeat with theapp in appsList
	try
		repeat while application theapp is not running
			tell application theapp to launch
		end repeat
	end try
end repeat
delay 2

(*****************************************************************************************
 * PasteBot setup
 ****************************************************************************************)
try
	tell application "System Events" to tell process "Pastebot"
		set frontmost to true
		try
			delay 0.1
			click menu item "Clear Clipboard" of menu 1 of menu bar item "Edit" of menu bar 1
			delay 0.1
			click button "Clear" of window ""
		end try
		delay 0.05
		click menu item "Close Window" of menu 1 of menu bar item "File" of menu bar 1
	end tell
end try


(*****************************************************************************************
 * ColorSnapper setup
 ****************************************************************************************)
try
	tell application "System Events" to tell process "ColorSnapper2"
		set frontmost to true
		key code 53
	end tell
end try

(*****************************************************************************************
 * clean up Twitterrific windows
 ****************************************************************************************)
tell application "System Events"
	set twitterrific to (path to applications folder as text) & "Twitterrific.app"
	
	if exists folder twitterrific then
		tell application "System Events" to tell process "Twitterrific"
			set frontmost to true
			delay 0.5
			click menu item "PreferencesÉ" of menu 1 of menu bar item "Twitterrific" of menu bar 1
			click button "Accounts" of toolbar 1 of window "Preferences"
			click button "Clear Cache" of window "Preferences"
			click button "OK" of sheet 1 of window "Preferences"
			click button "General" of toolbar 1 of window "Preferences"
			click button 1 of window "Preferences"
			
			click checkbox 2 of window 1
			delay 0.1
			repeat 10 times
				key code 126 using {command down}
				delay 1
			end repeat
		end tell
		
		delay 3.5
		tell application "System Events"
			click UI element "Twitterrific" of list 1 of application process "Dock"
		end tell
		
		tell application "System Events" to tell process "Twitterrific"
			set frontmost to true
			click checkbox 2 of window 1
			delay 0.05
			click checkbox 1 of window 1
		end tell
	end if
end tell

(*****************************************************************************************
 * clean up Twitter windows
 ****************************************************************************************)
if application "Twitter" is running then
	try
		tell application "Twitter" to activate
		tell application "System Events" to tell process "Twitter"
			click menu item "Home" of menu 1 of menu bar item "View" of menu bar 1
		end tell
	end try
end if

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
					delay 35
					tell application "Alfred 4" to launch
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
end tell

(*****************************************************************************************
 * Slack setup
 ****************************************************************************************)
if application "Slack" is running then
	try
		tell application "Slack"
			activate
			delay 0.2
			close window 1
		end tell
	end try
end if
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

set volume output volume 50 with output muted --100%
set volume without output muted

(*****************************************************************************************
 * if iTerm is running activate it
 ****************************************************************************************)
if application "iTerm" is running then
	tell application "iTerm"
		activate
	end tell
end if
