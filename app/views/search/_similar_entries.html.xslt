<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="../shared/_chars.xsl"/>
	<xsl:import href="../shared/_tei_entry.xsl"/>
	<xsl:import href="../shared/_urls.xsl"/>

	<xsl:variable name="entries" select="/rails:variables/rails:similar_entries"/>

	<xsl:key name="entries" match="/rails:variables/rails:similar_entries/rails:elem/rails:entry/*[self::tei:entry or self::tei:re]" use="tei:form/tei:orth" />

	<xsl:template match="/">
		<section class="results similar">
			<h2>
				<xsl:text>Similar matches</xsl:text>
			</h2>
			<xsl:value-of select="$char-newline"/>

			<xsl:apply-templates select="$entries" mode="summary"/>
			<xsl:value-of select="$char-newline"/>

			<xsl:apply-templates select="$entries"/>
		</section>
	</xsl:template>

	<xsl:template match="rails:similar_entries" mode="summary">
		<xsl:variable name="num-entries" select="count(./rails:elem)"/>

		<details>
			<summary>
				<xsl:value-of select="$num-entries"/>
				<xsl:text> results</xsl:text>
			</summary>

			<!-- FIXME: count results from each dictionary -->
			<p><xsl:text>KKK results in KKK</xsl:text></p>
			<p><xsl:text>YYY results in YYY</xsl:text></p>
		</details>
	</xsl:template>

	<xsl:template match="rails:similar_entries">
		<ul>
			<xsl:apply-templates select="rails:elem/rails:entry/*[self::tei:entry or self::tei:re][generate-id() = generate-id(key('entries', tei:form/tei:orth)[1])]"/>
		</ul>
	</xsl:template>

	<xsl:template match="tei:entry | tei:re">
		<xsl:for-each select="key('entries', tei:form/tei:orth)">
			<xsl:variable name="lemma" select="tei:form/tei:orth/text()"/>

			<xsl:variable name="search-url">
				<xsl:call-template name="search-url">
					<xsl:with-param name="text" select="$lemma"/>
				</xsl:call-template>
			</xsl:variable>

			<li>
				<a href="{$search-url}" class="lemma search">
					<xsl:call-template name="text-and-transliterations">
						<xsl:with-param name="text" select="$lemma"/>
						<xsl:with-param name="rails-entry" select="parent::rails:entry"/>
					</xsl:call-template>
				</a>
			</li>

			<xsl:value-of select="$char-newline"/>

			<!-- FIXME: test with only two chars are key -->
			<!-- FIXME: link to search (what dicts? what params? the controller should tell us) -->
			<!-- FIXME: show provenance -->
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
