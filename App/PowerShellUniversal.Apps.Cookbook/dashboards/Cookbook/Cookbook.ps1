[CmdletBinding()]
Param()

begin {

}

end {
    $Navigation = New-UDList -Content {
        New-UDListItem -Label "Home" -Icon (New-UDIcon -Icon Home) -OnClick { Invoke-UDRedirect -Url '/home' }
        New-UDListItem -Label 'Browse' -Onclick { Invoke-UDRedirect -Url '/browse'}
    }

    $app = @{
        Title            = 'Kitchen Library'
        Pages            = @($homepage,$browse,$recipe,$print)
        Navigation       = $Navigation
        NavigationLayout = 'Temporary'
    }

    New-UDApp @app

}