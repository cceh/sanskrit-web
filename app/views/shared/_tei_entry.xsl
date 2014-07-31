<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="_urls.xsl"/>

	<xsl:variable name="space-char" xml:space="preserve"><xsl:text>&#32;</xsl:text></xsl:variable>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:lemma/rails:dict_handle/text()"/>
	<xsl:variable name="entry" select="/rails:variables/rails:lemma/rails:entry/*[self::tei:entry or self::tei:re]"/>
	<xsl:variable name="orth" select="$entry/tei:form/tei:orth/text()"/>
	<xsl:variable name="transliterations" select="/rails:variables/rails:lemma/rails:transliterations/rails:*[@orig-key = $orth or local-name() = $orth]"/>

	<xsl:template match="tei:form" mode="heading">
		<xsl:variable name="native-script" select="$transliterations/*[not(contains(local-name(), '-Latn'))]"/>
		<xsl:variable name="additional-scripts" select="$transliterations/*[contains(local-name(), '-Latn')]"/>

		<xsl:apply-templates select="$native-script" mode="heading"/>
		<xsl:apply-templates select="../@n"/>

		<xsl:value-of select="$space-char"/>

		<span class="transliterations">
			<xsl:text>(</xsl:text>

			<xsl:for-each select="$additional-scripts">
				<xsl:sort select="local-name()"/>

				<xsl:apply-templates select="." mode="heading">
					<xsl:with-param name="last" select="position() = count($additional-scripts)"/>
				</xsl:apply-templates>
			</xsl:for-each>

			<xsl:text>)</xsl:text>
		</span>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*/rails:*" mode="heading">
		<xsl:param name="last" select="true()"/>

		<xsl:variable name="lang" select="local-name()"/>
		<xsl:variable name="text" select="text()"/>

		<span xml:lang="{$lang}">
			<xsl:value-of select="$text"/>
		</span>

		<xsl:if test="not($last)">
			<xsl:value-of select="$space-char"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:form">
		<xsl:variable name="native-script" select="$transliterations/*[not(contains(local-name(), '-Latn'))]"/>
		<xsl:variable name="additional-scripts" select="$transliterations/*[contains(local-name(), '-Latn')]"/>

		<xsl:apply-templates select="$native-script"/>
		<xsl:apply-templates select="../@n"/>

		<xsl:value-of select="$space-char"/>

		<div class="transliterations">
			<xsl:text>(</xsl:text>

			<xsl:for-each select="$additional-scripts">
				<xsl:sort select="local-name()"/>

				<xsl:apply-templates select=".">
					<xsl:with-param name="last" select="position() = count($additional-scripts)"/>
					<xsl:with-param name="class">transliteration</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>

			<xsl:text>)</xsl:text>
		</div>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*/rails:*">
		<xsl:param name="last" select="true()"/>
		<xsl:param name="class">native-script</xsl:param>

		<xsl:variable name="lang" select="local-name()"/>
		<xsl:variable name="text" select="text()"/>
		<xsl:variable name="method">
			<xsl:call-template name="method-name">
				<xsl:with-param name="lang" select="$lang"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="lemma-url">
			<xsl:call-template name="lemma-url">
				<xsl:with-param name="entry" select="$entry"/>
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
			</xsl:call-template>
		</xsl:variable>

		<dt xml:lang="{$lang}" class="{$class}">
			<a href="{$lemma-url}">
				<xsl:if test="$method != ''">
					<span class="method">
						<xsl:value-of select="$method"/>
					</span>
					<xsl:text>: </xsl:text>
				</xsl:if>

				<dfn>
					<xsl:value-of select="$text"/>
				</dfn>
			</a>
		</dt>

		<xsl:if test="not($last)">
			<xsl:value-of select="$space-char"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:*/@n">
		<sup class="homograph-id">
			<xsl:value-of select="."/>
		</sup>
	</xsl:template>

	<xsl:template name="method-name">
		<xsl:param name="lang"/>

		<!-- FIXME: use a proper mapping between language tags and transliteration methods -->
		<xsl:value-of select="substring-after($lang, '-x-')"/>
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

	<xsl:template match="tei:cit/tei:bibl">
		<xsl:variable name="expansion">FIXME autorities</xsl:variable>

<!--
		<xsl:variable name="biblio-url">
			<xsl:call-template name="biblio-url">
				<xsl:with-param name="biblio-ref" select="tei:ref"/>
			</xsl:call-template>
		</xsl:variable>
