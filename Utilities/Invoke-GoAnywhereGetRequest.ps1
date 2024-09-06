
function Invoke-GoAnywhereGetRequest {

    param(
        [parameter(Mandatory=$true)]
        [String]$Uri,
        [parameter(Mandatory=$true)]
        [String]$Endpoint,
        [parameter(Mandatory=$true)]
        [string]$Token,
        [HashTable]$Query = @{}
    )


    Add-Type -AssemblyName System.Web

    # Create a http name value collection from an empty string
    $collection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    foreach ($option in $query.GetEnumerator()){
        $collection.Add($option.key, $option.value)
    }

    $uri = ($($uri, $endpoint) -join '/') -replace '(?<!:)/+', '/'

    # Build the uri
    $request = [System.UriBuilder]$uri
    $request.Query = $collection.ToString()

    $uri = $request.Uri.OriginalString

    $settings = @{
    "Method"        = "Get"
        "ContentType"   = "application/json"
        "Headers"       = @{
            "Authorization" = "Bearer $($token)"
        }
    }

    Invoke-RestMethod @settings -Uri $uri

}
