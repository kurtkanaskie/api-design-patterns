<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sap="urn:sap-com:document:sap:soap:functions:mc-style" exclude-result-prefixes="sap soap-env fn xs">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<customers>
			<xsl:apply-templates select="//sap:ZlotcShiptosOfSoldtoGetResponse"/>
		</customers>
	</xsl:template>
	
	<xsl:template match="sap:ZlotcShiptosOfSoldtoGetResponse">
		<customer>
			<xsl:apply-templates select="*:TBapisoldto/*:item"/>
			<shippingLocations>
				<count><xsl:value-of select="count(*:TShiptos/*:item)"/></count>
				<xsl:for-each select="*:TShiptos/*:item">
					<shippingLocation>
						<xsl:apply-templates select="."/>
					</shippingLocation>
				</xsl:for-each>
			</shippingLocations>
		</customer>
	</xsl:template>
	
	<xsl:template match="*:item">
		<id><xsl:value-of select="*:Partner"/></id>
		<name><xsl:value-of select="*:Name"/></name>
		<address>
			<buildingNumber><xsl:value-of select="*:ZzhouseNo"/></buildingNumber>
			<suite><xsl:value-of select="*:ZzhouseNo2"/></suite>
			<street><xsl:value-of select="*:Street"/></street>
			<postalCode><xsl:value-of select="*:PostlCode"/></postalCode>
			<city><xsl:value-of select="*:City"/></city>
			<region><xsl:value-of select="*:Region"/></region>
			<country><xsl:value-of select="*:Country"/></country>
			<taxJurisdictionCode><xsl:value-of select="*:Zztaxjurcode"/></taxJurisdictionCode>
		</address>
		<communication>
			<type>telephone</type>
			<sequence>1</sequence>
			<value><xsl:value-of select="*:Telephone"/></value>
		</communication>
		<communication>
			<type>telephone</type>
			<sequence>2</sequence>
			<value><xsl:value-of select="*:Telephone2"/></value>
		</communication>
		<communication>
			<type>fax</type>
			<value><xsl:value-of select="*:FaxNumber"/></value>
		</communication>
		<communication>
			<type>email</type>
			<value><xsl:value-of select="*:Zzemail"/></value>
		</communication>
	</xsl:template>
</xsl:stylesheet>
