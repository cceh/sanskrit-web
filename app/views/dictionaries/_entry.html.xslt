<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_chars.xsl"/>
	<xsl:import href="../shared/_urls.xsl"/>

	<xsl:variable name="url-root" select="string(/rails:variables/rails:relative_url_root)"/>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:dict_handle"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/rails:variables/rails:header/tei:teiHeader"/>
	</xsl:template>

	<xsl:template match="tei:teiHeader">
		<xsl:variable name="desc-title" select=".//tei:titleStmt//tei:title[@type='desc']"/>
		<xsl:variable name="orig-title" select=".//tei:sourceDesc//tei:title[@type='main']"/>
		<xsl:variable name="orig-sub-title" select=".//tei:sourceDesc//tei:title[@type='sub']"/>

		<xsl:variable name="author" select=".//tei:sourceDesc//tei:author"/>

		<xsl:variable name="dict-url">
			<xsl:call-template name="dict-url">
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
				<xsl:with-param name="url-root" select="$url-root"/>
			</xsl:call-template>
		</xsl:variable>

		<section>
			<h2>
				<a href="{$dict-url}">
					<xsl:value-of select="$desc-title"/>
				</a>
			</h2>

			<p>
				<xsl:text>Originally: </xsl:text>
				<xsl:value-of select="$orig-title"/>
				<xsl:if test="$orig-sub-title">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="$orig-sub-title"/>
				</xsl:if>
			</p>

			<p>
				<xsl:text>By </xsl:text>
				<xsl:value-of select="$author"/>
				<xsl:text>.</xsl:text>
			</p>

			<p>
				<a href="{$dict-url}">
					<xsl:text>More info</xsl:text>
				</a>

				<xsl:value-of select="$char-space"/>

				<a href="{$dict-url}/scans">
					<xsl:text>Browse</xsl:text>
				</a>

				<xsl:value-of select="$char-space"/>

				<a href="../search?dict={$dict-handle}">
					<xsl:text>Search inside</xsl:text>
				</a>
			</p>
		</section>
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
