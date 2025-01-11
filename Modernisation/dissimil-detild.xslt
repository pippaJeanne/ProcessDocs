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
    3 : détildage : ajout d'orig/reg pour le contenu ciblé des <w> en supprimant <w>. Si pas de règle appliqué, on laisse <w>
    4 : dissimilation : ajout d'orig/reg pour le contenu ciblé des <w> en supprimant <w>. suppression des <w>
    3 : gestion de ceux ayant déjà été concernés par une 1ère règle en modifiant le contenu des <reg>.
    -->
    <xsl:template match="/">
        <xsl:variable name="pass1">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:variable name="pass2">
            <xsl:for-each select="$pass1">
                <xsl:apply-templates mode="pass2"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="pass3">
            <xsl:for-each select="$pass2">
                <xsl:apply-templates mode="pass3"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$pass3">
            <xsl:apply-templates mode="pass4"/>
        </xsl:for-each>
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
    <!--copie 2 : tout contenu et balisage-->
    <xsl:template match="tei:*" mode="pass2">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="tei:*|processing-instruction()|comment()|text()"
                mode="pass2"/>
        </xsl:copy>
    </xsl:template>
    <!--copie 3 : tout contenu et balisage-->
    <xsl:template match="tei:*" mode="pass3">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="tei:*|processing-instruction()|comment()|text()"
                mode="pass3"/>
        </xsl:copy>
    </xsl:template>
    <!--copie 4 : tout contenu et balisage-->
    <xsl:template match="tei:*" mode="pass4">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="tei:*|processing-instruction()|comment()|text()"
                mode="pass4"/>
        </xsl:copy>
    </xsl:template>
    <!--1°) tokenisation : chaque mot mis dans une balise <w>, sauf si ce mot est contenu dans :
        - une balise ayant un @xml:lang, un @type="sig" 
        - ou bien dans un sic, corr ou orig (NB : les <reg> seront concernés dans le 2ème passage donc à supprimer avant passage de la feuille)-->
    <xsl:template match="tei:text//tei:*[not(self::tei:choice or self::tei:*[@xml:lang])]/tei:*[not(@xml:lang or @type='sig')]/text()">
<!--    <xsl:template match="tei:text//tei:*/text()">-->
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
   
   <!--NB : Pour les opérations suivantes, l'ordre des règles a son importance-->
   
    <!--2°) Détildage application de règle pour chaque w (ici dès qu'un règle est appliquée, 
        les autres ne le sont pas et plus de <w> mais du choice    -->

    <xsl:template match="tei:w" mode="pass2">
        <xsl:choose>
            <!--[DETILDAGE]-->
           <!--nécessiterait 3 passages des règles sans cette exception-->
<xsl:when test="matches(.,'^(\w*)cōmāderēt$')">
              <choice><orig><xsl:value-of select="."/></orig>
       <reg><xsl:value-of select="substring-before(.,'cōmāderēt')"/>commanderent</reg></choice>
           </xsl:when>
           <!--nécessiterait 3 passages des règles sans cette exception-->
<xsl:when test="matches(.,'^(\w*)cōmēcemēt(\w*)$')">
              <choice><orig><xsl:value-of select="."/></orig>
       <reg><xsl:value-of select="substring-before(.,'cōmēcemēt')"/>commencement<xsl:value-of select="substring-after(.,'cōmēcemēt')"/></reg></choice>
           </xsl:when>
           <!--nécessiterait 3 passages des règles sans cette exception-->
<xsl:when test="matches(.,'^(\w*)cōseruatiō(\w*)$')">
              <choice><orig><xsl:value-of select="."/></orig>
       <reg><xsl:value-of select="substring-before(.,'cōseruatiō')"/>conservation<xsl:value-of select="substring-after(.,'cōseruatiō')"/></reg></choice>
           </xsl:when>    
           <!--nécessiterait 3 passages des règles sans cette exception-->
<xsl:when test="matches(.,'^(\w*)cōdānerēt(\w*)$')">
              <choice><orig><xsl:value-of select="."/></orig>
       <reg><xsl:value-of select="substring-before(.,'cōdānerēt')"/>condamnerent<xsl:value-of select="substring-after(.,'cōdānerēt')"/></reg></choice>
           </xsl:when>              
<xsl:when test="matches(.,'^(\w*)ām(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ām')"/>amm<xsl:value-of select="substring-after(.,'ām')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)āb(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'āb')"/>amb<xsl:value-of select="substring-after(.,'āb')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)āp(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'āp')"/>amp<xsl:value-of select="substring-after(.,'āp')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)dān(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ān')"/>amn<xsl:value-of select="substring-after(.,'ān')"/></reg>
  </choice>         
           </xsl:when>
<xsl:when test="matches(.,'^(\w*)ān(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ān')"/>ann<xsl:value-of select="substring-after(.,'ān')"/></reg></choice>
            </xsl:when>
            <xsl:when test="matches(.,'^(\w*)ā[^(a|e|i|o|u|é|è|y)](\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ā')"/>an<xsl:value-of select="substring-after(.,'ā')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ā$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ā')"/>an</reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ēm(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ēm')"/>emm<xsl:value-of select="substring-after(.,'ēm')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ēb(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ēb')"/>emb<xsl:value-of select="substring-after(.,'ēb')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ēp(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ēp')"/>emp<xsl:value-of select="substring-after(.,'ēp')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ēn(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ēn')"/>enn<xsl:value-of select="substring-after(.,'ēn')"/></reg></choice>
            </xsl:when>
            <xsl:when test="matches(.,'^(\w*)ē[^(a|e|i|o|é|è|y)](\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ē')"/>en<xsl:value-of select="substring-after(.,'ē')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ē$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ē')"/>en</reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)īm(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'īm')"/>imm<xsl:value-of select="substring-after(.,'īm')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)īb(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'īb')"/>imb<xsl:value-of select="substring-after(.,'īb')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)īp(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'īp')"/>imp<xsl:value-of select="substring-after(.,'īp')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)īn(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'īn')"/>inn<xsl:value-of select="substring-after(.,'īn')"/></reg></choice>
            </xsl:when>
            <xsl:when test="matches(.,'^(\w*)ī[^(a|e|i|o|u|é|è|y)](\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ī')"/>in<xsl:value-of select="substring-after(.,'ī')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ī$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ī')"/>in</reg></choice>
            </xsl:when>              
<xsl:when test="matches(.,'^(\w*)ōm(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ōm')"/>omm<xsl:value-of select="substring-after(.,'ōm')"/></reg></choice>
            </xsl:when>      
<xsl:when test="matches(.,'^(\w*)ōb(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ōb')"/>omb<xsl:value-of select="substring-after(.,'ōb')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ōp(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ōp')"/>omp<xsl:value-of select="substring-after(.,'ōp')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ōn(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ōn')"/>onn<xsl:value-of select="substring-after(.,'ōn')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ō[^(é|è)](\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ō')"/>on<xsl:value-of select="substring-after(.,'ō')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ō$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ō')"/>on</reg></choice>
            </xsl:when>            
<xsl:when test="matches(.,'^(\w*)ūm(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ūm')"/>umm<xsl:value-of select="substring-after(.,'ūm')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ūb(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ūb')"/>umb<xsl:value-of select="substring-after(.,'ūb')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ūp(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ūp')"/>ump<xsl:value-of select="substring-after(.,'ūp')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ūn(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ūn')"/>umn<xsl:value-of select="substring-after(.,'ūn')"/></reg></choice>
            </xsl:when>
            <xsl:when test="matches(.,'^(\w*)ū[^(a|e|i|o|é|è|y)](\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ū')"/>un<xsl:value-of select="substring-after(.,'ū')"/></reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ū$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg><xsl:value-of select="substring-before(.,'ū')"/>un</reg></choice>
            </xsl:when>
            <!--pour les mots n'étant concerné par aucune régle, on copie la même chose sans <w>-->
            <xsl:otherwise>
                <w><xsl:value-of select="."/></w>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--    3°)Dissimilation application de règle pour chaque w (ici dès qu'un règle est appliquée, 
        les autres ne le sont pas et plus de <w> mais du choice-->
    
 
    <xsl:template match="tei:w" mode="pass3">
        <xsl:choose>
            



<!--[DISSIMILATION]-->
<xsl:when test="matches(.,'^i$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^i$')"><reg>j</reg></xsl:if>
   <xsl:if test="matches(.,'^I$')"><reg>J</reg></xsl:if></choice>
            </xsl:when>

<!--A-->
<xsl:when test="matches(.,'^Aiax$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg>Ajax</reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)aio(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)aio(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ai')"/>aj<xsl:value-of select="substring-after(.,'ai')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Aio(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Ai')"/>Aj<xsl:value-of select="substring-after(.,'Ai')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AIO(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AI')"/>AJ<xsl:value-of select="substring-after(.,'AI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^ajan(ts?|s)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(a|A)jan(ts?|s)$')">
      <reg><xsl:value-of select="substring-before(.,'jan')"/>ian<xsl:value-of select="substring-after(.,'jan')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^AJAN(TS?|s)$')">
      <reg>AIAN<xsl:value-of select="substring-after(.,'AJAN')"/></reg></xsl:if></choice>
            </xsl:when>
<!--sauf e à cause de "eaue" et autres tests pour mots débutant par "aue"-->
<xsl:when test="matches(.,'^(\w*[^e])aue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*[^e])aue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aue')"/>ave<xsl:value-of select="substring-after(.,'aue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*[^E])AUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUE')"/>AVE<xsl:value-of select="substring-after(.,'AUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^Aue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^Aue(\w*)$')">
      <reg>Ave<xsl:value-of select="substring-after(.,'Aue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^aue(\w*)$')">
      <reg>ave<xsl:value-of select="substring-after(.,'aue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^AUE(\w*)$')">
      <reg>AVE<xsl:value-of select="substring-after(.,'AUE')"/></reg></xsl:if></choice>
            </xsl:when>                      
<xsl:when test="matches(.,'^av$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^av$')"><reg>au</reg></xsl:if>
   <xsl:if test="matches(.,'^AV$')"><reg>AU</reg></xsl:if>
   <xsl:if test="matches(.,'^Av$')"><reg>Au</reg></xsl:if></choice>
            </xsl:when>         
<xsl:when test="matches(.,'^auiour(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(a|A)uiour(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiour')"/>ujour<xsl:value-of select="substring-after(.,'uiour')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^AUIOUR(\w*)$')">
      <reg>AUJOUR<xsl:value-of select="substring-after(.,'AUIOUR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)aua(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)aua(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aua')"/>ava<xsl:value-of select="substring-after(.,'aua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AUA(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUA')"/>AVA<xsl:value-of select="substring-after(.,'AUA')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Aua(\w*)$')">
      <reg>Ava<xsl:value-of select="substring-after(.,'Aua')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)aué(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)aué(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aué')"/>avé<xsl:value-of select="substring-after(.,'aué')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AUÉ(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUÉ')"/>AVÉ<xsl:value-of select="substring-after(.,'AUÉ')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Aué(\w*)$')">
      <reg>Avé<xsl:value-of select="substring-after(.,'Aué')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)aui(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)aui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aui')"/>avi<xsl:value-of select="substring-after(.,'aui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AUA(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUI')"/>AVI<xsl:value-of select="substring-after(.,'AUI')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Aui(\w*)$')">
      <reg>Avi<xsl:value-of select="substring-after(.,'Aui')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)auo(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)auo(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'auo')"/>avo<xsl:value-of select="substring-after(.,'auo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AUO(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUO')"/>AVO<xsl:value-of select="substring-after(.,'AUO')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Auo(\w*)$')">
      <reg>Avo<xsl:value-of select="substring-after(.,'Auo')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^adu(a|e|i|o)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^adu(a|e|i|o)(\w*)$')">
      <reg>adv<xsl:value-of select="substring-after(.,'adu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ADU(A|E|I|O)(\w*)$')">
      <reg>ADV<xsl:value-of select="substring-after(.,'ADU')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Adu(a|e|i|o)(\w*)$')">
      <reg>Adv<xsl:value-of select="substring-after(.,'Adu')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^abi(e|u)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(a|A)bi(e|u)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'bi')"/>bj<xsl:value-of select="substring-after(.,'bi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ABI(E|U)(\w*)$')">
      <reg>ABJ<xsl:value-of select="substring-after(.,'ABI')"/></reg></xsl:if></choice>
            </xsl:when>
           <!--adio adiu adia--> 
<xsl:when test="matches(.,'^(co)?adio?(u|i?n|a)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(co|Co)?(a|A)dio?(u|i?n|a)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'di')"/>dj<xsl:value-of select="substring-after(.,'di')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(CO)?ADIO?(U|I?N|A)(\w*)$')">
      <reg>ADJ<xsl:value-of select="substring-after(.,'ADI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)avme(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)(a|A)vme(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vme')"/>ume<xsl:value-of select="substring-after(.,'vme')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)AVME(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AVME')"/>AUME<xsl:value-of select="substring-after(.,'AVME')"/></reg></xsl:if></choice>
            </xsl:when>      
<xsl:when test="matches(.,'^avt(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(a|A)vt(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vt')"/>ut<xsl:value-of select="substring-after(.,'vt')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^AVT(\w*)$')">
      <reg>AUT<xsl:value-of select="substring-after(.,'VT')"/></reg></xsl:if></choice>
            </xsl:when>            

<!--B-->
           <!--bienuueil bienueil bienueuil-->
<xsl:when test="matches(.,'^bienuu?eu?il(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(b|B)ienuu?eu?il(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ienu')"/>ienv<xsl:value-of select="substring-after(.,'ienu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^BIENUU?EU?IL(\w*)$')">
      <reg>BIENV<xsl:value-of select="substring-after(.,'BIENU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^bouvrevil(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(b|B)ouvrevil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ouvrevil')"/>ouvreuil<xsl:value-of select="substring-after(.,'ouvrevil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^BOUVREVIL(\w*)$')">
      <reg>BOUVREUIL<xsl:value-of select="substring-after(.,'BOUVREVIL')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^brauerie(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(b|B)rauerie(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rauerie')"/>raverie<xsl:value-of select="substring-after(.,'rauerie')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^BRAUERIE(\w*)$')">
      <reg>BRAVERIE<xsl:value-of select="substring-after(.,'BRAUERIE')"/></reg></xsl:if></choice>
            </xsl:when>
            <xsl:when test="matches(.,'^brieue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(b|B)rieue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rieue')"/>rieve<xsl:value-of select="substring-after(.,'rieue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^BRIEUE(\w*)$')">
      <reg>BRIEVE<xsl:value-of select="substring-after(.,'BRIEUE')"/></reg></xsl:if></choice>
            </xsl:when>              

<!--C-->
<xsl:when test="matches(.,'^cerfevil(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(c|C)erfevil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'erfevil')"/>erfeuil<xsl:value-of select="substring-after(.,'erfevil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CERFEVIL(\w*)$')">
      <reg>CERFEUIL<xsl:value-of select="substring-after(.,'CERFEVIL')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)ceur(a|o)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
                   <xsl:if test="matches(.,'^(\w+)ceur(a|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ceur')"/>cevr<xsl:value-of select="substring-after(.,'ceur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)CEUR(A|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CEUR')"/>CEVR<xsl:value-of select="substring-after(.,'CEUR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^cheur(e|o)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
     <xsl:if test="matches(.,'^(c|C)heur(e|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'heur')"/>hevr<xsl:value-of select="substring-after(.,'heur')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^CHEUR(E|O)(\w*)$')">
      <reg>CHEVR<xsl:value-of select="substring-after(.,'CHEUR')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--  exception pour "meurier" -->
<xsl:when test="matches(.,'^(\w*[^(m|M)])eurier(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*[^(m|M)])eurier(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eurier')"/>evrier<xsl:value-of select="substring-after(.,'eurier')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*[^M])EURIER(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EURIER')"/>EVRIER<xsl:value-of select="substring-after(.,'EURIER')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^chevrevil(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(c|C)hevrevil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'hevrevil')"/>hevreuil<xsl:value-of select="substring-after(.,'hevrevil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CHEVREVIL(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CHEVREVIL')"/>CHEVREUIL<xsl:value-of select="substring-after(.,'CHEVREVIL')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^conceuro(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(c|C)onceuro(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'onceuro')"/>oncevro<xsl:value-of select="substring-after(.,'onceuro')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CONCEURO(\w*)$')">
      <reg>CONCEVRO<xsl:value-of select="substring-after(.,'CONCEURO')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)conve?s?$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(c|C)onve?s?$')">
      <reg><xsl:value-of select="substring-before(.,'onv')"/>onu<xsl:value-of select="substring-after(.,'onv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CONVE?S?$')">
      <reg><xsl:value-of select="substring-before(.,'CONVE')"/>CONUE<xsl:value-of select="substring-after(.,'CONVE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^conui(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(c|C)onui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'onui')"/>onvi<xsl:value-of select="substring-after(.,'onui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CONUI(\w*)$')">
      <reg>CONVI<xsl:value-of select="substring-after(.,'CONUI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)Calui(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)CALUI(\w*)$')">
      <reg>CALVI<xsl:value-of select="substring-after(.,'CALUI')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Calui(\w*)$')">
      <reg>Calvi<xsl:value-of select="substring-after(.,'Calui')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^coni(oi|ur)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(c|C)oni(oi|ur)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'oni')"/>onj<xsl:value-of select="substring-after(.,'oni')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CONI(OI|UR)(\w*)$')">
      <reg>CONJ<xsl:value-of select="substring-after(.,'CONI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)conu(e|é|o)(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(c|C)onu(e|é|o)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'onu')"/>onv<xsl:value-of select="substring-after(.,'onu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CONU(E|É|O)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'CONU')"/>CONV<xsl:value-of select="substring-after(.,'CONU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)cerue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(c|C)erue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'erue')"/>erve<xsl:value-of select="substring-after(.,'erue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CERUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CERUE')"/>CERVE<xsl:value-of select="substring-after(.,'CERUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(c|C)uiur(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(c|C)uiur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiur')"/>uivr<xsl:value-of select="substring-after(.,'uiur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CUIUR(\w*)$')">
      <reg>CUIVR<xsl:value-of select="substring-after(.,'CUIUR')"/></reg></xsl:if></choice>
            </xsl:when>         
<xsl:when test="matches(.,'^cevl?x$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(c|C)evl?x$')">
      <reg><xsl:value-of select="substring-before(.,'ev')"/>eu<xsl:value-of select="substring-after(.,'ev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CEVL?X$')">
      <reg>CEU<xsl:value-of select="substring-after(.,'CEV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)ceve$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)ceve$')">
      <reg><xsl:value-of select="substring-before(.,'ceve')"/>ceue</reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)CEVE$')">
      <reg><xsl:value-of select="substring-before(.,'CEVE')"/>CEUE</reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)continv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(c|C)ontinv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ontinv')"/>ontinu<xsl:value-of select="substring-after(.,'ontinv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CONTINV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CONTINV')"/>CONTINU<xsl:value-of select="substring-after(.,'CONTINV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)covrs(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(c|C)ovrs(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovrs')"/>ours<xsl:value-of select="substring-after(.,'ovrs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)COVRS(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'COVRS')"/>COURS<xsl:value-of select="substring-after(.,'COVRS')"/></reg></xsl:if></choice>
            </xsl:when>            
<xsl:when test="matches(.,'^(\w*)ctevr(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(c|C)tevr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'tevr')"/>teur<xsl:value-of select="substring-after(.,'tevr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CTEVR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CTEVR')"/>CTEUR<xsl:value-of select="substring-after(.,'CTEVR')"/></reg></xsl:if></choice>
            </xsl:when>
           <xsl:when test="matches(.,'^(\w*)cvlev(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
    <xsl:if test="matches(.,'^(\w*)(c|C)vlev(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'vlev')"/>uleu<xsl:value-of select="substring-after(.,'vlev')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)CVLEV(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'CVLEV')"/>CULEU<xsl:value-of select="substring-after(.,'CVLEV')"/></reg></xsl:if></choice>
           </xsl:when>     
           <xsl:when test="matches(.,'^creué(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
    <xsl:if test="matches(.,'^(c|C)reué(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'reué')"/>revé<xsl:value-of select="substring-after(.,'reué')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)CREUÉ(\w*)$')">
       <reg>CREVÉ<xsl:value-of select="substring-after(.,'CREUÉ')"/></reg></xsl:if></choice>
           </xsl:when>            
          
          
<!--D-->
            <!--deura deuro deuri-->
<xsl:when test="matches(.,'^deur(a|o|i)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(d|D)eur(a|o|i)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eur')"/>evr<xsl:value-of select="substring-after(.,'eur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DEUR(A|O|I)(\w*)$')">
      <reg>DEUR<xsl:value-of select="substring-after(.,'DEUR')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--déura déuro déuri (dans le 1er livre de Vitruve) -->
<xsl:when test="matches(.,'^déur(a|o|i)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(d|D)éur(a|o|i)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'éur')"/>évr<xsl:value-of select="substring-after(.,'éur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DÉUR(A|O|I)(\w*)$')">
      <reg>DÉUR<xsl:value-of select="substring-after(.,'DÉUR')"/></reg></xsl:if></choice>
            </xsl:when>            
<xsl:when test="matches(.,'^(d|v|s)evil(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(d|D|v|V|s|S)evil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'evil')"/>euil<xsl:value-of select="substring-after(.,'evil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(D|V|S)EVIL(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EVIL')"/>EUIL<xsl:value-of select="substring-after(.,'EVIL')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--desia desià-->
<xsl:when test="matches(.,'^desi(a|à)$')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(d|D)esi(a|à)$')">
      <reg><xsl:value-of select="substring-before(.,'esi')"/>esj<xsl:value-of select="substring-after(.,'esi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DESI(A|À)$')">
      <reg><xsl:value-of select="substring-before(.,'ESI')"/>ESJ<xsl:value-of select="substring-after(.,'ESI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^des?liur(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(d|D)es?liur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'liur')"/>livr<xsl:value-of select="substring-after(.,'liur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DES?LIUR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'LIUR')"/>LIVR<xsl:value-of select="substring-after(.,'LIUR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^desu(i|o)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(d|D)esu(i|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'esu')"/>esv<xsl:value-of select="substring-after(.,'esu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DESU(I|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'DESU')"/>DESV<xsl:value-of select="substring-after(.,'DESU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^diev(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(d|D)iev(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'iev')"/>ieu<xsl:value-of select="substring-after(.,'iev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DIEV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'DIEV')"/>DIEU<xsl:value-of select="substring-after(.,'DIEV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)douic(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)douic(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'douic')"/>dovic<xsl:value-of select="substring-after(.,'douic')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)DOUIC(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'DOUIC')"/>DOVIC<xsl:value-of select="substring-after(.,'LIUR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^dv$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(d|D)v$')">
      <reg><xsl:value-of select="substring-before(.,'v')"/>u</reg></xsl:if>
   <xsl:if test="matches(.,'^DV$')">
      <reg>DU</reg></xsl:if></choice>
            </xsl:when>
            <!--lvc dvc-->
<xsl:when test="matches(.,'^(\w*)(d|l)vc(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(d|D|l|L)vc(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vc')"/>uc<xsl:value-of select="substring-after(.,'vc')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(D|L)VC(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VC')"/>UC<xsl:value-of select="substring-after(.,'VC')"/></reg></xsl:if></choice>
            </xsl:when>

<!--E-->
                <!--ebuo ebur-->
<xsl:when test="matches(.,'^(\w+)ebu(o|r)(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)ebu(o|r)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'ebu')"/>ebv<xsl:value-of select="substring-after(.,'ebu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)EBU(O|R)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'EBU')"/>EBV<xsl:value-of select="substring-after(.,'EBU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)edvi(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)edvi(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'edvi')"/>edui<xsl:value-of select="substring-after(.,'edvi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EDVI(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EDVI')"/>EDUI<xsl:value-of select="substring-after(.,'EDVI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ei(et|o)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)ei(et|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ei')"/>ej<xsl:value-of select="substring-after(.,'ei')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EI(ET|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EI')"/>EJ<xsl:value-of select="substring-after(.,'EI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)es?ua(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E)s?ua(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ua')"/>va<xsl:value-of select="substring-after(.,'ua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ES?UA(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UA')"/>VA<xsl:value-of select="substring-after(.,'UA')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)eru(a|e|é|o|i|y)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)eru(a|e|é|o|i|y)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eru')"/>erv<xsl:value-of select="substring-after(.,'eru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)ERU(A|E|É|O|I|Y)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ERU')"/>ERV<xsl:value-of select="substring-after(.,'ERU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^eue$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^Eue$')"><reg>Eve</reg></xsl:if>
   <xsl:if test="matches(.,'^EUE$')"><reg>EVE</reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)epu(o|e|a)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)epu(o|e|a)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'epu')"/>epv<xsl:value-of select="substring-after(.,'epu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)EPU(O|E|A)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EPU')"/>EPV<xsl:value-of select="substring-after(.,'EPU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)ipu(o|e|a)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)ipu(o|e|a)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ipu')"/>ipv<xsl:value-of select="substring-after(.,'ipu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)IPU(O|E|A)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'IPU')"/>IPV<xsl:value-of select="substring-after(.,'IPU')"/></reg></xsl:if></choice>
            </xsl:when>   
           <!--reuiu reuiue-->
<xsl:when test="matches(.,'^reuiu(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
    <xsl:if test="matches(.,'^(r|R)euiu(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'euiu')"/>eviv<xsl:value-of select="substring-after(.,'euiu')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^REUIU(\w*)$')">
       <reg>REVIV<xsl:value-of select="substring-after(.,'REUIU')"/></reg></xsl:if></choice>
           </xsl:when>       
<xsl:when test="matches(.,'^(\w*)eui[^l](\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E)ui[^l](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ui')"/>vi<xsl:value-of select="substring-after(.,'ui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EUI[^L](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EUI')"/>EVI<xsl:value-of select="substring-after(.,'EUI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^preuil(\w*)$')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(p|P)reuil(\w*)$')">
      <reg>previl<xsl:value-of select="substring-after(.,'preuil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PREUIL(\w*)$')">
      <reg>PREVIL<xsl:value-of select="substring-after(.,'PREUIL')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^eue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(e|E)ue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ue')"/>ve<xsl:value-of select="substring-after(.,'ue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^EUE(\w*)$')">
      <reg>EVE<xsl:value-of select="substring-after(.,'EUE')"/></reg></xsl:if></choice>
            </xsl:when>
           <!--eueu lueu-->
<xsl:when test="matches(.,'^(\w+)(e|l)ueu(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)(e|E|l|L)ueu(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'ueu')"/>veu<xsl:value-of select="substring-after(.,'ueu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)(E|L)UEU(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'UEU')"/>VEU<xsl:value-of select="substring-after(.,'UEU')"/></reg></xsl:if></choice>
           </xsl:when>
<xsl:when test="matches(.,'^(\w*)[^d]euem(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)[^d|D]uem(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uem')"/>vem<xsl:value-of select="substring-after(.,'uem')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)[^D]UEM(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UEM')"/>VEM<xsl:value-of select="substring-after(.,'UEM')"/></reg></xsl:if></choice>
           </xsl:when>
           <!--acheue acheué soubleué, pas descheue -->
<xsl:when test="matches(.,'^(\w*)(ach|bl)eu(e|é)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
                 <xsl:if test="matches(.,'^(\w*)((A|a)ch|bl)eu(e|é)$')">
                    <reg><xsl:value-of select="substring-before(.,'eu')"/>ev<xsl:value-of select="substring-after(.,'eu')"/></reg></xsl:if>
                 <xsl:if test="matches(.,'^(\w*)(ACH|BL)EU(E|É)$')">
                    <reg><xsl:value-of select="substring-before(.,'EU')"/>EV<xsl:value-of select="substring-after(.,'EU')"/></reg></xsl:if></choice>
           </xsl:when>
            <!--ésuo éuo esuo euo-->
<xsl:when test="matches(.,'^(\w*)(e|é)s?uo(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E|é|É)s?uo(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uo')"/>vo<xsl:value-of select="substring-after(.,'uo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(E|É)S?UO(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UO')"/>VO<xsl:value-of select="substring-after(.,'UO')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^enuers$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(e|E)nuers$')">
      <reg><xsl:value-of select="substring-before(.,'nuers')"/>nvers<xsl:value-of select="substring-after(.,'nuers')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ENUERS$')">
      <reg>ENVERS</reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)eniam(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E)niam(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'niam')"/>njam<xsl:value-of select="substring-after(.,'niam')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ENIAM(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ENIAM')"/>ENJAM<xsl:value-of select="substring-after(.,'ENIAM')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)(e|r)uiur(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)(e|r)uiur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiur')"/>vivr<xsl:value-of select="substring-after(.,'uiur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)(E|R)UIUR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UIUR')"/>VIVR<xsl:value-of select="substring-after(.,'UIUR')"/></reg></xsl:if></choice>
            </xsl:when>
           <!--renu alenu bienu-->
