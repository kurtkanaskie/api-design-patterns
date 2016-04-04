<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sap="urn:sap-com:document:sap:soap:functions:mc-style" exclude-result-prefixes="sap soap-env fn xs">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<creditCards>
			<xsl:apply-templates select="//sap:AparEbppGetCardlistResponse"/>
		</creditCards>
	</xsl:template>
	
	<xsl:template match="sap:AparEbppGetCardlistResponse">
		<count><xsl:value-of select="count(*:TCardDetails/*:item)"/></count>
		<xsl:apply-templates select="*:TCardDetails/*:item"/>
	</xsl:template>
	
	<xsl:template match="*:TCardDetails/*:item">
		<creditCard>
			<id><xsl:value-of select="*:CcardId"/></id>
			<type><xsl:value-of select="*:Ccins"/></type>
			<category><xsl:value-of select="*:Cctyp"/></category>
			<number><xsl:value-of select="*:Ccnum"/></number>
			<name><xsl:value-of select="*:Ccaccname"/></name>
			<accountName><xsl:value-of select="*:Ccname"/></accountName>
			<validFrom><xsl:value-of select="*:Datab"/></validFrom>
			<validThru><xsl:value-of select="*:Datbi"/></validThru>
		</creditCard>
	</xsl:template>
</xsl:stylesheet>
