<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_tei_entry.xsl"/>

	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:lemma/rails:dict_handle/text()"/>
	<xsl:variable name="entry" select="/rails:variables/rails:lemma/rails:entry/*[self::tei:entry or self::tei:re]"/>

	<xsl:template match="/">
		<li><xsl:apply-templates select="$entry/tei:form"/></li>
	</xsl:template>
</xsl:stylesheet>
