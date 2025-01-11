<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xd tei" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" version="1.0"
        xmlns="http://www.tei-c.org/ns/1.0"/>




<xd:doc type="stylesheet">
    <xd:short>
        Script de dissimilation/détildage pour des textes en Français de la Renaissance
  </xd:short>
  <xd:detail>Programme de recherche des Bibliothèques Virtuelles Humanistes (sous la direction de Marie-Luce Demonet)
     CESR, 59 rue Néricault-Destouches, BP 12050, 37020 Tours Cedex France.
  </xd:detail>  
  <xd:author>Jorge Fins jorge.fins@univ-tours.fr</xd:author>
    <xd:copyright>CC BY-NC-SA 3.0 France</xd:copyright>
  </xd:doc>

    <!--    phasage des template
    1 : tout copier
    2 : tokénisation
    3 : 1er passage : ajout de reg/reg@type=modernisation pour le contenu ciblé des <w> étant enfant de <reg> en supprimant <w>. Si pas de règle appliqué, on laisse <w>
    4 : 2ème passage : ajout de reg/reg@type=modernisation pour le contenu ciblé des <w> n'étant pas enfant de <reg> en supprimant <w>. suppression des <w>
    5 : gestion de ceux ayant déjà été concernés par une 1ère règle en modifiant le contenu des <reg@type=modernisation>.
    -->
   <xsl:template match="tei:TEI">
            <xsl:apply-templates/> 
    </xsl:template>
    <!--copie 1 : tout contenu et balisage-->
    <xsl:template match="tei:*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="tei:* | comment() | text()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*|processing-instruction()|comment()">
        <xsl:copy/>
    </xsl:template>
 
    <!--1° tokenisation : chaque mot mis dans une balise <w>, sauf si ce mot est contenu dans :
        - une balise ayant un @xml:lang, un @type="sig" 
        - ou bien dans un sic, corr ou orig (NB : les <reg> seront concernés dans le 2ème passage donc à supprimer avant passage de la feuille)-->
   <xsl:template match="tei:body//tei:*/text()">
    <xsl:analyze-string select="." regex="\w+">
            <xsl:matching-substring>
                <w>
                    <xsl:value-of select="."/>
                </w>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
</xsl:template>


</xsl:stylesheet>