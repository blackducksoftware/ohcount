;; =================================================
;; Script: new-suffix.r
;; downloaded from: www.REBOL.org
;; on: 1-Jun-2011
;; at: 21:19:08.38986 UTC
;; owner: carl [script library member who can update
;; this script]
;; =================================================
REBOL [
    Title: "Change File Extensions (Suffix)"
    File: %new-suffix.r
    Author: "Carl Sassenrath"
    Date: 25-Jan-2005
    Purpose: {
        Change the file extension (suffix) for files with a specific extension.
        For example, change all .txt files to .r files in the current directory.
        Displays a list of changes before it makes them.
    }
    Warning: "Back up your files first, just in case!"
    License: "BSD - Use at your own risk."
    Library: [
        level: 'beginner
        platform: 'all
        type: [tool]
        domain: [files]
        tested-under: none
        support: none
        license: 'bsd
        see-also: none
    ]
]

from-suffix: %.txt
to-suffix:   %.r

bulk-rename: func [confirmed] [
    foreach file load %./ [
        if all [
            not find file #"/" ; (ignore directories)
            from-suffix = find/last file #"."
        ][
            new-file: copy file
            append clear find/last new-file #"." to-suffix
            either confirmed [
                print ["Renaming" file "to" new-file]
                rename file new-file
            ][
                print ["Will rename" file "to" new-file]
            ]
        ]
    ]
]

bulk-rename false
if not confirm "Are you sure you want to rename all those files?" [
    quit
]
bulk-rename true
ask "Done. Press enter."
