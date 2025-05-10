<#
.SYNOPSIS
    Installs Spicetify CLI with proper administrator privileges.
.DESCRIPTION
    This script installs Spicetify CLI, adds it to the PATH, and optionally installs the Spicetify Marketplace.
    It requires administrator privileges to function correctly and provides enhanced error handling and user feedback.
.PARAMETER Version
    Specifies a specific version of Spicetify to install. If not specified, the latest version will be installed.
.EXAMPLE
    .\Install-Spicetify.ps1
    # Installs the latest version of Spicetify CLI
.EXAMPLE
    .\Install-Spicetify.ps1 -Version "2.16.2"
    # Installs version 2.16.2 of Spicetify CLI
.NOTES
    Author: Spicetify Team (Enhanced version)
    Requires: PowerShell 5.1 or higher
    Requires: Administrator privileges
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$Version
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Variables
$spicetifyFolderPath = "$env:LOCALAPPDATA\spicetify"
$spicetifyOldFolderPath = "$HOME\spicetify-cli"
$logFile = "$env:TEMP\spicetify_install_log.txt"
$PSMinVersion = [version]'5.1'
$startTime = Get-Date
#endregion Variables

#region Helper Functions
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success', 'Debug')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
    
    # Write to console with appropriate color
    switch ($Level) {
        'Info'    { Write-Host $Message }
        'Warning' { Write-Host $Message -ForegroundColor Yellow }
        'Error'   { Write-Host $Message -ForegroundColor Red }
        'Success' { Write-Host $Message -ForegroundColor Green }
        'Debug'   { 
            if ($VerbosePreference -eq 'Continue') {
                Write-Host "[DEBUG] $Message" -ForegroundColor Magenta 
            }
        }
    }
}

function Write-StatusMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [switch]$NoNewline
    )
    
    Write-Host -Object $Message -NoNewline:$NoNewline
    Write-Log -Message $Message -Level 'Info'
}

function Write-Success {
    [CmdletBinding()]
    param (
        [string]$Message = " > OK"
    )
    
    Write-Host -Object $Message -ForegroundColor 'Green'
    Write-Log -Message $Message -Level 'Success'
}

function Write-Unsuccess {
    [CmdletBinding()]
    param (
        [string]$Message = " > ERROR"
    )
    
    Write-Host -Object $Message -ForegroundColor 'Red'
    Write-Log -Message $Message -Level 'Error'
}

function Show-ProgressBar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Activity,
        
        [Parameter(Mandatory=$true)]
        [int]$PercentComplete,
        
        [Parameter(Mandatory=$false)]
        [string]$Status = ""
    )
    
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    Write-Log -Message "$Activity - $PercentComplete% $Status" -Level 'Debug'
}

function Confirm-Continue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [bool]$DefaultYes = $true
    )
    
    $Host.UI.RawUI.FlushInputBuffer()
    $default = 0
    if (-not $DefaultYes) {
        $default = 1
    }
    
    $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
        (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Continue with operation.'),
        (New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Abort operation.')
    )
    
    $choice = $Host.UI.PromptForChoice('', $Message, $choices, $default)
    
    return ($choice -eq 0)
}

function Test-InternetConnection {
    [CmdletBinding()]
    param ()
    
    try {
        Write-StatusMessage -Message "Checking internet connection..." -NoNewline
        $result = Test-Connection -ComputerName "github.com" -Count 1 -Quiet
        if ($result) {
            Write-Success
            return $true
        } else {
            Write-Unsuccess
            Write-Log -Message "Failed to connect to GitHub" -Level 'Error'
            return $false
        }
    } catch {
        Write-Unsuccess
        Write-Log -Message "Exception testing internet connection: $_" -Level 'Error'
        return $false
    }
}

