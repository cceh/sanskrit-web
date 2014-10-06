<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="_chars.xsl"/>
	<xsl:import href="_urls.xsl"/>

	<xsl:variable name="dict-handle" select="/rails:variables/rails:lemma/rails:dict_handle/text()"/>

	<xsl:template match="tei:form" mode="heading">
		<xsl:variable name="tei-entry" select="ancestor::*[self::tei:entry or self::tei:re]"/>
		<xsl:variable name="rails-entry" select="$tei-entry/.."/>
		<xsl:variable name="tei-orth" select="tei:orth/text()"/>
		<xsl:variable name="transliterations" select="$rails-entry/../rails:transliterations/rails:*[@orig-key = $tei-orth or local-name() = $tei-orth]"/>

		<xsl:variable name="native-script" select="$transliterations/*[not(contains(local-name(), '-Latn'))]"/>
		<xsl:variable name="additional-scripts" select="$transliterations/*[contains(local-name(), '-Latn')]"/>

		<xsl:apply-templates select="$native-script" mode="heading"/>
		<xsl:apply-templates select="../@n"/>

		<xsl:value-of select="$char-space"/>

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
			<xsl:value-of select="$char-space"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:form" mode="definition">
		<xsl:param name="linked-url"/>

		<xsl:call-template name="text-and-transliterations">
			<xsl:with-param name="text" select="tei:orth/text()"/>
			<xsl:with-param name="wrapper-native">div</xsl:with-param>
			<xsl:with-param name="wrapper-transliterations">div</xsl:with-param>
			<xsl:with-param name="wrapper-text-container">dt</xsl:with-param>
			<xsl:with-param name="wrapper-text">dfn</xsl:with-param>
			<xsl:with-param name="linked-url" select="$linked-url"/>
			<xsl:with-param name="rails-entry" select="parent::tei:*/parent::rails:entry"/>
		</xsl:call-template>

		<xsl:if test="tei:hyph/text() != tei:orth/text()">
			<xsl:call-template name="text-and-transliterations">
				<xsl:with-param name="text" select="tei:hyph/text()"/>
				<xsl:with-param name="wrapper-native">div</xsl:with-param>
				<xsl:with-param name="wrapper-transliterations">div</xsl:with-param>
				<xsl:with-param name="wrapper-text-container">dt</xsl:with-param>
				<xsl:with-param name="wrapper-text">dfn</xsl:with-param>
				<xsl:with-param name="linked-url" select="$linked-url"/>
				<xsl:with-param name="rails-entry" select="parent::tei:*/parent::rails:entry"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tei:form" mode="listing">
		<xsl:param name="linked-url"/>

		<xsl:call-template name="text-and-transliterations">
			<xsl:with-param name="text" select="tei:orth/text()"/>
			<xsl:with-param name="wrapper-native">div</xsl:with-param>
			<xsl:with-param name="wrapper-transliterations">div</xsl:with-param>
			<xsl:with-param name="wrapper-text-container">dt</xsl:with-param>
			<xsl:with-param name="wrapper-text">dfn</xsl:with-param>
			<xsl:with-param name="linked-url" select="$linked-url"/>
			<xsl:with-param name="rails-entry" select="parent::tei:*/parent::rails:entry"/>
		</xsl:call-template>
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





	<xsl:template match="tei:sense" mode="definition">
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

	<xsl:template match="tei:choice">
		<xsl:choose>
			<xsl:when test="tei:abbr and tei:expan">
				<xsl:apply-templates select="tei:expan"/>
			</xsl:when>
			<xsl:when test="tei:reg">
				<xsl:variable name="favourites" select="tei:reg[descendant-or-self::tei:*[@xml:lang = 'san-Latn-x-SLP1']]"/>

				<xsl:apply-templates select="$favourites"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:abbr">
		<xsl:variable name="expansion">FIXME abbrevations</xsl:variable>

		<abbr class="tei-abbr" title="{$expansion}">
			<xsl:value-of select="normalize-space(.)"/>
		</abbr>
	</xsl:template>

	<xsl:template match="tei:expan">
		<span class="tei-expan">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<xsl:template match="tei:reg">
		<span class="tei-reg">
			<xsl:apply-templates/>
		</span>
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

		<abbr class="tei-bibl" title="{$expansion}">
			<xsl:value-of select="normalize-space(.)"/>
		</abbr>
	</xsl:template>

	<xsl:template match="tei:w | tei:m">
		<xsl:variable name="is-in-sanskrit" select="contains(@xml:lang, 'san-Latn-')"/>

		<xsl:variable name="is-part-of-mixed-script-word" select="self::tei:m and following-sibling::text()"/>
		<xsl:variable name="is-or-needs-transliteration" select="$is-in-sanskrit and not($is-part-of-mixed-script-word)"/> <!-- FIXME: maybe set to true for cyrillic and others -->
		<xsl:variable name="should-be-searchable" select="$is-in-sanskrit"/>

		<xsl:variable name="text" select="string(.)"/> <!-- FIXME: deal with <g> elements inside <w> -->

		<xsl:variable name="text-content">
			<xsl:choose>
				<xsl:when test="$is-or-needs-transliteration">
					<xsl:call-template name="text-and-transliterations">
						<xsl:with-param name="text" select="$text"/>
						<xsl:with-param name="rails-entry" select="ancestor::rails:entry"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$is-part-of-mixed-script-word">
					<span class="mixed-scripts">
						<xsl:apply-templates/> <!-- FIXME: generate transliterations -->
					</span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="search-url">
			<xsl:call-template name="search-url">
				<xsl:with-param name="text" select="$text"/>
			</xsl:call-template>
		</xsl:variable>

		<span class="tei-{local-name()}">
			<xsl:choose>
				<xsl:when test="$should-be-searchable">
					<a href="{$search-url}" class="lemma search">
						<xsl:if test="not($is-or-needs-transliteration)">
							<xsl:if test="@xml:lang">
								<xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
								<xsl:attribute name="lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
							</xsl:if>
						</xsl:if>

						<xsl:copy-of select="$text-content"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not($is-or-needs-transliteration)">
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
							<xsl:attribute name="lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
						</xsl:if>
					</xsl:if>

					<xsl:copy-of select="$text-content"/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

	<xsl:template name="text-and-transliterations">
		<xsl:param name="text"/>
		<xsl:param name="wrapper-native">span</xsl:param>
		<xsl:param name="wrapper-transliterations">span</xsl:param>
		<xsl:param name="wrapper-text-container">span</xsl:param>
		<xsl:param name="wrapper-text">span</xsl:param>
		<xsl:param name="linked-url"/>
		<xsl:param name="rails-entry"/>

		<xsl:variable name="transliterations" select="$rails-entry/../rails:transliterations/rails:*[@orig_key = $text or local-name() = $text]"/>
		<xsl:variable name="native-script" select="$transliterations/*[not(contains(local-name(), '-Latn'))]"/>
		<xsl:variable name="additional-scripts" select="$transliterations/*[contains(local-name(), '-Latn')]"/>
		<xsl:variable name="is-lemma-text" select="$rails-entry/tei:*/tei:form/tei:orth/text() = $text"/>

		<xsl:element name="{$wrapper-native}">
			<xsl:attribute name="class">native-script</xsl:attribute>

			<xsl:apply-templates select="$native-script" mode="generic">
				<xsl:with-param name="wrapper-text-container" select="$wrapper-text-container"/>
				<xsl:with-param name="wrapper-text" select="$wrapper-text"/>
				<xsl:with-param name="linked-url" select="$linked-url"/>
			</xsl:apply-templates>
			<xsl:if test="$is-lemma-text">
				<xsl:apply-templates select="$rails-entry/tei:*/@n"/> <!-- FIXME: how are homographs distinguished in tei:w? -->
			</xsl:if>
		</xsl:element>

		<xsl:value-of select="$char-space"/>

		<xsl:element name="{$wrapper-transliterations}">
			<xsl:attribute name="class">transliterations</xsl:attribute>

			<xsl:text>(</xsl:text>

			<xsl:for-each select="$additional-scripts">
				<xsl:sort select="local-name()"/>

				<xsl:apply-templates select="." mode="generic">
					<xsl:with-param name="class">transliteration</xsl:with-param>
					<xsl:with-param name="last" select="position() = count($additional-scripts)"/>
					<xsl:with-param name="wrapper-text-container" select="$wrapper-text-container"/>
					<xsl:with-param name="wrapper-text" select="$wrapper-text"/>
					<xsl:with-param name="linked-url" select="$linked-url"/>
				</xsl:apply-templates>
			</xsl:for-each>

			<xsl:text>)</xsl:text>
		</xsl:element>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*/rails:*" mode="generic">
		<xsl:param name="last" select="true()"/>
		<xsl:param name="class">native-script</xsl:param>
		<xsl:param name="wrapper-text-container"/>
		<xsl:param name="wrapper-text"/>
		<xsl:param name="linked-url"/>

		<xsl:variable name="lang" select="local-name()"/>
		<xsl:variable name="text" select="text()"/>
		<xsl:variable name="method">
			<xsl:call-template name="method-name">
				<xsl:with-param name="lang" select="$lang"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="formatted-text">
			<xsl:if test="$method != ''">
				<span class="method">
					<xsl:value-of select="$method"/>
					<xsl:text>:</xsl:text>
				</span>

				<xsl:value-of select="$char-space"/>
			</xsl:if>

			<xsl:element name="{$wrapper-text}">
				<xsl:attribute name="xml:lang"><xsl:value-of select="$lang"/></xsl:attribute>
				<xsl:attribute name="lang"><xsl:value-of select="$lang"/></xsl:attribute>
				<xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>

				<xsl:value-of select="$text"/>
			</xsl:element>
		</xsl:variable>

		<xsl:element name="{$wrapper-text-container}">
			<xsl:choose>
				<xsl:when test="$linked-url != ''">
					<a href="{$linked-url}">
						<xsl:copy-of select="$formatted-text"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$formatted-text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

		<xsl:if test="not($last)">
			<xsl:value-of select="$char-space"/>
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

		<xsl:value-of select="$char-space"/>

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

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
