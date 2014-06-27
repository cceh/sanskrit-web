<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:variable name="dict-name" select="/rails:variables/rails:dict_handle/text()"/>  <!-- FIXME: extract dictionary name -->

	<!-- page-code = page-frontmatter-iv -->
	<!-- page-name = iv (front matter) -->

	<xsl:template match="/">
		<rails:wrapper>
			<xsl:apply-templates select="/rails:variables/rails:scan"/>
		</rails:wrapper>
	</xsl:template>

	<xsl:template match="rails:scan">
		<xsl:variable name="format">jpeg</xsl:variable> <!-- FIXME: read format from data -->

		<xsl:variable name="page-code">
			<xsl:call-template name="page-code">
				<xsl:with-param name="graphic" select="/rails:variables/rails:scan/tei:graphic"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="page-name">
			<xsl:call-template name="page-name">
				<xsl:with-param name="graphic" select="/rails:variables/rails:scan/tei:graphic"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="img-url">
			<xsl:value-of select="$page-code"/>
			<xsl:text>.</xsl:text>
			<xsl:value-of select="$format"/>
		</xsl:variable>

		<xsl:variable name="alt-text">
			<xsl:text>Scan of page </xsl:text>
			<xsl:value-of select="$page-code"/>
			<xsl:text> from </xsl:text>
			<xsl:value-of select="$dict-name"/>
		</xsl:variable>

		<h1>
			<xsl:text>Page </xsl:text>
			<xsl:value-of select="$page-name"/>
			<xsl:text> of </xsl:text>
			<xsl:value-of select="$dict-name"/>
		</h1>

		<nav>
			<ol>
				<li><xsl:apply-templates select="../rails:prev_scan"/></li>
				<li><xsl:apply-templates select="../rails:next_scan"/></li>
			</ol>
		</nav>

		<img src="{$img-url}" alt="{$alt-text}"/>
	</xsl:template>

	<xsl:template match="rails:prev_scan | rails:next_scan">
		<xsl:variable name="page-code">
			<xsl:call-template name="page-code">
				<xsl:with-param name="graphic" select="./tei:graphic"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="page-name">
			<xsl:call-template name="page-name">
				<xsl:with-param name="graphic" select="./tei:graphic"/>
			</xsl:call-template>
		</xsl:variable>

		<a href="{$page-code}">
			<xsl:value-of select="$page-name"/>
		</a>
	</xsl:template>

	<xsl:template name="page-code">
		<xsl:param name="graphic"/>

		<xsl:value-of select="$graphic/@xml:id"/>
	</xsl:template>

	<xsl:template name="page-name">
		<xsl:param name="graphic"/>

		<!-- FIXME: use human-readable name instead of code -->
		<xsl:variable name="page-code">
			<xsl:call-template name="page-code">
				<xsl:with-param name="graphic" select="$graphic"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="substring-after($page-code, 'page-')"/>
	</xsl:template>
</xsl:stylesheet>
