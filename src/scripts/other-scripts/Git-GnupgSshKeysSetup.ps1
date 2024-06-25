Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\debloat-helper\Remove-ItemVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\package-managers\Manage-Software.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\ui\Select-Folder.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\ui\Show-MessageDialog.psm1"

function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Initialize-GitUser() {
    [CmdletBinding()]
    param (
        [String] $GIT_PROPERTY_NAME, # Ex: user, user, init
        [String] $GIT_NAME_PROPERTY, # Ex: name, email, defaultBranch
        [String] $GIT_PROPERTY_VALUE # Ex: Your Name, your@email.com
    )

    If (($null -eq $GIT_PROPERTY_VALUE) -or ($GIT_PROPERTY_VALUE -eq "")) {
        $GIT_PROPERTY_VALUE = $GIT_PROPERTY_VALUE.Trim(" ")

        While (($null -eq $GIT_PROPERTY_VALUE) -or ($GIT_PROPERTY_VALUE -eq "")) {
            Write-Warning "GIT: Could not found 'git config --global $GIT_PROPERTY_NAME.$GIT_NAME_PROPERTY' value, is null or empty."
            $GIT_PROPERTY_VALUE = Read-Host "GIT: Please enter your git $GIT_PROPERTY_NAME.$GIT_NAME_PROPERTY"
            $GIT_PROPERTY_VALUE = $GIT_PROPERTY_VALUE.Trim(" ")
        }

        Write-Host "GIT: Setting your git $GIT_PROPERTY_NAME.$GIT_NAME_PROPERTY to '$GIT_PROPERTY_VALUE' ..." -ForegroundColor Cyan
        git config --global "$GIT_PROPERTY_NAME.$GIT_NAME_PROPERTY" "$GIT_PROPERTY_VALUE"

        Write-Host "GIT: Your $GIT_PROPERTY_NAME.$GIT_NAME_PROPERTY on git is: $(git config --global "$GIT_PROPERTY_NAME.$GIT_NAME_PROPERTY")`n" -ForegroundColor Cyan
    } Else {
        Write-Warning "Your $GIT_PROPERTY_NAME.$GIT_NAME_PROPERTY already exists: $(git config --global "$GIT_PROPERTY_NAME.$GIT_NAME_PROPERTY")`nSkipping..."
    }
}

function Set-GitProfile() {
    $GitUserName = $(git config --global user.name)
    $GitUserEmail = $(git config --global user.email)
    $GitInitDefaultBranch = $(git config --global init.defaultBranch)

    $GIT_PROPERTIES = @(
        @{ Name = "user"; Property = "name" },
        @{ Name = "user"; Property = "email" },
        @{ Name = "init"; Property = "defaultBranch" }
    )

    Initialize-GitUser -GIT_PROPERTY_NAME $GIT_PROPERTIES[0].Name -GIT_NAME_PROPERTY $GIT_PROPERTIES[0].Property -GIT_PROPERTY_VALUE $GitUserName
    Initialize-GitUser -GIT_PROPERTY_NAME $GIT_PROPERTIES[1].Name -GIT_NAME_PROPERTY $GIT_PROPERTIES[1].Property -GIT_PROPERTY_VALUE $GitUserEmail
    Initialize-GitUser -GIT_PROPERTY_NAME $GIT_PROPERTIES[2].Name -GIT_NAME_PROPERTY $GIT_PROPERTIES[2].Property -GIT_PROPERTY_VALUE $GitInitDefaultBranch
}