<xsl:when test="matches(.,'^(r|al|bi)?enu(ie|ir|y|o|e)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(Al|al|R|r|bi|Bi)?(e|E)nu(ie|ir|y|o|e)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nu')"/>nv<xsl:value-of select="substring-after(.,'nu')"/></reg></xsl:if>
  <xsl:if test="matches(.,'^(R|AL|BI)?ENU(IE|IR|Y|O|E)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ENU')"/>ENV<xsl:value-of select="substring-after(.,'ENU')"/></reg></xsl:if></choice>
            </xsl:when>
            <xsl:when test="matches(.,'^(co|e)nioi(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(e|E|co|Co)nioi(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nioi')"/>njoi<xsl:value-of select="substring-after(.,'nioi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(E|CO)NIOI(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'NIOI')"/>NJOI<xsl:value-of select="substring-after(.,'NIOI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^enuelo(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E)nuelo(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nuelo')"/>nvelo<xsl:value-of select="substring-after(.,'nuelo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ENUEL(\w*)$')">
      <reg>ENVEL<xsl:value-of select="substring-after(.,'ENUEL')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)euei(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E)uei(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uei')"/>vei<xsl:value-of select="substring-after(.,'uei')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EUEI(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EUEI')"/>EVEI<xsl:value-of select="substring-after(.,'EUEI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)eue(e|l|n|r|z|st|t)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E)ue(e|l|n|r|z|st|t)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ue')"/>ve<xsl:value-of select="substring-after(.,'ue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EUE(E|L|N|R|Z|ST|T)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EUE')"/>EVE<xsl:value-of select="substring-after(.,'EUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)esue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E)sue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'sue')"/>sve<xsl:value-of select="substring-after(.,'sue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ESUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ESUE')"/>ESVE<xsl:value-of select="substring-after(.,'ESUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)euesq(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(e|E)uesq(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uesq')"/>vesq<xsl:value-of select="substring-after(.,'uesq')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EUESQ(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EUESQ')"/>EVESQ<xsl:value-of select="substring-after(.,'EUESQ')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--pour evnvque => eunuque-->
<xsl:when test="matches(.,'^evnv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(e|E)vnv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vnv')"/>unu<xsl:value-of select="substring-after(.,'vnv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^EVNV(\w*)$')">
      <reg>EUNU<xsl:value-of select="substring-after(.,'EVNV')"/></reg></xsl:if></choice>
            </xsl:when>

<!--F-->
<xsl:when test="matches(.,'^fautevil(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(f|F)autevil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'autevil')"/>auteuil<xsl:value-of select="substring-after(.,'autevil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FAUTEVIL(\w*)$')">
      <reg>FAUTEUIL<xsl:value-of select="substring-after(.,'FAUTEVIL')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^fev$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(f|F)ev$')">
      <reg><xsl:value-of select="substring-before(.,'ev')"/>eu<xsl:value-of select="substring-after(.,'ev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FEV$')">
      <reg>FEU</reg></xsl:if></choice>
            </xsl:when>            
<xsl:when test="matches(.,'^feville(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(f|F)eville(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eville')"/>euille<xsl:value-of select="substring-after(.,'eville')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FEVILLE(\w*)$')">
      <reg>FEUILLE<xsl:value-of select="substring-after(.,'FEVILLE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^fi(e|é)ure(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(f|F)i(e|é)ure(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ure')"/>vre<xsl:value-of select="substring-after(.,'ure')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FI(E|É)URE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'URE')"/>VRE<xsl:value-of select="substring-after(.,'URE')"/></reg></xsl:if></choice>
            </xsl:when>
            <xsl:when test="matches(.,'^flevr(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(f|F)levr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'levr')"/>leur<xsl:value-of select="substring-after(.,'levr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FLEVR(\w*)$')">
      <reg>FLEUR<xsl:value-of select="substring-after(.,'FLEVR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^foruo(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(f|F)oruo(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'oruo')"/>orvo<xsl:value-of select="substring-after(.,'oruo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FORUO(\w+)$')">
      <reg>FORVO<xsl:value-of select="substring-after(.,'FORUO')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^fvt$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(f|F)vt$')">
      <reg><xsl:value-of select="substring-before(.,'vt')"/>ut</reg></xsl:if>
   <xsl:if test="matches(.,'^FVT$')">
      <reg>FUT</reg></xsl:if></choice>
            </xsl:when>

<!--G-->
<xsl:when test="matches(.,'^(\w*)graue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(g|G)raue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'raue')"/>rave<xsl:value-of select="substring-after(.,'raue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)GRAUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'GRAUE')"/>GRAVE<xsl:value-of select="substring-after(.,'GRAUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)gnevr(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)gnevr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'gnevr')"/>gneur<xsl:value-of select="substring-after(.,'gnevr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)GNEVR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'GNEVR')"/>GNEUR<xsl:value-of select="substring-after(.,'GNEVR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)gv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)gv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'gv')"/>gu<xsl:value-of select="substring-after(.,'gv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Gv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Gv')"/>Gu<xsl:value-of select="substring-after(.,'Gv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)GV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'GV')"/>GU<xsl:value-of select="substring-after(.,'GV')"/></reg></xsl:if></choice>
            </xsl:when>

<!--H-->

<xsl:when test="matches(.,'^hvm(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(h|H)vm(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vm')"/>um<xsl:value-of select="substring-after(.,'vm')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)HVM(\w*)$')">
      <reg>HUM<xsl:value-of select="substring-after(.,'HVM')"/></reg></xsl:if></choice>
            </xsl:when>

<!--I-->

<!--I qui devient J debut de mot-->
<!-- i devenant j-->
<xsl:when test="matches(.,'^ie$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg>je</reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^IE$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg>JE</reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^Ie$')">
                <choice><orig><xsl:value-of select="."/></orig>
      <reg>Je</reg></choice>
            </xsl:when>
<xsl:when test="matches(.,'^ia(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ia(\w*)$')">
      <reg>ja<xsl:value-of select="substring-after(.,'ia')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Ia(\w*)$')">
      <reg>Ja<xsl:value-of select="substring-after(.,'Ia')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)IA(\w*)$')">
      <reg>JA<xsl:value-of select="substring-after(.,'IA')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^iehan(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^iehan(\w*)$')">
      <reg>jehan<xsl:value-of select="substring-after(.,'iehan')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iehan(\w*)$')">
      <reg>Jehan<xsl:value-of select="substring-after(.,'Iehan')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IEHAN(\w*)$')">
      <reg>JEHAN<xsl:value-of select="substring-after(.,'IEHAN')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^iesu(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^iesu(\w*)$')">
      <reg>jesu<xsl:value-of select="substring-after(.,'iesu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iesu(\w*)$')">
      <reg>Jesu<xsl:value-of select="substring-after(.,'Iesu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IESU(\w*)$')">
      <reg>JESU<xsl:value-of select="substring-after(.,'IESU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^iett(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^iett(\w*)$')">
      <reg>jett<xsl:value-of select="substring-after(.,'iett')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iett(\w*)$')">
      <reg>Jett<xsl:value-of select="substring-after(.,'Iett')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IETT(\w*)$')">
      <reg>JETT<xsl:value-of select="substring-after(.,'IETT')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ieun(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)ieun(\w*)$')">
      <reg>jeun<xsl:value-of select="substring-after(.,'ieun')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Ieun(\w*)$')">
      <reg>Jeun<xsl:value-of select="substring-after(.,'Ieun')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)IEUN(\w*)$')">
      <reg>JEUN<xsl:value-of select="substring-after(.,'IEUN')"/></reg></xsl:if></choice>
            </xsl:when>  
<xsl:when test="matches(.,'^ieux?$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ieux?$')">
      <reg>jeu<xsl:value-of select="substring-after(.,'ieu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ieux?$')">
      <reg>Jeu<xsl:value-of select="substring-after(.,'Ieu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IEUX?$')">
      <reg>JEU<xsl:value-of select="substring-after(.,'IEU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^ievx?$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ievx?$')">
      <reg>jeu<xsl:value-of select="substring-after(.,'iev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ievx?$')">
      <reg>Jeu<xsl:value-of select="substring-after(.,'Iev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IEVX?$')">
      <reg>JEU<xsl:value-of select="substring-after(.,'IEV')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--iouial jouial-->
<xsl:when test="matches(.,'^(i|j)ouial(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(i|j)ouial(\w*)$')">
      <reg>jovial<xsl:value-of select="substring-after(.,'ouial')"/></reg></xsl:if> 
   <xsl:if test="matches(.,'^(I|J)ouial(\w*)$')">
      <reg>Jovial<xsl:value-of select="substring-after(.,'ouial')"/></reg></xsl:if>    
   <xsl:if test="matches(.,'^(I|J)OUIAL(\w*)$')">
      <reg>JOVIAL<xsl:value-of select="substring-after(.,'IOUIAL')"/></reg></xsl:if></choice>
            </xsl:when>            
<xsl:when test="matches(.,'^io[^n](\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^io[^n](\w*)$')">
      <reg>jo<xsl:value-of select="substring-after(.,'io')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Io[^n](\w*)$')">
      <reg>Jo<xsl:value-of select="substring-after(.,'Io')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IO[^N](\w*)$')">
      <reg>JO<xsl:value-of select="substring-after(.,'IO')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--ionc ionche iong-->
