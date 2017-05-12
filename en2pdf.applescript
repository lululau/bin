tell application "Evernote"
    set root_path to POSIX path of "/Users/liuxiang/Desktop/ExportedEvernotes/"
    do shell script "mkdir -p " & root_path
    set html_path to root_path & "html/"
    do shell script "mkdir -p " & html_path
    set html_path to POSIX file html_path as alias
    set pdf_path to root_path & "pdf/"
    do shell script "mkdir -p " & pdf_path
    set a to selection
    repeat with nt in a
        set the_title to my replaceText(title of nt as text, ":", "--")
        
        set the_path to html_path & the_title as text
        set html_file to the_path & ":" & (title of nt as text) & ".html"
        set pdf_file to pdf_path & the_title & ".pdf"
        
        export {nt} to the_path format HTML
        
        tell application "Safari"
            activate
            open html_file as text
        end tell
        
        tell application "System Events" to tell process "Safari"
            keystroke "p" using {command down}
            repeat until exists sheet 1 of window 1
                delay 0.2
            end repeat
            tell the first pop up button of first sheet of front window
                click
                delay 0.2
                keystroke "A5"
                keystroke return
            end tell
            
            tell menu button "PDF" of sheet 1 of front window
                click
                delay 0.2
                click menu item "存储为 PDF…" of menu "PDF"
            end tell
            repeat until exists sheet 1 of sheet 1 of front window
                delay 0.2
            end repeat
            tell sheet 1 of sheet 1 of front window
                keystroke "g" using {command down, shift down}
                repeat until exists sheet 1
                    delay 0.2
                end repeat
                set value of text field 1 of sheet 1 to pdf_file
                click button "前往" of sheet 1
                
                click button "存储"
                
            end tell
            
            repeat while exists sheet 1 of window 1
                delay 0.2
            end repeat
            keystroke "w" using {command down}
        end tell
    end repeat
end tell

to replaceText(someText, oldItem, newItem)
    (*
     replace all occurances of oldItem with newItem
          parameters -     someText [text]: the text containing the item(s) to change
                    oldItem [text, list of text]: the item to be replaced
                    newItem [text]: the item to replace with
          returns [text]:     the text with the item(s) replaced
     *)
    set {tempTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, oldItem}
    try
        set {itemList, AppleScript's text item delimiters} to {text items of someText, newItem}
        set {someText, AppleScript's text item delimiters} to {itemList as text, tempTID}
    on error errorMessage number errorNumber -- oops
        set AppleScript's text item delimiters to tempTID
        error errorMessage number errorNumber -- pass it on
    end try
    
    return someText
end replaceText