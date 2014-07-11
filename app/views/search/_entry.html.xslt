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
		<xsl:element name="dl">
			<!-- FIXME: find a better way to show lemmas and transliterations -->
			<xsl:apply-templates select="$side-data/rails:lemma"/>
			<xsl:element name="div">
				<xsl:attribute name="class">transliterations</xsl:attribute>

				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="$side-data/rails:transliterations/rails:*"/>
				<xsl:text>)</xsl:text>
			</xsl:element>

			<xsl:apply-templates select="./*/tei:sense"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="rails:lemma">
		<xsl:element name="dt">
			<xsl:attribute name="class">lemma</xsl:attribute>
			<xsl:attribute name="xml:lang">san-Deva</xsl:attribute>

			<xsl:element name="a">
				<xsl:attribute name="href">
					<xsl:text>/lemma/</xsl:text>
					<xsl:value-of select="$side-data/rails:lemma"/>
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
					<xsl:text>/lemma/</xsl:text>
					<xsl:value-of select="$lemma"/>
					<xsl:text>?iscript=</xsl:text>
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

	<xsl:template match="tei:sense">
		<dd class="sense">
			<xsl:apply-templates select="node()[not(self::tei:note)]"/>

			<xsl:call-template name="provenance-info">
				<xsl:with-param name="sense" select="."/>
			</xsl:call-template>
		</dd>
	</xsl:template>

	<xsl:template match="tei:gram">
		<em class="gram">
			<xsl:value-of select="."/>
		</em>
	</xsl:template>

	<xsl:template match="tei:cit">
		<!-- FIXME: use a proper citational URI scheme -->
		<a href="/biblio/FIXME">
			<xsl:value-of select="normalize-space(.)"/>
		</a>

		<xsl:value-of select="$space-char"/>
	</xsl:template>

	<xsl:template name="provenance-info">
		<xsl:param name="sense"/>

		<xsl:variable name="dictionary" select="$side-data/rails:dict"/>
		<xsl:variable name="page-info" select="$sense/tei:note/tei:ref"/>
		<xsl:variable name="page-num" select="substring-after($page-info/@target, '#page-')"/>

		<xsl:value-of select="$space-char"/>

		<cite class="provenance-info">
			<xsl:text>(</xsl:text>
			<abbr class="dictionary">
				<a href="/dictionary/{$dictionary}">
					<xsl:value-of select="$dictionary"/>
				</a>
			</abbr>

			<xsl:text> at page </xsl:text>
			<!-- FIXME: link to the scan using a proper URI scheme -->
			<a href="/dictionary/{$dictionary}/scan/{$page-num}">
				<xsl:value-of select="$page-info"/>
			</a>
			<xsl:text>)</xsl:text>
		</cite>
	</xsl:template>
</xsl:stylesheet>