function Start-SafeRetry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter(Mandatory=$true)]
        [string]$OperationName,
        
        [Parameter(Mandatory=$false)]
        [int]$MaxRetries = 3,
        
        [Parameter(Mandatory=$false)]
        [int]$RetryDelaySeconds = 2
    )
    
    $retryCount = 0
    $success = $false
    $result = $null
    
    while (-not $success -and $retryCount -lt $MaxRetries) {
        try {
            if ($retryCount -gt 0) {
                Write-Log -Message "Retry $retryCount of $MaxRetries for '$OperationName'" -Level 'Warning'
                Start-Sleep -Seconds $RetryDelaySeconds
            }
            
            $result = & $ScriptBlock
            $success = $true
        }
        catch {
            $retryCount++
            $errorMsg = $_.Exception.Message
            Write-Log -Message "Error during '$OperationName' (Attempt $retryCount of $MaxRetries): $errorMsg" -Level 'Error'
            
            if ($retryCount -ge $MaxRetries) {
                Write-Log -Message "Maximum retries reached for '$OperationName'" -Level 'Error'
                throw $_
            }
        }
    }
    
    return $result
}
#endregion Helper Functions

#region Main Functions
function Test-AdminPrivileges {
    [CmdletBinding()]
    param ()
    
    try {
        Write-StatusMessage -Message "Checking for administrator privileges..." -NoNewline
        $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if ($isAdmin) {
            Write-Success
            Write-Log -Message "Script is running with administrator privileges" -Level 'Success'
            return $true
        } else {
            Write-Unsuccess
            Write-Log -Message "Script is NOT running with administrator privileges" -Level 'Error'
            
            # Try to restart with administrator privileges
            $scriptPath = $MyInvocation.MyCommand.Definition
            $scriptArgs = $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value)`"" }
            $arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`" $scriptArgs"
            
            Write-StatusMessage -Message "Attempting to restart with administrator privileges..." 
            
            try {
                $p = Start-Process PowerShell -Verb RunAs -ArgumentList $arguments -PassThru -ErrorAction Stop
                Write-Success "Successfully launched elevated process (PID: $($p.Id))"
                Write-Log -Message "Exiting current non-elevated instance" -Level 'Info'
                exit 0
            } catch {
                Write-Unsuccess
                Write-Log -Message "Failed to restart with administrator privileges: $_" -Level 'Error'
                
                $continue = Confirm-Continue -Message "Spicetify installation requires administrator privileges for proper operation. Continue anyway (not recommended)?"
                if (-not $continue) {
                    Write-Log -Message "User aborted installation due to lack of admin privileges" -Level 'Warning'
                    exit 1
                }
                
                Write-Log -Message "Continuing without administrator privileges (not recommended)" -Level 'Warning'
                return $false
            }
        }
    } catch {
        Write-Unsuccess
        Write-Log -Message "Exception checking admin privileges: $_" -Level 'Error'
        return $false
    }
}

function Test-PowerShellVersion {
    [CmdletBinding()]
    param ()
    
    try {
        Write-StatusMessage -Message "Checking PowerShell version compatibility..." -NoNewline
        $versionCompatible = $PSVersionTable.PSVersion -ge $PSMinVersion
        
        if ($versionCompatible) {
            Write-Success
            Write-Log -Message "PowerShell version $($PSVersionTable.PSVersion) is compatible" -Level 'Success'
            return $true
        } else {
            Write-Unsuccess
            Write-Log -Message "PowerShell $PSMinVersion or higher is required. Current version: $($PSVersionTable.PSVersion)" -Level 'Error'
            
            Write-StatusMessage -Message "PowerShell upgrade resources:"
            Write-StatusMessage -Message " - PowerShell 5.1: https://learn.microsoft.com/skypeforbusiness/set-up-your-computer-for-windows-powershell/download-and-install-windows-powershell-5-1"
            Write-StatusMessage -Message " - PowerShell 7+: https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows"
            
            $continue = Confirm-Continue -Message "Continue anyway with unsupported PowerShell version?"
            if (-not $continue) {
                Write-Log -Message "User aborted installation due to incompatible PowerShell version" -Level 'Warning'
                exit 1
            }
            
            Write-Log -Message "Continuing with unsupported PowerShell version (not recommended)" -Level 'Warning'
            return $false
        }
    } catch {
        Write-Unsuccess
        Write-Log -Message "Exception checking PowerShell version: $_" -Level 'Error'
        
        $continue = Confirm-Continue -Message "Continue anyway with unknown PowerShell version?"
        if (-not $continue) {
            Write-Log -Message "User aborted installation after version check error" -Level 'Warning'
            exit 1
        }
        
        return $false
    }
}

