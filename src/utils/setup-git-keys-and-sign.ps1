function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Initialize-GitUser() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String]	$GitUserProperty, # Ex: Plínio Larrubia, email@email.com
        [String]	$GitPropertyName  # Ex: Name, Email
    )

    While ($GitUserProperty -eq "" -or $GitUserProperty -eq $null) {

        Write-Warning "Could not found 'user.$GitPropertyName', is null or empty."
        $GitUserProperty = Read-Host "Please enter your $GitPropertyName (For git config --global)"

        If (!(($GitUserProperty -eq "") -or ($null -eq $GitUserProperty))) {

            Write-Host "Setting your git user.$GitPropertyName to $GitUserProperty..."
            git config --global user.$GitPropertyName "$GitUserProperty"
            Write-Host "Updated: $(git config --global user.$GitPropertyName)."

        }
    }

    Write-Host "Your GitUserProperty is: $GitUserProperty."
    return $GitUserProperty

}

function Set-GitProfile() {
    [CmdletBinding()] param()

    $Global:GitUserName = $null
    $Global:GitUserName = $(git config --global user.name)

    $Global:GitUserEmail = $null
    $Global:GitUserEmail = $(git config --global user.email)

    $Global:git_user_props = @("name", "email")

    $Global:GitUserName = $(Initialize-GitUser -GitUserProperty $GitUserName -GitPropertyName $git_user_props[0])
    $Global:GitUserEmail = $(Initialize-GitUser -GitUserProperty $GitUserEmail -GitPropertyName $git_user_props[1])

}

function Set-SSHKey() {
    [CmdletBinding()] param()

    $SSHPath = "~/.ssh"
    $SSHEncryptionType = "ed25519"
    $SSHFileName = "$($GitUserEmail)_id_$SSHEncryptionType"
    $SSHAltFileName = "id_$SSHEncryptionType" # Need to be checked

    If (!(Test-Path "$SSHPath")) {
        mkdir "$SSHPath" | Out-Null
    }
    Push-Location "$SSHPath"

    # Check if SSH Key already exists
    If (!((Test-Path "$SSHPath/$SSHAltFileName") -or (Test-Path "$SSHPath/$SSHFileName"))) {

        Write-Host "$SSHPath/$SSHAltFileName NOT Exists AND"
        Write-Host "$SSHPath/$SSHFileName NOT Exists..."
        Write-Host "Using your email from git to create a SSH Key: $GitUserEmail."
        Write-Warning "I recommend you save your passphrase somewhere, in case you don't remember."

        #           Encryption type    Command              Output file
        ssh-keygen -t "$SSHEncryptionType" -C "$GitUserEmail" -f "$SSHPath/$($SSHFileName)"

        Write-Host "Starting ssh-agent Service, this part is the reason to get admin permissions."
        Start-Service -Name ssh-agent
        Set-Service -Name ssh-agent -StartupType Automatic

        Write-Host "Checking if ssh-agent.exe is running before adding the keys..."
        ssh-agent.exe

    }
    Else {

        Write-Host "$SSHPath/$SSHFileName Exists OR"
        Write-Host "$SSHPath/$SSHAltFileName Exists"

    }

    Write-Host "Importing your SSH private key(s)." # Remind: No QUOTES in variables
    ssh-add $SSHFileName
    ssh-add $SSHAltFileName

    Pop-Location

}

