Function Set-EnvVar 
{ 
    Param
    ( 
        [string]
        $key, 

        [string]
        $value, 

        [ValidateSet('User', 'Machine')] 
        [string]
        $scope = 'User'
    ) 
    Process 
    { 
        # Persist variable
        [environment]::setEnvironmentVariable($key, $value, $scope)
        # Aplly value to current shell
        Set-Item "env:${key}" "$value"
    } 
}

function Read-HostWithDefault([string]$message, [string]$defaultValue)
{
    $userTyped = Read-Host "$message [$defaultValue]"
    if([string]::IsNullOrEmpty($userTyped))
    {
        return $defaultValue
    }
    else
    {        
        return $userTyped
    }
}

function Get-RemoteContent([string] $uri) 
{
    return (new-object net.webclient).downloadstring($uri)
}

function Resolve-ScoopPath([string] $shim)
{
    return resolve-path (scoop which $shim)
}

function Invoke-RemoteContent([string] $uri){
    Invoke-Expression (Get-RemoteContent $uri)
}

if (Get-Command scoop -errorAction SilentlyContinue)
{
    # scoop is already installed, nothing to do
}
else
{
    $scoopDir = Read-HostWithDefault "Folder to install scoop" "D:\dev-env\scoop"
    Set-EnvVar "SCOOP" $scoopDir
    Invoke-RemoteContent 'https://get.scoop.sh'
}

# Install Git
scoop install git openssh sudo
Set-EnvVar 'GIT_SSH' (Resolve-ScoopPath ssh).Path

# Adds UI Tools
scoop bucket add extras
scoop install extras/p4merge extras/gitextensions extras/vcredist2013

Invoke-RemoteContent 'https://raw.githubusercontent.com/webartoli/git-init/master/install-environment/config/apply.ps1'