<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sap="urn:sap-com:document:sap:soap:functions:mc-style" exclude-result-prefixes="sap soap-env fn xs">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<creditCards>
			<xsl:apply-templates select="//sap:AparEbppDeleteCardResponse"/>
		</creditCards>
	</xsl:template>
	
	<xsl:template match="sap:AparEbppDeleteCardResponse">
		<xsl:choose>
			<xsl:when test="EReturncode=1"><xsl:apply-templates select="*:TMessages/*:item"/></xsl:when>
			<xsl:otherwise><count>1</count><creditCard><status>deleted</status></creditCard></xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="*:ENewcard"/>
	</xsl:template>
	
	<xsl:template match="*:TMessages/*:item">
		<errorMessage>
			<id><xsl:value-of select="*:Msgid"/></id>
			<type><xsl:value-of select="*:Msgty"/></type>
			<number><xsl:value-of select="*:Msgno"/></number>
			<version><xsl:value-of select="*:Msgv1"/></version>
			<subversion><xsl:value-of select="*:Msgv2"/></subversion>
			<description><xsl:value-of select="*:Msgtx"/></description>
		</errorMessage>
	</xsl:template>
</xsl:stylesheet>
