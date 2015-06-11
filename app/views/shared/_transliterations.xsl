<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
	<xsl:import href="_chars.xsl"/>

	<xsl:template name="text-and-transliterations">
		<xsl:param name="text"/>
		<xsl:param name="wrapper-native">span</xsl:param>
		<xsl:param name="wrapper-transliterations">span</xsl:param>
		<xsl:param name="wrapper-text-container">span</xsl:param>
		<xsl:param name="wrapper-text">span</xsl:param>
		<xsl:param name="linked-url"/>
		<xsl:param name="rails-entry"/>

		<xsl:variable name="lookup-text">
			<xsl:call-template name="text-for-lookup">
				<xsl:with-param name="elem" select="$text"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="transliterations" select="$rails-entry/../rails:transliterations/rails:*[@orig_key = $lookup-text or local-name() = $lookup-text]"/>
		<xsl:variable name="native-script" select="$transliterations/*[not(contains(local-name(), '-Latn'))]"/>
		<xsl:variable name="romanized-script" select="$transliterations/rails:san-Latn-x-ISO15919"/>
		<xsl:variable name="additional-scripts" select="$transliterations/*[not(self::rails:san-Latn-x-ISO15919) and contains(local-name(), '-Latn')]"/>
		<xsl:variable name="is-lemma-text" select="$rails-entry/tei:*/tei:form/tei:orth = $text"/>

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

			<xsl:apply-templates select="$romanized-script" mode="generic">
				<xsl:with-param name="class">transliteration</xsl:with-param>
				<xsl:with-param name="last" select="false()"/>
				<xsl:with-param name="wrapper-text-container" select="$wrapper-text-container"/>
				<xsl:with-param name="wrapper-text" select="$wrapper-text"/>
				<xsl:with-param name="linked-url" select="$linked-url"/>
			</xsl:apply-templates>

			<xsl:value-of select="$char-space"/>

			<span class="parens">
				<xsl:text>(</xsl:text>
			</span>

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

			<span class="parens">
				<xsl:text>)</xsl:text>
			</span>
		</xsl:element>
	</xsl:template>

	<xsl:template name="method-name">
		<xsl:param name="lang"/>

		<!-- FIXME: use a proper mapping between language tags and transliteration methods -->
		<xsl:value-of select="substring-after($lang, '-x-')"/>
	</xsl:template>

	<xsl:template name="text-for-lookup">
		<xsl:param name="elem"/>
		<xsl:variable name="pieces" select="$elem/text() | $elem/*"/>

		<xsl:variable name="pieces-text">
			<xsl:for-each select="$pieces">
				<xsl:choose>
					<xsl:when test="self::text()">
						<xsl:value-of select="normalize-space(.)"/>
					</xsl:when>
					<xsl:when test="@ref">
						<xsl:text>+++</xsl:text>
						<xsl:value-of select="local-name(.)"/>
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring-after(@ref, '#')"/>
						<xsl:text>+++</xsl:text>
					</xsl:when>
					<xsl:when test="text()">
						<xsl:text>+++</xsl:text>
						<xsl:value-of select="local-name(.)"/>
						<xsl:text>-</xsl:text>
						<xsl:value-of select="text()"/>
						<xsl:text>+++</xsl:text>
					</xsl:when>
					<xsl:when test="not(*)">
						<xsl:text>+++</xsl:text>
						<xsl:value-of select="local-name(.)"/>
						<xsl:text>+++</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>

		<xsl:value-of select="string($pieces-text)"/>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*/rails:*" mode="generic">
		<xsl:param name="last" select="true()"/>
		<xsl:param name="class">native-script</xsl:param>
		<xsl:param name="wrapper-text-container"/>
		<xsl:param name="wrapper-text"/>
		<xsl:param name="linked-url"/>

		<xsl:variable name="lang" select="local-name()"/>
		<xsl:variable name="text-pieces" select="./rails:elem"/>
		<xsl:variable name="method">
			<xsl:call-template name="method-name">
				<xsl:with-param name="lang" select="$lang"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="formatted-text">
			<xsl:if test="($method != '') and ($method != 'ISO15919')">
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

				<xsl:apply-templates select="$text-pieces"/>
			</xsl:element>
		</xsl:variable>

		<xsl:element name="{$wrapper-text-container}">
			<xsl:attribute name="class">transliteration-wrapper</xsl:attribute>

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

	<xsl:template match="rails:transliterations/rails:*/rails:*" mode="heading">
		<xsl:param name="last" select="true()"/>

		<xsl:variable name="lang" select="local-name()"/>
		<xsl:variable name="text-pieces" select="./rails:elem"/>

		<span xml:lang="{$lang}">
			<xsl:apply-templates select="$text-pieces"/>
		</span>

		<xsl:if test="not($last)">
			<xsl:value-of select="$char-space"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*/rails:*/rails:elem[not(*)]">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*/rails:*/rails:elem[*]">
		<xsl:apply-templates select="*"/>
	</xsl:template>

	<xsl:template match="rails:transliterations/rails:*/rails:*/rails:elem/tei:g">
		<!--
			FIXME: follow reference and use mappings, see
			<https://github.com/gioele/sanskrit-dict-to-tei/issues/151>
		-->
	</xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
