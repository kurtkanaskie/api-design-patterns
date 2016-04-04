<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sap="urn:sap-com:document:sap:soap:functions:mc-style" exclude-result-prefixes="sap soap-env fn xs">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<customers>
			<xsl:apply-templates select="//sap:IsaCustomerGetsalesareasResponse"/>
		</customers>
	</xsl:template>
	<xsl:template match="sap:IsaCustomerGetsalesareasResponse">
		<customer>
			<id><xsl:value-of select="*:Salesareas/*:item[1]/*:Customer"/></id>
			<salesAreas>
				<count><xsl:value-of select="count(*:Salesareas/*:item)"/></count>
				<xsl:for-each select="*:Salesareas/*:item">
					<salesArea>
						<salesOrganization><xsl:value-of select="*:Salesorg"/></salesOrganization>
						<distributionChannel><xsl:value-of select="*:Distrchn"/></distributionChannel>
						<division><xsl:value-of select="*:Division"/></division>
					</salesArea>
				</xsl:for-each>
			</salesAreas>
		</customer>
	</xsl:template>
</xsl:stylesheet>