function Set-GPGKey() {
    [CmdletBinding()]

    # https://www.gnupg.org/documentation/manuals/gnupg/OpenPGP-Key-Management.html
    $GnuPGGeneratePath = "~/AppData/Roaming/gnupg"
    $GnuPGPath = "~/.gnupg"
    $GnuPGEncryptionSize = "4096"
    $GnuPGEncryptionType = "rsa$GnuPGEncryptionSize"
    $GnuPGFileName = "$($GitUserEmail)_$GnuPGEncryptionType"

    If (!(Test-Path "$GnuPGPath")) {
        mkdir "$GnuPGPath" | Out-Null
    }
    Push-Location "$GnuPGPath"

    # GPG Key creation/import "check"
    If (!((Test-Path "$GnuPGPath/*$GnuPGFileName*") -or (Test-Path "$GnuPGPath/*.gpg"))) {

        Write-Host "$GnuPGPath/*$GnuPGFileName* NOT Exists AND"
        Write-Host "$GnuPGPath/*.gpg* NOT Exists..."

        Write-Host "Generating new GPG key in $GnuPGPath/$GnuPGFileName..."

        Write-Host "Before exporting your public and private keys, add manually an email." -ForegroundColor Yellow
        Write-Host "Type: 1 (RSA and RSA) [ENTER]." -ForegroundColor Yellow
        Write-Host "Type: 4096 [ENTER]." -ForegroundColor Yellow
        Write-Host "Then: 0 (does not expire at all) [ENTER]." -ForegroundColor Yellow
        Write-Host "Then: y [ENTER]." -ForegroundColor Yellow
        Write-Host "Then: $GitUserName [ENTER]." -ForegroundColor Yellow
        Write-Host "Then: $GitUserEmail [ENTER]" -ForegroundColor Yellow
        Write-Host "Then: Anything you want (Ex: Git Keys) [ENTER]." -ForegroundColor Yellow
        Write-Host "Then: O (Ok) [ENTER]." -ForegroundColor Yellow
        Write-Host "Then: [your passphrase] [ENTER]." -ForegroundColor Yellow
        Write-Host "Then: [your passphrase again] [ENTER]." -ForegroundColor Yellow
        gpg --full-generate-key

        # If you want to delete unwanted keys, this is just for reference
        #gpg --delete-secret-keys $GitUserName
        #gpg --delete-keys $GitUserName

        Write-Host "Copying all files to $GnuPGPath..."
        Copy-Item -Path "$GnuPGGeneratePath/*" -Destination "$GnuPGPath/" -Recurse
        Remove-Item -Path "$GnuPGPath/*" -Exclude "*.gpg", "*.key", "*.pub", "*.rev" -Recurse
        Remove-Item -Path "$GnuPGPath/trustdb.gpg"

        # Export public and private key to a file: {email@email.com}_{encryption_type}_public.gpg
        gpg --output "$($GnuPGFileName)_public.gpg" --armor --export "$GitUserEmail"
        gpg --output "$($GnuPGFileName)_secret.gpg" --armor --export-secret-key "$GitUserEmail"

        # Get the exact Key ID from the system
        $key_id = $((gpg --list-keys --keyid-format LONG).Split(" ")[5].Split("/")[1])

        If (!(($key_id -eq "") -or ($null -eq $key_id))) {

            Write-Host "key_id found: $key_id."
            Write-Host "Registering the Key ID found to git user..."
            git config --global user.signingkey "$key_id"
            Write-Host "Your git user.signingkey now is: $(git config --global user.signingkey)."

            Write-Host "Signed git commits enabled."
            git config --global commit.gpgsign true

            Write-Host "Copy and Paste the lines below on your"
            Write-Host "Github/Gitlab > Settings > SSH and GPG Keys > New GPG Key."
            Get-Content "$GnuPGPath/$($GnuPGFileName)_public.gpg"

        }
        Else {

            Write-Host "Failed to retrieve your key_id: $key_id."

        }
    }
    Else {

        Write-Host "$GnuPGPath/*$GnuPGFileName* Exists OR"
        Write-Host "$GnuPGPath/*.gpg Exists..."

    }

    Write-Host "Setting GnuPG program path to ${env:ProgramFiles(x86)}\GnuPG\bin\gpg.exe"
    git config --global gpg.program "${env:ProgramFiles(x86)}\GnuPG\bin\gpg.exe"

    Write-Host "Importing your GPG private key(s)." # Remind: No QUOTES in variables
    gpg --import *$GnuPGFileName*
    gpg --import *.gpg*

    Pop-Location

}

function Main() {

    Request-AdminPrivilege

    Write-Host "Installing: Git and GnuPG..."
    winget install --silent --source "winget" --id Git.Git | Out-Host
    winget install --silent --source "winget" --id GnuPG.GnuPG | Out-Host
    Write-Host "Before everything, your data will only be keep locally, only in YOUR PC." -ForegroundColor Cyan
    Write-Host "I've made this to be more productive and will not lose time setting keys on Windows." -ForegroundColor Cyan
    Write-Warning "If you already have your keys located at ~/.ssh and ~/.gnupg, the signing setup will be skipped."
    Write-Warning "Make sure you got winget installed already."
    Read-Host "Press Enter to continue..."
    Set-GitProfile
    Set-SSHKey
    Set-GPGKey
}

Main