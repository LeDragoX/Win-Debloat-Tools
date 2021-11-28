# Reference: https://michlstechblog.info/blog/powershell-show-a-messagebox/#:~:text=Sometimes%20while%20a%20powershell%20script,NET%20Windows.
function Use-SysForms() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    # Load assembly
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
}

function Show-Message() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String]    $Title = "Insert title here",
        [Array]     $Message = 
        "Crash
         Bandicoot"
    )

    Use-SysForms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Demo: Show-Message -Title "Title" -Message "Message"

function Show-Question() {

    param (
        [String]    $Title = "Insert title here",
        [Array]     $Message = 
        "Crash
         Bandicoot"
    )

    Use-SysForms
    $Answer = [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNoCancel, [System.Windows.Forms.MessageBoxIcon]::Question)

    return $Answer
}

function Request-PcRestart() {

    $Ask = "If you want to see the changes restart your computer!
    Do you want to Restart now?"

    switch (Show-Question -Title "Read carefully" -Message $Ask) {
        'Yes' {
            Write-Host "You choose to Restart now"
            Restart-Computer        
        }
        'No' {
            Write-Host "You choose to Restart later"
        }
        'Cancel' {
            # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose to Restart later"
        }
    }
}

<#
Example:
$Question = Show-Question -Title "Title" -Message "Message"
Returns Yes or No or Cancel
#>