<xsl:when test="matches(.,'^ion(c|g)(\w*)$', 'i')">
          <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ion(c|g)(\w*)$')">
      <reg>jon<xsl:value-of select="substring-after(.,'ion')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ion(c|g)(\w*)$')">
      <reg>Jon<xsl:value-of select="substring-after(.,'Ion')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ION(C|G)(\w*)$')">
      <reg>JON<xsl:value-of select="substring-after(.,'ION')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^iurog(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^iurog(\w*)$')">
      <reg>ivrog<xsl:value-of select="substring-after(.,'iurog')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iurog(\w*)$')">
      <reg>Ivrog<xsl:value-of select="substring-after(.,'Iurog')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IUROG(\w*)$')">
      <reg>IVROG<xsl:value-of select="substring-after(.,'IUROG')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^iu(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^iu(\w*)$')">
      <reg>ju<xsl:value-of select="substring-after(.,'iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iu(\w*)$')">
      <reg>Ju<xsl:value-of select="substring-after(.,'Iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IU(\w*)$')">
      <reg>JU<xsl:value-of select="substring-after(.,'IU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^innoü(\w*)$')">
              <choice><orig><xsl:value-of select="."/></orig>
     <reg>innov<xsl:value-of select="substring-after(.,'innoü')"/></reg></choice>
           </xsl:when>               
<xsl:when test="matches(.,'^uifue(\w+)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
  <xsl:if test="matches(.,'^uifue(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'uifue')"/>vifve<xsl:value-of select="substring-after(.,'uifue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Uifue(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'Uifue')"/>Vifve<xsl:value-of select="substring-after(.,'Uifue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UIFUE(\w+)$')">
      <reg>VIFVE<xsl:value-of select="substring-after(.,'UIUFE')"/></reg></xsl:if></choice>
           </xsl:when>         
<xsl:when test="matches(.,'^uiur(\w+)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^uiur(\w+)$')">
     <reg><xsl:value-of select="substring-before(.,'uiur')"/>vivr<xsl:value-of select="substring-after(.,'uiur')"/></reg></xsl:if>
  <xsl:if test="matches(.,'^Uiur(\w+)$')">
     <reg><xsl:value-of select="substring-before(.,'Uiur')"/>Vivr<xsl:value-of select="substring-after(.,'Uiur')"/></reg></xsl:if>                 
<xsl:if test="matches(.,'^UIUR(\w+)$')">
     <reg>VIVR<xsl:value-of select="substring-after(.,'UIUR')"/></reg></xsl:if></choice>
           </xsl:when> 
           <!--efue iefue iufue eufue  -->
<xsl:when test="matches(.,'^(\w+)(i|ï|e)u?fue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)(i|ï|e)u?fue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'fue')"/>fve<xsl:value-of select="substring-after(.,'fue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)(I|Ï|E)U?FUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'FUE')"/>FVE<xsl:value-of select="substring-after(.,'FUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^inconu(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(i|I)nconu(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'nconu')"/>nconv<xsl:value-of select="substring-after(.,'nconu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^INCONU(\w+)$')">
      <reg>INCONV<xsl:value-of select="substring-after(.,'INCONU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^iniu(r|s)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(i|I)niu(r|s)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'niu')"/>nju<xsl:value-of select="substring-after(.,'niu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^INIUR(R|S)(\w*)$')">
      <reg>INJU<xsl:value-of select="substring-after(.,'INIU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^iniv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(i|I)niv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'niv')"/>nju<xsl:value-of select="substring-after(.,'niv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^INIV(\w*)$')">
      <reg>INJUR<xsl:value-of select="substring-after(.,'INIV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^iu(r|s)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^iu(r|s)(\w*)$')">
      <reg>ju<xsl:value-of select="substring-after(.,'iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iu(r|s)(\w*)$')">
      <reg>Ju<xsl:value-of select="substring-after(.,'Iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IU(R|S)(\w*)$')">
      <reg>JU<xsl:value-of select="substring-after(.,'IU')"/></reg></xsl:if></choice>
            </xsl:when>
           <!--iuue cuue estuu-->
<xsl:when test="matches(.,'^(i|c|est)uue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(i|I|c|C|est|Est)uue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uue')"/>uve<xsl:value-of select="substring-after(.,'uue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(I|C|Est)UUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UUE')"/>UVE<xsl:value-of select="substring-after(.,'UUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(tres)?inui(s|t|n|o)(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(tres|Tres)?(i|I)nui(s|t|n|o)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'nui')"/>nvi<xsl:value-of select="substring-after(.,'nui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(TRES)?INUI(S|T|N|O)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'INUI')"/>INVI<xsl:value-of select="substring-after(.,'INUI')"/></reg></xsl:if></choice>
            </xsl:when>            
<xsl:when test="matches(.,'^(\w*)inv(s|t)i(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(i|I)nv(s|t)i(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nv')"/>nu<xsl:value-of select="substring-after(.,'nv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)INV(S|T)I(\w+)$')">
      <reg>INU<xsl:value-of select="substring-after(.,'INV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)iect(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)iect(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'iect')"/>ject<xsl:value-of select="substring-after(.,'iect')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iect(\w*)$')">
      <reg>Ject<xsl:value-of select="substring-after(.,'Iect')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)IECT(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'IECT')"/>JECT<xsl:value-of select="substring-after(.,'IECT')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^ieusn(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ieusn(\w*)$')">
      <reg>jeusn<xsl:value-of select="substring-after(.,'ieusn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ieusn(\w*)$')">
      <reg>Jeusn<xsl:value-of select="substring-after(.,'Ieusn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)IEUSN(\w*)$')">
      <reg>JEUSN<xsl:value-of select="substring-after(.,'IEUSN')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^inue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(i|I)nue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nue')"/>nve<xsl:value-of select="substring-after(.,'nue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^INUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NUE')"/>NVE<xsl:value-of select="substring-after(.,'NUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^ivnon?$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ivnon?$')">
      <reg>juno<xsl:value-of select="substring-after(.,'ivno')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ivnon?$')">
      <reg>Juno<xsl:value-of select="substring-after(.,'Ivno')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IVNON?$')">
      <reg>JUNO<xsl:value-of select="substring-after(.,'IVNO')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)iu(e|i|o|a|é|y|ÿ)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)iu(e|i|o|a|é|y|ÿ)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'iu')"/>iv<xsl:value-of select="substring-after(.,'iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)IU(E|I|O|A|É|Y|Ÿ)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'IU')"/>IV<xsl:value-of select="substring-after(.,'IU')"/></reg></xsl:if></choice>
            </xsl:when>

<!--J-->
<xsl:when test="matches(.,'^janui(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(j|J)anui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'anui')"/>anvi<xsl:value-of select="substring-after(.,'anui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^JANUI(\w*)$')">
      <reg>JANVI<xsl:value-of select="substring-after(.,'JANUI')"/></reg></xsl:if></choice>
            </xsl:when>

<!--L-->
<xsl:when test="matches(.,'^(\w*)[^b]leu(e|è|é|rau)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)[^b]leu(e|è|é|rau)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'leu')"/>lev<xsl:value-of select="substring-after(.,'leu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)[^b]LEU(E|È|É|RAU)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'LEU')"/>LEV<xsl:value-of select="substring-after(.,'LEU')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--leue leuè leué leurau-->
<xsl:when test="matches(.,'^leu(e|è|é|rau)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^leu(e|è|é|rau)(\w*)$')">
      <reg>lev<xsl:value-of select="substring-after(.,'leu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Leu(e|è|é|rau)(\w*)$')">
      <reg>Lev<xsl:value-of select="substring-after(.,'Leu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^LEU(E|È|É|RAU)(\w*)$')">
      <reg>LEV<xsl:value-of select="substring-after(.,'LEU')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--liéue liéuè liéué liéurau-->
<xsl:when test="matches(.,'^liéu(e|è|é|rau)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^liéu(e|è|é|rau)(\w*)$')">
      <reg>liév<xsl:value-of select="substring-after(.,'liéu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Liéu(e|è|é|rau)(\w*)$')">
      <reg>Liév<xsl:value-of select="substring-after(.,'Liéu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^LIÉU(E|È|É|RAU)(\w*)$')">
      <reg>LIÉV<xsl:value-of select="substring-after(.,'LIÉU')"/></reg></xsl:if></choice>
            </xsl:when>   
            <!--lieure lieuè lieué lieurau-->
<xsl:when test="matches(.,'^lieu(re|è|é|rau)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
                    <xsl:if test="matches(.,'^lieu(re|è|é|rau)(\w*)$')">
                        <reg>liev<xsl:value-of select="substring-after(.,'lieu')"/></reg></xsl:if>
                    <xsl:if test="matches(.,'^Lieu(re|è|é|rau)(\w*)$')">
                        <reg>Liev<xsl:value-of select="substring-after(.,'Lieu')"/></reg></xsl:if>
                    <xsl:if test="matches(.,'^LIEU(RE|È|É|RAU)(\w*)$')">
                        <reg>LIEV<xsl:value-of select="substring-after(.,'LIEU')"/></reg></xsl:if></choice>
            </xsl:when> 
            <!--leure lèure-->
<xsl:when test="matches(.,'^l(e|è)ure(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(l|L)(e|è)ure(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ure')"/>vre<xsl:value-of select="substring-after(.,'ure')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^L(È|E)URE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'URE')"/>VRE<xsl:value-of select="substring-after(.,'URE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^levrs?$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(l|L)evrs?$')">
      <reg><xsl:value-of select="substring-before(.,'evr')"/>eur<xsl:value-of select="substring-after(.,'evr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^LEVRS?$')">
      <reg>LEUR<xsl:value-of select="substring-after(.,'LEVR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)liur(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(l|L)iur(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'iur')"/>ivr<xsl:value-of select="substring-after(.,'iur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)LIUR(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'LIUR')"/>LIVR<xsl:value-of select="substring-after(.,'LIUR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^oliu(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(o|O)liu(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'liu')"/>liv<xsl:value-of select="substring-after(.,'liu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^OLIU(\w+)$')">
      <reg>OLIV<xsl:value-of select="substring-after(.,'OLIU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^oual(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
                    <xsl:if test="matches(.,'^oual(\w*)$')">
                        <reg>oval<xsl:value-of select="substring-after(.,'oual')"/></reg></xsl:if>
                    <xsl:if test="matches(.,'^OUAL(\w*)$')">
                        <reg>OVAL<xsl:value-of select="substring-after(.,'OUAL')"/></reg></xsl:if></choice>
            </xsl:when>            
<xsl:when test="matches(.,'^(l|pr)ova(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(l|L|pr|PR)ova(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ova')"/>oua<xsl:value-of select="substring-after(.,'ova')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(L|PR)OVA(\w*)$')">
      <reg>LOUA<xsl:value-of select="substring-after(.,'LOVA')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)lvs(\w*)$', 'i')">
                 <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)lvs(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'lvs')"/>lus<xsl:value-of select="substring-after(.,'lvs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)LVS(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'LVS')"/>LUS<xsl:value-of select="substring-after(.,'LVS')"/></reg></xsl:if></choice>
            </xsl:when>
            
<!--M-->
<xsl:when test="matches(.,'^maie(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(m|M)aie(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aie')"/>aje<xsl:value-of select="substring-after(.,'aie')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^MAIE(\w*)$')">
      <reg>MAJE<xsl:value-of select="substring-after(.,'MAIE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)minv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(m|M)inv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'inv')"/>inu<xsl:value-of select="substring-after(.,'inv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)MINV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MINV')"/>MINU<xsl:value-of select="substring-after(.,'MINV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)meruei(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(m|M)eruei(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eruei')"/>ervei<xsl:value-of select="substring-after(.,'eruei')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)MERUEI(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MERUEI')"/>MERVEI<xsl:value-of select="substring-after(.,'MERUEI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)mvn(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(m|M)vn(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vn')"/>un<xsl:value-of select="substring-after(.,'vn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)MVN(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MVN')"/>MUN<xsl:value-of select="substring-after(.,'MVN')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)mvr(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(m|M)vr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vr')"/>ur<xsl:value-of select="substring-after(.,'vr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)MVR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MVR')"/>MUR<xsl:value-of select="substring-after(.,'MVR')"/></reg></xsl:if></choice>
            </xsl:when>            

<!--N-->
<xsl:when test="matches(.,'^naur(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(n|N)aur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aur')"/>avr<xsl:value-of select="substring-after(.,'aur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^NAUR(\w*)$')">
      <reg>NAVR<xsl:value-of select="substring-after(.,'NAUR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)nevf(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(n|N)evf(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'evf')"/>euf<xsl:value-of select="substring-after(.,'evf')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)NEVF(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NEVF')"/>NEUF<xsl:value-of select="substring-after(.,'NEVF')"/></reg></xsl:if></choice>
            </xsl:when>          
<xsl:when test="matches(.,'^nouic(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(n|N)ouic(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ouic')"/>ovic<xsl:value-of select="substring-after(.,'ouic')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^NOUIC(\w*)$')">
      <reg>NOVIC<xsl:value-of select="substring-after(.,'NOUIC')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)[^e]nvel(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)[^e]nvel(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nvel')"/>nuel<xsl:value-of select="substring-after(.,'nvel')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)[^E]NVEL(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NVEL')"/>NUEL<xsl:value-of select="substring-after(.,'NVEL')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^nepueu(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(n|N)epueu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'epueu')"/>epveu<xsl:value-of select="substring-after(.,'epueu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^NEPUEU(\w*)$')">
      <reg>NEPVEU<xsl:value-of select="substring-after(.,'NEPUEU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)niur(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)niur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'niur')"/>njur<xsl:value-of select="substring-after(.,'niur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)NIUR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NIUR')"/>NJUR<xsl:value-of select="substring-after(.,'NIUR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^nouembre$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(n|N)ouembre$')">
      <reg><xsl:value-of select="substring-before(.,'ouembre')"/>ovembre</reg></xsl:if>
   <xsl:if test="matches(.,'^NOUEMBRE$')">
      <reg>NOVEMBRE</reg></xsl:if></choice>
            </xsl:when>         
<xsl:when test="matches(.,'^(\w+)nua(sion|in)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)nua(sion|in)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nua')"/>nva<xsl:value-of select="substring-after(.,'nua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)NUA(SION|IN)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NUA')"/>NVA<xsl:value-of select="substring-after(.,'NUA')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^nvag(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(n|N)vag(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vag')"/>uag<xsl:value-of select="substring-after(.,'vag')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^NVAG(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NUA')"/>NUAG<xsl:value-of select="substring-after(.,'NVAG')"/></reg></xsl:if></choice>
            </xsl:when>

<!--O-->
 <xsl:when test="matches(.,'^obui(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(o|O)bui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'bui')"/>bvi<xsl:value-of select="substring-after(.,'bui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^OBUI(\w*)$')">
      <reg>OBVI<xsl:value-of select="substring-after(.,'OBUI')"/></reg></xsl:if></choice>
           </xsl:when>
<xsl:when test="matches(.,'^(\w+)oiu(e|r)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)oiu(e|r)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'oiu')"/>oiv<xsl:value-of select="substring-after(.,'oiu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)OIU(E|R)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OIU')"/>OIV<xsl:value-of select="substring-after(.,'OIU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)oibue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)oibue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'oibue')"/>oibve<xsl:value-of select="substring-after(.,'oibue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)OIBUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OIBUE')"/>OIBVE<xsl:value-of select="substring-after(.,'OIBUE')"/></reg></xsl:if></choice>
            </xsl:when>            
<xsl:when test="matches(.,'^(\w+)ouveve(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)ouveve(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ouveve')"/>ouveue<xsl:value-of select="substring-after(.,'ouveve')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)OUVEVE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OUVEVE')"/>OUVEUE<xsl:value-of select="substring-after(.,'OUVEVE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^covar(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(c|C)ovar(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovar')"/>ouar<xsl:value-of select="substring-after(.,'ovar')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^COVAR(\w*)$')">
      <reg>COUAR<xsl:value-of select="substring-after(.,'COVAR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ouu(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)ouu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ouu')"/>ouv<xsl:value-of select="substring-after(.,'ouu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ouu(\w*)$')">
      <reg>Ouv<xsl:value-of select="substring-after(.,'Ouu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)OUU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OUU')"/>OUV<xsl:value-of select="substring-after(.,'OUU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ovf(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)ovf(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovf')"/>ouf<xsl:value-of select="substring-after(.,'ovf')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Ovf(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Ovf')"/>Ouf<xsl:value-of select="substring-after(.,'Ovf')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)OVF(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OVF')"/>OUF<xsl:value-of select="substring-after(.,'OVF')"/></reg></xsl:if></choice>
            </xsl:when>   
<xsl:when test="matches(.,'^(\w*)ovz(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
    <xsl:if test="matches(.,'^(\w*)ovz(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'ovz')"/>ouz<xsl:value-of select="substring-after(.,'ovz')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^Ovz(\w*)$')">
       <reg>Ouz<xsl:value-of select="substring-after(.,'Ovs')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)OVZ(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'OVZ')"/>OUZ<xsl:value-of select="substring-after(.,'OVZ')"/></reg></xsl:if></choice>
           </xsl:when> 

<!--P-->
            <!--periu pariu-->
<xsl:when test="matches(.,'^p(a|e)riu(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(p|P)(a|e)riu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'riu')"/>rju<xsl:value-of select="substring-after(.,'riu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^P(A|E)RIU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'RIU')"/>RJU<xsl:value-of select="substring-after(.,'RIU')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--paruen paruin-->
<xsl:when test="matches(.,'^paru(e|i)n(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(p|P)aru(e|i)n(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aru')"/>arv<xsl:value-of select="substring-after(.,'aru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PARU(E|I)N(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'PARU')"/>PARV<xsl:value-of select="substring-after(.,'PARU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^pjece(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(p|P)jece(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'jece')"/>iece<xsl:value-of select="substring-after(.,'jece')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PJECE(\w*)$')">
      <reg>PIECE<xsl:value-of select="substring-after(.,'PJECE')"/></reg></xsl:if></choice>
            </xsl:when>
<!--poure paoure poureté. Ne s'applique pas sur poureuse (= peureuse) -->
            <xsl:when test="matches(.,'^(\w*)pa?oure(s|t\w*)?$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(p|P)a?oure(s|t\w*)?$')">
      <reg><xsl:value-of select="substring-before(.,'oure')"/>ovre<xsl:value-of select="substring-after(.,'oure')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)PA?OURE(s|t\w*)?$')">
      <reg><xsl:value-of select="substring-before(.,'OURE')"/>OVRE<xsl:value-of select="substring-after(.,'OURE')"/></reg></xsl:if></choice>
            </xsl:when>   
<xsl:when test="matches(.,'^pouo(\w*)?$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(p|P)ouo(\w*)?$')">
       <reg><xsl:value-of select="substring-before(.,'ouo')"/>ovo<xsl:value-of select="substring-after(.,'ouo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^POUO(\w*)?$')">
      <reg>POVO<xsl:value-of select="substring-after(.,'POUO')"/></reg></xsl:if></choice>
            </xsl:when> 
<xsl:when test="matches(.,'^povr$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(p|P)ovr$')">
      <reg><xsl:value-of select="substring-before(.,'ovr')"/>our</reg></xsl:if>
   <xsl:if test="matches(.,'^POVR$')">
      <reg>POUR</reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^preiu(\w*)?$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
    <xsl:if test="matches(.,'^(\w*)(p|P)reiu(\w*)?$')">
      <reg><xsl:value-of select="substring-before(.,'reiu')"/>reju<xsl:value-of select="substring-after(.,'reiu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)PREIU(\w*)?$')">
      <reg><xsl:value-of select="substring-before(.,'PREIU')"/>PREJU<xsl:value-of select="substring-after(.,'PREIU')"/></reg></xsl:if></choice>
           </xsl:when>           
            <!--prev prevx-->
<xsl:when test="matches(.,'^prevx?$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(p|P)revx?$')">
      <reg><xsl:value-of select="substring-after(.,'rev')"/>reu<xsl:value-of select="substring-after(.,'rev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PREVX?$')">
      <reg>PREU<xsl:value-of select="substring-after(.,'PREV')"/></reg></xsl:if></choice>
            </xsl:when>            
           <!--prouen proui prouo proueu prouer-->
<xsl:when test="matches(.,'^prou(en|i|o|eu|er)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(p|P)rou(en|i|o|eu|er)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rou')"/>rov<xsl:value-of select="substring-after(.,'rou')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PROU(EN|I|O|EU|ER)(\w*)$')">
      <reg>PROV<xsl:value-of select="substring-after(.,'PROU')"/></reg></xsl:if></choice>
            </xsl:when>
            <xsl:when test="matches(.,'^pvb(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^pvb(\w+)$')">
      <reg>pub<xsl:value-of select="substring-after(.,'pvb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Pvb(\w+)$')">
      <reg>Pub<xsl:value-of select="substring-after(.,'Pvb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PVB(\w+)$')">
      <reg>PUB<xsl:value-of select="substring-after(.,'PVB')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)mpv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)mpv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'mpv')"/>mpu<xsl:value-of select="substring-after(.,'mpv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)MPV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MPV')"/>MPU<xsl:value-of select="substring-after(.,'MPV')"/></reg></xsl:if></choice>
            </xsl:when>

<!--Q-->
            <!--qve qvi qvo qva-->
<xsl:when test="matches(.,'^(\w*)qv(e|i|a|o)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)qv(e|i|a|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'qv')"/>qu<xsl:value-of select="substring-after(.,'qv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Qv(e|i|a|o)(\w*)$')">
      <reg>Qu<xsl:value-of select="substring-after(.,'Qv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)QV(E|I|A|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'QV')"/>QU<xsl:value-of select="substring-after(.,'QV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^queve(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(q|Q)ueve(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ueve')"/>ueue<xsl:value-of select="substring-after(.,'ueve')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^QUEVE(\w*)$')">  
      <reg>QUEUE<xsl:value-of select="substring-after(.,'QUEVE')"/></reg></xsl:if></choice>
            </xsl:when>

<!--R-->
<xsl:when test="matches(.,'^(\w+)radv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)radv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'radv')"/>radu<xsl:value-of select="substring-after(.,'radv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)RADV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'RADV')"/>RADU<xsl:value-of select="substring-after(.,'RADV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)rajon(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(r|R)ajon(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ajon')"/>aion<xsl:value-of select="substring-after(.,'ajon')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)RAJON(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'RAJON')"/>RAION<xsl:value-of select="substring-after(.,'RAJON')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^recev$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(r|R)ecev$')">
      <reg><xsl:value-of select="substring-before(.,'ecev')"/>eceu<xsl:value-of select="substring-after(.,'ecev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^RECEV$')">
      <reg>RECEU<xsl:value-of select="substring-after(.,'RECEV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)reie(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(r|R)eie(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eie')"/>eje<xsl:value-of select="substring-after(.,'eie')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)REIE(\w*)$')">
      <reg>REJE<xsl:value-of select="substring-after(.,'REIE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^reu(e|u)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(r|R)eu(e|u)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eu')"/>ev<xsl:value-of select="substring-after(.,'eu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^REU(E|U)(\w*)$')">
      <reg>REV<xsl:value-of select="substring-after(.,'REU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^renuer(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(r|R)enuer(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'enuer')"/>enver<xsl:value-of select="substring-after(.,'enuer')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^RENUER(\+)$')">
      <reg>RENVER<xsl:value-of select="substring-after(.,'RENUER')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^réue(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(r|R)éue(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'éue')"/>éve<xsl:value-of select="substring-after(.,'éue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^RÉUE(\+)$')">
      <reg>RÉVE<xsl:value-of select="substring-after(.,'RÉUE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^t?r?esio(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(t|T)?(r|R)?(e|E)sio(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'sio')"/>sjo<xsl:value-of select="substring-after(.,'sio')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^T?R?ESIO(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'ESIO')"/>ESJO<xsl:value-of select="substring-after(.,'ESIO')"/></reg></xsl:if></choice>
            </xsl:when>

<!--S-->
<xsl:when test="matches(.,'^(\w*)(sa|p)ulu(e|o|a|é)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(sa|p|Sa|P)ulu(e|o|a|é)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ulu')"/>ulv<xsl:value-of select="substring-after(.,'ulu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(SA|P)ULU(E|O|A|É)(\*w)$')">
      <reg><xsl:value-of select="substring-before(.,'ULU')"/>ULV<xsl:value-of select="substring-after(.,'ULU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)ssevr(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)ssevr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ssevr')"/>sseur<xsl:value-of select="substring-after(.,'ssevr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)SSEVR(\*w)$')">
      <reg>SSEUR<xsl:value-of select="substring-after(.,'SSEVR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)seru(i|o)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(s|S)eru(i|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eru')"/>erv<xsl:value-of select="substring-after(.,'eru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)SERU(I|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'SERU')"/>SERV<xsl:value-of select="substring-after(.,'SERU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^sjec(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(s|S)jec(\w+)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'jec')"/>iec<xsl:value-of select="substring-after(.,'jec')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^SJEC(\w+)$')">
      <reg>SIEC<xsl:value-of select="substring-after(.,'SJEC')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)solua(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(s|S)olua(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'olua')"/>olva<xsl:value-of select="substring-after(.,'olua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)SOLUA(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'SOLUA')"/>SOLVA<xsl:value-of select="substring-after(.,'SOLUA')"/></reg></xsl:if></choice>
           </xsl:when>             
<xsl:when test="matches(.,'^(as)?subi(e|u)(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(as|As)?(s|S)ubi(e|u)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'ubi')"/>ubj<xsl:value-of select="substring-after(.,'ubi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(AS)?SUBI(E|U)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'SUBI')"/>SUBJ<xsl:value-of select="substring-after(.,'SUBI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)suiet(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(s|S)uiet(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiet')"/>ujet<xsl:value-of select="substring-after(.,'uiet')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^SUIET(\w*)$')">
      <reg>SUJET<xsl:value-of select="substring-after(.,'SUIET')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^suru(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(s|S)uru(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uru')"/>urv<xsl:value-of select="substring-after(.,'uru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^SURU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'SURU')"/>SURV<xsl:value-of select="substring-after(.,'SURU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)suiu(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(s|S)uiu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiu')"/>uiv<xsl:value-of select="substring-after(.,'uiu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)SUIU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'SUIU')"/>SUIV<xsl:value-of select="substring-after(.,'SUIU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^svr$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(s|S)vr$')">
      <reg><xsl:value-of select="substring-before(.,'vr')"/>ur</reg></xsl:if>
   <xsl:if test="matches(.,'^SVR$')">
      <reg>SUR</reg></xsl:if></choice>
            </xsl:when>            

<!--T-->
<xsl:when test="matches(.,'^tous?iours$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(t|T)ous?iours$')">
      <reg><xsl:value-of select="substring-before(.,'iours')"/>jours</reg></xsl:if>
   <xsl:if test="matches(.,'^TOUS?IOURS$')">
      <reg><xsl:value-of select="substring-before(.,'IOURS')"/>JOURS</reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)tovr(\w*)$', 'i')">
           <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(t|T)ovr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovr')"/>our<xsl:value-of select="substring-after(.,'ovr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)TOVR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TOVR')"/>TOUR<xsl:value-of select="substring-after(.,'TOVR')"/></reg></xsl:if></choice>
            </xsl:when>             
