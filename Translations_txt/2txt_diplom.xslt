<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xd tei" version="2.0">
    <xsl:output method="text" indent="no" encoding="UTF-8" version="1.0"
        xmlns="http://www.tei-c.org/ns/1.0"/>

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="text/*">
   <xsl:apply-templates/>
</xsl:template>

<xsl:template match="profileDesc/*">
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="fileDesc/*">
</xsl:template>

<xsl:template match="body//note">
<xsl:text>
</xsl:text><xsl:apply-templates/>
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="choice/reg">
</xsl:template>

<xsl:template match="choice/corr">
</xsl:template>

<xsl:template match="add">
</xsl:template>


</xsl:stylesheet>