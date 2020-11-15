tell application "Things3"
	set collected_projects to {}
	repeat with pr in projects
		copy date of pr to end of collected_projects
	end repeat
	
	return collected_projects
end tell