<xsl:when test="matches(.,'^tovs$', 'i')">            
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(t|T)ovs$')">
      <reg><xsl:value-of select="substring-before(.,'ovs')"/>ous</reg></xsl:if>
   <xsl:if test="matches(.,'^TOVS$')">
      <reg>TOUS</reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^tresiust(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(t|T)resiust(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'resiust')"/>resjust<xsl:value-of select="substring-after(.,'resiust')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^TRESIUST(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TRESIUST')"/>TRESJUST<xsl:value-of select="substring-after(.,'TRESIUST')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^tresui(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(t|T)resui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'resui')"/>resvi<xsl:value-of select="substring-after(.,'resui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^TRESUI(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TRESUI')"/>TRESVI<xsl:value-of select="substring-after(.,'TRESUI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)trv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(T|t)rv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rv')"/>ru<xsl:value-of select="substring-after(.,'rv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)TRV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TRV')"/>TRU<xsl:value-of select="substring-after(.,'TRV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)trouer(s|e)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(t|T)rouer(s|e)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rouer')"/>rover<xsl:value-of select="substring-after(.,'rouer')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)TROUER(S|E)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TROUER')"/>TROVER<xsl:value-of select="substring-after(.,'TROUER')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--treue greue preue-->
<xsl:when test="matches(.,'^(g|t|p)reue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(t|T|g|G|p|P)reue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'reue')"/>reve<xsl:value-of select="substring-after(.,'reue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(T|G|P)REUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'REUE')"/>REVE<xsl:value-of select="substring-after(.,'REUE')"/></reg></xsl:if></choice>
            </xsl:when>
            <!--petv entv titv ectv-->
<xsl:when test="matches(.,'^(\w*)(pe|en|ti|c)tv(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(pe|Pe|en|En|ti|Ti|c)tv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'tv')"/>tu<xsl:value-of select="substring-after(.,'tv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(PE|EN|TI|C)TV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TV')"/>TU<xsl:value-of select="substring-after(.,'TV')"/></reg></xsl:if></choice>
            </xsl:when>
            
<!--U-->

<!-- U qui devient V en début de mot-->
<xsl:when test="matches(.,'^ua(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ua(\w*)$')">
      <reg>va<xsl:value-of select="substring-after(.,'ua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ua(\w*)$')">
      <reg>Va<xsl:value-of select="substring-after(.,'Ua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UA(\w*)$')">
      <reg>VA<xsl:value-of select="substring-after(.,'UA')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^ue(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ue(\w*)$')">
      <reg>ve<xsl:value-of select="substring-after(.,'ue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ue(\w*)$')">
      <reg>Ve<xsl:value-of select="substring-after(.,'Ue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UE(\w*)$')">
      <reg>Ve<xsl:value-of select="substring-after(.,'UE')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^ui(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ui(\w*)$')">
      <reg>vi<xsl:value-of select="substring-after(.,'ui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ui(\w*)$')">
      <reg>Vi<xsl:value-of select="substring-after(.,'Ui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UI(\w*)$')">
      <reg>VI<xsl:value-of select="substring-after(.,'UI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^uo(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^uo(\w*)$')">
      <reg>vo<xsl:value-of select="substring-after(.,'uo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Uo(\w*)$')">
      <reg>Vo<xsl:value-of select="substring-after(.,'Uo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UO(\w*)$')">
      <reg>VO<xsl:value-of select="substring-after(.,'UO')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^uu(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^uu(\w*)$')">
      <reg>vu<xsl:value-of select="substring-after(.,'uu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Uu(\w*)$')">
      <reg>Vu<xsl:value-of select="substring-after(.,'Uu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UU(\w*)$')">
      <reg>VU<xsl:value-of select="substring-after(.,'UU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^ura(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^ura(\w*)$')">
      <reg>vra<xsl:value-of select="substring-after(.,'ura')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ura(\w*)$')">
      <reg>Vra<xsl:value-of select="substring-after(.,'Ura')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^URA(\w*)$')">
      <reg>VRA<xsl:value-of select="substring-after(.,'URA')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)uru(o|u|eu)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)uru(o|u|eu)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uru')"/>urv<xsl:value-of select="substring-after(.,'uru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)URU(O|U|EU)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'URU')"/>URV<xsl:value-of select="substring-after(.,'URU')"/></reg></xsl:if></choice>
            </xsl:when>       
<xsl:when test="matches(.,'^(\w*)uul(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)uul(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uul')"/>vul<xsl:value-of select="substring-after(.,'uul')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Uul(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Uul')"/>Vul<xsl:value-of select="substring-after(.,'Uul')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)UUL(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UUL')"/>VUL<xsl:value-of select="substring-after(.,'UUL')"/></reg></xsl:if></choice>
            </xsl:when>
           <!--auu euu luu ex: oeuure-->
<xsl:when test="matches(.,'^(\w+)(a|e|l)uu(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)(a|e|l)uu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uu')"/>uv<xsl:value-of select="substring-after(.,'uu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)(A|E|L)UU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UU')"/>UV<xsl:value-of select="substring-after(.,'UU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^euu(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(e|E)uu(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'uu')"/>uv<xsl:value-of select="substring-after(.,'uu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^EUU(\w*)$')">
       <reg>EUV<xsl:value-of select="substring-after(.,'EUU')"/></reg></xsl:if></choice>
           </xsl:when>           
<xsl:when test="matches(.,'^(\w+)uyu(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)uyu(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'uyu')"/>uyv<xsl:value-of select="substring-after(.,'uyu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)UYU(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'UYU')"/>UYV<xsl:value-of select="substring-after(.,'UYU')"/></reg></xsl:if></choice>
            </xsl:when>

<!--V-->
<xsl:when test="matches(.,'^(\w*)viu[^s](\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)viu[^s](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'viu')"/>viv<xsl:value-of select="substring-after(.,'viu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Viu[^s](\w*)$')">
      <reg>Viv<xsl:value-of select="substring-after(.,'Viu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VIU[^s](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VIU')"/>VIV<xsl:value-of select="substring-after(.,'VIU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)vev(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)vev(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vev')"/>veu<xsl:value-of select="substring-after(.,'vev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Vev(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Vev')"/>Veu<xsl:value-of select="substring-after(.,'Vev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VEV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VEV')"/>VEU<xsl:value-of select="substring-after(.,'VEV')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^vingtvn(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(v|V)ingtvn(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'ingtvn')"/>ingtun<xsl:value-of select="substring-after(.,'ingtvn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VINGTVN(\w+)$')">
      <reg>VINGTUN<xsl:value-of select="substring-after(.,'VINGTVN')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)vti(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)vti(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'vti')"/>uti<xsl:value-of select="substring-after(.,'vti')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Vti(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'Vti')"/>Uti<xsl:value-of select="substring-after(.,'Vti')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VTI(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'VTI')"/>UTI<xsl:value-of select="substring-after(.,'VTI')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^vl(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^vl(\w+)$')">
      <reg>ul<xsl:value-of select="substring-after(.,'vl')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vl(\w+)$')">
      <reg>Ul<xsl:value-of select="substring-after(.,'Vl')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VL(\w+)$')">
      <reg>UL<xsl:value-of select="substring-after(.,'VL')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)vle(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)vle(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vle')"/>ule<xsl:value-of select="substring-after(.,'vle')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Vle(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Vle')"/>Ule<xsl:value-of select="substring-after(.,'Vle')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VLE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VLE')"/>ULE<xsl:value-of select="substring-after(.,'VLE')"/></reg></xsl:if></choice>
            </xsl:when>             
<xsl:when test="matches(.,'^(\w+)vlx$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)vlx$')">
      <reg><xsl:value-of select="substring-before(.,'vlx')"/>ulx</reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)VLX$')">
      <reg><xsl:value-of select="substring-before(.,'VLX')"/>ULX</reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)vmb(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)vmb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vmb')"/>umb<xsl:value-of select="substring-after(.,'vmb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Vmb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Vmb')"/>Umb<xsl:value-of select="substring-after(.,'Vmb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VMB(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VMB')"/>UMB<xsl:value-of select="substring-after(.,'UMB')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^vn(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^vn(\w*)$')">
      <reg>un<xsl:value-of select="substring-after(.,'vn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vn(\w*)$')">
      <reg>Un<xsl:value-of select="substring-after(.,'Vn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VN(\w*)$')">
      <reg>UN<xsl:value-of select="substring-after(.,'VN')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)vp(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w+)vp(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'vp')"/>up<xsl:value-of select="substring-after(.,'vp')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)VP(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'VP')"/>UP<xsl:value-of select="substring-after(.,'VP')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^vr(b|g|l|n|r|s)(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^vr(b|g|l|n|r|s)(\w+)$')">
      <reg>ur<xsl:value-of select="substring-after(.,'vr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vr(b|g|l|n|r|s)(\w+)$')">
      <reg>Ur<xsl:value-of select="substring-after(.,'Vr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VR(B|G|L|N|R|S)(\w+)$')">
      <reg>UR<xsl:value-of select="substring-after(.,'VR')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^vb(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^vb(\w+)$')">
      <reg>ub<xsl:value-of select="substring-after(.,'vb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vb(\w+)$')">
      <reg>Ub<xsl:value-of select="substring-after(.,'Vb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VB(\w+)$')">
      <reg>UB<xsl:value-of select="substring-after(.,'VB')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^vs(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^vs(\w+)$')">
      <reg>us<xsl:value-of select="substring-after(.,'vs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vs(\w+)$')">
      <reg>Us<xsl:value-of select="substring-after(.,'Vs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VS(\w+)$')">
      <reg>US<xsl:value-of select="substring-after(.,'VS')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^vt(\w+)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^vt(\w+)$')">
      <reg>ut<xsl:value-of select="substring-after(.,'vt')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vt(\w+)$')">
      <reg>Ut<xsl:value-of select="substring-after(.,'Vt')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VT(\w+)$')">
      <reg>UT<xsl:value-of select="substring-after(.,'VT')"/></reg></xsl:if></choice>
            </xsl:when>

<!--Y-->
            <!--yue yuro yuoi-->
<xsl:when test="matches(.,'^(\w*)yu(e|ro|oi)(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)yu(e|ro|oi)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'yu')"/>yv<xsl:value-of select="substring-after(.,'yu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Yu(e|ro|oi)(\w*)$')">
      <reg>Yv<xsl:value-of select="substring-after(.,'Yu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)YU(E|RO|OI)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'YU')"/>YV<xsl:value-of select="substring-after(.,'YU')"/></reg></xsl:if></choice>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)yur(\w*)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
    <xsl:if test="matches(.,'^(\w*)yur(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'yur')"/>yvr<xsl:value-of select="substring-after(.,'yur')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^Yur(\w*)$')">
       <reg>Yvr<xsl:value-of select="substring-after(.,'Yur')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)YUR(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'YUR')"/>YVR<xsl:value-of select="substring-after(.,'YUR')"/></reg></xsl:if></choice>
           </xsl:when>         
<xsl:when test="matches(.,'^(\w*)ÿuer(\w*)$', 'i')">
                <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(Ÿ|ÿ)uer(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uer')"/>ver<xsl:value-of select="substring-after(.,'uer')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ŸUER(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ŸUER')"/>ŸVER<xsl:value-of select="substring-after(.,'ŸUER')"/></reg></xsl:if></choice>
            </xsl:when>            
            
<!--Z-->           
           <!--Zuingle sixuingts-->
