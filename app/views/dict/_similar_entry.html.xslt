<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:variable name="side-data" select="/rails:variables/rails:side_data"/>

	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/rails:variables/rails:entry"/>
	</xsl:template>

	<xsl:template match="rails:entry">
		<xsl:element name="li">
			<!-- FIXME: find a better way to show lemmas and transliterations -->
			<xsl:apply-templates select="$side-data/rails:lemma"/>
			<xsl:element name="div">
				<xsl:attribute name="class">transliterations</xsl:attribute>

				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="$side-data/rails:transliterations/rails:*"/>
				<xsl:text>)</xsl:text>

				<xsl:call-template name="provenance-info"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="rails:lemma">
		<xsl:element name="dt">
			<xsl:attribute name="class">lemma</xsl:attribute>
			<xsl:attribute name="xml:lang">san-Deva</xsl:attribute>

			<xsl:element name="a">
				<xsl:attribute name="href">
					<xsl:text>/dict?q=</xsl:text>
					<xsl:value-of select="$side-data/rails:lemma"/>
					<xsl:text>;iscript=devanagari;utf8=✓</xsl:text>
				</xsl:attribute>

				<xsl:element name="dfn">
					<xsl:value-of select="$side-data/rails:lemma"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*">
		<xsl:variable name="method" select="local-name()"/>
		<xsl:variable name="lemma" select="text()"/>

		<xsl:element name="dt">
			<xsl:attribute name="class">transliteration</xsl:attribute>
			<xsl:attribute name="xml:lang">san-Latn</xsl:attribute> <!-- FIXME: set according to $method -->

			<xsl:element name="a">
				<xsl:attribute name="href">
					<xsl:text>/dict?q=</xsl:text>
					<xsl:value-of select="$lemma"/>
					<xsl:text>;iscript=</xsl:text>
					<xsl:value-of select="$method"/>
				</xsl:attribute>

				<xsl:element name="span">
					<xsl:attribute name="class">method</xsl:attribute>
					<xsl:value-of select="$method"/>
				</xsl:element>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="$lemma"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="provenance-info">
		<xsl:variable name="dictionary" select="$side-data/rails:dict"/>

		<xsl:value-of select="$space-char"/>

		<cite class="provenance-info">
			<xsl:text>(</xsl:text>
			<abbr class="dictionary">
				<a href="/dictionary/{$dictionary}">
					<xsl:value-of select="$dictionary"/>
				</a>
			</abbr>
			<xsl:text>)</xsl:text>
		</cite>
	</xsl:template>
</xsl:stylesheet>
