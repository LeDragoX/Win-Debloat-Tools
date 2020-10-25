Function LoadSysForms {
    # Load assembly
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
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