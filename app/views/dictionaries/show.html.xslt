<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:variable name="handle" select="/rails:variables/rails:handle"/>
	<xsl:variable name="num-lemmas" select="/rails:variables/rails:num_lemmas"/>
	<xsl:variable name="lang-code-lemmas" select="/rails:variables/rails:lang_lemmas"/>
	<xsl:variable name="lang-code-definitions" select="/rails:variables/rails:lang_definitions"/>

	<xsl:variable name="lang-lemmas">
		<xsl:call-template name="language-name">
			<xsl:with-param name="lang-code" select="$lang-code-lemmas"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="lang-definitions">
		<xsl:call-template name="language-name">
			<xsl:with-param name="lang-code" select="$lang-code-definitions"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:template match="/rails:variables/rails:header/tei:teiHeader">
		<xsl:variable name="desc-title" select=".//tei:titleStmt/tei:title[@type='desc']"/>
		<xsl:variable name="orig-title" select=".//tei:sourceDesc//tei:title[@type='main']"/>
		<xsl:variable name="orig-sub-title" select=".//tei:sourceDesc//tei:title[@type='sub']"/>

		<xsl:variable name="author" select=".//tei:sourceDesc//tei:author"/>

		<rails:wrapper>
			<h1>
				<xsl:value-of select="$desc-title"/>
			</h1>

			<p>
				<xsl:text>Originally: </xsl:text>
				<xsl:value-of select="$orig-title"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$orig-sub-title"/>
			</p>

			<p>
				<xsl:text>By </xsl:text>
				<xsl:value-of select="$author"/>
				<xsl:text>.</xsl:text>
			</p>

			<p>
				<xsl:text>The </xsl:text>
				<xsl:value-of select="$desc-title"/>
				<xsl:text> dictionary contains </xsl:text>
				<xsl:value-of select="$num-lemmas"/>
				<xsl:value-of select="$space-char"/>
				<xsl:text> lemmas in </xsl:text>
				<xsl:copy-of select="$lang-lemmas"/>
				<xsl:text> and </xsl:text>
				<xsl:text> definitions in </xsl:text>
				<xsl:copy-of select="$lang-definitions"/>
				<xsl:text>.</xsl:text>
			</p>

			<a href="{$handle}/lemmas">
				<xsl:text>Browse lemmas</xsl:text>
			</a>

			<a href="{$handle}/scans">
				<xsl:text>Browse scans</xsl:text>
			</a>

			<a href="../search?dict={$handle}">
				<xsl:text>Search inside</xsl:text>
			</a>
		</rails:wrapper>
	</xsl:template>

	<xsl:template name="language-name">
		<xsl:param name="lang-code"/>

		<xsl:choose>
			<xsl:when test="starts-with($lang-code, 'en')">English</xsl:when>
			<xsl:when test="starts-with($lang-code, 'san')">Sanskrit</xsl:when>
			<xsl:when test="$lang-code = 'unk'">an unknown language</xsl:when>
			<xsl:otherwise>
				<xsl:text>the language </xsl:text>
				<em>
					<xsl:value-of select="$lang-code"/>
				</em>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
