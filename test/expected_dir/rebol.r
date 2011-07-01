rebol	comment	;; =================================================
rebol	comment	;; Script: new-suffix.r
rebol	comment	;; downloaded from: www.REBOL.org
rebol	comment	;; on: 1-Jun-2011
rebol	comment	;; at: 21:19:08.38986 UTC
rebol	comment	;; owner: carl [script library member who can update
rebol	comment	;; this script]
rebol	comment	;; =================================================
rebol	code	REBOL [
rebol	code	    Title: "Change File Extensions (Suffix)"
rebol	code	    File: %new-suffix.r
rebol	code	    Author: "Carl Sassenrath"
rebol	code	    Date: 25-Jan-2005
rebol	code	    Purpose: {
rebol	code	        Change the file extension (suffix) for files with a specific extension.
rebol	code	        For example, change all .txt files to .r files in the current directory.
rebol	code	        Displays a list of changes before it makes them.
rebol	code	    }
rebol	code	    Warning: "Back up your files first, just in case!"
rebol	code	    License: "BSD - Use at your own risk."
rebol	code	    Library: [
rebol	code	        level: 'beginner
rebol	code	        platform: 'all
rebol	code	        type: [tool]
rebol	code	        domain: [files]
rebol	code	        tested-under: none
rebol	code	        support: none
rebol	code	        license: 'bsd
rebol	code	        see-also: none
rebol	code	    ]
rebol	code	]
rebol	blank	
rebol	code	from-suffix: %.txt
rebol	code	to-suffix:   %.r
rebol	blank	
rebol	code	bulk-rename: func [confirmed] [
rebol	code	    foreach file load %./ [
rebol	code	        if all [
rebol	code	            not find file #"/" ; (ignore directories)
rebol	code	            from-suffix = find/last file #"."
rebol	code	        ][
rebol	code	            new-file: copy file
rebol	code	            append clear find/last new-file #"." to-suffix
rebol	code	            either confirmed [
rebol	code	                print ["Renaming" file "to" new-file]
rebol	code	                rename file new-file
rebol	code	            ][
rebol	code	                print ["Will rename" file "to" new-file]
rebol	code	            ]
rebol	code	        ]
rebol	code	    ]
rebol	code	]
rebol	blank	
rebol	code	bulk-rename false
rebol	code	if not confirm "Are you sure you want to rename all those files?" [
rebol	code	    quit
rebol	code	]
rebol	code	bulk-rename true
rebol	code	ask "Done. Press enter."