function Set-FileNamePrefix() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $false)]
        [String] $DefaultFileName,
        [String] $FixedFileName,
        [String] $KeyType
    )
    [String] $FileNamePrefix = ""
    [String] $Response = ""
    [Array]  $AcceptedEntries = @("y", "yes", "n", "no")

    If ($DefaultFileName) {
        While ($Response -notin $AcceptedEntries) {
            Write-Host "$KeyType`: Would you like to use the default file name '$DefaultFileName'? (Y/n)" -ForegroundColor Cyan
            $Response = $(Read-Host -Prompt "=====> $KeyType").Trim(" ").ToLower()
            If ($Response -notin $AcceptedEntries) {
                Write-Host "=====> $KeyType`: Invalid entry! $Response" -ForegroundColor Red
            }
        }
    }

    If ($Response -in @("y", "yes")) { return $DefaultFileName }

    While (($null -eq $FileNamePrefix) -or ($FileNamePrefix -eq "")) {
        Write-Warning "$KeyType`: Please set a valid file name identifier."
        $FileNamePrefix = Read-Host "$KeyType`: Please enter a name identifier before '$FixedFileName'"
        $FileNamePrefix = $FileNamePrefix.Trim(" ")
    }

    $FileName = "$FileNamePrefix$FixedFileName"
    Write-Host "$KeyType`: Output file: $FileName"
    return $FileName
}

function Enable-SshAndGpgAgent() {
    Write-Host "Starting ssh-agent Service (Requires Admin)" -ForegroundColor Cyan
    Get-Service -Name "ssh-agent" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
    Start-Service -Name "ssh-agent"

    Write-Host "Checking if ssh-agent.exe is running before adding the keys..." -ForegroundColor Cyan
    ssh-agent.exe

    Write-Host "Setting git config GnuPG program path to ${env:ProgramFiles(x86)}\gnupg\bin\gpg.exe ..." -ForegroundColor Cyan
    git config --global gpg.program "${env:ProgramFiles(x86)}\gnupg\bin\gpg.exe"
}

function Set-SSHKey() {
    $SSHPath = "~\.ssh"
    $SSHEncryptionType = "ed25519"
    $SSHDefaultFileName = "id_$SSHEncryptionType"
    $SSHFileName = Set-FileNamePrefix -DefaultFileName $SSHDefaultFileName -FixedFileName "_$SSHDefaultFileName" -KeyType "SSH"

    If (!(Test-Path "$SSHPath")) {
        Write-Host "Creating folder on '$SSHPath'"
        New-Item -Path "$SSHPath" | Out-Null
    }
    Push-Location "$SSHPath"

    Write-Warning "I recommend you save your passphrase somewhere, in case you don't remember."
    Write-Host "Generating new SSH Key on $SSHPath\$SSHFileName" -ForegroundColor Cyan
    #           Encryption type        Comment                                Output file
    ssh-keygen -t "$SSHEncryptionType" -C "$(git config --global user.email) SSH Signing Key" -f "$SSHFileName" | Out-Host

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
    $GnuPGFileName = Set-FileNamePrefix -FixedFileName "_$GnuPGEncryptionType" -KeyType "GPG"

    If (!(Test-Path "$GnuPGPath")) {
        Write-Host "Creating folder on '$GnuPGPath'"
        New-Item -Path "$GnuPGPath" | Out-Null
    }

    Push-Location "$GnuPGPath"

    Write-Host "Generating new GPG key in $GnuPGPath/$GnuPGFileName..."
    Write-Host "Before exporting your public and private keys, add manually an email." -ForegroundColor Cyan
    Write-Host "Type: 1 (RSA and RSA) [ENTER]." -ForegroundColor Cyan
    Write-Host "Type: 4096 [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: 0 (does not expire at all) or `"10y`" [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: y [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: $(git config --global user.name) [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: $(git config --global user.email) [ENTER]" -ForegroundColor Cyan
    Write-Host "Then: Anything you want (e.g. Git Keys) [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: O (Ok) [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: [your passphrase] [ENTER]." -ForegroundColor Cyan
    Write-Host "Then: [your passphrase again] [ENTER]." -ForegroundColor Cyan
    gpg --full-generate-key

    Write-Status -Types "@" -Status "If you want to delete unwanted keys, this is just for reference"
    Write-Status -Types "@" -Status 'gpg --delete-secret-keys $(git config --global user.name)'
    Write-Status -Types "@" -Status 'gpg --delete-keys $(git config --global user.name)'

    Write-Host "Copying all files to $GnuPGPath"
    Copy-Item -Path "$GnuPGGeneratePath/*" -Destination "$GnuPGPath/" -Recurse -Force
    Remove-ItemVerified -Path "$GnuPGPath/*" -Exclude "*.gpg", "*.key", "*.pub", "*.rev" -Recurse
    Remove-ItemVerified -Path "$GnuPGPath/trustdb.gpg"

    Write-Host "Export public and private key to files:`n- $GnuPGPath\$($GnuPGFileName)_public.gpg`n- $GnuPGPath\$($GnuPGFileName)_secret.gpg"
    gpg --output "$($GnuPGFileName)_public.gpg" --armor --export "$(git config --global user.email)"
    gpg --output "$($GnuPGFileName)_secret.gpg" --armor --export-secret-key "$(git config --global user.email)"

    # Get the exact Key ID from the system
    $KeyId = $((gpg --list-keys --keyid-format LONG).Split(" ")[5].Split("/")[1])
    $CurrentGPGKey = $(git config --global user.signingkey)

    If (($KeyId -eq "") -or ($null -eq $KeyId) -or ($KeyId -ne $CurrentGPGKey)) {
        Write-Host "GPG Key id found: $KeyId."
        Write-Host "Registering the GPG Key ID to git user..."
        git config --global user.signingkey "$KeyId"
        Write-Host "Your user.signingkey on git is: $(git config --global user.signingkey)"

        Write-Host "Enabling commit.gpgsign on git..."
        git config --global commit.gpgsign true

        Write-Host "Copy and Paste the lines below on your`nGithub/Gitlab > Settings > SSH and GPG Keys > New GPG Key"
        Get-Content -Path "$GnuPGPath/$($GnuPGFileName)_public.gpg" -Encoding UTF8
    } Else {
        Write-Host "Failed to retrieve your key_id: $KeyId"
    }

    Write-Host "Importing your key on $GnuPGPath\$($GnuPGFileName)_public.gpg and $($GnuPGFileName)_secret.gpg"
    gpg --import $GnuPGFileName * .gpg # Remind: No QUOTES in variables
    Write-Host "Importing all GPG keys on $GnuPGPath" -ForegroundColor Cyan
    gpg --import *

    Pop-Location
}

