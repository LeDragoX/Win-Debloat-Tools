function QuickPrivilegesElevation() {
  # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
  If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function CheckGitUser() {
  [CmdletBinding()] #<<-- This turns a regular function into an advanced function
  param (
    [String]	$git_user_property, # Ex: Plínio Larrubia, email@email.com
    [String]	$git_property_name  # Ex: Name, Email
  )

  # Github email creation "check"
  While ($git_user_property -eq "" -or $git_user_property -eq $null) {
  
    Write-Host "Could not found 'user.$git_user_property', is null or empty."
    $git_user_property = Read-Host "Please enter your $git_user_property (For git config --global)"

    # Set your user email for git
    If (!(($git_user_property -eq "") -or ($null -eq $git_user_property))) {
  
      Write-Host "Setting your git user.$git_property_name to $git_user_property..."
      git config --global user.$git_property_name "$git_user_property"
      Write-Host "Updated: $(git config --global user.$git_property_name)."
  
    }  

  }

  Write-Host "Your git_user_property is: $git_user_property."
  return $git_user_property

}

function SetUpGit() {
  # Use variables to make life easier
  $git_user_name = $null
  $git_user_name = $(git config --global user.name)

  $git_user_email = $null
  $git_user_email = $(git config --global user.email)

  $git_user_props = @("name", "email")

  $git_user_name = $(CheckGitUser -git_user_property $git_user_name -git_property_name $git_user_props[0])
  $git_user_email = $(CheckGitUser -git_user_property $git_user_email -git_property_name $git_user_props[1]).ToLower()

  $ssh_path = "~/.ssh"
  $ssh_enc_type = "ed25519"
  $ssh_file = "$($git_user_email)_id_$ssh_enc_type"
  $ssh_alt_file = "id_$ssh_enc_type" # Need to be checked

  # https://www.gnupg.org/documentation/manuals/gnupg/OpenPGP-Key-Management.html
  $gnupg_gen_path = "~/AppData/Roaming/gnupg"
  $gnupg_path = "~/.gnupg"
  $gnupg_enc_size = "4096"
  $gnupg_enc_type = "rsa$gnupg_enc_size"
  $gnupg_usage = "cert"
  $gnupg_expires_in = 0
  $gnupg_file = "$($git_user_email)_$gnupg_enc_type"

  # Test Location
  If (!(Test-Path "$ssh_path")) {
    mkdir "$ssh_path" | Out-Null
  }
  Push-Location "$ssh_path"

  # Check if SSH Key already exists
  If (!((Test-Path "$ssh_path/$ssh_alt_file") -or (Test-Path "$ssh_path/$ssh_file"))) {

    Write-Host ""
    Write-Host "$ssh_path/$ssh_alt_file NOT Exists AND"
    Write-Host "$ssh_path/$ssh_file NOT Exists..."
    Write-Host "Using your email from git to create a SSH Key: $git_user_email."
    # Generate a new ssh key, passing every parameter as variables (Make sure to config git user.email first)
    Write-Host ""
    Write-Warning "I recommend you save your passphrase somewhere, in case you don't remember."
    Write-Host ""

    #          Encryption type    Command              Output file
    ssh-keygen -t "$ssh_enc_type" -C "$git_user_email" -f "$ssh_path/$($ssh_file)"

    Write-Host "Starting ssh-agent Service, this part is the reason to get admin permissions."
    Start-Service -Name ssh-agent
    Set-Service -Name ssh-agent -StartupType Automatic
  
    Write-Host "Checking if ssh-agent is running before adding the keys..."
    ssh-agent.exe
  
    Write-Host "Add your private key (One of these will pass)." # Remind: No QUOTES in variables
    ssh-add $ssh_file
    ssh-add $ssh_alt_file  

  }
  Else {
    
    Write-Host ""
    Write-Host "$ssh_path/$ssh_file Exists OR"
    Write-Host "$ssh_path/$ssh_alt_file Exists"
    
  }

  Pop-Location
  
  # Test Location
  If (!(Test-Path "$gnupg_path")) {
    mkdir "$gnupg_path" | Out-Null
  }
  Push-Location "$gnupg_path"

  # GPG Key creation/import "check"
  If (!((Test-Path "$gnupg_path/*$gnupg_file*") -or (Test-Path "$gnupg_path/*.gpg*"))) {

    Write-Host ""
    Write-Host "$gnupg_path/*$gnupg_file* NOT Exists AND"
    Write-Host "$gnupg_path/*.gpg* NOT Exists..."

    Write-Host ""
    Write-Host "Generating new GPG key in $gnupg_path/$gnupg_file..."
    # Unfortunately, i couldn't automate this, so i will go with full-gen-key
    #gpg --quick-generate-key $git_user_name $gnupg_enc_type $gnupg_usage $gnupg_expires_in

    Write-Host "Before exporting your public and private keys, add manually an email." -ForegroundColor Green
    Write-Host "Type: 1 (RSA and RSA) [ENTER]." -ForegroundColor Green
    Write-Host "Type: 4096 [ENTER]." -ForegroundColor Green
    Write-Host "Then: 0 (does not expire at all) [ENTER]." -ForegroundColor Green
    Write-Host "Then: y [ENTER]." -ForegroundColor Green
    Write-Host "Then: $git_user_name [ENTER]." -ForegroundColor Green
    Write-Host "Then: $git_user_email [ENTER]" -ForegroundColor Green
    Write-Host "Then: Anything you want (Ex: Git Keys) [ENTER]." -ForegroundColor Green
    Write-Host "Then: O (Ok) [ENTER]." -ForegroundColor Green
    Write-Host "Then: [your passphrase] [ENTER]." -ForegroundColor Green
    Write-Host "Then: [your passphrase again] [ENTER]." -ForegroundColor Green
    Write-Host ""
    gpg --full-generate-key
    
    # If you want to delete unwanted keys, this is just for reference
    #gpg --delete-secret-keys $git_user_name
    #gpg --delete-keys $git_user_name
    
    Write-Host "Copying all files to $gnupg_path..."
    Copy-Item -Path "$gnupg_gen_path/*" -Destination "$gnupg_path/" -Recurse
    Remove-Item -Path "$gnupg_path/*" -Exclude "*.gpg", "*.key", "*.pub", "*.rev"  -Recurse
    Remove-Item -Path "$gnupg_path/trustdb.gpg"

    # Get the exact Key ID from the system
    $key_id = $((gpg --list-keys --keyid-format LONG).Split(" ")[5].Split("/")[1])

    # Export public and private key to a file: {email@email.com}_{encryption_type}_public.gpg
    gpg --output "$($gnupg_file)_public.gpg" --armor --export "$git_user_email"
    gpg --output "$($gnupg_file)_secret.gpg" --armor --export-secret-key "$git_user_email"

    # Import GPG keys
    gpg --import *$gnupg_file*
    gpg --import *.gpg*

    If (!(($key_id -eq "") -or ($null -eq $key_id))) {

      Write-Host ""
      Write-Host "key_id found: $key_id."
      Write-Host "Registering the Key ID found to git user..."
      git config --global user.signingkey "$key_id"
      Write-Host "Your git user.signingkey now is: $(git config --global user.signingkey)."

      # Always commit with GPG signature
      Write-Host "Signed git commits enabled."
      git config --global commit.gpgsign true

      Write-Host "Copy and Paste the lines below on your"
      Write-Host "Github/Gitlab > Settings > SSH and GPG Keys > New GPG Key."
      Write-Host ""
      Get-Content "$gnupg_path/$($gnupg_file)_public.gpg"
      Write-Host ""

    }
    Else {

      Write-Host "Failed to retrive your key_id: $key_id."

    }
  }
  Else {

    Write-Host ""
    Write-Host "$gnupg_path/*$gnupg_file* Exists OR"
    Write-Host "$gnupg_path/*.gpg* Exists..."

  }
  
  Pop-Location

}

function Main() {

  QuickPrivilegesElevation
  Write-Host "Before everything, your data will only be keep locally, only in YOUR PC" -ForegroundColor Green
  Write-Host "I've made this to be more productive and will not lose time setting keys on Windows" -ForegroundColor Green
  Write-Warning "Make sure you got winget installed already"
  Read-Host "Press Enter to continue..."
  Write-Host "Installing: Git and GnuPG..."
  winget install --silent Git.Git | Out-Host
  winget install --silent GnuPG.GnuPG | Out-Host
  SetUpGit

}

Main