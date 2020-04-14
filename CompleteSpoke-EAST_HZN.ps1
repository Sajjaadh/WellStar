#############################################################################
#  This code creates a Resource Group, adds the NetworkConsumer Role to it,
#  creates a spoke VNet, and creates peering to an already existing hub.
#
#  WellStar Avanade Team
#  April 2020
#############################################################################

#Note:  change destination Resource group in NetworkConsumer Parameter file
$SpokeRGName= "RG-HZN-HZN-EAST"
$Locate = "East US 2"

$SpokeFile = "C:\Users\sajjaad.hoossainy\Desktop\Wellstar\Spoke\Final\SpokeTemplatev2HZN.json"
$SpokeParameterFile = "C:\Users\sajjaad.hoossainy\Desktop\Wellstar\Spoke\Final\SpokeTemplatev2HZN.parameters-EAST_HZN.json"
$SpokeName = "VNET-EastUS2-HZN"
$HubToSpokePeeringName = "HubToSpokePeeringHZN"
$SpokeToHubPeeringName = "SpokeToHubPeeringHZN"
$HubName = "VNET-USEAST2-EA-Hub"
$HubRGName = "RG-NetworkHUB-Prod"
$DeploymentToPROD=$false
$PPEcontext = Get-AzSubscription -SubscriptionName "WS_HZN_EA"
$PRODcontext = Get-AzSubscription -SubscriptionName "WS_EA"


#If not deploying Production Spoke, Create a Resource Group
If (!$DeploymentToPROD) 
{
  #Set-AzContext $PPEcontext
  #Write-Output "Deployment is not to Prod (Prod Spoke), creating Resource Group: $SpokeRGName"
  New-AzResourceGroup -Name $SpokeRGName -Location $Locate -Tag @{"Business Service"= "Infrastructure"; "Business Unit"="IT"; "Compliance" = "N/A"; "Cost Center" = "N/A"; Environment="PPE"; Owner ="Network Team"}
}



#Create Spoke
New-AzResourceGroupDeployment -ResourceGroupName $SpokeRGName -TemplateParameterFile $SpokeParameterFile -TemplateFile $SpokeFile 



#Variables for Peering
Set-AzContext $PRODcontext
$vnetHub = Get-AzVirtualNetwork -name $HubName -ResourceGroupName $HubRGName

Set-AzContext $PPEcontext
$vnetSpoke = Get-AzVirtualNetwork -name $SpokeName -ResourceGroupName $SpokeRGName



#Create Peering

Add-AzVirtualNetworkPeering -name $SpokeToHubPeeringName -VirtualNetwork $vnetSpoke -RemoteVirtualNetworkId $vnetHub.Id -UseRemoteGateways

Set-AzContext $PRODcontext
Add-AzVirtualNetworkPeering -name $HubToSpokePeeringName -VirtualNetwork $vnetHub -RemoteVirtualNetworkId $vnetSpoke.id -AllowGatewayTransit