-->

		<abbr title="{$expansion}">
			<xsl:value-of select="normalize-space(.)"/>
		</abbr>
	</xsl:template>


	<xsl:template match="tei:abbr">
		<xsl:variable name="expansion">FIXME abbrevations</xsl:variable>

		<abbr title="{$expansion}">
			<xsl:value-of select="normalize-space(.)"/>
		</abbr>
	</xsl:template>

	<xsl:template match="tei:w | tei:m">
		<xsl:variable name="is-or-needs-transliteration" select="contains(@xml:lang, 'san-Latn-')"/> <!-- FIXME: maybe set to true for cyrillic and others -->

		<xsl:variable name="text" select="."/> <!-- FIXME: can there be elements inside tei:w? -->
		<xsl:variable name="class" select="concat('tei-', local-name())"/>

		<span class="{$class}">
			<xsl:choose>
				<xsl:when test="$is-or-needs-transliteration">
					<xsl:call-template name="text-and-transliterations">
						<xsl:with-param name="text" select="$text"/>
						<xsl:with-param name="wrapper-native">span</xsl:with-param>
						<xsl:with-param name="wrapper-transliterations">span</xsl:with-param>
						<xsl:with-param name="entry" select="/rails:variables/rails:lemma"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="@xml:lang">
						<xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
						<xsl:attribute name="lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
					</xsl:if>

					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

	<xsl:template name="text-and-transliterations">
		<xsl:param name="text"/>
		<xsl:param name="wrapper-native"/>
		<xsl:param name="wrapper-transliterations"/>
		<xsl:param name="entry"/>

		<xsl:variable name="transliterations" select="$entry/rails:transliterations/rails:*[@orig-key = $text or local-name() = $text]"/>
		<xsl:variable name="native-script" select="$transliterations/*[not(contains(local-name(), '-Latn'))]"/>
		<xsl:variable name="additional-scripts" select="$transliterations/*[contains(local-name(), '-Latn')]"/>

		<xsl:element name="{$wrapper-native}">
			<xsl:attribute name="class">native</xsl:attribute>

			<xsl:apply-templates select="$native-script" mode="generic"/>
			<xsl:apply-templates select="../@n"/> <!-- FIXME: how are homographs distinguished in tei:w? -->
		</xsl:element>

		<xsl:value-of select="$space-char"/>

		<xsl:element name="{$wrapper-transliterations}">
			<xsl:attribute name="class">transliterations</xsl:attribute>

			<xsl:text>(</xsl:text>

			<xsl:for-each select="$additional-scripts">
				<xsl:sort select="local-name()"/>

				<xsl:apply-templates select="." mode="generic">
					<xsl:with-param name="class">transliteration</xsl:with-param>
					<xsl:with-param name="last" select="position() = count($additional-scripts)"/>
				</xsl:apply-templates>
			</xsl:for-each>

			<xsl:text>)</xsl:text>
		</xsl:element>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*/rails:*" mode="generic">
		<xsl:param name="last" select="true()"/>
		<xsl:param name="class">native-script</xsl:param>

		<xsl:variable name="lang" select="local-name()"/>
		<xsl:variable name="text" select="text()"/>
		<xsl:variable name="method">
			<xsl:call-template name="method-name">
				<xsl:with-param name="lang" select="$lang"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="search-url">
			<xsl:call-template name="search-url">
				<xsl:with-param name="text" select="$text"/>
			</xsl:call-template>
		</xsl:variable>

		<span>
			<a href="{$search-url}">
				<xsl:if test="$method != ''">
					<span class="method">
						<xsl:value-of select="$method"/>
						<xsl:text>:</xsl:text>
					</span>

					<xsl:value-of select="$space-char"/>
				</xsl:if>

				<span xml:lang="{$lang}" lang="{$lang}" class="{$class}">
					<xsl:value-of select="$text"/>
				</span>
			</a>
		</span>

		<xsl:if test="not($last)">
			<xsl:value-of select="$space-char"/>
		</xsl:if>
	</xsl:template>





	<xsl:template name="provenance-info">
		<xsl:param name="sense"/>

		<xsl:variable name="page-ref" select="$sense/tei:note/tei:ref"/>
		<xsl:variable name="scan-url">
			<xsl:call-template name="scan-url">
				<xsl:with-param name="page-ref" select="$page-ref"/>
				<xsl:with-param name="dict-handle" select="$dict-handle"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$space-char"/>

		<cite class="provenance-info">
			<xsl:text>(</xsl:text>
			<abbr class="dictionary">
				<a href="/dictionary/{$dict-handle}">
					<xsl:value-of select="$dict-handle"/>
				</a>
			</abbr>

			<xsl:text> at page </xsl:text>

			<a href="{$scan-url}">
				<xsl:value-of select="$page-ref"/>
			</a>

			<xsl:text>)</xsl:text>
		</cite>
	</xsl:template>
</xsl:stylesheet>
