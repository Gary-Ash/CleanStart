#!/usr/bin/env osascript
(*****************************************************************************************
 * CleanStart.applescript
 *
 * Clean start my system with my favorite apps running and ready!
 *
 * Author   :  Gary Ash <gary.ash@icloud.com>
 * Created  :   3-Feb-2026  8:20pm
 * Modified : 16-Sep-2026  8:09pm
 *
 * Copyright © 2026 By Gary Ash All rights reserved.
 *****************************************************************************************)

property appsList : {"Pastebot", "Mona", "Moom"}

on run
	(*****************************************************************************************
	 * Everything happens inside the run handler.
	 *
	 * Keeping the applet's work here makes its lifecycle explicit and allows us to
	 * unconditionally terminate the applet when the work is complete.
	 *****************************************************************************************)
	try
		set volume with output muted
		
		my ensureAssistiveAccess()
		my terminateForegroundApps()
		my launchFavoriteApps()
		my startSSHAgent()
		my cleanPasteBot()
		my setupSnippetsLab()
		my setupMona()
		my cleanSlack()
		my cleanFinder()
		
	on error errorMessage number errorNumber
		try
			log ("CleanStart error " & errorNumber & ": " & errorMessage)
		end try
	end try
	
	set volume output volume 40
	
	(*****************************************************************************************
	 * Explicitly terminate the applet.
	 *****************************************************************************************)
	tell me to quit
end run

(*****************************************************************************************
 * Ensure the applet has Accessibility access to the system.
 *****************************************************************************************)
on ensureAssistiveAccess()
	set haveAssistiveAccess to false
	
	repeat until haveAssistiveAccess
		try
			tell application "System Events" to tell process "Finder"
				name of every menu of menu bar 1
				set haveAssistiveAccess to true
			end tell
			
		on error
			tell application "System Settings"
				set securityPane to pane id "com.apple.preference.security"
				tell securityPane to reveal anchor "Privacy_Accessibility"
				activate
			end tell
			
			delay 1
		end try
	end repeat
end ensureAssistiveAccess

(*****************************************************************************************
 * Terminate all foreground applications except this applet.
 *****************************************************************************************)
on terminateForegroundApps()
	set myProcessName to name of me
	
	tell application "System Events"
		try
			set processList to name of every process where background only is false
			
			repeat with processName in processList
				try
					if (processName as text) is not equal to myProcessName then
						do shell script "killall " & quoted form of (processName as text)
						delay 0.15
					end if
				end try
			end repeat
		end try
	end tell
end terminateForegroundApps

(*****************************************************************************************
 * Launch favorite applications and hide them after they have started.
 *
 * The wait for each application to come up is protected by a 12-second timeout.
 *****************************************************************************************)
on launchFavoriteApps()
	repeat with theApp in appsList
		try
			set appName to theApp as text
			
			if application appName is not running then
				tell application appName to launch
				
				set startTime to current date
				
				repeat while application appName is not running
					if (current date) - startTime > 12 then exit repeat
					delay 0.15
				end repeat
				
				tell application "System Events"
					set visible of application process appName to false
				end tell
			end if
		end try
	end repeat
end launchFavoriteApps

(*****************************************************************************************
 * Start SSH agent so git commit signing works without having to think about it.
 *****************************************************************************************)
on startSSHAgent()
	try
		set p to do shell script "ps -A"
		
		if p does not contain "ssh-agent" then
			do shell script "ssh-add --apple-load-keychain >/dev/null 2>&1"
		end if
	end try
end startSSHAgent

(*****************************************************************************************
 * Clean up Pastebot.
 *****************************************************************************************)
on cleanPasteBot()
	try
		tell application "Pastebot" to activate
		delay 0.5
		
		tell application "System Events" to tell process "Pastebot"
			set frontmost to true
			
			try
				tell application "Pastebot" to activate
				
				click menu item "Clear Clipboard" of Â
					menu 1 of menu bar item "Edit" of menu bar 1
				
				delay 0.2
				
				try
					click button "Clear" of sheet 1 of window 1
				on error
					try
						click button "Clear" of window 1
					end try
				end try
			end try
		end tell
	end try
end cleanPasteBot

(*****************************************************************************************
 * SnippetsLab setup.
 *
 * Starts SnippetsLab if necessary, waits for its window, then closes all windows.
 * Each wait is protected by a 12-second timeout.
 *****************************************************************************************)
on setupSnippetsLab()
	if application "SnippetsLab" is not running then
		try
			tell application "SnippetsLab" to activate
			
			tell application "System Events"
				set startTime to current date
				
				repeat until exists process "SnippetsLab"
					if (current date) - startTime > 12 then exit repeat
					delay 0.1
				end repeat
				
				set startTime to current date
				
				tell process "SnippetsLab"
					repeat until (count of windows) > 0
						if (current date) - startTime > 12 then exit repeat
						delay 0.1
					end repeat
				end tell
				
				set startTime to current date
				
				tell process "SnippetsLab"
					repeat while (count of windows) > 0
						if (current date) - startTime > 12 then exit repeat
						delay 0.1
						
						tell application "SnippetsLab" to activate
						keystroke "w" using command down
					end repeat
				end tell
			end tell
		end try
	end if