<xsl:when test="matches(.,'^(\w*)(z|x)uing(\w+)$', 'i')">
              <choice><orig><xsl:value-of select="."/></orig>
   <xsl:if test="matches(.,'^(\w*)(Z|z|x|X)uing(\w+)$')">
     <reg><xsl:value-of select="substring-before(.,'uing')"/>ving<xsl:value-of select="substring-after(.,'uing')"/></reg></xsl:if>
  <xsl:if test="matches(.,'^(\w*)(Z|X)UING(\w+)$')">
     <reg><xsl:value-of select="substring-before(.,'UING')"/>ZVING<xsl:value-of select="substring-after(.,'UING')"/></reg></xsl:if></choice>
           </xsl:when>        
            
            <!--pour les mots n'étant concerné par aucune régle, on copie la même chose sans <w>-->
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    <!-- 4°)Pour ceux ayant eu une règle appliquée, on relance les mêmes règles sur le reg-->
    <xsl:template match="tei:reg" mode="pass4">
        <xsl:choose>
           
<!--[DETILDAGE]-->
           <!--nécessiterait 3 passages des règles sans cette exception-->
<xsl:when test="matches(.,'^(\w*)cōmāderēt$')">
       <reg><xsl:value-of select="substring-before(.,'cōmāderēt')"/>commanderent</reg>
           </xsl:when>
           <!--nécessiterait 3 passages des règles sans cette exception-->
<xsl:when test="matches(.,'^(\w*)cōmēcemēt(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'cōmēcemēt')"/>commencement<xsl:value-of select="substring-after(.,'cōmēcemēt')"/></reg>
           </xsl:when>
           <!--nécessiterait 3 passages des règles sans cette exception-->
<xsl:when test="matches(.,'^(\w*)cōseruatiō(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'cōseruatiō')"/>conservation<xsl:value-of select="substring-after(.,'cōseruatiō')"/></reg>
           </xsl:when>            
           <!--nécessiterait 3 passages des règles sans cette exception-->
<xsl:when test="matches(.,'^(\w*)cōdānerēt(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'cōdānerēt')"/>condamnerent<xsl:value-of select="substring-after(.,'cōdānerēt')"/></reg>
           </xsl:when>           
<xsl:when test="matches(.,'^(\w*)ām(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ām')"/>amm<xsl:value-of select="substring-after(.,'ām')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)āb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'āb')"/>amb<xsl:value-of select="substring-after(.,'āb')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)āp(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'āp')"/>amp<xsl:value-of select="substring-after(.,'āp')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)dān(\w*)$', 'i')">
      <reg><xsl:value-of select="substring-before(.,'ān')"/>amn<xsl:value-of select="substring-after(.,'ān')"/></reg>     
            </xsl:when>   
<xsl:when test="matches(.,'^(\w*)ān(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ān')"/>ann<xsl:value-of select="substring-after(.,'ān')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ā[^(a|e|i|o|u|é|è)](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ā')"/>an<xsl:value-of select="substring-after(.,'ā')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ā$')">
      <reg><xsl:value-of select="substring-before(.,'ā')"/>an</reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ēm(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ēm')"/>emm<xsl:value-of select="substring-after(.,'ēm')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ēb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ēb')"/>emb<xsl:value-of select="substring-after(.,'ēb')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ēp(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ēp')"/>emp<xsl:value-of select="substring-after(.,'ēp')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ēn(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ēn')"/>enn<xsl:value-of select="substring-after(.,'ēn')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ē[^(a|e|i|o|é|è)](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ē')"/>en<xsl:value-of select="substring-after(.,'ē')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ē$')">
      <reg><xsl:value-of select="substring-before(.,'ē')"/>en</reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)īm(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'īm')"/>imm<xsl:value-of select="substring-after(.,'īm')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)īb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'īb')"/>imb<xsl:value-of select="substring-after(.,'īb')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)īp(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'īp')"/>imp<xsl:value-of select="substring-after(.,'īp')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)īn(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'īn')"/>inn<xsl:value-of select="substring-after(.,'īn')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ī[^(a|e|i|o|u|é|è)](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ī')"/>in<xsl:value-of select="substring-after(.,'ī')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ī$')">
      <reg><xsl:value-of select="substring-before(.,'ī')"/>in</reg>
            </xsl:when>             
<xsl:when test="matches(.,'^(\w*)ōm(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ōm')"/>omm<xsl:value-of select="substring-after(.,'ōm')"/></reg>
            </xsl:when>    
<xsl:when test="matches(.,'^(\w*)ōb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ōb')"/>omb<xsl:value-of select="substring-after(.,'ōb')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ōp(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ōp')"/>omp<xsl:value-of select="substring-after(.,'ōp')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ōn(\w*)$')">
   <reg><xsl:value-of select="substring-before(.,'ōn')"/>onn<xsl:value-of select="substring-after(.,'ōn')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ō[^(é|è)](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ō')"/>on<xsl:value-of select="substring-after(.,'ō')"/></reg>
            </xsl:when> 
<xsl:when test="matches(.,'^(\w*)ō$')">
      <reg><xsl:value-of select="substring-before(.,'ō')"/>on</reg>
            </xsl:when>                  
<xsl:when test="matches(.,'^(\w*)ūm(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ūm')"/>umm<xsl:value-of select="substring-after(.,'ūm')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ūb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ūb')"/>umb<xsl:value-of select="substring-after(.,'ūb')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ūp(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ūp')"/>ump<xsl:value-of select="substring-after(.,'ūp')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ūn(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ūn')"/>umn<xsl:value-of select="substring-after(.,'ūn')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ū[^(a|e|i|o|é|è)](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ū')"/>un<xsl:value-of select="substring-after(.,'ū')"/></reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ū$')">
      <reg><xsl:value-of select="substring-before(.,'ū')"/>un</reg>
            </xsl:when>

<!--[DISSIMILATION]-->
<xsl:when test="matches(.,'^i$', 'i')">
   <xsl:if test="matches(.,'^i$')"><reg>j</reg></xsl:if>
   <xsl:if test="matches(.,'^I$')"><reg>J</reg></xsl:if>
            </xsl:when>

<!--A-->
<xsl:when test="matches(.,'^Aiax$')">
      <reg>Ajax</reg>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)aio(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)aio(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ai')"/>aj<xsl:value-of select="substring-after(.,'ai')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Aio(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Ai')"/>Aj<xsl:value-of select="substring-after(.,'Ai')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AIO(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AI')"/>AJ<xsl:value-of select="substring-after(.,'AI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^ajan(ts?|s)$', 'i')">
   <xsl:if test="matches(.,'^(a|A)jan(ts?|s)$')">
      <reg><xsl:value-of select="substring-before(.,'jan')"/>ian<xsl:value-of select="substring-after(.,'jan')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^AJAN(TS?|s)$')">
      <reg>AIAN<xsl:value-of select="substring-after(.,'AJAN')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*[^e])aue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*[^e])aue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aue')"/>ave<xsl:value-of select="substring-after(.,'aue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*[^E])AUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUE')"/>AVE<xsl:value-of select="substring-after(.,'AUE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^Aue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^Aue(\w*)$')">
      <reg>Ave<xsl:value-of select="substring-after(.,'Aue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^aue(\w*)$')">
      <reg>ave<xsl:value-of select="substring-after(.,'aue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^AUE(\w*)$')">
      <reg>AVE<xsl:value-of select="substring-after(.,'AUE')"/></reg></xsl:if>
            </xsl:when>             
<xsl:when test="matches(.,'^av$', 'i')">
   <xsl:if test="matches(.,'^av$')"><reg>au</reg></xsl:if>
   <xsl:if test="matches(.,'^AV$')"><reg>AU</reg></xsl:if>
   <xsl:if test="matches(.,'^Av$')"><reg>Au</reg></xsl:if>
            </xsl:when>         
<xsl:when test="matches(.,'^auiour(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(a|A)uiour(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiour')"/>ujour<xsl:value-of select="substring-after(.,'auiour')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^AUIOUR(\w*)$')">
      <reg>AUJOUR<xsl:value-of select="substring-after(.,'AUIOUR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)aua(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)aua(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aua')"/>ava<xsl:value-of select="substring-after(.,'aua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AUA(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUA')"/>AVA<xsl:value-of select="substring-after(.,'AUA')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Aua(\w*)$')">
      <reg>Ava<xsl:value-of select="substring-after(.,'Aua')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)aué(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)aué(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aué')"/>avé<xsl:value-of select="substring-after(.,'aué')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AUÉ(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUÉ')"/>AVÉ<xsl:value-of select="substring-after(.,'AUÉ')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Aué(\w*)$')">
      <reg>Avé<xsl:value-of select="substring-after(.,'Aué')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)aui(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)aui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aui')"/>avi<xsl:value-of select="substring-after(.,'aui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AUA(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUI')"/>AVI<xsl:value-of select="substring-after(.,'AUI')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Aui(\w*)$')">
      <reg>Avi<xsl:value-of select="substring-after(.,'Aui')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)auo(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)auo(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'auo')"/>avo<xsl:value-of select="substring-after(.,'auo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)AUO(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AUO')"/>AVO<xsl:value-of select="substring-after(.,'AUO')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Auo(\w*)$')">
      <reg>Avo<xsl:value-of select="substring-after(.,'Auo')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^adu(a|e|i|o)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^adu(a|e|i|o)(\w*)$')">
      <reg>adv<xsl:value-of select="substring-after(.,'adu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ADU(A|E|I|O)(\w*)$')">
      <reg>ADV<xsl:value-of select="substring-after(.,'ADU')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Adu(a|e|i|o)(\w*)$')">
      <reg>Adv<xsl:value-of select="substring-after(.,'Adu')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^abi(e|u)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(a|A)bi(e|u)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'bi')"/>bj<xsl:value-of select="substring-after(.,'bi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ABI(E|U)(\w*)$')">
      <reg>ABJ<xsl:value-of select="substring-after(.,'ABI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(co)?adio?(u|i?n|a)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(co|Co)?(a|A)dio?(u|i?n|a)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'di')"/>dj<xsl:value-of select="substring-after(.,'di')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(CO)?ADIO?(U|I?N|A)(\w*)$')">
      <reg>ADJ<xsl:value-of select="substring-after(.,'ADI')"/></reg></xsl:if>
           </xsl:when>
<xsl:when test="matches(.,'^(\w+)avme(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)(a|A)vme(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vme')"/>ume<xsl:value-of select="substring-after(.,'vme')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)AVME(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'AVME')"/>AUME<xsl:value-of select="substring-after(.,'AVME')"/></reg></xsl:if>
            </xsl:when>     
<xsl:when test="matches(.,'^avt(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(a|A)vt(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vt')"/>ut<xsl:value-of select="substring-after(.,'vt')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^AVT(\w*)$')">
      <reg>AUT<xsl:value-of select="substring-after(.,'VT')"/></reg></xsl:if>
            </xsl:when>              

<!--B-->
<xsl:when test="matches(.,'^bienuu?eu?il(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(b|B)ienuu?eu?il(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ienu')"/>ienv<xsl:value-of select="substring-after(.,'ienu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^BIENUU?EU?IL(\w*)$')">
      <reg>BIENV<xsl:value-of select="substring-after(.,'BIENU')"/></reg></xsl:if>
           </xsl:when>
<xsl:when test="matches(.,'^bouvrevil(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(b|B)ouvrevil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ouvrevil')"/>ouvreuil<xsl:value-of select="substring-after(.,'ouvrevil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^BOUVREVIL(\w*)$')">
      <reg>BOUVREUIL<xsl:value-of select="substring-after(.,'BOUVREVIL')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^brauerie(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(b|B)rauerie(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rauerie')"/>raverie<xsl:value-of select="substring-after(.,'rauerie')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^BRAUERIE(\w*)$')">
      <reg>BRAVERIE<xsl:value-of select="substring-after(.,'BRAUERIE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^brieue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(b|B)rieue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rieue')"/>rieve<xsl:value-of select="substring-after(.,'rieue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^BRIEUE(\w*)$')">
      <reg>BRIEVE<xsl:value-of select="substring-after(.,'BRIEUE')"/></reg></xsl:if>
            </xsl:when>            

<!--C-->
<xsl:when test="matches(.,'^cerfevil(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(c|C)erfevil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'erfevil')"/>erfeuil<xsl:value-of select="substring-after(.,'erfevil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CERFEVIL(\w*)$')">
      <reg>CERFEUIL<xsl:value-of select="substring-after(.,'CERFEVIL')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\+)ceur(a|o)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)ceur(a|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ceur')"/>cevr<xsl:value-of select="substring-after(.,'ceur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)CEUR(A|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CEUR')"/>CEVRA<xsl:value-of select="substring-after(.,'CEUR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^cheur(e|o)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(c|C)heur(e|o)(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'heur')"/>hevr<xsl:value-of select="substring-after(.,'heur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CHEUR(E|O)(\w*)$')">
      <reg>CHEVR<xsl:value-of select="substring-after(.,'CHEUR')"/></reg></xsl:if>
           </xsl:when>
<!--  exception pour "meurier" -->
<xsl:when test="matches(.,'^(\w*[^(m|M)])eurier(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*[^(m|M)])eurier(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eurier')"/>evrier<xsl:value-of select="substring-after(.,'eurier')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*[^M])EURIER(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EURIER')"/>EVRIER<xsl:value-of select="substring-after(.,'EURIER')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^chevrevil(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(c|C)hevrevil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'hevrevil')"/>hevreuil<xsl:value-of select="substring-after(.,'hevrevil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CHEVREVIL(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CHEVREVIL')"/>CHEVREUIL<xsl:value-of select="substring-after(.,'CHEVREVIL')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^conceuro(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(c|C)onceuro(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'onceuro')"/>oncevro<xsl:value-of select="substring-after(.,'onceuro')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CONCEURO(\w*)$')">
      <reg>CONCEVRO<xsl:value-of select="substring-after(.,'CONCEURO')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)conve?s?$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(c|C)onve?s?$')">
      <reg><xsl:value-of select="substring-before(.,'onv')"/>onu<xsl:value-of select="substring-after(.,'onv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CONVE?S?$')">
      <reg><xsl:value-of select="substring-before(.,'CONVE')"/>CONUE<xsl:value-of select="substring-after(.,'CONVE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^conui(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(c|C)onui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'onui')"/>onvi<xsl:value-of select="substring-after(.,'onui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CONUI(\w*)$')">
      <reg>CONVI<xsl:value-of select="substring-after(.,'CONUI')"/></reg></xsl:if>
            </xsl:when>             
<xsl:when test="matches(.,'^(\w*)Calui(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)CALUI(\w*)$')">
      <reg>CALVI<xsl:value-of select="substring-after(.,'CALUI')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Calui(\w*)$')">
      <reg>Calvi<xsl:value-of select="substring-after(.,'Calui')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^coni(oi|ur)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(c|C)oni(oi|ur)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'oni')"/>onj<xsl:value-of select="substring-after(.,'oni')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CONI(OI|UR)(\w*)$')">
      <reg>CONJ<xsl:value-of select="substring-after(.,'CONI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)conu(e|é|o)(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(c|C)onu(e|é|o)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'onu')"/>onv<xsl:value-of select="substring-after(.,'onu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CONU(E|É|O)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'CONU')"/>CONV<xsl:value-of select="substring-after(.,'CONU')"/></reg></xsl:if>
            </xsl:when>   
<xsl:when test="matches(.,'^(\w*)cerue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(c|C)erue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'erue')"/>erve<xsl:value-of select="substring-after(.,'erue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CERUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CERUE')"/>CERVE<xsl:value-of select="substring-after(.,'CERUE')"/></reg></xsl:if>
            </xsl:when> 
<xsl:when test="matches(.,'^(c|C)uiur(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(c|C)uiur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiur')"/>uivr<xsl:value-of select="substring-after(.,'uiur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CUIUR(\w*)$')">
      <reg>CUIVR<xsl:value-of select="substring-after(.,'CUIUR')"/></reg></xsl:if>
            </xsl:when>           
<xsl:when test="matches(.,'^cevl?x$', 'i')">
   <xsl:if test="matches(.,'^(c|C)evl?x$')">
      <reg><xsl:value-of select="substring-before(.,'ev')"/>eu<xsl:value-of select="substring-after(.,'ev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^CEVL?X$')">
      <reg>CEU<xsl:value-of select="substring-after(.,'CEV')"/></reg></xsl:if>
            </xsl:when> 
<xsl:when test="matches(.,'^(\w+)ceve$', 'i')">
   <xsl:if test="matches(.,'^(\w+)ceve$')">
      <reg><xsl:value-of select="substring-before(.,'ceve')"/>ceue</reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)CEVE$')">
      <reg><xsl:value-of select="substring-before(.,'CEVE')"/>CEUE</reg></xsl:if>
            </xsl:when>           
<xsl:when test="matches(.,'^(\w*)continv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(c|C)ontinv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ontinv')"/>ontinu<xsl:value-of select="substring-after(.,'ontinv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CONTINV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CONTINV')"/>CONTINU<xsl:value-of select="substring-after(.,'CONTINV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)covrs(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(c|C)ovrs(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovrs')"/>ours<xsl:value-of select="substring-after(.,'ovrs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)COVRS(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'COVRS')"/>COURS<xsl:value-of select="substring-after(.,'COVRS')"/></reg></xsl:if>
            </xsl:when>                
<xsl:when test="matches(.,'^(\w*)ctevr(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(c|C)tevr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'tevr')"/>teur<xsl:value-of select="substring-after(.,'tevr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CTEVR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CTEVR')"/>CTEUR<xsl:value-of select="substring-after(.,'CTEVR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)cvlev(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(c|C)vlev(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vlev')"/>uleu<xsl:value-of select="substring-after(.,'vlev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CVLEV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'CVLEV')"/>CULEU<xsl:value-of select="substring-after(.,'CVLEV')"/></reg></xsl:if>
            </xsl:when>     
<xsl:when test="matches(.,'^creué(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(c|C)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'reué')"/>revé<xsl:value-of select="substring-after(.,'reué')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)CREUÉ(\w*)$')">
      <reg>CREVÉ<xsl:value-of select="substring-after(.,'CREUÉ')"/></reg></xsl:if>
           </xsl:when>   

<!--D-->
            <!--deura deuro deuri-->            
<xsl:when test="matches(.,'^deur(a|o|i)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(d|D)eur(a|o|i)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eur')"/>evr<xsl:value-of select="substring-after(.,'eur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DEUR(A|O|I)(\w*)$')">
      <reg>DEUR<xsl:value-of select="substring-after(.,'DEUR')"/></reg></xsl:if>
            </xsl:when>
            <!--déura déuro déuri (dans le 1er livre de Vitruve) -->
<xsl:when test="matches(.,'^déur(a|o|i)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(d|D)éur(a|o|i)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'éur')"/>évr<xsl:value-of select="substring-after(.,'éur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DÉUR(A|O|I)(\w*)$')">
      <reg>DÉUR<xsl:value-of select="substring-after(.,'DÉUR')"/></reg></xsl:if>
            </xsl:when>               
<xsl:when test="matches(.,'^(d|v|s)evil(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(d|D|v|V|s|S)evil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'evil')"/>euil<xsl:value-of select="substring-after(.,'evil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(D|V|S)EVIL(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EVIL')"/>EUIL<xsl:value-of select="substring-after(.,'DEVIL')"/></reg></xsl:if>
            </xsl:when>
            <!--desia desià-->
