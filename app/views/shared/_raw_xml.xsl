<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template name="raw-xml">
		<xsl:param name="root"/>

		<xsl:apply-templates select="$root" mode="raw-xml"/>
	</xsl:template>

	<xsl:template match="*" mode="raw-xml">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:apply-templates select="@*" mode="raw-xml" />
		<xsl:choose>
			<xsl:when test="node()">
				<xsl:text>&gt;</xsl:text>
				<xsl:apply-templates mode="raw-xml" />
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> /&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*" mode="raw-xml">
		<xsl:text> </xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>="</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="text()" mode="raw-xml">
		<xsl:value-of select="."/>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
