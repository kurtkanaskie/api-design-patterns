<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:fn="http://www.w3.org/2005/xpath-functions"
xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:sap="urn:sap-com:document:sap:soap:functions:mc-style"
exclude-result-prefixes="sap soap-env fn xs">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:template match="/">
		<salesOrders>
			<xsl:apply-templates select="//sap:ZgotcIsaorderGetdetailListResponse"/>
		</salesOrders>
	</xsl:template>
	
	<xsl:template match="sap:ZgotcIsaorderGetdetailListResponse">
		<salesOrder>
			<xsl:apply-templates select="*:OrderHeadersOut/*:item[1]"/>
			<xsl:apply-templates select="*:OrderStatusheadersOut/*:item[1]"/>
			<xsl:apply-templates select="*:OrderBusinessOut/*:item"/>
			<partners>
				<xsl:apply-templates select="*:OrderPartnersOut/*:item"/>
			</partners>
			<!--
			<addresses>
				<xsl:apply-templates select="*:OrderAddressOut/*:item"/>
			</addresses>
			-->
			<items>
				<xsl:apply-templates select="*:OrderItemsOut/*:item"/>
				<!--
				<xsl:apply-templates select="*:OrderStatusitemsOut/*:item"/>
				-->
			</items>
			<!--
			<schedules>
				<xsl:apply-templates select="*:OrderSchedulesOut/*:item"/>
			</schedules>
			-->
			</salesOrder>
	</xsl:template>
	
	<xsl:template match="*:OrderHeadersOut/*:item">
		<id><xsl:value-of select="*:DocNumber"/></id>
		<!--
		<soldToPartnerID><xsl:value-of select="*:SoldTo"/></soldToPartnerID>
		-->
		<salesOrganization><xsl:value-of select="*:SalesOrg"/></salesOrganization>
		<distributionChannel><xsl:value-of select="*:DistrChan"/></distributionChannel>
		<division><xsl:value-of select="*:Division"/></division>
		<currency><xsl:value-of select="*:Currency"/></currency>
      	<typeCode><xsl:value-of select="*:DocType"/></typeCode>
		<typeName>
			<xsl:choose>
				<xsl:when test="*:DocType='ZPAP'">Patient Assistance</xsl:when>
				<xsl:when test="*:DocType='ZOR'">Standard</xsl:when>
				<xsl:otherwise>unknown</xsl:otherwise>
			</xsl:choose>
		</typeName>
		<createdDate><xsl:value-of select="*:CreatedDate"/></createdDate>
		<createdBy><xsl:value-of select="*:CreatedBy"/></createdBy>
		<purchaseOrderId><xsl:value-of select="*:PurchNo"/></purchaseOrderId>
		<purchaseDate><xsl:value-of select="*:PurchDate"/></purchaseDate>
		<documentDate><xsl:value-of select="*:DocDate"/></documentDate>
		<orderDate><xsl:value-of select="*:RecDate"/></orderDate>
		<orderTime><xsl:value-of select="*:RecTime"/></orderTime>
		<requestDate><xsl:value-of select="*:ReqDateH"/></requestDate>
		<changeDate><xsl:value-of select="*:ChOn"/></changeDate>
		<netValueAmount><xsl:value-of select="*:NetValHd"/></netValueAmount>
	</xsl:template>
	
	<xsl:template match="*:OrderStatusheadersOut/*:item">
		<status><xsl:value-of select="*:IsaDocStatus"/></status>
      	<rejectionStatusCode><xsl:value-of select="*:Overallrej"/></rejectionStatusCode>
		<rejectionStatus><xsl:call-template name="convertDeliveryCode"><xsl:with-param name="code" select="*:Overallrej"/></xsl:call-template></rejectionStatus>

        <creditStatusCode><xsl:value-of select="*:Totstatcch"/></creditStatusCode>
		<creditStatus>
			<xsl:choose>
				<xsl:when test="*:Totstatcch='D'">Delinquent</xsl:when>
				<xsl:otherwise>unknown value</xsl:otherwise>
			</xsl:choose>
		</creditStatus>
	</xsl:template>
	
	<xsl:template match="*:OrderBusinessOut/*:item">
		<businessTerms>
			<purchaseDate><xsl:value-of select="*:PriceDate"/></purchaseDate>
			<billDate><xsl:value-of select="*:BillDate"/></billDate>
			<paymentTerms>
				<code><xsl:value-of select="*:Pmnttrms"/></code>
			</paymentTerms>
			<incoTerms>
				<code><xsl:value-of select="*:Incoterms1"/></code>
				<description><xsl:value-of select="*:Incoterms2"/></description>
			</incoTerms>
		</businessTerms>
	</xsl:template>
	
	<xsl:template match="*:OrderPartnersOut/*:item">
		<partner>
          <roleCode><xsl:value-of select="*:PartnRole"/></roleCode>
          <roleName>
			<xsl:choose>
				<xsl:when test="*:PartnRole='AG'">SoldTo</xsl:when>
				<xsl:when test="*:PartnRole='RE'">BillTo</xsl:when>
				<xsl:when test="*:PartnRole='WE'">ShipTo</xsl:when>
				<xsl:when test="*:PartnRole='RG'">Payer</xsl:when>
				<xsl:otherwise><xsl:value-of select="*:PartnRole"/></xsl:otherwise>
			</xsl:choose>
			</roleName>
			<id><xsl:value-of select="*:Customer"/></id>
			<addressID><xsl:value-of select="*:Address"/></addressID>
			<addressIndicator><xsl:value-of select="*:AddreIndi"/></addressIndicator>
			<transportationZone><xsl:value-of select="*:Transpzone"/></transportationZone>
			<xsl:apply-templates select="../../*:OrderAddressOut/*:item[*:Address=current()/*:Address]"/>
		</partner>
	</xsl:template>
	
	<xsl:template match="*:OrderAddressOut/*:item">
		<address>
			<id><xsl:value-of select="*:Address"/></id>
			<name><xsl:value-of select="*:Name"/></name>
			<attentionOfName><xsl:value-of select="*:Name2"/></attentionOfName>
			<addressLine><xsl:value-of select="*:Street"/></addressLine>
			<buildingNumber><xsl:value-of select="*:HouseNo"/></buildingNumber>
			<suite><xsl:value-of select="*:ZzhouseNo2"/></suite>
			<street><xsl:value-of select="*:Streetna"/></street>
			<POBox><xsl:value-of select="*:PoBox"/></POBox>
			<city><xsl:value-of select="*:City"/></city>
			<region><xsl:value-of select="*:Region"/></region>
			<postalCode><xsl:value-of select="*:PostlCode"/></postalCode>
			<country><xsl:value-of select="*:Country"/></country>
			<transportationZone><xsl:value-of select="*:Transpzone"/></transportationZone>
			<taxJurisdictionCode><xsl:value-of select="*:Taxjurcode"/></taxJurisdictionCode>
			<communication>
				<type>telephone</type>
				<value><xsl:value-of select="*:Telephone"/></value>
			</communication>
		</address>
	</xsl:template>
	
	<xsl:template match="*:OrderItemsOut/*:item">
		<item>
			<lineNumber><xsl:value-of select="*:ItmNumber"/></lineNumber>
			<material><xsl:value-of select="*:Material"/></material>
			<materialGroup><xsl:value-of select="*:MatlGroup"/></materialGroup>
			<materialCategory><xsl:value-of select="*:ItemCateg"/></materialCategory>
			<description><xsl:value-of select="*:ShortText"/></description>
			<billingBlock><xsl:value-of select="*:BillBlock"/></billingBlock>
			<deliveryBlock><xsl:value-of select="*:DlvBlock"/></deliveryBlock>
			<EANUPC><xsl:value-of select="*:EanUpc"/></EANUPC>
			<productHierarchy><xsl:value-of select="*:ProdHier"/></productHierarchy>
			<requestedQuantity><xsl:value-of select="*:ReqQty"/></requestedQuantity>
			<deliveredQuantity><xsl:value-of select="*:DlvQty"/></deliveredQuantity>
			<UOM><xsl:value-of select="*:SalesUnit"/></UOM>
			<netValue><xsl:value-of select="*:NetValue"/></netValue>
			<netPrice><xsl:value-of select="*:NetPrice"/></netPrice>
			<creditPrice><xsl:value-of select="*:Credpric"/></creditPrice>
			<currency><xsl:value-of select="*:Currency"/></currency>
			<grossWeight><xsl:value-of select="*:GrossWeig"/></grossWeight>
			<netWeight><xsl:value-of select="*:NetWeight"/></netWeight>
			<weightUOM><xsl:value-of select="*:UnitOfWt"/></weightUOM>
			<volume><xsl:value-of select="*:Volume"/></volume>
			<volumeUOM><xsl:value-of select="*:Volumeunit"/></volumeUOM>			
			<plant><xsl:value-of select="*:Plant"/></plant>			
			<shipPoint><xsl:value-of select="*:ShipPoint"/></shipPoint>
			<route><xsl:value-of select="*:Route"/></route>
			<profitCenter><xsl:value-of select="*:ProfitCtr"/></profitCenter>
			<xsl:apply-templates select="../../*:OrderStatusitemsOut/*:item[*:ItmNumber=current()/*:ItmNumber]"/>
			<schedules>
				<xsl:apply-templates select="../../*:OrderSchedulesOut/*:item[*:ItmNumber=current()/*:ItmNumber]"/>
			</schedules>
		</item>
	</xsl:template>
	
	<xsl:template match="*:OrderStatusitemsOut/*:item">
		<status>
			<lineNumber><xsl:value-of select="*:ItmNumber"/></lineNumber>
			<deliveryStatusCode><xsl:value-of select="*:DelivStat"/></deliveryStatusCode>
			<deliveryStatus><xsl:call-template name="convertDeliveryCode"><xsl:with-param name="code" select="*:DelivStat"/></xsl:call-template></deliveryStatus>
			
          	<rejectionStatusCode><xsl:value-of select="*:Rejstatit"/></rejectionStatusCode>
			<rejectionStatus><xsl:call-template name="convertDeliveryCode"><xsl:with-param name="code" select="*:Rejstatit"/></xsl:call-template></rejectionStatus>
			
          	<goodsMovementStatusCode><xsl:value-of select="*:Goodsmvsta"/></goodsMovementStatusCode>
			<goodsMovementStatus><xsl:call-template name="convertDeliveryCode"><xsl:with-param name="code" select="*:Goodsmvsta"/></xsl:call-template></goodsMovementStatus>
		</status>
	</xsl:template>
	
	<xsl:template match="*:OrderSchedulesOut/*:item">
		<schedule>
			<lineNumber><xsl:value-of select="*:ItmNumber"/></lineNumber>
			<type><xsl:value-of select="*:SchedType"/></type>
			<requestType><xsl:value-of select="*:ReqType"/></requestType>
			<requestDate><xsl:value-of select="*:ReqDate"/></requestDate>
			<loadDate><xsl:value-of select="*:LoadDate"/></loadDate>
			<goodsIssueDate><xsl:value-of select="*:GiDate"/></goodsIssueDate>
			<requiredQuantity><xsl:value-of select="*:ReqQty"/></requiredQuantity>
			<confirmedQuantity><xsl:value-of select="*:ConfirQty"/></confirmedQuantity>
			<UOM><xsl:value-of select="*:SalesUnit"/></UOM>
		</schedule>
	</xsl:template>
	
	<xsl:template name="convertDeliveryCode">
	<xsl:param name="code"/>
	<xsl:choose>
		<xsl:when test="$code='A'">Not Processed</xsl:when>
		<xsl:when test="$code='B'">Partially Processed</xsl:when>
		<xsl:when test="$code='C'">Completed</xsl:when>
		<xsl:otherwise>unknown</xsl:otherwise>
	</xsl:choose>
	</xsl:template>

	
</xsl:stylesheet>