end setupSnippetsLab

(*****************************************************************************************
 * Set up Mona.
 *****************************************************************************************)
on setupMona()
	try
		if application "Mona" is running then
			tell application "Mona" to activate
			delay 1.5
			
			tell application "System Events" to tell process "Mona"
				click menu item "Refresh" of Â
					menu 1 of menu bar item "File" of menu bar 1
				
				delay 1.5
				
				tell application "Mona" to activate
				
				key code 126 using command down
				delay 0.1
				key code 126 using command down
				
				tell application "Finder" to activate
			end tell
		end if
	end try
end setupMona

(*****************************************************************************************
 * Slack cleanup.
 *****************************************************************************************)
on cleanSlack()
	if application "Slack" is running then
		try
			tell application "Slack" to activate
			delay 0.1
			
			try
				tell application "System Events" to tell process "Slack"
					tell application "Slack" to activate
					keystroke "1" using {command down}
					
					delay 0.1
					
					repeat 10 times
						try
							tell application "Slack" to activate
							
							click menu item "All Unreads" of Â
								menu 1 of menu bar item "Go" of menu bar 1
							
							delay 0.01
							
							tell application "Slack" to activate
							key code 53 using {shift down}
							
							click menu item "Select Next Workspace" of Â
								menu of menu item "Workspace" of Â
								menu of menu bar item "File" of menu bar 1
						end try
					end repeat
					
					delay 0.1
					
					tell application "Slack" to activate
					keystroke "1" using {command down}
					
					delay 0.1
					
					click menu item "Close Window" of Â
						menu 1 of menu bar item "File" of menu bar 1
				end tell
			end try
		end try
	end if
end cleanSlack

(*****************************************************************************************
 * Clean up Finder windows.
 *****************************************************************************************)
on cleanFinder()
	try
		tell application "Finder"
			set desktopBounds to bounds of window of desktop
			
			set windowX to round (((item 3 of desktopBounds) - 1100) / 2)
			set windowY to round (((item 4 of desktopBounds) - 1000) / 2)
			set finderBounds to {windowX, windowY, windowX + 1100, windowY + 1000}
			
			activate
			open (path to home folder)
			delay 0.5
			
			set windowList to every Finder window
			
			repeat with aWindow in windowList
				activate
				set index of aWindow to 1
				delay 0.3
				
				(* Collapsing an empty window beeps, so ask Finder before sending the keys. *)
				set folderHasItems to false
				try
					set folderHasItems to ((count of items of (target of aWindow)) > 0)
				end try
				
				tell application "System Events" to tell process "Finder"
					set editMenu to menu 1 of menu bar item "Edit" of menu bar 1
					
					if folderHasItems then
						click menu item "Select All" of editMenu
						delay 0.1
						key code 123 -- Left Arrow
					end if
					
					set bounds of aWindow to finderBounds
					
					click menu item "Deselect All" of editMenu
					delay 0.1
					
					close aWindow
				end tell
			end repeat
			
			open (path to downloads folder)
			delay 0.5
			
			set current view of Finder window 1 to list view
			set downloadsHasItems to ((count of items of folder (path to downloads folder)) > 0)
			
			tell application "System Events" to tell process "Finder"
				keystroke "j" using command down
				delay 1
				
				tell group 1 of window 1
					repeat with colName in {"Size", "Kind", "Date Created", "Date Modified"}
						if value of checkbox colName is 0 then
							click checkbox colName
						end if
					end repeat
					
					repeat with colName in {"Date Added", "Date Last Opened", "iCloud Status", Â
						"Last Modified By", "Shared By", "Version", "Comments", "Tags"}
						
						if value of checkbox colName is 1 then
							click checkbox colName
						end if
					end repeat
					
					keystroke "j" using command down
				end tell
				
				set editMenu to menu 1 of menu bar item "Edit" of menu bar 1
				
				if downloadsHasItems then
					click menu item "Select All" of editMenu
					delay 0.1
					key code 123 -- Left Arrow
				end if
				
				click menu item "Clear Menu" of Â
					menu of menu item "Recent Items" of Â
					menu of menu bar item "Apple" of menu bar 1
				
				click menu item "Clear Menu" of Â
					menu of menu item "Recent Folders" of Â
					menu of menu bar item "Go" of menu bar 1
			end tell
			
			set bounds of Finder window 1 to finderBounds
			delay 0.1
			close every Finder window
		end tell
	end try
end cleanFinder
