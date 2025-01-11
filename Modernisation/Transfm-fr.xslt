<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0">
    
    <xsl:output method="html"/>

    
<xsl:template match="tei:TEI">
<xsl:apply-templates select="tei:text"/>
<hr width="40%" style="margin-top:1rem;margin-bottom:1rem;margin-left:30% ;border-top:1px solid #4d596b;"/>
<text><h2>Bibliographie</h2>
  </text>
<xsl:apply-templates select="tei:teiHeader"/>
</xsl:template>

<xsl:template match="tei:text">
   <xsl:apply-templates/>
   <hr width="40%" style="margin-top:1rem;margin-bottom:1rem;margin-left:30% ;border-top:1px solid #4d596b;"/>
  <div>
  <h2>Notes</h2>
  <xsl:for-each select=".//tei:note[@place]">
   <div style="display:flex;flex-direction:row;">
    <sup style="top:1em !important;">
    <a class="sup" style="text-decoration:none;"> 
    <xsl:attribute name="href">
    #<xsl:value-of select="./@n"/>FR</xsl:attribute>
    <xsl:attribute name="name">
    <xsl:value-of select="./@n"/>fr</xsl:attribute>
    <xsl:value-of select="./@n"/>
    </a> 
    </sup>
    <span>
    <xsl:apply-templates/>
    </span>
   </div>
   </xsl:for-each>
  </div>

</xsl:template>

<xsl:template match="tei:teiHeader">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:titleStmt">
  <span style="display:none;">
  <xsl:value-of select="./tei:title"/>
  </span>
  <xsl:for-each select="./tei:editor">
  <p> 
  <span style="font-weight:bold;">
  <xsl:value-of select="./@role"/> : </span>
  <span><xsl:value-of select="."/></span>
  </p>
  </xsl:for-each>
</xsl:template> 

<xsl:template match="tei:publicationStmt">
</xsl:template> 


  <xsl:template match="tei:bibl">

    <p style="font-style:italic;">
    <xsl:value-of select="."/>
    </p>

  </xsl:template>

   <xsl:template match="tei:notesStmt">

    <p style="font-style:italic;">
    <xsl:value-of select="."/>

    </p>

  </xsl:template>

  <xsl:template match="tei:body/tei:opener/tei:note">
    <h6>
     <xsl:apply-templates/>
    </h6>
  </xsl:template>

  <xsl:template match="tei:hi[@rend='bold']">
    <h5 style="font-weight:bold;">
      <xsl:apply-templates/>
    </h5>
  </xsl:template>
  
  <xsl:template match="tei:body//tei:p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:body//tei:p/text()">
    <span>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

   <xsl:template match="tei:choice/tei:reg">
    <span>
    <xsl:value-of select="."/>
    </span>
  </xsl:template>

   <xsl:template match="tei:choice/tei:orig">
  </xsl:template>

  <xsl:template match="tei:choice/tei:corr">
    <span>
    <xsl:value-of select="."/>
    </span>
  </xsl:template>

   <xsl:template match="tei:choice/tei:sic">
  </xsl:template>

   <xsl:template match="tei:add">
    <span>
    <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="tei:p/tei:hi[@rend='italic']">
    <span style="font-style:italic;">
    <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:address">
    <h2>
    <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="tei:dateline[@xml:id='opener']">
    <h6 class="toRight">
    <xsl:apply-templates/>
    </h6>
  </xsl:template>

  <xsl:template match="tei:dateline/text()">
  <span>
    <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="tei:dateline/tei:date/text()">
  <span>
    <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="tei:salute">
    <p>
    <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:signed">
    <p class="toRight">
    <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:signed/text()">
    <span><strong>
    <xsl:value-of select="."/>
    </strong>
    </span>
  </xsl:template>

<xsl:template match="tei:signed//tei:reg">
    <span><strong>
    <xsl:value-of select="."/>
    </strong>
    </span>
  </xsl:template>
  

  <xsl:template match="tei:placeName">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  

  <xsl:template match="tei:persName">

    <strong>

      <xsl:apply-templates/>

    </strong>

  </xsl:template>

  <xsl:template match="tei:hi[@rend='superscript']">
    <sup>
      <xsl:copy-of select="."/>
    </sup>
  </xsl:template>

  <xsl:template match="tei:note[@place]">
    <sup>
    <a class="sup" style="text-decoration:none;cursor:pointer;"> 
    <xsl:attribute name="title">
    <xsl:apply-templates/>
    </xsl:attribute>
    <xsl:attribute name="name">
    <xsl:value-of select="./@n"/>FR</xsl:attribute>
    <xsl:attribute name="href">#<xsl:value-of select="./@n"/>fr</xsl:attribute>
    <xsl:value-of select="./@n"/>
    </a> 
    </sup>
  </xsl:template>

  <xsl:template match="tei:profileDesc">
  </xsl:template>

</xsl:stylesheet>