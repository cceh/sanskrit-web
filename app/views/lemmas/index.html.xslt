<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_urls.xsl"/>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:dict/rails:handle/text()"/>

	<xsl:variable name="count" select="count(/rails:variables/rails:lemmas/rails:elem)"/>

	<xsl:template match="/">
		<rails:wrapper>
			<h1>
				<xsl:text>Lemmas in </xsl:text>
				<xsl:value-of select="$dict-handle"/>
				<xsl:text> FIXME(complete name) (</xsl:text>
				<xsl:value-of select="$count"/>
				<xsl:text>)</xsl:text>
			</h1>

			<ol>
				<xsl:apply-templates select="/rails:variables/rails:lemmas/rails:elem/rails:entry/tei:*"/>
			</ol>
		</rails:wrapper>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re">
		<xsl:variable name="class">
			<xsl:text>tei-</xsl:text>
			<xsl:value-of select="local-name()"/>
			<!-- FIXME: extra parameter for deeply nested entries -->
		</xsl:variable>

		<li class="{$class}">
			<xsl:variable name="lemma" select="tei:form/tei:orth/text()"/>

			<xsl:variable name="lemma-url">
				<xsl:call-template name="lemma-url">
					<xsl:with-param name="tei-entry" select="."/>
					<xsl:with-param name="dict-handle" select="$dict-handle"/>
				</xsl:call-template>
			</xsl:variable>

			<a href="{$lemma-url}">
				<xsl:call-template name="text-and-transliterations">
					<xsl:with-param name="text" select="$lemma"/>
					<xsl:with-param name="rails-entry" select="parent::rails:entry"/>
				</xsl:call-template>
			</a>
		</li>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