function Move-OldSpicetifyFolder {
    [CmdletBinding()]
    param ()
    
    try {
        if (Test-Path -Path $spicetifyOldFolderPath) {
            Write-StatusMessage -Message "Moving old spicetify folder contents..." -NoNewline
            
            # Create destination directory if it doesn't exist
            if (-not (Test-Path -Path $spicetifyFolderPath)) {
                New-Item -Path $spicetifyFolderPath -ItemType Directory -Force | Out-Null
            }
            
            # Copy files with progress
            $files = Get-ChildItem -Path "$spicetifyOldFolderPath\*" -Recurse
            $totalFiles = $files.Count
            $processedFiles = 0
            
            foreach ($file in $files) {
                $processedFiles++
                $percentComplete = [math]::Min(100, [math]::Round(($processedFiles / $totalFiles) * 100))
                
                Show-ProgressBar -Activity "Moving old spicetify files" -PercentComplete $percentComplete -Status "$processedFiles of $totalFiles"
                
                $destination = $file.FullName.Replace($spicetifyOldFolderPath, $spicetifyFolderPath)
                $destinationFolder = Split-Path -Path $destination -Parent
                
                if (-not (Test-Path -Path $destinationFolder)) {
                    New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
                }
                
                Copy-Item -Path $file.FullName -Destination $destination -Force
            }
            
            # Clean up the old folder
            Remove-Item -Path $spicetifyOldFolderPath -Recurse -Force
            Write-Success
            Write-Log -Message "Successfully moved old spicetify folder contents" -Level 'Success'
        }
    } catch {
        Write-Unsuccess
        Write-Log -Message "Error moving old spicetify folder: $_" -Level 'Error'
        
        $continue = Confirm-Continue -Message "Failed to move old Spicetify folder. Do you want to continue with installation anyway?"
        if (-not $continue) {
            Write-Log -Message "User aborted installation after folder move error" -Level 'Warning'
            exit 1
        }
    }
}

function Get-SpicetifyVersion {
    [CmdletBinding()]
    param ()
    
    try {
        if ($Version) {
            if ($Version -match '^\d+\.\d+\.\d+$') {
                Write-StatusMessage -Message "Using specified Spicetify version: $Version" -NoNewline
                Write-Success
                return $Version
            } else {
                Write-Warning -Message "You have specified an invalid spicetify version: $Version"
                Write-Log -Message "Invalid version format: $Version" -Level 'Warning'
                Write-StatusMessage -Message "The version must be in the following format: 1.2.3"
                
                $continue = Confirm-Continue -Message "Do you want to use the latest version instead?"
                if (-not $continue) {
                    Write-Log -Message "User aborted installation due to invalid version" -Level 'Warning'
                    exit 1
                }
            }
        }
        
        Write-StatusMessage -Message "Fetching the latest spicetify version..." -NoNewline
        $latestRelease = Start-SafeRetry -ScriptBlock {
            Invoke-RestMethod -Uri 'https://api.github.com/repos/spicetify/cli/releases/latest'
        } -OperationName "Fetch Latest Spicetify Version" -MaxRetries 3
        
        $targetVersion = $latestRelease.tag_name -replace 'v', ''
        Write-Success
        Write-Log -Message "Latest Spicetify version: $targetVersion" -Level 'Success'
        
        return $targetVersion
    } catch {
        Write-Unsuccess
        Write-Log -Message "Error fetching Spicetify version: $_" -Level 'Error'
        
        $continue = Confirm-Continue -Message "Failed to fetch latest version. Do you want to try with version 2.16.2 as fallback?"
        if (-not $continue) {
            Write-Log -Message "User aborted installation after version fetch error" -Level 'Warning'
            exit 1
        }
        
        return "2.16.2"  # Fallback version
    }
}

