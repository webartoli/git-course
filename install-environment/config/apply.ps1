
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

function Read-UserInfo
{
    $result = @{}
    $result.name = Read-HostWithDefault 'Git name' 'Claudio Bartoli'
    $result.mail = Read-HostWithDefault 'Git mail' 'c.bartoli@iconsulting.biz'
    return $result
}

function Get-UserInfo
{
    try
    {
        $searcher = [adsisearcher]"(samaccountname=$env:USERNAME)"
        $props = $searcher.FindOne().Properties
        return @{
            "name" = $props.mail;
            "mail" = $props.cn;
        }
    }
    catch
    {
        return Read-UserInfo
    }
}

function Get-RemoteContent([string] $uri) 
{
    return (new-object net.webclient).downloadstring($uri)
}

function Set-GlobalGitIgnore 
{
    Get-RemoteContent "$domain/.gitignore" | Out-File "$env:USERPROFILE\.gitignore"
}

$domain = 'https://raw.githubusercontent.com/webartoli/git-init/master/install-environment/config'

function Set-GlobalGitConfig($user) 
{

    $template = Get-RemoteContent "$domain/.gitconfig"
    
    $template | `
        % {$_.replace("{{user.name}}",$user.name)} | `
        % {$_.replace("{{user.mail}}",$user.mail)} | `
        Out-File "$env:USERPROFILE\.gitconfig"    
}

$user = Get-UserInfo
Set-GlobalGitConfig $user
Set-GlobalGitIgnore