<xsl:when test="matches(.,'^desi(a|à)$')">
   <xsl:if test="matches(.,'^(d|D)esi(a|à)$')">
      <reg><xsl:value-of select="substring-before(.,'esi')"/>esj<xsl:value-of select="substring-after(.,'esi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DESI(A|À)$')">
      <reg><xsl:value-of select="substring-before(.,'ESI')"/>ESJ<xsl:value-of select="substring-after(.,'ESI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^d(e|é)s?liur(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(d|D)(e|é)s?liur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'liur')"/>livr<xsl:value-of select="substring-after(.,'liur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^D(E|É)S?LIUR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'LIUR')"/>LIVR<xsl:value-of select="substring-after(.,'LIUR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^desu(i|o)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(d|D)esu(i|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'esu')"/>esv<xsl:value-of select="substring-after(.,'esu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DESU(I|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'DESU')"/>DESV<xsl:value-of select="substring-after(.,'DESU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^diev(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(d|D)iev(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'iev')"/>ieu<xsl:value-of select="substring-after(.,'iev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^DIEV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'DIEV')"/>DIEU<xsl:value-of select="substring-after(.,'DIEV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)douic(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)douic(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'douic')"/>dovic<xsl:value-of select="substring-after(.,'douic')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)DOUIC(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'DOUIC')"/>DOVIC<xsl:value-of select="substring-after(.,'LIUR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^dv$', 'i')">
   <xsl:if test="matches(.,'^(d|D)v$')">
      <reg><xsl:value-of select="substring-before(.,'v')"/>u</reg></xsl:if>
   <xsl:if test="matches(.,'^DV$')">
      <reg>DU</reg></xsl:if>
            </xsl:when>
            <!--lvc dvc-->
<xsl:when test="matches(.,'^(\w*)(d|l)vc(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(d|D|l|L)vc(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vc')"/>uc<xsl:value-of select="substring-after(.,'vc')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(D|L)VC(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VC')"/>UC<xsl:value-of select="substring-after(.,'VC')"/></reg></xsl:if>
            </xsl:when>

<!--E-->
            <!--ebuo ebur-->
