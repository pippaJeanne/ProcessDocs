<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xd tei" version="2.0">
    <xsl:output method="text" indent="yes" encoding="UTF-8" version="1.0"
        xmlns="http://www.tei-c.org/ns/1.0"/>

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="*">
    <xsl:value-of select="."/>
</xsl:template>


<xsl:template match="//choice/orig">
</xsl:template>

<xsl:template match="//choice/sic">
</xsl:template>

<xsl:template match="//del">
</xsl:template>


</xsl:stylesheet>