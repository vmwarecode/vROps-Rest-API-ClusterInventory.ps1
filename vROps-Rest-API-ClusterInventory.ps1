#Enter your vROps FQDN and credentials here
$vrops = "vropsfqdn"
$username = "user"
$pass = "password"

########################################################
# First Part : This part will get authentication token #
########################################################
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json; utf-8")
$headers.Add("Accept", "application/json")

$body = "{
`n  `"username`" : `"$username`",
`n  `"password`" : `"$pass`",
`n  `"others`" : [ ],
`n  `"otherAttributes`" : { }
`n}"

#Create string to combine download URL 
$myVrops = "https://"+$vrops+"/suite-api/api/auth/token/acquire"
#Type-cast $myvROps string parameter
$uri = [System.Uri]$myVrops

$response = Invoke-RestMethod $uri -Method 'POST' -Headers $headers -Body $body
$token = $response.token

#################################################################################
# Second Part : This part will create VM Inventory report against vSphere World #
#################################################################################

# Change Resource ID that you want to run the report against.
$resourceID = "57380ae3-fcf6-4494-a70d-cef2c34bc3f8"
# Change Report Definition ID for the report that you want to run
$reportDefinitionID = "db91f097-a20a-45b7-8b6f-695f2a0dee9d"

$headers1 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers1.Add("Accept", "application/json")
$headers1.Add("Content-Type", "application/json; utf-8")
$headers1.Add("Authorization", "vRealizeOpsToken $token")

$body1 = "{
`n  `"resourceId`" : `"$resourceID`",
`n  `"reportDefinitionId`" : `"$reportDefinitionID`",
`n  `"traversalSpec`" : {
`n    `"name`" : `"vSphere Hosts and Clusters`",
`n    `"rootAdapterKindKey`" : `"VMWARE`",
`n    `"rootResourceKindKey`" : `"vSphere World`",
`n    `"adapterInstanceAssociation`" : false
`n  }
`n}"

#Create string to combine download URL 
$myVrops1 = "https://"+$vrops+"/suite-api/api/reports"
#Type-cast $myvROps1 string parameter
$uri1 = [System.Uri]$myVrops1

$response1 = Invoke-RestMethod $uri1 -Method 'POST' -Headers $headers1 -Body $body1
$reportID = $response1.id


###  ATTENTION!!! If your inventory is large, increase the size ###
###  of the sleep time. Otherwise your report will be empty!!!  ###

sleep -Seconds 10

#################################################################################################
# Third Part : This part will download VM Inventory report into $reportPath that you'll specify #
#################################################################################################
$headers2 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers2.Add("Accept", "application/json")
$headers2.Add("Content-Type", "application/json; utf-8")
$headers2.Add("Authorization", "vRealizeOpsToken $token")

#Create string to combine download URL 
$myVrops2 = "https://"+$vrops+"/suite-api/api/reports/"+$reportID+"/download?format=csv"

#Type-cast $myvROps1 string parameter
$uri2 = [System.Uri]$myVrops2

$response2 = Invoke-RestMethod $uri2 -Method 'GET' -Headers $headers2

# You can edit $reportName and $reportPath according to your needs!
$reportDate = Get-Date -UFormat "%m-%d-%Y"
$reportName = "Cluster-Inventory-Report-"+$reportDate
$reportPath = "yourpath\$reportName.csv"

$response2 | Out-file $reportPath


