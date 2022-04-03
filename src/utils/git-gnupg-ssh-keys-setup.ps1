Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"install-software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"

function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Initialize-GitUser() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String] $GIT_PROPERTY_NAME, # Ex: Name, Email
        [String] $GitUserProperty  # Ex: Your Name, your@email.com
    )

    $GitUserProperty = $GitUserProperty.Trim(" ")

    While (($null -eq $GitUserProperty) -or ($GitUserProperty -eq "")) {
        Write-Warning "GIT: Could not found 'git config --global user.$GIT_PROPERTY_NAME' value, is null or empty."
        $GitUserProperty = Read-Host "GIT: Please enter your git user.$GIT_PROPERTY_NAME"
        $GitUserProperty = $GitUserProperty.Trim(" ")
    }

    Write-Host "GIT: Setting your git user.$GIT_PROPERTY_NAME to '$GitUserProperty' ..." -ForegroundColor Cyan
    git config --global user.$GIT_PROPERTY_NAME "$GitUserProperty"

    Write-Host "GIT: Your user.$GIT_PROPERTY_NAME on git is: $(git config --global user.$GIT_PROPERTY_NAME)`n" -ForegroundColor Cyan
    return $GitUserProperty
}

function Set-GitProfile() {
    [CmdletBinding()] param()

    $GitUserName = $(git config --global user.name)
    $GitUserEmail = $(git config --global user.email)
    $GIT_USER_PROPERTIES = @("name", "email")

    $GitUserName = $(Initialize-GitUser -GIT_PROPERTY_NAME $GIT_USER_PROPERTIES[0] -GitUserProperty $GitUserName)
    $GitUserEmail = $(Initialize-GitUser -GIT_PROPERTY_NAME $GIT_USER_PROPERTIES[1] -GitUserProperty $GitUserEmail)
}

function Set-FileNameIdentifier() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $false)]
        [String] $DefaultFileName,
        [String] $FixedFileName,
        [String] $KeyType
    )
    [String] $FileNameIdentifier = ""
    [String] $UserInput = ""
    [Array]  $AcceptedEntries = @("y", "yes", "n", "no")

    If ($DefaultFileName) {
        While ($UserInput -notin $AcceptedEntries) {
            Write-Host "$KeyType`: Would you like to use the default file name '$DefaultFileName'? (Y/n)" -ForegroundColor Cyan
            $UserInput = $(Read-Host -Prompt "==> $KeyType").Trim(" ").ToLower()
            If ($UserInput -notin $AcceptedEntries) {
                Write-Host "==> $KeyType`: Invalid entry! $UserInput" -ForegroundColor Red
            }
        }
    }

    If ($UserInput -in @("y", "yes")) { return $DefaultFileName }

    While (($null -eq $FileNameIdentifier) -or ($FileNameIdentifier -eq "")) {
        Write-Warning "$KeyType`: Please set a valid file name identifier."
        $FileNameIdentifier = Read-Host "$KeyType`: Please enter a name identifier before '$FixedFileName'"
        $FileNameIdentifier = $FileNameIdentifier.Trim(" ")
    }

    $FileName = "$FileNameIdentifier$FixedFileName"
    Write-Host "$KeyType`: Output file: $FileName"
    return $FileName
}

function Set-SSHKey() {
    [CmdletBinding()] param()

    $SSHPath = "~\.ssh"
    $SSHEncryptionType = "ed25519"
    $SSHDefaultFileName = "id_$SSHEncryptionType"
    $SSHFileName = Set-FileNameIdentifier -DefaultFileName $SSHDefaultFileName -FixedFileName "_$SSHDefaultFileName" -KeyType "SSH"

    If (!(Test-Path "$SSHPath")) {
        Write-Host "Creating folder on '$SSHPath'"
        mkdir "$SSHPath" | Out-Null
    }
    Push-Location "$SSHPath"

    Write-Warning "I recommend you save your passphrase somewhere, in case you don't remember."
    Write-Host "Generating new SSH Key on $SSHPath\$SSHFileName" -ForegroundColor Cyan
    #           Encryption type        Comment                                Output file
    ssh-keygen -t "$SSHEncryptionType" -C "$(git config --global user.email)" -f "$SSHFileName" | Out-Host

    Write-Host "Checking if ssh-agent.exe is running before adding the keys..."
    ssh-agent.exe

    Write-Host "Starting ssh-agent Service, this part is the reason to get admin permissions."
    Get-Service -Name "ssh-agent" -ErrorAction SilentlyContinue | Set-Service -StartupType Manual
    Start-Service -Name "ssh-agent"

    Write-Host "Importing your key on $SSHPath\$SSHFileName"
    ssh-add $SSHFileName # Remind: No QUOTES on import
    Write-Host "Importing all SSH keys on $SSHPath" -ForegroundColor Cyan
    ssh-add $(Get-ChildItem)

    Pop-Location
}