function Get-Spicetify {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetVersion
    )
    
    try {
        # Determine architecture
        if ($env:PROCESSOR_ARCHITECTURE -eq 'AMD64') {
            $architecture = 'x64'
        }
        elseif ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
            $architecture = 'arm64'
        }
        else {
            $architecture = 'x32'
        }
        
        Write-Log -Message "Detected architecture: $architecture" -Level 'Info'
        
        $archivePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "spicetify-$TargetVersion.zip")
        $downloadUrl = "https://github.com/spicetify/cli/releases/download/v$TargetVersion/spicetify-$TargetVersion-windows-$architecture.zip"
        
        Write-StatusMessage -Message "Downloading Spicetify v$TargetVersion for $architecture..." -NoNewline
        
        try {
            # Try to use more modern method with progress reporting
            $webClient = New-Object System.Net.WebClient
            $downloadComplete = $false
            
            $webClient.DownloadFileCompleted += {
                param($sender, $e)
                $downloadComplete = $true
                if ($e.Error) {
                    throw $e.Error
                }
            }
            
            # Set up download progress event
            $webClient.DownloadProgressChanged += {
                param($sender, $e)
                Show-ProgressBar -Activity "Downloading Spicetify" -PercentComplete $e.ProgressPercentage -Status "$($e.BytesReceived) of $($e.TotalBytesToReceive) bytes"
            }
            
            $webClient.DownloadFileAsync([Uri]$downloadUrl, $archivePath)
            
            # Wait for download to complete with timeout
            $timeout = New-TimeSpan -Minutes 5
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            while (-not $downloadComplete -and $stopwatch.Elapsed -lt $timeout) {
                Start-Sleep -Milliseconds 100
            }
            
            if (-not $downloadComplete) {
                $webClient.CancelAsync()
                throw "Download timed out after $($timeout.TotalMinutes) minutes"
            }
            
            Write-Success
        }
        catch {
            # Fallback to basic method if the above fails
            Write-Log -Message "Using fallback download method: $_" -Level 'Warning'
            
            Start-SafeRetry -ScriptBlock {
                Invoke-WebRequest -Uri $downloadUrl -UseBasicParsing -OutFile $archivePath
            } -OperationName "Download Spicetify" -MaxRetries 3
            
            Write-Success
        }
        
        # Verify the downloaded file
        if (-not (Test-Path -Path $archivePath) -or (Get-Item -Path $archivePath).Length -eq 0) {
            throw "Downloaded file is missing or empty: $archivePath"
        }
        
        return $archivePath
    }
    catch {
        Write-Unsuccess
        Write-Log -Message "Error downloading Spicetify: $_" -Level 'Error'
        
        $retry = Confirm-Continue -Message "Download failed. Would you like to retry?"
        if ($retry) {
            Write-Log -Message "Retrying download..." -Level 'Info'
            return Get-Spicetify -TargetVersion $TargetVersion
        }
        else {
            Write-Log -Message "User aborted installation after download failure" -Level 'Warning'
            exit 1
        }
    }
}

function Add-SpicetifyToPath {
    [CmdletBinding()]
    param ()
    
    try {
        Write-StatusMessage -Message "Adding Spicetify to the PATH environment variable..." -NoNewline
        $user = [EnvironmentVariableTarget]::User
        $path = [Environment]::GetEnvironmentVariable('PATH', $user)
        
        # Remove old path if it exists
        $path = $path -replace "$([regex]::Escape($spicetifyOldFolderPath))\\*;*", ''
        
        # Add new path if it's not already there
        if ($path -notlike "*$spicetifyFolderPath*") {
            $path = "$path;$spicetifyFolderPath"
        }
        
        # Set the updated PATH
        [Environment]::SetEnvironmentVariable('PATH', $path, $user)
        $env:PATH = $path
        
        Write-Success
        Write-Log -Message "Successfully added Spicetify to PATH" -Level 'Success'
        return $true
    }
    catch {
        Write-Unsuccess
        Write-Log -Message "Error adding Spicetify to PATH: $_" -Level 'Error'
        
        $continue = Confirm-Continue -Message "Failed to add Spicetify to PATH. Spicetify commands may not work directly. Do you want to continue?"
        if (-not $continue) {
            Write-Log -Message "User aborted installation after PATH update error" -Level 'Warning'
            exit 1
        }
        
        return $false
    }
}

