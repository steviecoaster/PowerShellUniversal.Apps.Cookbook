$app = @{
    Name = 'Recipe Manager'
    BaseUrl = '/cookbook'
    Module = 'PowerShellUniversal.Apps.Cookbook'
    Command = 'New-UDCookbookApp'
    AutoDeploy = $true
    Description = 'A simple recipe manager and browsing dashboard for PowerShell Universal'
    Environment = 'PowerShell 7'
}

New-PSUApp @app