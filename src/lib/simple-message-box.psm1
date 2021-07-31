# Reference: https://michlstechblog.info/blog/powershell-show-a-messagebox/#:~:text=Sometimes%20while%20a%20powershell%20script,NET%20Windows.
function LoadSysForms() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    # Load assembly
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
}

function ShowMessage() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String]    $Title = "Insert title here",
        [Array]     $Message = 
        "Crash
         Bandicoot"
    )

    LoadSysForms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Demo: ShowMessage -Title "Title" -Message "Message"

function ShowQuestion() {

    param (
        [String]    $Title = "Insert title here",
        [Array]     $Message = 
        "Crash
         Bandicoot"
    )

    LoadSysForms
    $Answer = [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNoCancel, [System.Windows.Forms.MessageBoxIcon]::Question)

    return $Answer
}

# Example:
# $Question = ShowQuestion -Title "Title" -Message "Message"
# Returns Yes or No or Cancel