<xsl:when test="matches(.,'^(\w+)ebu(o|r)(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)ebu(o|r)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'ebu')"/>ebv<xsl:value-of select="substring-after(.,'ebu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)EBU(O|R)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'EBU')"/>EBV<xsl:value-of select="substring-after(.,'EBU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)edvi(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)edvi(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'edvi')"/>edui<xsl:value-of select="substring-after(.,'edvi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EDVI(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EDVI')"/>EDUI<xsl:value-of select="substring-after(.,'EDVI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ei(et|o)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)ei(et|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ei')"/>ej<xsl:value-of select="substring-after(.,'ei')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EI(ET|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EI')"/>EJ<xsl:value-of select="substring-after(.,'EI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)es?ua(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(e|E)s?ua(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ua')"/>va<xsl:value-of select="substring-after(.,'ua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ES?UA(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UA')"/>VA<xsl:value-of select="substring-after(.,'UA')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)eru(a|e|é|o|i|y)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)eru(a|e|é|o|i|y)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eru')"/>erv<xsl:value-of select="substring-after(.,'eru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)ERU(A|E|É|O|I|Y)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ERU')"/>ERV<xsl:value-of select="substring-after(.,'ERU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^eue$', 'i')">
   <xsl:if test="matches(.,'^Eue$')"><reg>Eve</reg></xsl:if>
   <xsl:if test="matches(.,'^EUE$')"><reg>EVE</reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)epu(o|e|a)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)epu(o|e|a)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'epu')"/>epv<xsl:value-of select="substring-after(.,'epu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)EPU(O|E|A)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EPU')"/>EPV<xsl:value-of select="substring-after(.,'EPU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)ipu(o|e|a)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)ipu(o|e|a)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ipu')"/>ipv<xsl:value-of select="substring-after(.,'ipu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)IPU(O|E|A)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'IPU')"/>IPV<xsl:value-of select="substring-after(.,'IPU')"/></reg></xsl:if>
            </xsl:when>           
           <!--reuiu reuiue-->
<xsl:when test="matches(.,'^reuiu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(r|R)euiu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'euiu')"/>eviv<xsl:value-of select="substring-after(.,'euiu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^REUIU(\w*)$')">
      <reg>REVIV<xsl:value-of select="substring-after(.,'REUIU')"/></reg></xsl:if>
           </xsl:when>               
<xsl:when test="matches(.,'^(\w*)eui[^l](\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(e|E)ui[^l](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ui')"/>vi<xsl:value-of select="substring-after(.,'ui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EUI[^L](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EUI')"/>EVI<xsl:value-of select="substring-after(.,'EUI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^preuil(\w*)$')">
   <xsl:if test="matches(.,'^(p|P)reuil(\w*)$')">
      <reg>previl<xsl:value-of select="substring-after(.,'preuil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PREUIL(\w*)$')">
      <reg>PREVIL<xsl:value-of select="substring-after(.,'PREUIL')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^eue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(e|E)ue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ue')"/>ve<xsl:value-of select="substring-after(.,'ue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^EUE(\w*)$')">
      <reg>EVE<xsl:value-of select="substring-after(.,'EUE')"/></reg></xsl:if>
            </xsl:when>
           <!--eueu lueu-->
<xsl:when test="matches(.,'^(\w+)(e|l)ueu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)(e|E|l|L)ueu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ueu')"/>veu<xsl:value-of select="substring-after(.,'ueu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)(E|L)UEU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UEU')"/>VEU<xsl:value-of select="substring-after(.,'UEU')"/></reg></xsl:if>
           </xsl:when>
<xsl:when test="matches(.,'^(\w*)[^d]euem(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)[^d|D]uem(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uem')"/>vem<xsl:value-of select="substring-after(.,'uem')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)[^D]UEM(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UEM')"/>VEM<xsl:value-of select="substring-after(.,'UEM')"/></reg></xsl:if>
           </xsl:when>
<!--acheue acheué soubleué, pas descheue -->
<xsl:when test="matches(.,'^(\w*)(ach|bl)eu(e|é)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)((a|A)ch|bl)eu(e|é)$')">
      <reg><xsl:value-of select="substring-before(.,'eu')"/>ev<xsl:value-of select="substring-after(.,'eu')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)(ACH|BL)EU(E|É)$')">
      <reg><xsl:value-of select="substring-before(.,'EU')"/>EV<xsl:value-of select="substring-after(.,'EU')"/></reg></xsl:if>
           </xsl:when>           
<xsl:when test="matches(.,'^(\w*)(e|é)s?uo(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(e|E|é|É)s?uo(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uo')"/>vo<xsl:value-of select="substring-after(.,'uo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(E|É)S?UO(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UO')"/>VO<xsl:value-of select="substring-after(.,'UO')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^enuers$', 'i')">
   <xsl:if test="matches(.,'^(e|E)nuers$')">
      <reg><xsl:value-of select="substring-before(.,'nuers')"/>nvers<xsl:value-of select="substring-after(.,'nuers')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ENUERS$')">
      <reg>ENVERS</reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)eniam(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(e|E)niam(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'niam')"/>njam<xsl:value-of select="substring-after(.,'niam')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ENIAM(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ENIAM')"/>ENJAM<xsl:value-of select="substring-after(.,'ENIAM')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)(e|r)uiur(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)(e|r)uiur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'euiur')"/>evivr<xsl:value-of select="substring-after(.,'euiur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)(E|R)UIUR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UIUR')"/>VIVR<xsl:value-of select="substring-after(.,'UIUR')"/></reg></xsl:if>
            </xsl:when>
           <!--renu alenu bienu-->
<xsl:when test="matches(.,'^(r|al|bi)?enu(ie|ir|y|o|e)(\w*)$', 'i')">
    <xsl:if test="matches(.,'^(Al|al|R|r|bi|Bi)?(e|E)nu(ie|ir|y|o|e)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nu')"/>nv<xsl:value-of select="substring-after(.,'nu')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(R|AL|BI)?ENU(IE|IR|Y|O|E)(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'ENU')"/>ENV<xsl:value-of select="substring-after(.,'ENU')"/></reg></xsl:if>
           </xsl:when>
<xsl:when test="matches(.,'^(e|co)nioi(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(e|E|co|CO)nioi(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nioi')"/>njoi<xsl:value-of select="substring-after(.,'nioi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(E|CO)NIOI(\w*)$')">
       <reg><xsl:value-of select="substring-after(.,'NIOI')"/>NJOI<xsl:value-of select="substring-after(.,'NIOI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^enuelo(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(e|E)nuelo(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nuelo')"/>nvelo<xsl:value-of select="substring-after(.,'nuelo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ENUEL(\w*)$')">
      <reg>ENVEL<xsl:value-of select="substring-after(.,'ENUEL')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)euei(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(e|E)uei(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uei')"/>vei<xsl:value-of select="substring-after(.,'uei')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EUEI(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EUEI')"/>EVEI<xsl:value-of select="substring-after(.,'EUEI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)eue(e|l|n|r|z|st|t)(\w*)$', 'i')">
    <xsl:if test="matches(.,'^(\w*)(e|E)ue(e|l|n|r|z|st|t)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ue')"/>ve<xsl:value-of select="substring-after(.,'ue')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)EUE(E|L|N|R|Z|ST|T)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EUE')"/>EVE<xsl:value-of select="substring-after(.,'EUE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)esue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(e|E)sue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'sue')"/>sve<xsl:value-of select="substring-after(.,'sue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ESUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ESUE')"/>ESVE<xsl:value-of select="substring-after(.,'ESUE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)euesq(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(e|E)uesq(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uesq')"/>vesq<xsl:value-of select="substring-after(.,'uesq')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)EUESQ(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'EUESQ')"/>EVESQ<xsl:value-of select="substring-after(.,'EUESQ')"/></reg></xsl:if>
            </xsl:when>
            <!--pour evnvque => eunuque-->
<xsl:when test="matches(.,'^evnv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(e|E)vnv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vnv')"/>unu<xsl:value-of select="substring-after(.,'vnv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^EVNV(\w*)$')">
      <reg>EUNU<xsl:value-of select="substring-after(.,'EVNV')"/></reg></xsl:if>
            </xsl:when>

<!--F-->
<xsl:when test="matches(.,'^fautevil(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(f|F)autevil(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'autevil')"/>auteuil<xsl:value-of select="substring-after(.,'autevil')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FAUTEVIL(\w*)$')">
      <reg>FAUTEUIL<xsl:value-of select="substring-after(.,'FAUTEVIL')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^fev$', 'i')">
   <xsl:if test="matches(.,'^(f|F)ev$')">
      <reg><xsl:value-of select="substring-before(.,'ev')"/>eu<xsl:value-of select="substring-after(.,'ev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FEV$')">
      <reg>FEU</reg></xsl:if>
            </xsl:when>              
<xsl:when test="matches(.,'^feville(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(f|F)eville(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eville')"/>euille<xsl:value-of select="substring-after(.,'eville')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FEVILLE(\w*)$')">
      <reg>FEUILLE<xsl:value-of select="substring-after(.,'FEVILLE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^fi(e|é)ure(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(f|F)i(e|é)ure(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ure')"/>vre<xsl:value-of select="substring-after(.,'ure')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FI(E|É)URE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'URE')"/>VRE<xsl:value-of select="substring-after(.,'URE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^flevr(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(f|F)levr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'levr')"/>leur<xsl:value-of select="substring-after(.,'levr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FLEVR(\w*)$')">
      <reg>FLEUR<xsl:value-of select="substring-after(.,'FLEVR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^foruo(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(f|F)oruo(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'oruo')"/>orvo<xsl:value-of select="substring-after(.,'oruo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^FORUO(\w+)$')">
      <reg>FORVO<xsl:value-of select="substring-after(.,'FORUO')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^fvt$', 'i')">
   <xsl:if test="matches(.,'^(f|F)vt$')">
      <reg><xsl:value-of select="substring-before(.,'vt')"/>ut</reg></xsl:if>
   <xsl:if test="matches(.,'^FVT$')">
      <reg>FUT</reg></xsl:if>
            </xsl:when>

<!--G-->
<xsl:when test="matches(.,'^(\w*)graue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(g|G)raue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'raue')"/>rave<xsl:value-of select="substring-after(.,'raue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)GRAUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'GRAUE')"/>GRAVE<xsl:value-of select="substring-after(.,'GRAUE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)gnevr(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)gnevr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'gnevr')"/>gneur<xsl:value-of select="substring-after(.,'gnevr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)GNEVR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'GNEVR')"/>GNEUR<xsl:value-of select="substring-after(.,'GNEVR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)gv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)gv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'gv')"/>gu<xsl:value-of select="substring-after(.,'gv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Gv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Gv')"/>Gu<xsl:value-of select="substring-after(.,'Gv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)GV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'GV')"/>GU<xsl:value-of select="substring-after(.,'GV')"/></reg></xsl:if>
            </xsl:when>

<!--H-->

<xsl:when test="matches(.,'^hvm(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(h|H)vm(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vm')"/>um<xsl:value-of select="substring-after(.,'vm')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)HVM(\w*)$')">
      <reg>HUM<xsl:value-of select="substring-after(.,'HVM')"/></reg></xsl:if>
            </xsl:when>
            

<!--I-->

<!--I qui devient J debut de mot-->
<!-- i devenant j-->
<xsl:when test="matches(.,'^IE$')">
      <reg>JE</reg>
            </xsl:when>
<xsl:when test="matches(.,'^Ie$')">
      <reg>Je</reg>
            </xsl:when>
<xsl:when test="matches(.,'^ie$')">
      <reg>je</reg>
            </xsl:when>
<xsl:when test="matches(.,'^ia(\w*)$', 'i')">
   <xsl:if test="matches(.,'^ia(\w*)$')">
      <reg>ja<xsl:value-of select="substring-after(.,'ia')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Ia(\w*)$')">
      <reg>Ja<xsl:value-of select="substring-after(.,'Ia')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)IA(\w*)$')">
      <reg>JA<xsl:value-of select="substring-after(.,'IA')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^iehan(\w*)$', 'i')">
   <xsl:if test="matches(.,'^iehan(\w*)$')">
      <reg>jehan<xsl:value-of select="substring-after(.,'iehan')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iehan(\w*)$')">
      <reg>Jehan<xsl:value-of select="substring-after(.,'Iehan')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IEHAN(\w*)$')">
      <reg>JEHAN<xsl:value-of select="substring-after(.,'IEHAN')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^iesu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^iesu(\w*)$')">
      <reg>jesu<xsl:value-of select="substring-after(.,'iesu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iesu(\w*)$')">
      <reg>Jesu<xsl:value-of select="substring-after(.,'Iesu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IESU(\w*)$')">
      <reg>JESU<xsl:value-of select="substring-after(.,'IESU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^iett(\w*)$', 'i')">
   <xsl:if test="matches(.,'^iett(\w*)$')">
      <reg>jett<xsl:value-of select="substring-after(.,'iett')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iett(\w*)$')">
      <reg>Jett<xsl:value-of select="substring-after(.,'Iett')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IETT(\w*)$')">
      <reg>JETT<xsl:value-of select="substring-after(.,'IETT')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ieun(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)ieun(\w*)$')">
      <reg>jeun<xsl:value-of select="substring-after(.,'ieun')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Ieun(\w*)$')">
      <reg>Jeun<xsl:value-of select="substring-after(.,'Ieun')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)IEUN(\w*)$')">
      <reg>JEUN<xsl:value-of select="substring-after(.,'IEUN')"/></reg></xsl:if>
            </xsl:when>  
<xsl:when test="matches(.,'^ieux?$', 'i')">
   <xsl:if test="matches(.,'^ieux?$')">
      <reg>jeu<xsl:value-of select="substring-after(.,'ieu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ieux?$')">
      <reg>Jeu<xsl:value-of select="substring-after(.,'Ieu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IEUX?$')">
      <reg>JEU<xsl:value-of select="substring-after(.,'IEU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^ievx?$', 'i')">
   <xsl:if test="matches(.,'^ievx?$')">
      <reg>jeu<xsl:value-of select="substring-after(.,'iev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ievx?$')">
      <reg>Jeu<xsl:value-of select="substring-after(.,'Iev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IEVX?$')">
      <reg>JEU<xsl:value-of select="substring-after(.,'IEV')"/></reg></xsl:if>
            </xsl:when>
            <!--iouial jouial-->
<xsl:when test="matches(.,'^(i|j)ouial(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(i|j)ouial(\w*)$')">
     <reg>jovial<xsl:value-of select="substring-after(.,'ouial')"/></reg></xsl:if> 
    <xsl:if test="matches(.,'^(I|J)ouial(\w*)$')">
        <reg>Jovial<xsl:value-of select="substring-after(.,'ouial')"/></reg></xsl:if>    
   <xsl:if test="matches(.,'^(I|J)OUIAL(\w*)$')">
     <reg>JOVIAL<xsl:value-of select="substring-after(.,'IOUIAL')"/></reg></xsl:if>
            </xsl:when>              
<xsl:when test="matches(.,'^io[^n](\w*)$', 'i')">
   <xsl:if test="matches(.,'^io[^n](\w*)$')">
      <reg>jo<xsl:value-of select="substring-after(.,'io')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Io[^n](\w*)$')">
      <reg>Jo<xsl:value-of select="substring-after(.,'Io')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IO[^N](\w*)$')">
      <reg>JO<xsl:value-of select="substring-after(.,'IO')"/></reg></xsl:if>
            </xsl:when>
<!--ionc ionche iong-->
<xsl:when test="matches(.,'^ion(c|g)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^ion(c|g)(\w*)$')">
      <reg>jon<xsl:value-of select="substring-after(.,'ion')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ion(c|g)(\w*)$')">
      <reg>Jon<xsl:value-of select="substring-after(.,'Ion')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^ION(C|G)(\w*)$')">
      <reg>JON<xsl:value-of select="substring-after(.,'ION')"/></reg></xsl:if>
            </xsl:when>            
<xsl:when test="matches(.,'^iurog(\w*)$', 'i')">
   <xsl:if test="matches(.,'^iurog(\w*)$')">
      <reg>ivrog<xsl:value-of select="substring-after(.,'iurog')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iurog(\w*)$')">
      <reg>Ivrog<xsl:value-of select="substring-after(.,'Iurog')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IUROG(\w*)$')">
      <reg>IVROG<xsl:value-of select="substring-after(.,'IUROG')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^iu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^iu(\w*)$')">
      <reg>ju<xsl:value-of select="substring-after(.,'iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iu(\w*)$')">
      <reg>Ju<xsl:value-of select="substring-after(.,'Iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IU(\w*)$')">
      <reg>JU<xsl:value-of select="substring-after(.,'IU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^innoü(\w*)$')">
      <reg>innov<xsl:value-of select="substring-after(.,'innoü')"/></reg>
            </xsl:when>      
<xsl:when test="matches(.,'^uifue(\w+)$', 'i')">
    <xsl:if test="matches(.,'^uifue(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'uifue')"/>vifve<xsl:value-of select="substring-after(.,'uifue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Uifue(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'Uifue')"/>Vifve<xsl:value-of select="substring-after(.,'Uifue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UIFUE(\w+)$')">
       <reg>VIFVE<xsl:value-of select="substring-after(.,'UIUFE')"/></reg></xsl:if>
           </xsl:when>         
<xsl:when test="matches(.,'^uiur(\w+)$', 'i')">
   <xsl:if test="matches(.,'^uiur(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'uiur')"/>vivr<xsl:value-of select="substring-after(.,'uiur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Uiur(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'Uiur')"/>Vivr<xsl:value-of select="substring-after(.,'Uiur')"/></reg></xsl:if>                 
   <xsl:if test="matches(.,'^UIUR(\w+)$')">
      <reg>VIVR<xsl:value-of select="substring-after(.,'UIUR')"/></reg></xsl:if>
           </xsl:when>            
<xsl:when test="matches(.,'^(\w+)(i|ï|e)u?fue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)(i|ï|e)u?fue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'fue')"/>fve<xsl:value-of select="substring-after(.,'fue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)(I|Ï|E)U?FUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'FUE')"/>FVE<xsl:value-of select="substring-after(.,'FUE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^inconu(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(i|I)nconu(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'nconu')"/>nconv<xsl:value-of select="substring-after(.,'nconu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^INCONU(\w+)$')">
      <reg>INCONV<xsl:value-of select="substring-after(.,'INCONU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^iniu(r|s)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(i|I)niu(r|s)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'niu')"/>nju<xsl:value-of select="substring-after(.,'niu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^INIUR(R|S)(\w*)$')">
      <reg>INJU<xsl:value-of select="substring-after(.,'INIU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^iniv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(i|I)niv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'niv')"/>nju<xsl:value-of select="substring-after(.,'niv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^INIV(\w*)$')">
      <reg>INJU<xsl:value-of select="substring-after(.,'INIV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^iu(r|s)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^iu(r|s)(\w*)$')">
      <reg>ju<xsl:value-of select="substring-after(.,'iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iu(r|s)(\w*)$')">
      <reg>Ju<xsl:value-of select="substring-after(.,'Iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IU(R|S)(\w*)$')">
      <reg>JU<xsl:value-of select="substring-after(.,'IU')"/></reg></xsl:if>
            </xsl:when>
           <!--iuue cuue estuu-->
<xsl:when test="matches(.,'^(i|c|est)uue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(i|I|c|C|est|Est)uue(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'uue')"/>uve<xsl:value-of select="substring-after(.,'uue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(I|C|Est)UUE(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'UUE')"/>UVE<xsl:value-of select="substring-after(.,'UUE')"/></reg></xsl:if>
           </xsl:when>
<xsl:when test="matches(.,'^(tres)?inui(s|t|n|o)(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(tres|Tres)?(i|I)nui(s|t|n|o)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'nui')"/>nvi<xsl:value-of select="substring-after(.,'nui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(TRES)?INUI(S|T|N|O)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'INUI')"/>INVI<xsl:value-of select="substring-after(.,'INUI')"/></reg></xsl:if>
            </xsl:when>  
<xsl:when test="matches(.,'^(\w*)inv(s|t)i(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(i|I)nv(s|t)i(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nv')"/>nu<xsl:value-of select="substring-after(.,'nv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)INV(S|T)I(\w+)$')">
      <reg>INU<xsl:value-of select="substring-after(.,'INV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)iect(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)iect(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'iect')"/>ject<xsl:value-of select="substring-after(.,'iect')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Iect(\w*)$')">
      <reg>Ject<xsl:value-of select="substring-after(.,'Iect')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)IECT(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'IECT')"/>JECT<xsl:value-of select="substring-after(.,'IECT')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^ieusn(\w*)$', 'i')">
   <xsl:if test="matches(.,'^ieusn(\w*)$')">
      <reg>jeusn<xsl:value-of select="substring-after(.,'ieusn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ieusn(\w*)$')">
      <reg>Jeusn<xsl:value-of select="substring-after(.,'Ieusn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)IEUSN(\w*)$')">
      <reg>JEUSN<xsl:value-of select="substring-after(.,'IEUSN')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^inue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^inue(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'nue')"/>nve<xsl:value-of select="substring-after(.,'nue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^INUE(\w*)$')">
     <reg><xsl:value-of select="substring-before(.,'NUE')"/>NVE<xsl:value-of select="substring-after(.,'NUE')"/></reg></xsl:if>
           </xsl:when>
<xsl:when test="matches(.,'^ivnon?$', 'i')">
   <xsl:if test="matches(.,'^ivnon?$')">
      <reg>juno<xsl:value-of select="substring-after(.,'ivno')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ivnon?$')">
      <reg>Juno<xsl:value-of select="substring-after(.,'Ivno')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^IVNON?$')">
      <reg>JUNO<xsl:value-of select="substring-after(.,'IVNO')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)iu(e|i|o|a|é|y|ÿ)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)iu(e|i|o|a|é|y|ÿ)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'iu')"/>iv<xsl:value-of select="substring-after(.,'iu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)IU(E|I|O|A|É|Y|Ÿ)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'IU')"/>IV<xsl:value-of select="substring-after(.,'IU')"/></reg></xsl:if>
            </xsl:when>

<!--J-->
<xsl:when test="matches(.,'^janui(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(j|J)anui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'anui')"/>anvi<xsl:value-of select="substring-after(.,'anui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^JANUI(\w*)$')">
      <reg>JANVI<xsl:value-of select="substring-after(.,'JANUI')"/></reg></xsl:if>
            </xsl:when>

<!--L-->
<xsl:when test="matches(.,'^(\w*)[^b]leu(e|è|rau)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)[^b]leu(e|è|rau)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'leu')"/>lev<xsl:value-of select="substring-after(.,'leu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)[^b]LEU(E|È|RAU)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'LEU')"/>LEV<xsl:value-of select="substring-after(.,'LEU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^leu(e|è|é|rau)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^leu(e|è|é|rau)(\w*)$')">
      <reg>lev<xsl:value-of select="substring-after(.,'leu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Leu(e|è|é|rau)(\w*)$')">
      <reg>Lev<xsl:value-of select="substring-after(.,'Leu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^LEU(E|È|É|RAU)(\w*)$')">
      <reg>LEV<xsl:value-of select="substring-after(.,'LEU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^liéu(e|è|é|rau)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^liéu(e|è|é|rau)(\w*)$')">
      <reg>liév<xsl:value-of select="substring-after(.,'liéu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Liéu(e|è|é|rau)(\w*)$')">
      <reg>Liév<xsl:value-of select="substring-after(.,'Liéu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^LIÉU(E|È|É|RAU)(\w*)$')">
      <reg>LIÉV<xsl:value-of select="substring-after(.,'LIÉU')"/></reg></xsl:if>
            </xsl:when>     
            <!--lieure lieuè lieué lieurau-->
<xsl:when test="matches(.,'^lieu(re|è|é|rau)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^lieu(re|è|é|rau)(\w*)$')">
     <reg>liev<xsl:value-of select="substring-after(.,'lieu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Lieu(re|è|é|rau)(\w*)$')">
     <reg>Liev<xsl:value-of select="substring-after(.,'Lieu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^LIEU(RE|È|É|RAU)(\w*)$')">
     <reg>LIEV<xsl:value-of select="substring-after(.,'LIEU')"/></reg></xsl:if>
            </xsl:when>             
            <!--leure lèure-->
<xsl:when test="matches(.,'^l(e|è)ure(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(l|L)(e|è)ure(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ure')"/>vre<xsl:value-of select="substring-after(.,'ure')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^L(È|E)URE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'URE')"/>VRE<xsl:value-of select="substring-after(.,'URE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^levrs?$', 'i')">
   <xsl:if test="matches(.,'^(l|L)evrs?$')">
      <reg><xsl:value-of select="substring-before(.,'evr')"/>eur<xsl:value-of select="substring-after(.,'evr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^LEVRS?$')">
      <reg>LEUR<xsl:value-of select="substring-after(.,'LEVR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)liur(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(l|L)iur(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'iur')"/>ivr<xsl:value-of select="substring-after(.,'iur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)LIUR(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'LIUR')"/>LIVR<xsl:value-of select="substring-after(.,'LIUR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^oliu(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(o|O)liu(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'liu')"/>liv<xsl:value-of select="substring-after(.,'liu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^OLIU(\w+)$')">
      <reg>OLIV<xsl:value-of select="substring-after(.,'OLIU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^oual(\w*)$', 'i')">
   <xsl:if test="matches(.,'^oual(\w*)$')">
      <reg>oval<xsl:value-of select="substring-after(.,'oual')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^OUAL(\w*)$')">
      <reg>OVAL<xsl:value-of select="substring-after(.,'OUAL')"/></reg></xsl:if>
            </xsl:when>               
<xsl:when test="matches(.,'^(l|pr)ova(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(l|L|pr|PR)ova(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ova')"/>oua<xsl:value-of select="substring-after(.,'ova')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(L|PR)OVA(\w*)$')">
      <reg>LOUA<xsl:value-of select="substring-after(.,'LOVA')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)lvs(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)lvs(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'lvs')"/>lus<xsl:value-of select="substring-after(.,'lvs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)LVS(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'LVS')"/>LUS<xsl:value-of select="substring-after(.,'LVS')"/></reg></xsl:if>
            </xsl:when>
<!--M-->
<xsl:when test="matches(.,'^maie(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(m|M)aie(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aie')"/>aje<xsl:value-of select="substring-after(.,'aie')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^MAIE(\w*)$')">
      <reg>MAJE<xsl:value-of select="substring-after(.,'MAIE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)minv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(m|M)inv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'inv')"/>inu<xsl:value-of select="substring-after(.,'inv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)MINV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MINV')"/>MINU<xsl:value-of select="substring-after(.,'MINV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)meruei(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(m|M)eruei(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eruei')"/>ervei<xsl:value-of select="substring-after(.,'eruei')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)MERUEI(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MERUEI')"/>MERVEI<xsl:value-of select="substring-after(.,'MERUEI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)mvn(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(m|M)vn(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vn')"/>un<xsl:value-of select="substring-after(.,'vn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)MVN(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MVN')"/>MUN<xsl:value-of select="substring-after(.,'MVN')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)mvr(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(m|M)vr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vr')"/>ur<xsl:value-of select="substring-after(.,'vr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)MVR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MVR')"/>MUR<xsl:value-of select="substring-after(.,'MVR')"/></reg></xsl:if>
            </xsl:when>               

<!--N-->
<xsl:when test="matches(.,'^naur(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(n|N)aur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aur')"/>avr<xsl:value-of select="substring-after(.,'aur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^NAUR(\w*)$')">
      <reg>NAVR<xsl:value-of select="substring-after(.,'NAUR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)nevf(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(n|N)evf(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'evf')"/>euf<xsl:value-of select="substring-after(.,'evf')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)NEVF(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NEVF')"/>NEUF<xsl:value-of select="substring-after(.,'NEVF')"/></reg></xsl:if>
            </xsl:when>            
<xsl:when test="matches(.,'^nouic(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(n|N)ouic(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ouic')"/>ovic<xsl:value-of select="substring-after(.,'ouic')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^NOUIC(\w*)$')">
      <reg>NOVIC<xsl:value-of select="substring-after(.,'NOUIC')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)[^e]nvel(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)[^e]nvel(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nvel')"/>nuel<xsl:value-of select="substring-after(.,'nvel')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)[^E]NVEL(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NVEL')"/>NUEL<xsl:value-of select="substring-after(.,'NVEL')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)niur(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)niur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'niur')"/>njur<xsl:value-of select="substring-after(.,'niur')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)NIUR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NIUR')"/>NJUR<xsl:value-of select="substring-after(.,'NIUR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^nouembre$', 'i')">
   <xsl:if test="matches(.,'^(n|N)ouembre$')">
      <reg><xsl:value-of select="substring-before(.,'ouembre')"/>ovembre</reg></xsl:if>
   <xsl:if test="matches(.,'^NOUEMBRE$')">
      <reg>NOVEMBRE</reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)nua(sion|in)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)nua(sion|in)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'nua')"/>nva<xsl:value-of select="substring-after(.,'nua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)NUA(SION|IN)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NUA')"/>NVA<xsl:value-of select="substring-after(.,'NUA')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^nvag(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(n|N)vag(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vag')"/>uag<xsl:value-of select="substring-after(.,'vag')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^NVAG(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'NUA')"/>NUAG<xsl:value-of select="substring-after(.,'NVAG')"/></reg></xsl:if>
            </xsl:when>

<!--O-->
<xsl:when test="matches(.,'^obui(\w*)$', 'i')">
    <xsl:if test="matches(.,'^(o|O)bui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'bui')"/>bvi<xsl:value-of select="substring-after(.,'bui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^OBUI(\w*)$')">
      <reg>OBVI<xsl:value-of select="substring-after(.,'OBUI')"/></reg></xsl:if>
           </xsl:when>
<xsl:when test="matches(.,'^(\w+)oiu(e|r)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)oiu(e|r)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'oiu')"/>oiv<xsl:value-of select="substring-after(.,'oiu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)OIU(E|R)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OIU')"/>OIV<xsl:value-of select="substring-after(.,'OIU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)oibue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)oibue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'oibue')"/>oibve<xsl:value-of select="substring-after(.,'oibue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)OIBUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OIBUE')"/>OIBVE<xsl:value-of select="substring-after(.,'OIBUE')"/></reg></xsl:if>
            </xsl:when>            
<xsl:when test="matches(.,'^(\w+)ouveve(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)ouveve(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ouveve')"/>ouveue<xsl:value-of select="substring-after(.,'ouveve')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)OUVEVE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OUVEVE')"/>OUVEUE<xsl:value-of select="substring-after(.,'OUVEVE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^covar(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(c|C)ovar(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovar')"/>ouar<xsl:value-of select="substring-after(.,'ovar')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^COVAR(\w*)$')">
      <reg>COUAR<xsl:value-of select="substring-after(.,'COVAR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ouu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)ouu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ouu')"/>ouv<xsl:value-of select="substring-after(.,'ouu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ouu(\w*)$')">
      <reg>Ouv<xsl:value-of select="substring-after(.,'Ouu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)OUU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OUU')"/>OUV<xsl:value-of select="substring-after(.,'OUU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)ovf(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)ovf(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovf')"/>ouf<xsl:value-of select="substring-after(.,'ovf')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Ovf(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Ovf')"/>Ouf<xsl:value-of select="substring-after(.,'Ovf')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)OVF(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OVF')"/>OUF<xsl:value-of select="substring-after(.,'OVF')"/></reg></xsl:if>
            </xsl:when>    
<xsl:when test="matches(.,'^(\w*)ovz(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)ovz(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovz')"/>ouz<xsl:value-of select="substring-after(.,'ovz')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ovz(\w*)$')">
      <reg>Ouz<xsl:value-of select="substring-after(.,'Ovs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)OVZ(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'OVZ')"/>OUZ<xsl:value-of select="substring-after(.,'OVZ')"/></reg></xsl:if>
           </xsl:when> 

<!--P-->
            <!--periu pariu-->
<xsl:when test="matches(.,'^p(a|e)riu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(p|P)(a|e)riu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'riu')"/>rju<xsl:value-of select="substring-after(.,'riu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^P(A|E)RIU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'RIU')"/>RJU<xsl:value-of select="substring-after(.,'RIU')"/></reg></xsl:if>
            </xsl:when>
            <!--paruen paruin-->
<xsl:when test="matches(.,'^paru(e|i)n(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(p|P)aru(e|i)n(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'aru')"/>arv<xsl:value-of select="substring-after(.,'aru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PARU(E|I)N(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'PARU')"/>PARV<xsl:value-of select="substring-after(.,'PARU')"/></reg></xsl:if>
            </xsl:when>            
<xsl:when test="matches(.,'^pjece(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(p|P)jece(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'jece')"/>iece<xsl:value-of select="substring-after(.,'jece')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PJECE(\w*)$')">
      <reg>PIECE<xsl:value-of select="substring-after(.,'PJECE')"/></reg></xsl:if>
            </xsl:when>
            <!--poure paoure poureté. Ne s'applique pas sur poureuse (= peureuse) -->
<xsl:when test="matches(.,'^(\w*)pa?oure(s|t\w*)?$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(p|P)a?oure(s|t\w*)?$')">
      <reg><xsl:value-of select="substring-before(.,'oure')"/>ovre<xsl:value-of select="substring-after(.,'oure')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)PA?OURE(s|t\w*)?$')">
      <reg><xsl:value-of select="substring-before(.,'OURE')"/>OVRE<xsl:value-of select="substring-after(.,'OURE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^pouo(\w*)?$', 'i')">
   <xsl:if test="matches(.,'^(p|P)ouo(\w*)?$')">
       <reg><xsl:value-of select="substring-before(.,'ouo')"/>ovo<xsl:value-of select="substring-after(.,'ouo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^POUO(\w*)?$')">
      <reg>POVO<xsl:value-of select="substring-after(.,'POUO')"/></reg></xsl:if>
            </xsl:when>             
<xsl:when test="matches(.,'^povr$', 'i')">
   <xsl:if test="matches(.,'^(p|P)ovr$')">
      <reg><xsl:value-of select="substring-before(.,'ovr')"/>our</reg></xsl:if>
   <xsl:if test="matches(.,'^POVR$')">
      <reg>POUR</reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^preiu(\w*)?$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(p|P)reiu(\w*)?$')">
     <reg><xsl:value-of select="substring-before(.,'reiu')"/>reju<xsl:value-of select="substring-after(.,'reiu')"/></reg></xsl:if>
  <xsl:if test="matches(.,'^(\w*)PREIU(\w*)?$')">
     <reg><xsl:value-of select="substring-before(.,'PREIU')"/>PREJU<xsl:value-of select="substring-after(.,'PREIU')"/></reg></xsl:if>
           </xsl:when>            
            <!--prev prevx-->
<xsl:when test="matches(.,'^prevx?$', 'i')">
   <xsl:if test="matches(.,'^(p|P)revx?$')">
     <reg><xsl:value-of select="substring-after(.,'rev')"/>reu<xsl:value-of select="substring-after(.,'rev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PREVX?$')">
     <reg>PREU<xsl:value-of select="substring-after(.,'PREV')"/></reg></xsl:if>
            </xsl:when>  
           <!--prouen proui prouo proueu prouer-->            
<xsl:when test="matches(.,'^prou(en|i|o|eu|er)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(p|P)rou(en|i|o|eu|er)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rou')"/>rov<xsl:value-of select="substring-after(.,'rou')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PROU(EN|I|O|EU|ER)(\w*)$')">
      <reg>PROV<xsl:value-of select="substring-after(.,'PROU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^pvb(\w+)$', 'i')">
   <xsl:if test="matches(.,'^pvb(\w+)$')">
      <reg>pub<xsl:value-of select="substring-after(.,'pvb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Pvb(\w+)$')">
      <reg>Pub<xsl:value-of select="substring-after(.,'Pvb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^PVB(\w+)$')">
      <reg>PUB<xsl:value-of select="substring-after(.,'PVB')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)mpv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)mpv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'mpv')"/>mpu<xsl:value-of select="substring-after(.,'mpv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)MPV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'MPV')"/>MPU<xsl:value-of select="substring-after(.,'MPV')"/></reg></xsl:if>
            </xsl:when>

<!--Q-->

            <!--qve qvi qvo qva-->
<xsl:when test="matches(.,'^(\w*)qv(e|i|a|o)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)qv(e|i|a|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'qv')"/>qu<xsl:value-of select="substring-after(.,'qv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Qv(e|i|a|o)(\w*)$')">
      <reg>Qu<xsl:value-of select="substring-after(.,'Qv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)QV(E|I|A|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'QV')"/>QU<xsl:value-of select="substring-after(.,'QV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^queve(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(q|Q)ueve(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ueve')"/>ueue<xsl:value-of select="substring-after(.,'ueve')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^QUEVE(\w*)$')">  
      <reg>QUEUE<xsl:value-of select="substring-after(.,'QUEVE')"/></reg></xsl:if>
            </xsl:when>

<!--R-->
<xsl:when test="matches(.,'^(\w+)radv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)radv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'radv')"/>radu<xsl:value-of select="substring-after(.,'radv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)RADV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'RADV')"/>RADU<xsl:value-of select="substring-after(.,'RADV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)rajon(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(r|R)ajon(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ajon')"/>aion<xsl:value-of select="substring-after(.,'ajon')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)RAJON(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'RAJON')"/>RAION<xsl:value-of select="substring-after(.,'RAJON')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^recev$', 'i')">
   <xsl:if test="matches(.,'^(r|R)ecev$')">
      <reg><xsl:value-of select="substring-before(.,'ecev')"/>eceu<xsl:value-of select="substring-after(.,'ecev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^RECEV$')">
      <reg>RECEU<xsl:value-of select="substring-after(.,'RECEV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)reie(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(r|R)eie(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eie')"/>eje<xsl:value-of select="substring-after(.,'eie')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)REIE(\w*)$')">
      <reg>REJE<xsl:value-of select="substring-after(.,'REIE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^reu(e|u)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(r|R)eu(e|u)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eu')"/>ev<xsl:value-of select="substring-after(.,'eu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^REU(E|U)(\w*)$')">
      <reg>REV<xsl:value-of select="substring-after(.,'REU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^renuer(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(r|R)enuer(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'enuer')"/>enver<xsl:value-of select="substring-after(.,'enuer')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^RENUER(\+)$')">
      <reg>RENVER<xsl:value-of select="substring-after(.,'RENUER')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^réue(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(r|R)éue(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'éue')"/>éve<xsl:value-of select="substring-after(.,'éue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^RÉUE(\+)$')">
      <reg>RÉVE<xsl:value-of select="substring-after(.,'RÉUE')"/></reg></xsl:if>
            </xsl:when>
           <!--esiouy tresioyeux-->
<xsl:when test="matches(.,'^t?r?esio(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(t|T)?(r|R)?(e|E)sio(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'sio')"/>sjo<xsl:value-of select="substring-after(.,'sio')"/></reg></xsl:if>
  <xsl:if test="matches(.,'^T?R?ESIO(\w+)$')">
     <reg><xsl:value-of select="substring-before(.,'ESIO')"/>ESJO<xsl:value-of select="substring-after(.,'ESIO')"/></reg></xsl:if>
           </xsl:when>
           

<!--S-->
<xsl:when test="matches(.,'^(\w*)(sa|p)ulu(e|o|a|é)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(sa|p|Sa|P)ulu(e|o|a|é)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ulu')"/>ulv<xsl:value-of select="substring-after(.,'ulu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(SA|P)ULU(E|O|A|É)(\*w)$')">
      <reg><xsl:value-of select="substring-before(.,'ULU')"/>ULV<xsl:value-of select="substring-after(.,'ULU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)ssevr(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)ssevr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ssevr')"/>sseur<xsl:value-of select="substring-after(.,'ssevr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)SSEVR(\*w)$')">
      <reg>SSEUR<xsl:value-of select="substring-after(.,'SSEVR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)seru(i|o)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(s|S)eru(i|o)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'eru')"/>erv<xsl:value-of select="substring-after(.,'eru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)SERU(I|O)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'SERU')"/>SERV<xsl:value-of select="substring-after(.,'SERU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^sjec(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(s|S)jec(\w+)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'jec')"/>iec<xsl:value-of select="substring-after(.,'jec')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^SJEC(\w+)$')">
      <reg>SIEC<xsl:value-of select="substring-after(.,'SJEC')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)solua(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(s|S)olua(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'olua')"/>olva<xsl:value-of select="substring-after(.,'olua')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)SOLUA(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'SOLUA')"/>SOLVA<xsl:value-of select="substring-after(.,'SOLUA')"/></reg></xsl:if>
           </xsl:when>           
<xsl:when test="matches(.,'^(as)?subi(e|u)(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(as|As)?(s|S)ubi(e|u)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'ubi')"/>ubj<xsl:value-of select="substring-after(.,'ubi')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(AS)?SUBI(E|U)(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'SUBI')"/>SUBJ<xsl:value-of select="substring-after(.,'SUBI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)suiet(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(s|S)uiet(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiet')"/>ujet<xsl:value-of select="substring-after(.,'uiet')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^SUIET(\w*)$')">
      <reg>SUJET<xsl:value-of select="substring-after(.,'SUIET')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^suru(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(s|S)uru(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uru')"/>urv<xsl:value-of select="substring-after(.,'uru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^SURU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'SURU')"/>SURV<xsl:value-of select="substring-after(.,'SURU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)suiu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(s|S)uiu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uiu')"/>uivr<xsl:value-of select="substring-after(.,'uiu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)SUIU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'SUIU')"/>SUIV<xsl:value-of select="substring-after(.,'SUIU')"/></reg></xsl:if>
            </xsl:when>


<!--T-->
<xsl:when test="matches(.,'^tous?iours$', 'i')">
   <xsl:if test="matches(.,'^(t|T)ous?iours$')">
      <reg><xsl:value-of select="substring-before(.,'iours')"/>jours</reg></xsl:if>
   <xsl:if test="matches(.,'^TOUS?IOURS$')">
      <reg><xsl:value-of select="substring-before(.,'IOURS')"/>JOURS</reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)tovr(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(t|T)ovr(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ovr')"/>our<xsl:value-of select="substring-after(.,'ovr')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)TOVR(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TOVR')"/>TOUR<xsl:value-of select="substring-after(.,'TOVR')"/></reg></xsl:if>
            </xsl:when>            
<xsl:when test="matches(.,'^tovs$', 'i')">
   <xsl:if test="matches(.,'^(t|T)ovs$')">
      <reg><xsl:value-of select="substring-before(.,'ovs')"/>ous</reg></xsl:if>
   <xsl:if test="matches(.,'^TOVS$')">
      <reg>TOUS</reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^tresiust(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(t|T)resiust(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'resiust')"/>resjust<xsl:value-of select="substring-after(.,'resiust')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^TRESIUST(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TRESIUST')"/>TRESJUST<xsl:value-of select="substring-after(.,'TRESIUST')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^tresui(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(t|T)resui(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'resui')"/>resvi<xsl:value-of select="substring-after(.,'resui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^TRESUI(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TRESUI')"/>TRESVI<xsl:value-of select="substring-after(.,'TRESUI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)trv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(T|t)rv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rv')"/>ru<xsl:value-of select="substring-after(.,'rv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)TRV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TRV')"/>TRU<xsl:value-of select="substring-after(.,'TRV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)trouer(s|e)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(t|T)rouer(s|e)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'rouer')"/>rover<xsl:value-of select="substring-after(.,'rouer')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)TROUER(S|E)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TROUER')"/>TROVER<xsl:value-of select="substring-after(.,'TROUER')"/></reg></xsl:if>
            </xsl:when>
            <!--treue greue preue-->
