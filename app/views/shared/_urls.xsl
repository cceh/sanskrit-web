<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template name="search-url">
		<xsl:param name="text"/>
		<xsl:param name="url-root"/>

		<xsl:value-of select="$url-root"/>
		<xsl:text>/search</xsl:text>
		<xsl:text>?</xsl:text>
		<xsl:text>utf8=✓</xsl:text>
		<xsl:text>&amp;</xsl:text>
		<xsl:text>q=</xsl:text>
		<xsl:value-of select="$text"/>
		<xsl:text>&amp;</xsl:text>
		<xsl:text>iscript=slp1</xsl:text>
	</xsl:template>

	<xsl:template name="lemma-url">
		<xsl:param name="tei-entry"/>
		<xsl:param name="dict-handle"/>
		<xsl:param name="url-root"/>

		<xsl:variable name="id-for-url" select="substring-after($tei-entry/@xml:id, 'lemma-')"/>

		<xsl:value-of select="$url-root"/>
		<xsl:text>/dictionary/</xsl:text>
		<xsl:value-of select="$dict-handle"/>
		<xsl:text>/lemma/</xsl:text>
		<xsl:value-of select="$id-for-url"/>
	</xsl:template>

	<xsl:template name="scan-url">
		<xsl:param name="page-ref"/>
		<xsl:param name="dict-handle"/>
		<xsl:param name="url-root"/>

		<xsl:variable name="page-num" select="substring-after($page-ref/@target, '#page-')"/>

		<xsl:value-of select="$url-root"/>
		<xsl:text>/dictionary/</xsl:text>
		<xsl:value-of select="$dict-handle"/>
		<xsl:text>/scan/</xsl:text>
		<xsl:value-of select="$page-num"/>
	</xsl:template>

	<xsl:template name="biblio-url">
		<xsl:param name="biblio-ref"/>
		<xsl:param name="dict-handle"/>
		<xsl:param name="url-root"/>

		<xsl:variable name="biblio-id" select="substring-after($biblio-ref/@target, '#auth-')"/>

		<xsl:value-of select="$url-root"/>
		<xsl:text>/dictionary/</xsl:text>
		<xsl:value-of select="$dict-handle"/>
		<xsl:text>/biblio/</xsl:text>
		<xsl:value-of select="$biblio-id"/>
	</xsl:template>

	<xsl:template name="dict-url">
		<xsl:param name="dict-handle"/>
		<xsl:param name="url-root"/>

		<xsl:value-of select="$url-root"/>
		<xsl:text>/dictionary/</xsl:text>
		<xsl:value-of select="$dict-handle"/>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
