# Reference: https://michlstechblog.info/blog/powershell-show-a-messagebox/#:~:text=Sometimes%20while%20a%20powershell%20script,NET%20Windows.
Function LoadSysForms {
    # Load assembly
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
}

Function ShowMessage {
    param (
        $Title = 'Insert title here',
        [array]$Message = 
        'Crash
         Bandicoot'
    )

    LoadSysForms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
}

function ShowQuestion {
    param (
        $Title = 'Insert title here',
        [array]$Message = 
        'Crash
         Bandicoot'
    )

    LoadSysForms
    $Answer = [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,[System.Windows.Forms.MessageBoxIcon]::Question)

    return $Answer
}