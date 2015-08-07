<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:rails="http://svario.it/xslt-rails"
                exclude-result-prefixes="tei rails"
                version="1.0">
    <xsl:template name="page-code">
        <xsl:param name="graphic"/>

        <xsl:variable name="id" select="$graphic/@xml:id"/>
        <xsl:variable name="code" select="substring-after($id, 'page-')"/>

        <xsl:value-of select="$code"/>
    </xsl:template>

    <xsl:template name="page-name">
        <xsl:param name="graphic"/>

        <!-- FIXME: use human-readable name instead of code -->
        <xsl:variable name="page-code">
            <xsl:call-template name="page-code">
                <xsl:with-param name="graphic" select="$graphic"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="$page-code"/>
    </xsl:template>
</xsl:stylesheet>

<!-- Licensed under the ISC licence, see LICENCE.ISC for details -->
