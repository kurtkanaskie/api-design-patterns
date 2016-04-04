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
			<xsl:apply-templates select="//sap:SalesorderGetlistResponse/Return"/>
			<xsl:apply-templates select="//sap:SalesorderGetlistResponse"/>
		</salesOrders>
	</xsl:template>
	
	<xsl:template match="*:Return">
		<status>
				<xsl:choose>
					<xsl:when test="*:Type='S' or *:Type=''"><code>S</code><name>success</name><description>Requested data was processed successfully.</description></xsl:when>
					<xsl:when test="*:Type='E'"><code>E</code><name>error</name><description>There was an application error processing the request data.</description></xsl:when>
					<xsl:when test="*:Type='W'"><code>W</code><name>warning</name><description>Requested data was processed successfully and warning information is provided</description></xsl:when>
					<xsl:when test="*:Type='I'"><code>I</code><name>information</name><description>Requested data was processed successfully and additional information is provided.</description></xsl:when>
					<xsl:when test="*:Type='A'"><code>A</code><name>abort</name><description>Request data processing was aborted.</description></xsl:when>
					<xsl:otherwise><code>U</code><name>unknown</name><description>An unknown error condition exists.</description></xsl:otherwise>
				</xsl:choose>
			<xsl:if test="*:Type!='S' and *:Type!=''">
				<messages>
					<count>1</count>
					<message>
						<id><xsl:value-of select="*:Id"/></id>
						<type><xsl:value-of select="*:Type"/></type>
						<number><xsl:value-of select="*:Number"/></number>
						<description><xsl:value-of select="*:Message"/></description>
						<version><xsl:value-of select="*:MessageV1"/></version>
						<subversion><xsl:value-of select="*:MessageV2"/></subversion>
					</message>
				</messages>
			</xsl:if>
		</status>
	</xsl:template>
	
	<xsl:template match="sap:SalesorderGetlistResponse">
		<count><xsl:value-of select="count(*:SalesOrders/*:item)"/></count>
		<xsl:for-each-group select="*:SalesOrders/*:item" group-by="*:SdDoc">
            <salesOrder>
				<id><xsl:value-of select="*:SdDoc"/></id>
				<documentDate><xsl:value-of select="*:DocDate"/></documentDate>
				<creationDate><xsl:value-of select="*:CreationDate"/></creationDate>
				<creationTime><xsl:value-of select="*:CreationTime"/></creationTime>
				<soldTo><xsl:value-of select="*:SoldTo"/></soldTo>
				<soldToName><xsl:value-of select="*:Name"/></soldToName>
				<salesOrganization><xsl:value-of select="*:SalesOrg"/></salesOrganization>
				<typeCode><xsl:value-of select="*:DocType"/></typeCode>
              	<typeName>
					<xsl:choose>
						<xsl:when test="*:DocType='ZPAP'">Patient Assistance</xsl:when>
						<xsl:when test="*:DocType='ZOR'">Standard</xsl:when>
						<xsl:otherwise>unknown</xsl:otherwise>
					</xsl:choose>
				</typeName>
				<customerOrderID><xsl:value-of select="*:PurchNo"/></customerOrderID>
                <xsl:for-each select="current-group()">
                    <item>
						<customer>
							<id><xsl:value-of select="*:SoldTo"/></id>
							<name><xsl:value-of select="*:Name"/></name>
						</customer>
						<lineNumber><xsl:value-of select="*:ItmNumber"/></lineNumber>
						<status><xsl:value-of select="*:DocStatus"/></status>
						<goodsIssueDate><xsl:value-of select="*:GiDate"/></goodsIssueDate>
                      	<requestDate><xsl:value-of select="*:ReqDate"/></requestDate>
                      	<purchaseOrderId><xsl:value-of select="*:PurchNo"/></purchaseOrderId>
						<salesOrganization><xsl:value-of select="*:SalesOrg"/></salesOrganization>
						<billingBlock><xsl:value-of select="*:BillBlock"/></billingBlock>
						<deliveryBlock><xsl:value-of select="*:DlvBlock"/></deliveryBlock>
						<material><xsl:value-of select="*:Material"/></material>
						<description><xsl:value-of select="*:ShortText"/></description>
						<requestedQuantity><xsl:value-of select="*:ReqQty"/></requestedQuantity>
						<deliveredQuantity><xsl:value-of select="*:DlvQty"/></deliveredQuantity>
						<UOM><xsl:value-of select="*:SalesUnit"/></UOM>
						<netPrice><xsl:value-of select="*:NetPrice"/></netPrice>
						<netValue><xsl:value-of select="*:NetValue"/></netValue>
						<currency><xsl:value-of select="*:Currency"/></currency>
						<shipPoint><xsl:value-of select="*:ShipPoint"/></shipPoint>
						<plant><xsl:value-of select="*:Plant"/></plant>
                    </item>
                    </xsl:for-each>
            </salesOrder>
        </xsl:for-each-group>
	</xsl:template>
	
</xsl:stylesheet>
