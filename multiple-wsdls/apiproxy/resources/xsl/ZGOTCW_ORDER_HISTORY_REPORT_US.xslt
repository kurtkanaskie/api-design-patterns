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
		<orderHistory>
			<xsl:apply-templates select="//sap:ZlotcOrderHistoryReportUsResponse"/>
		</orderHistory>
	</xsl:template>
	
	<xsl:template match="sap:ZlotcOrderHistoryReportUsResponse">
		<count><xsl:value-of select="count(*:TabTotal/*:item)"/></count>
		<customer>
			<id><xsl:value-of select="*:ExAccountNo"/></id>
			<fullName><xsl:value-of select="*:ExAccountName"/></fullName>
		</customer>
		<shippingLocation>
			<id><xsl:value-of select="*:TabShipToParty/*:item/*:Kunnr"/></id>
			<address>
				<name><xsl:value-of select="*:TabShipLocation/*:item/*:Name1"/></name>
				<buildingNumber><xsl:value-of select="*:TabShipLocation/*:item/*:HouseNum1"/></buildingNumber>
				<suite><xsl:value-of select="*:TabShipLocation/*:item/*:HouseNum2"/></suite>
				<street><xsl:value-of select="*:TabShipLocation/*:item/*:Street"/></street>
				<city><xsl:value-of select="*:TabShipLocation/*:item/*:City1"/></city>
				<region><xsl:value-of select="*:TabShipLocation/*:item/*:Region"/></region>
				<postalCode><xsl:value-of select="*:TabShipLocation/*:item/*:PostCode1"/></postalCode>
				<country><xsl:value-of select="*:TabShipLocation/*:item/*:Country"/></country>
			</address>
		</shippingLocation>
		<xsl:for-each select="*:TabTotal/*:item">
            <product>
				<NDCid><xsl:value-of select="*:Ndc"/></NDCid>
				<description><xsl:value-of select="*:Descrip"/></description>
				<month-year><xsl:value-of select="*:Monthname"/></month-year>
				<value><xsl:value-of select="*:Value"/></value>
            </product>
        </xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