function Test-SpicetifyInstallation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$Silent
    )
    
    try {
        if (-not $Silent) {
            Write-StatusMessage -Message "Testing Spicetify installation..." -NoNewline
        }
        
        $spicetifyExe = Join-Path -Path $spicetifyFolderPath -ChildPath "spicetify.exe"
        
        if (-not (Test-Path -Path $spicetifyExe)) {
            if (-not $Silent) {
                Write-Unsuccess
            }
            Write-Log -Message "Spicetify executable not found at: $spicetifyExe" -Level 'Error'
            return $false
        }
        
        # Try to run spicetify to verify it works
        $output = & $spicetifyExe -v 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            if (-not $Silent) {
                Write-Unsuccess
            }
            Write-Log -Message "Spicetify test failed with exit code: $LASTEXITCODE" -Level 'Error'
            return $false
        }
        
        if (-not $Silent) {
            Write-Success
            Write-Log -Message "Spicetify test successful: $output" -Level 'Success'
        }
        
        return $true
    }
    catch {
        if (-not $Silent) {
            Write-Unsuccess
        }
        Write-Log -Message "Error testing Spicetify installation: $_" -Level 'Error'
        return $false
    }
}

function Install-SpicetifyCore {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetVersion
    )
    
    try {
        Write-StatusMessage -Message "Starting Spicetify installation process..." -NoNewline
        Write-Success
        
        # Create spicetify directory if it doesn't exist
        if (-not (Test-Path -Path $spicetifyFolderPath)) {
            Write-StatusMessage -Message "Creating Spicetify directory..." -NoNewline
            New-Item -Path $spicetifyFolderPath -ItemType Directory -Force | Out-Null
            Write-Success
        }
        
        # Download spicetify
        $archivePath = Get-Spicetify -TargetVersion $TargetVersion
        
        # Extract the archive
        Write-StatusMessage -Message "Extracting Spicetify files..." -NoNewline
        
        try {
            # Try to use improved extraction with progress
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
            $totalEntries = $zip.Entries.Count
            $processedEntries = 0
            
            foreach ($entry in $zip.Entries) {
                $processedEntries++
                $percentComplete = [math]::Min(100, [math]::Round(($processedEntries / $totalEntries) * 100))
                
                Show-ProgressBar -Activity "Extracting Spicetify files" -PercentComplete $percentComplete -Status "$processedEntries of $totalEntries"
                
                $destinationPath = Join-Path $spicetifyFolderPath $entry.FullName
                $destinationDir = [System.IO.Path]::GetDirectoryName($destinationPath)
                
                if (-not [string]::IsNullOrWhiteSpace($destinationDir) -and -not (Test-Path $destinationDir)) {
                    New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
                }
                
                if (-not $entry.FullName.EndsWith('/')) {
                    $entryStream = $entry.Open()
                    $fileStream = New-Object System.IO.FileStream $destinationPath, 'Create'
                    $entryStream.CopyTo($fileStream)
                    $fileStream.Close()
                    $entryStream.Close()
                }
            }
            
            $zip.Dispose()
            Write-Success
        }
        catch {
            Write-Log -Message "Using fallback extraction method: $_" -Level 'Warning'
            
            # Fallback to basic extraction
            Expand-Archive -Path $archivePath -DestinationPath $spicetifyFolderPath -Force
            Write-Success
        }
        
        # Add to PATH
        Add-SpicetifyToPath
        
        # Clean up the downloaded archive
        Remove-Item -Path $archivePath -Force -ErrorAction SilentlyContinue
        
        # Test installation
        $installationSuccessful = Test-SpicetifyInstallation
        
        if ($installationSuccessful) {
            Write-StatusMessage -Message "Spicetify v$TargetVersion was successfully installed!" -NoNewline
            Write-Success
            return $true
        } else {
            Write-StatusMessage -Message "Spicetify installation completed with issues." -NoNewline
            Write-Unsuccess
            
            $continue = Confirm-Continue -Message "Installation may not be working correctly. Do you want to continue anyway?"
            if (-not $continue) {
                Write-Log -Message "User aborted after installation verification failed" -Level 'Warning'
                exit 1
            }
            
            return $false
        }
    }
    catch {
        Write-Unsuccess
        Write-Log -Message "Error during Spicetify installation: $_" -Level 'Error'
        
        $retry = Confirm-Continue -Message "Installation failed. Would you like to retry?"
        if ($retry) {
            Write-Log -Message "Retrying installation..." -Level 'Info'
            return Install-SpicetifyCore -TargetVersion $TargetVersion
        }
        else {
            Write-Log -Message "User aborted after installation failure" -Level 'Warning'
            exit 1
        }
    }
}