function Import-KeysSshGpg() {
    [CmdletBinding()] param()

    $Folder = Select-Folder -Description "Select the existing SSH keys folder"

    If ($null -ne $Folder) {
        Write-Host "Importing SSH keys from: $Folder" -ForegroundColor Cyan
        Push-Location $Folder
        ssh-add $(Get-ChildItem)
        Pop-Location
        $Folder = $null
    }

    $Folder = Select-Folder -Description "Select the existing GPG keys folder"
    If ($null -ne $Folder) {
        Write-Host "Importing GPG keys from: $Folder" -ForegroundColor Cyan
        Push-Location $Folder
        gpg --import *
        Pop-Location
    }
}

$Ask = "Before everything, your data will only be keep locally, only in YOUR PC.`nI've made this to be more productive and not to lose time setting up signing keys on Windows.`n`nThis setup cover:`n- Git user name and email`n- SSH and GPG keys full creation and import (even other keys from ~\.ssh and ~\.gnupg)`n- Or import existing SSH and GPG keys (only changes git config gpg.program)`n`nDo you want to proceed?"

Request-AdminPrivilege
Install-Software -Name "Git + GnuPG" -Packages @("Git.Git", "GnuPG.GnuPG") -NoDialog

switch (Show-Question -Title "Warning" -Message $Ask -BoxIcon "Warning") {
    'Yes' {
        Set-GitProfile
        $Ask = "Are you creating new SSH and GPG keys?`n`nYes: Proceed to keys creation`nNo: Import Keys from selected folder`n`nReminder: for those who selected 'No', you must do manually, the configs for`n- git config --global user.signingkey (YOUR KEY)`n- git config --global commit.gpgsign true"
        Enable-SshAndGpgAgent

        switch (Show-Question -Title "Warning" -Message $Ask -BoxIcon "Warning") {
            'Yes' {
                Set-SSHKey
                Set-GPGKey
            }
            'No' {
                Import-KeysSshGpg
            }
            'Cancel' {
                Write-Host "Aborting..."
            }
        }
    }
    'No' {
        Write-Host "Aborting..."
    }
    'Cancel' {
        Write-Host "Aborting..."
    }
}