<xsl:when test="matches(.,'^(g|t|p)reue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(t|T|g|G|p|P)reue(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'reue')"/>reve<xsl:value-of select="substring-after(.,'reue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(T|G|P)REUE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'REUE')"/>REVE<xsl:value-of select="substring-after(.,'REUE')"/></reg></xsl:if>
            </xsl:when>
            <!--petv entv titv ectv-->
<xsl:when test="matches(.,'^(\w*)(pe|en|ti|c)tv(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(pe|Pe|en|En|ti|Ti|c)tv(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'tv')"/>tu<xsl:value-of select="substring-after(.,'tv')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(PE|EN|TI|C)TV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'TV')"/>TU<xsl:value-of select="substring-after(.,'TV')"/></reg></xsl:if>
            </xsl:when>

<!--U-->

<!-- U qui devient V en début de mot-->
<xsl:when test="matches(.,'^ua(\w*)$', 'i')">
   <xsl:if test="matches(.,'^ua(\w*)$')">
      <reg>va<xsl:value-of select="substring-after(.,'ua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ua(\w*)$')">
      <reg>Va<xsl:value-of select="substring-after(.,'Ua')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UA(\w*)$')">
      <reg>VA<xsl:value-of select="substring-after(.,'UA')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^ue(\w*)$', 'i')">
   <xsl:if test="matches(.,'^ue(\w*)$')">
      <reg>ve<xsl:value-of select="substring-after(.,'ue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ue(\w*)$')">
      <reg>Ve<xsl:value-of select="substring-after(.,'Ue')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UE(\w*)$')">
      <reg>Ve<xsl:value-of select="substring-after(.,'UE')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^ui(\w*)$', 'i')">
   <xsl:if test="matches(.,'^ui(\w*)$')">
      <reg>vi<xsl:value-of select="substring-after(.,'ui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ui(\w*)$')">
      <reg>Vi<xsl:value-of select="substring-after(.,'Ui')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UI(\w*)$')">
      <reg>VI<xsl:value-of select="substring-after(.,'UI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^uo(\w*)$', 'i')">
   <xsl:if test="matches(.,'^uo(\w*)$')">
      <reg>vo<xsl:value-of select="substring-after(.,'uo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Uo(\w*)$')">
      <reg>Vo<xsl:value-of select="substring-after(.,'Uo')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UO(\w*)$')">
      <reg>VO<xsl:value-of select="substring-after(.,'UO')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^uu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^uu(\w*)$')">
      <reg>vu<xsl:value-of select="substring-after(.,'uu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Uu(\w*)$')">
      <reg>Vu<xsl:value-of select="substring-after(.,'Uu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^UU(\w*)$')">
      <reg>VU<xsl:value-of select="substring-after(.,'UU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^ura(\w*)$', 'i')">
   <xsl:if test="matches(.,'^ura(\w*)$')">
      <reg>vra<xsl:value-of select="substring-after(.,'ura')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Ura(\w*)$')">
      <reg>Vra<xsl:value-of select="substring-after(.,'Ura')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^URA(\w*)$')">
      <reg>VRA<xsl:value-of select="substring-after(.,'URA')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)uru(o|u|eu)(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)uru(o|u|eu)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uru')"/>urv<xsl:value-of select="substring-after(.,'uru')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)URU(O|U|EU)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'URU')"/>URV<xsl:value-of select="substring-after(.,'URU')"/></reg></xsl:if>
            </xsl:when>        
<xsl:when test="matches(.,'^(\w*)uul(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)uul(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uul')"/>vul<xsl:value-of select="substring-after(.,'uul')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Uul(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Uul')"/>Vul<xsl:value-of select="substring-after(.,'Uul')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)UUL(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UUL')"/>VUL<xsl:value-of select="substring-after(.,'UUL')"/></reg></xsl:if>
            </xsl:when>
           <!--auu euu luu ex: oeuure-->
<xsl:when test="matches(.,'^(\w+)(a|e|l)uu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)(a|e|l)uu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uu')"/>uv<xsl:value-of select="substring-after(.,'uu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)(A|E|L)UU(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'UU')"/>UV<xsl:value-of select="substring-after(.,'UU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^euu(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(e|E)uu(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uu')"/>uv<xsl:value-of select="substring-after(.,'uu')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^EUU(\w*)$')">
      <reg>EUV<xsl:value-of select="substring-after(.,'EUU')"/></reg></xsl:if>
           </xsl:when>
<xsl:when test="matches(.,'^(\w+)uyu(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)uyu(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'uyu')"/>uyv<xsl:value-of select="substring-after(.,'uyu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)UYU(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'UYU')"/>UYV<xsl:value-of select="substring-after(.,'UYU')"/></reg></xsl:if>
            </xsl:when>
   
<!--V-->
<xsl:when test="matches(.,'^(\w*)viu[^s](\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)viu[^s](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'viu')"/>viv<xsl:value-of select="substring-after(.,'viu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Viu[^s](\w*)$')">
      <reg>Viv<xsl:value-of select="substring-after(.,'Viu')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VIU[^s](\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VIU')"/>VIV<xsl:value-of select="substring-after(.,'VIU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)vev(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)vev(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vev')"/>veu<xsl:value-of select="substring-after(.,'vev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Vev(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Vev')"/>Veu<xsl:value-of select="substring-after(.,'Vev')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VEV(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VEV')"/>VEU<xsl:value-of select="substring-after(.,'VEV')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^vingtvn(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(v|V)ingtvn(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'ingtvn')"/>ingtun<xsl:value-of select="substring-after(.,'ingtvn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VINGTVN(\w+)$')">
      <reg>VINGTUN<xsl:value-of select="substring-after(.,'VINGTVN')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)vti(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)vti(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'vti')"/>uti<xsl:value-of select="substring-after(.,'vti')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Vti(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'vti')"/>Uti<xsl:value-of select="substring-after(.,'Vti')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VTI(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'vti')"/>UTI<xsl:value-of select="substring-after(.,'VTI')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^vl(\w+)$', 'i')">
   <xsl:if test="matches(.,'^vl(\w+)$')">
      <reg>ul<xsl:value-of select="substring-after(.,'vl')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vl(\w+)$')">
      <reg>Ul<xsl:value-of select="substring-after(.,'Vl')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VL(\w+)$')">
      <reg>UL<xsl:value-of select="substring-after(.,'VL')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)vle(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)vle(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vle')"/>ule<xsl:value-of select="substring-after(.,'vle')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Vle(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Vle')"/>Ule<xsl:value-of select="substring-after(.,'Vle')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VLE(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VLE')"/>ULE<xsl:value-of select="substring-after(.,'VLE')"/></reg></xsl:if>
            </xsl:when>             
<xsl:when test="matches(.,'^(\w+)vlx$', 'i')">
   <xsl:if test="matches(.,'^(\w+)vlx$')">
      <reg><xsl:value-of select="substring-before(.,'vlx')"/>ulx</reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)VLX$')">
      <reg><xsl:value-of select="substring-before(.,'VLX')"/>ULX</reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)vmb(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)vmb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'vmb')"/>umb<xsl:value-of select="substring-after(.,'vmb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)Vmb(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'Vmb')"/>Umb<xsl:value-of select="substring-after(.,'Vmb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)VMB(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'VMB')"/>UMB<xsl:value-of select="substring-after(.,'VMB')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^vn(\w*)$', 'i')">
   <xsl:if test="matches(.,'^vn(\w*)$')">
      <reg>un<xsl:value-of select="substring-after(.,'vn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vn(\w*)$')">
      <reg>Un<xsl:value-of select="substring-after(.,'Vn')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VN(\w*)$')">
      <reg>UN<xsl:value-of select="substring-after(.,'VN')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w+)vp(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(\w+)vp(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'vp')"/>up<xsl:value-of select="substring-after(.,'vp')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w+)VP(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'VP')"/>UP<xsl:value-of select="substring-after(.,'VP')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^vr(b|g|l|n|r|s)(\w+)$', 'i')">
    <xsl:if test="matches(.,'^vr(b|g|l|n|r|s)(\w+)$')">
      <reg>ur<xsl:value-of select="substring-after(.,'vr')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^Vr(b|g|l|n|r|s)(\w+)$')">
      <reg>Ur<xsl:value-of select="substring-after(.,'Vr')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^VR(B|G|L|N|R|S)(\w+)$')">
      <reg>UR<xsl:value-of select="substring-after(.,'VR')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^vb(\w+)$', 'i')">
   <xsl:if test="matches(.,'^vb(\w+)$')">
      <reg>ub<xsl:value-of select="substring-after(.,'vb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vb(\w+)$')">
      <reg>Ub<xsl:value-of select="substring-after(.,'Vb')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VB(\w+)$')">
      <reg>UB<xsl:value-of select="substring-after(.,'VB')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^vs(\w+)$', 'i')">
   <xsl:if test="matches(.,'^vs(\w+)$')">
      <reg>us<xsl:value-of select="substring-after(.,'vs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vs(\w+)$')">
      <reg>Us<xsl:value-of select="substring-after(.,'Vs')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VS(\w+)$')">
      <reg>US<xsl:value-of select="substring-after(.,'VS')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^vt(\w+)$', 'i')">
   <xsl:if test="matches(.,'^vt(\w+)$')">
      <reg>ut<xsl:value-of select="substring-after(.,'vt')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^Vt(\w+)$')">
      <reg>Ut<xsl:value-of select="substring-after(.,'Vt')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^VT(\w+)$')">
      <reg>UT<xsl:value-of select="substring-after(.,'VT')"/></reg></xsl:if>
            </xsl:when>

<!--Y-->
<xsl:when test="matches(.,'^(\w*)yu(e|ro|oi)(\w*)$', 'i')">
    <xsl:if test="matches(.,'^(\w*)yu(e|ro|oi)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'yu')"/>yv<xsl:value-of select="substring-after(.,'yu')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^Yu(e|ro|oi)(\w*)$')">
      <reg>Yv<xsl:value-of select="substring-after(.,'Yu')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)YU(E|RO|OI)(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'YU')"/>YV<xsl:value-of select="substring-after(.,'YU')"/></reg></xsl:if>
            </xsl:when>
<xsl:when test="matches(.,'^(\w*)yur(\w*)$', 'i')">
    <xsl:if test="matches(.,'^(\w*)yur(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'yur')"/>yvr<xsl:value-of select="substring-after(.,'yur')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^Yur(\w*)$')">
       <reg>Yvr<xsl:value-of select="substring-after(.,'Yur')"/></reg></xsl:if>
    <xsl:if test="matches(.,'^(\w*)YUR(\w*)$')">
       <reg><xsl:value-of select="substring-before(.,'YUR')"/>YVR<xsl:value-of select="substring-after(.,'YUR')"/></reg></xsl:if>
           </xsl:when>              
<xsl:when test="matches(.,'^(\w*)ÿuer(\w*)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(Ÿ|ÿ)uer(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'uer')"/>ver<xsl:value-of select="substring-after(.,'uer')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)ŸUER(\w*)$')">
      <reg><xsl:value-of select="substring-before(.,'ŸUER')"/>ŸVER<xsl:value-of select="substring-after(.,'ŸUER')"/></reg></xsl:if>
            </xsl:when>              
            
<!--Z-->    
           <!--Zuingle sixuingts-->
<xsl:when test="matches(.,'^(\w*)(z|x)uing(\w+)$', 'i')">
   <xsl:if test="matches(.,'^(\w*)(Z|z|x|X)uing(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'uing')"/>ving<xsl:value-of select="substring-after(.,'uing')"/></reg></xsl:if>
   <xsl:if test="matches(.,'^(\w*)(Z|X)UING(\w+)$')">
      <reg><xsl:value-of select="substring-before(.,'UING')"/>ZVING<xsl:value-of select="substring-after(.,'UING')"/></reg></xsl:if>
            </xsl:when>
            
            <xsl:otherwise>
      <reg>
                    <xsl:value-of select="."/>
                </reg>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
</xsl:stylesheet>