function Install-SpicetifyMarketplace {
    [CmdletBinding()]
    param ()
    
    try {
        $Host.UI.RawUI.FlushInputBuffer()
        $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
            (New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Install Spicetify Marketplace."),
            (New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not install Spicetify Marketplace.")
        )
        
        $choice = $Host.UI.PromptForChoice('', "`nDo you also want to install Spicetify Marketplace? It will become available within the Spotify client, where you can easily install themes and extensions.", $choices, 0)
        
        if ($choice -eq 1) {
            Write-StatusMessage -Message "Spicetify Marketplace installation skipped" -NoNewline
            Write-Log -Message "User chose not to install Marketplace" -Level 'Info'
            Write-Success
            return $false
        }
        
        Write-StatusMessage -Message "Starting the Spicetify Marketplace installation..." -NoNewline
        Write-Success
        
        # Download and execute the Marketplace installer script
        $marketplaceInstaller = Start-SafeRetry -ScriptBlock {
            Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1' -UseBasicParsing
        } -OperationName "Download Marketplace Installer" -MaxRetries 3
        
        Write-Log -Message "Executing Marketplace installer script" -Level 'Info'
        
        # Create a temporary script file for the marketplace installer
        $tempScriptPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "install-spicetify-marketplace.ps1")
        Set-Content -Path $tempScriptPath -Value $marketplaceInstaller.Content
        
        # Execute the marketplace installer
        & $tempScriptPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-StatusMessage -Message "Spicetify Marketplace successfully installed!" -NoNewline
            Write-Success
            return $true
        } else {
            Write-StatusMessage -Message "Spicetify Marketplace installation may have issues." -NoNewline
            Write-Unsuccess
            Write-Log -Message "Marketplace installer exited with code: $LASTEXITCODE" -Level 'Warning'
            return $false
        }
    }
    catch {
        Write-Unsuccess
        Write-Log -Message "Error installing Spicetify Marketplace: $_" -Level 'Error'
        
        $retry = Confirm-Continue -Message "Marketplace installation failed. Would you like to retry?"
        if ($retry) {
            Write-Log -Message "Retrying Marketplace installation..." -Level 'Info'
            return Install-SpicetifyMarketplace
        }
        else {
            Write-Log -Message "Continuing without Marketplace" -Level 'Warning'
            return $false
        }
    }
    finally {
        # Clean up temporary script file
        if (Test-Path -Path $tempScriptPath) {
            Remove-Item -Path $tempScriptPath -Force -ErrorAction SilentlyContinue
        }
    }
}

