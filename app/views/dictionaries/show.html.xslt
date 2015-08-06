<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_chars.xsl"/>
	<xsl:import href="../shared/_raw_xml.xsl"/>
	<xsl:import href="../shared/_tei_header.xsl"/>

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
		<rails:wrapper>
			<xsl:call-template name="desc-title">
				<xsl:with-param name="root" select="."/>
			</xsl:call-template>

			<section>
				<h2>Original edition</h2>

				<xsl:apply-templates select=".//tei:fileDesc/tei:sourceDesc"/>
			</section>

			<section>
				<h2>Digital edition</h2>

				<xsl:apply-templates select=".//tei:fileDesc/tei:editionStmt"/>

				<xsl:apply-templates select=".//tei:fileDesc/tei:seriesStmt"/>
			</section>

			<nav>
				<ul>
					<li>
						<a href="{$handle}/lemmas">
							<xsl:text>Browse lemmas</xsl:text>
						</a>
					</li>
					<li>
						<a href="{$handle}/scans">
							<xsl:text>Browse scans</xsl:text>
						</a>
					</li>
					<li>
						<a href="../search?dict={$handle}">
							<xsl:text>Search inside</xsl:text>
						</a>
					</li>
				</ul>
			</nav>

			<xsl:call-template name="raw-tei-snippet">
				<xsl:with-param name="tei-element" select="."/>
			</xsl:call-template>
		</rails:wrapper>
	</xsl:template>

	<xsl:template name="desc-title">
		<xsl:param name="root"/>

		<xsl:variable name="desc-title" select="$root//tei:titleStmt/tei:title[@type='desc']"/>

		<h1>
			<xsl:value-of select="$desc-title"/>
		</h1>
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

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
