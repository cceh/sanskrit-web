<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:rails="http://svario.it/xslt-rails"
	exclude-result-prefixes="tei rails"
	version="1.0">

	<xsl:variable name="handle" select="/rails:variables/rails:handle"/>

	<xsl:template match="/">
		<ol>
			<li><xsl:value-of select="count(/rails:variables/rails:lemmas/*/*/tei:*)"/></li>
			<xsl:apply-templates select="/rails:variables/rails:lemmas/*/*/tei:*"/>
		</ol>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re">
		<li>
			<xsl:apply-templates select="tei:form"/>
		</li>
	</xsl:template>

	<xsl:template match="tei:form">
		<xsl:variable name="lemma-sanskrit">FIXME</xsl:variable>

		<a href="lemma/{$lemma-sanskrit}">
			<xsl:value-of select="tei:orth"/>
		</a>
	</xsl:template>
</xsl:stylesheet>
