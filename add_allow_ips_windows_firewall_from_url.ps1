# Create a rule in windows firewall for example "my_rule"
# The following script gets from a url a list of ips, separated by comma
# and adds them to Remote IP addresses in firewall scope.

$url = "https://www.mydomain.com/get_ips.php"

$response = Invoke-WebRequest -Uri $url

if ($response.StatusCode -eq 200) {

    $textResult = $response.Content.Substring(2)

    netsh advfirewall firewall set rule name="my_rule" new profile=domain remoteip=$textResult

    Write-Output "Firewall rule updated with remote IP: $textResult"
} else {
    Write-Output "Failed to retrieve content. HTTP status code: $($response.StatusCode)"
}
