#---------------------------------------------------------------------
# Configures a build envrionment for nim-status-client on windows.
#---------------------------------------------------------------------

# Helpers
function Install-Scoop {
    if ((Get-Command scoop -ErrorAction SilentlyContinue) -ne $null) {
        Write-Host "Scoop already installed!"
    } else {
        Write-Host "Installing Scoop package manager..."
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    }
}

# Install Git and other dependencies
function Install-Dependencies {
    Write-Host "Installing dependencies..."
    if (!(scoop bucket list | Where { $_.Name -eq "extras" })) {
        scoop bucket add extras
    }
    scoop install --global go@1.20.4
    scoop install --global vcredist2022
    scoop install --global `
        7zip git dos2unix findutils `
        wget rcedit inno-setup `
        make cmake gcc
}

function Install-Qt-SDK {
    Write-Host "Installing Qt $QtVersion SDK..."
    pip install aqtinstall
    aqt install-qt -O "C:\Qt" windows desktop $QtVersion win64_msvc2019_64 -m qtwebengine qtlottie
}

# Install Microsoft Visual C++ Build Tools 16.11.23
function Install-VC-BuildTools {
    $VCBuildToolsUrl = "https://download.visualstudio.microsoft.com/download/pr/33d686db-3937-4a19-bb3c-be031c5d69bf/66d85abf1020496b07c59aba176def5127352f2fbdd3c4c4143738ab7dfcb459/vs_BuildTools.exe"
    $VCBuildToolsExe = "$HOME\Downloads\vs_BuildTools.exe"

    Write-Host "Downloading Microsoft Visual C++ Build Tools..."
    (New-Object System.Net.WebClient).DownloadFile($VCBuildToolsUrl, $VCBuildToolsExe)

    Write-Host "Installing Microsoft Visual C++ Build Tools..."
    $VCBuildToolsArgs = $(
        "--installPath", "C:\BuildTools",
        "--quiet", "--wait", "--norestart", "--nocache",
        "--add", "Microsoft.VisualStudio.Workload.MSBuildTools",
        "--add", "Microsoft.VisualStudio.Workload.VCTools",
        "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
        "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest",
        "--add", "Microsoft.VisualStudio.Component.Windows10SDK.10240",
        "--add", "Microsoft.VisualStudio.Component.Windows10SDK.14393",
        "--add", "Microsoft.VisualStudio.Component.Windows81SDK",
        "--add", "Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Win81",
        "--add", "Microsoft.VisualStudio.ComponentGroup.UWP.VC.v141.BuildTools"
    )
    Start-Process -Wait -PassThru -FilePath $VCBuildToolsExe -ArgumentList $VCBuildToolsArgs
}

function Show-Success-Message {
    Write-Host @"

SUCCESS!

Before you attempt to build nim-status-client you'll need a few environment variables set:

export QTDIR="/c/Qt/$QtVersion/msvc2019_64"
export Qt5_DIR="/c/Qt/$QtVersion/msvc2019_64"
export VCINSTALLDIR="/c/BuildTools/VC"

You might also have to include the following paths in your `$PATH:

export PATH=`"/c/BuildTools/MSBuild/Current/Bin:`$PATH`"
export PATH=`"/c/BuildTools/VC/Tools/MSVC/14.29.30133/bin:`$PATH`"
export PATH=`"/c/ProgramData/scoop/apps/inno-setup/current:`$PATH`"
"@
}

#---------------------------------------------------------------------

# Stop the script after first error
$ErrorActionPreference = 'Stop'
# Version of Qt SDK available form aqt
$QtVersion = "5.15.2"

# Don't run when sourcing script
If ($MyInvocation.InvocationName -ne ".") {
    Install-Scoop
    Install-Dependencies
    Install-Qt-SDK
    Install-VC-BuildTools
    Show-Success-Message
}

#---------------------------------------------------------------------
