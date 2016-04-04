<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sap="urn:sap-com:document:sap:soap:functions:mc-style" exclude-result-prefixes="sap soap-env fn xs">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<customers>
			<xsl:choose>
				<xsl:when test="//sap:CustomerGetdetail2Response/Return/Type='E'"><count>0</count></xsl:when>
				<xsl:otherwise><count>1</count></xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="//sap:CustomerGetdetail2Response/Return"/>

			<xsl:if test="//sap:CustomerGetdetail2Response/Return/Type!='E'">
				<xsl:apply-templates select="//sap:CustomerGetdetail2Response"/>
			</xsl:if>
		</customers>
	</xsl:template>
	
	<xsl:template match="*:Return">
		<status>
				<xsl:choose>
					<xsl:when test="*:Type='S'"><code>S</code><name>success</name><description>Requested data was processed successfully.</description></xsl:when>
					<xsl:when test="*:Type='E'"><code>E</code><name>error</name><description>There was an application error processing the request data.</description></xsl:when>
					<xsl:when test="*:Type='W'"><code>W</code><name>warning</name><description>Requested data was processed successfully and warning information is provided</description></xsl:when>
					<xsl:when test="*:Type='I'"><code>I</code><name>information</name><description>Requested data was processed successfully and additional information is provided.</description></xsl:when>
					<xsl:when test="*:Type='A'"><code>A</code><name>abort</name><description>Request data processing was aborted.</description></xsl:when>
					<xsl:otherwise><code>U</code><name>unknown</name><description>An unknown error condition exists.</description></xsl:otherwise>
				</xsl:choose>
			<errorMessages>
				<count>1</count>
				<errorMessage>
					<id><xsl:value-of select="*:Id"/></id>
					<type><xsl:value-of select="*:Type"/></type>
					<number><xsl:value-of select="*:Number"/></number>
					<description><xsl:value-of select="*:Message"/></description>
					<version><xsl:value-of select="*:MessageV1"/></version>
					<subversion><xsl:value-of select="*:MessageV2"/></subversion>
				</errorMessage>
			</errorMessages>
		</status>
	</xsl:template>
	
	<xsl:template match="sap:CustomerGetdetail2Response">
		<customer>
			<id><xsl:value-of select="*:Customeraddress/*:Customer"/></id>
			<name><xsl:value-of select="*:Customeraddress/*:Name"/></name>
			<accountGroup><xsl:value-of select="*:Customergeneraldetail/*:AccntGrp"/></accountGroup>
			<taxJurisdictionCode><xsl:value-of select="*:Customergeneraldetail/*:Taxjurcode"/></taxJurisdictionCode>
			<addresses>
				<address>
					<street><xsl:value-of select="*:Customeraddress/*:Street"/></street>
					<city><xsl:value-of select="*:Customeraddress/*:City"/></city>
					<region><xsl:value-of select="*:Customeraddress/*:Region"/></region>
					<postalCode><xsl:value-of select="*:Customeraddress/*:PostlCode"/></postalCode>
					<country><xsl:value-of select="*:Customeraddress/*:Country"/></country>
					<transportationZone><xsl:value-of select="*:Customeraddress/*:Transpzone"/></transportationZone>
					<communication>
						<type>telephone</type>
						<value><xsl:value-of select="*:Customeraddress/*:Telephone2"/></value>
					</communication>
				</address>
			</addresses>
		</customer>
	</xsl:template>
</xsl:stylesheet>
