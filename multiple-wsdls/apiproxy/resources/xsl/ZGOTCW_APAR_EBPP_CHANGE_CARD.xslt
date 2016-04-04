<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sap="urn:sap-com:document:sap:soap:functions:mc-style" exclude-result-prefixes="sap soap-env fn xs">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<creditCards>
			<xsl:apply-templates select="//sap:AparEbppChangeCardResponse"/>
		</creditCards>
	</xsl:template>
	
	<xsl:template match="sap:AparEbppChangeCardResponse">
		<xsl:choose>
			<xsl:when test="EReturncode=1">
				<status>error</status>
				<xsl:apply-templates select="*:Return"/>
			</xsl:when>
			<xsl:otherwise>
				<count>1</count>
				<status>changed</status>
				<xsl:apply-templates select="*:ENewcard"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*:Return">
		<errorMessage>
			<id><xsl:value-of select="*:Id"/></id>
			<type><xsl:value-of select="*:Type"/></type>
			<number><xsl:value-of select="*:Number"/></number>
			<description><xsl:value-of select="*:Message"/></description>
			<version><xsl:value-of select="*:MessageV1"/></version>
			<subversion><xsl:value-of select="*:MessageV2"/></subversion>
		</errorMessage>
	</xsl:template>
	
	<xsl:template match="*:ENewcard">
		<creditCard>
			<id><xsl:value-of select="*:Carddetailid"/></id>
			<name><xsl:value-of select="*:Descrip"/></name>
		</creditCard>
	</xsl:template>
</xsl:stylesheet>