function Set-GPGKey() {
    [CmdletBinding()] param()

    # https://www.gnupg.org/documentation/manuals/gnupg/OpenPGP-Key-Management.html
    $GnuPGGeneratePath = "~\AppData/Roaming\gnupg"
    $GnuPGPath = "~\.gnupg"
    $GnuPGEncryptionSize = "4096"
    $GnuPGEncryptionType = "rsa$GnuPGEncryptionSize"
    $GnuPGFileName = Set-FileNameIdentifier -FixedFileName "_$GnuPGEncryptionType" -KeyType "GPG"

    If (!(Test-Path "$GnuPGPath")) {
        Write-Host "Creating folder on '$GnuPGPath'"
        mkdir "$GnuPGPath" | Out-Null
    }
    Push-Location "$GnuPGPath"

    Write-Host "Generating new GPG key in $GnuPGPath/$GnuPGFileName..."

    Write-Host "Before exporting your public and private keys, add manually an email." -ForegroundColor Cyan
    Write-Host "Type: 1 (RSA and RSA) [ENTER]." -ForegroundColor Cyan
    Write-Host "Type: 4096 [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: 0 (does not expire at all) [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: y [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: $(git config --global user.name) [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: $(git config --global user.email) [ENTER]" -ForegroundColor Cyan
    Write-Host "Then: Anything you want (e.g. git keys) [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: O (Ok) [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: [your passphrase] [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: [your passphrase again] [ENTER]." -ForegroundColor Cyan
    gpg --full-generate-key

    Write-Verbose "If you want to delete unwanted keys, this is just for reference"
    Write-Verbose 'gpg --delete-secret-keys $(git config --global user.name)'
    Write-Verbose 'gpg --delete-keys $(git config --global user.name)'

    Write-Host "Copying all files to $GnuPGPath"
    Copy-Item -Path "$GnuPGGeneratePath/*" -Destination "$GnuPGPath/" -Recurse
    Remove-Item -Path "$GnuPGPath/*" -Exclude "*.gpg", "*.key", "*.pub", "*.rev" -Recurse
    Remove-Item -Path "$GnuPGPath/trustdb.gpg"

    Write-Host "Export public and private key to files:`n- $GnuPGPath\$($GnuPGFileName)_public.gpg`n- $GnuPGPath\$($GnuPGFileName)_secret.gpg"
    gpg --output "$($GnuPGFileName)_public.gpg" --armor --export "$(git config --global user.email)"
    gpg --output "$($GnuPGFileName)_secret.gpg" --armor --export-secret-key "$(git config --global user.email)"

    # Get the exact Key ID from the system
    $key_id = $((gpg --list-keys --keyid-format LONG).Split(" ")[5].Split("/")[1])

    If (!(($key_id -eq "") -or ($null -eq $key_id))) {
        Write-Host "GPG Key id found: $key_id."
        Write-Host "Registering the GPG Key ID to git user..."
        git config --global user.signingkey "$key_id"
        Write-Host "Your user.signingkey on git is: $(git config --global user.signingkey)"

        Write-Host "Enabling commit.gpgsign on git..."
        git config --global commit.gpgsign true

        Write-Host "Copy and Paste the lines below on your`nGithub/Gitlab > Settings > SSH and GPG Keys > New GPG Key"
        Get-Content "$GnuPGPath/$($GnuPGFileName)_public.gpg"
    }
    Else {
        Write-Host "Failed to retrieve your key_id: $key_id"
    }

    Write-Host "Setting GnuPG program path to ${env:ProgramFiles(x86)}\gnupg\bin\gpg.exe"
    git config --global gpg.program "${env:ProgramFiles(x86)}\gnupg\bin\gpg.exe"

    Write-Host "Importing your key on $GnuPGPath\$($GnuPGFileName)_public.gpg and $($GnuPGFileName)_secret.gpg"
    gpg --import *$GnuPGFileName* # Remind: No QUOTES in variables
    Write-Host "Importing all GPG keys on $GnuPGPath" -ForegroundColor Cyan
    gpg --import *.gpg

    Pop-Location
}

function Main() {
    $Ask = "Before everything, your data will only be keep locally, only in YOUR PC.`nI've made this to be more productive and not to lose time setting signing keys on Windows.`nIf you already have your keys located at ~/.ssh and ~/.gnupg,`nthey'll be imported after a new key generation/setup on git.`n`nDo you want to proceed?"

    Request-AdminPrivilege
    Install-Software -Name "Git + GnuPG" -Packages @("Git.Git", "GnuPG.GnuPG") -NoDialog

    switch (Show-Question -Title "Warning" -Message $Ask -BoxIcon "Warning") {
        'Yes' {
            Set-GitProfile
            Set-SSHKey
            Set-GPGKey
        }
        'No' {
            Write-Host "Aborting..."
        }
        'Cancel' {
            Write-Host "Aborting..." # With Yes, No and Cancel, the user can press Esc to exit
        }
    }
}

Main