function Show-Summary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Version,
        
        [Parameter(Mandatory=$true)]
        [bool]$CoreSuccess,
        
        [Parameter(Mandatory=$false)]
        [bool]$MarketplaceSuccess = $false,
        
        [Parameter(Mandatory=$false)]
        [bool]$MarketplaceInstalled = $false
    )
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host ""
    Write-Host "======== Installation Summary ========" -ForegroundColor Cyan
    Write-Host "Spicetify Version: $Version"
    Write-Host "Installation Path: $spicetifyFolderPath"
    Write-Host "Installation Duration: $($duration.Minutes)m $($duration.Seconds)s"
    Write-Host "Log File: $logFile"
    Write-Host ""
    
    if ($CoreSuccess) {
        Write-Host "✓ Spicetify Core: Installed successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Spicetify Core: Installation issues detected" -ForegroundColor Red
    }
    
    if ($MarketplaceInstalled) {
        if ($MarketplaceSuccess) {
            Write-Host "✓ Spicetify Marketplace: Installed successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ Spicetify Marketplace: Installation issues detected" -ForegroundColor Yellow
        }
    } else {
        Write-Host "○ Spicetify Marketplace: Not installed (skipped)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host " 1. Run " -NoNewline
    Write-Host "spicetify -h" -ForegroundColor Yellow -NoNewline
    Write-Host " to see available commands"
    Write-Host " 2. Run " -NoNewline
    Write-Host "spicetify apply" -ForegroundColor Yellow -NoNewline
    Write-Host " to apply changes to Spotify"
    Write-Host " 3. Visit " -NoNewline
    Write-Host "https://spicetify.app/docs/getting-started" -ForegroundColor Blue -NoNewline
    Write-Host " for more information"
    Write-Host "====================================" -ForegroundColor Cyan
}
#endregion Main Functions

#region Main Script
try {
    # Create initial log file
    $logFileDir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path -Path $logFileDir)) {
        New-Item -Path $logFileDir -ItemType Directory -Force | Out-Null
    }
    
    Write-Log -Message "=== Spicetify Installation Script Started ===" -Level 'Info'
    Write-Log -Message "PowerShell Version: $($PSVersionTable.PSVersion)" -Level 'Info'
    Write-Log -Message "OS: $([Environment]::OSVersion.VersionString)" -Level 'Info'
    Write-Log -Message "Current User: $([Environment]::UserName)" -Level 'Info'
    
    # Initial banner
    Write-Host ""
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host "   Spicetify Installer (Enhanced)      " -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Run prerequisite checks
    $isAdmin = Test-AdminPrivileges
    $validPSVersion = Test-PowerShellVersion
    $internetConnected = Test-InternetConnection
    
    if (-not $internetConnected) {
        $continue = Confirm-Continue -Message "No internet connection detected. Installation requires internet access. Continue anyway?"
        if (-not $continue) {
            Write-Log -Message "User aborted installation due to no internet connection" -Level 'Warning'
            exit 1
        }
    }
    
    # Migrate old spicetify folder if it exists
    Move-OldSpicetifyFolder
    
    # Install spicetify
    $targetVersion = Get-SpicetifyVersion
    $coreSuccess = Install-SpicetifyCore -TargetVersion $targetVersion
    
    # Install marketplace if desired
    $marketplaceInstalled = $false
    $marketplaceSuccess = $false
    
    if ($coreSuccess) {
        $marketplaceInstalled = $true
        $marketplaceSuccess = Install-SpicetifyMarketplace
    }
    
    # Show summary
    Show-Summary -Version $targetVersion -CoreSuccess $coreSuccess -MarketplaceSuccess $marketplaceSuccess -MarketplaceInstalled $marketplaceInstalled
    
    Write-Log -Message "=== Spicetify Installation Script Completed ===" -Level 'Info'
    exit 0
}
catch {
    Write-Host ""
    Write-Host "An unexpected error occurred during installation:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Log -Message "Unhandled exception in main script: $_" -Level 'Error'
    Write-Log -Message $_.ScriptStackTrace -Level 'Error'
    
    Write-Host ""
    Write-Host "Please check the log file for details: $logFile" -ForegroundColor Yellow
    Write-Host "If you continue to experience issues, please report them at:" -ForegroundColor Yellow
    Write-Host "https://github.com/spicetify/spicetify-cli/issues" -ForegroundColor Cyan
    
    exit 1
}
#endregion Main Script
