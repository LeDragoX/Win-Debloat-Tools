# Reference: https://michlstechblog.info/blog/powershell-show-a-messagebox/#:~:text=Sometimes%20while%20a%20powershell%20script,NET%20Windows.
function Use-WindowsForm() {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null # Load assembly
}

function Show-MessageDialog() {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.DialogResult])]
    param (
        [Parameter(Position = 0)]
        [String] $Title = "Insert title here",
        [Parameter(Position = 1)]
        [String] $Message = "`nCrash`nBandicoot",
        [Parameter(Position = 2)]
        [ValidateSet('AbortRetryIgnore', 'OK', 'OKCancel', 'RetryCancel', 'YesNo', 'YesNoCancel')]
        [String] $BoxButtons = "OK",
        [Parameter(Position = 3)]
        [ValidateSet('Information', 'Question', 'Warning', 'Error', 'None')]
        [String] $BoxIcon = "Information" # Information, Question, Warning, Error or None
    )

    Use-WindowsForm
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::$BoxButtons, [System.Windows.Forms.MessageBoxIcon]::$BoxIcon)
}

function Show-Question() {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.DialogResult])]
    param (
        [Parameter(Position = 0)]
        [String] $Title = "Insert title here",
        [Parameter(Position = 1)]
        [String] $Message = "Crash`nBandicoot",
        [Parameter(Position = 2)]
        [ValidateSet('AbortRetryIgnore', 'OK', 'OKCancel', 'RetryCancel', 'YesNo', 'YesNoCancel')]
        [String] $BoxButtons = "YesNoCancel", # With Yes, No and Cancel, the user can press Esc to exit
        [Parameter(Position = 3)]
        [ValidateSet('Information', 'Question', 'Warning', 'Error', 'None')]
        [String] $BoxIcon = "Question"
    )

    Use-WindowsForm
    $Answer = [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::$BoxButtons, [System.Windows.Forms.MessageBoxIcon]::$BoxIcon)

    return $Answer
}

function Request-PcRestart() {
    $Ask = "If you want to see the changes restart your computer!`n    Do you want to Restart now?"

    switch (Show-Question -Title "Warning" -Message $Ask) {
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
Show-MessageDialog -Title "Title" -Message "Message"
$Question = Show-Question -Title "Title" -Message "Message"
Request-PcRestart
Returns Yes or No or Cancel
#>
