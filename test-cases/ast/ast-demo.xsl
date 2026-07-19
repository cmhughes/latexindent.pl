<?xml version='1.0'?> 
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  xmlns:exsl="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times"
  extension-element-prefixes="exsl date"
  >

<!-- Intend output for rendering by a web browser -->
<xsl:output method="html" encoding="utf-8"/>

<xsl:template match="html">
  <xsl:element name="html">
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<xsl:template match="head">
  <xsl:element name="cmhhead">
  <xsl:element name="script">
      <xsl:attribute name="type">
          <xsl:text>text/javascript</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="src">
          <xsl:text>myfile.js</xsl:text>
      </xsl:attribute>
      <xsl:text> </xsl:text>
  </xsl:element>
  <xsl:element name="script">
      <xsl:attribute name="type">
          <xsl:text>text/javascript</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="id">
          <xsl:text>MathJax-script</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="src">
          <xsl:text>https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js</xsl:text>
      </xsl:attribute>
      <xsl:text> </xsl:text>
  </xsl:element>
  </xsl:element>
   <xsl:apply-templates />
</xsl:template>

<xsl:template match="title">
  <xsl:element name="title">
      <xsl:value-of select="text()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="body">
  <xsl:element name="body">
      <xsl:attribute name="class">
          <xsl:value-of select="commands[@name='documentclass']/mandatoryArgument/paragraph/text()"/>
      </xsl:attribute>
   <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<xsl:template match="environments">
  <xsl:element name="div">
      <xsl:attribute name="class">
          <xsl:value-of select="@name" />
      </xsl:attribute>
    <xsl:element name="h2">
          <xsl:value-of select="optionalArgument/paragraph/text()"/>
    </xsl:element>
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<xsl:template match="paragraph">
  <xsl:element name="p">
      <xsl:value-of select="text()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="specialBeginEnd[@name='inlineMath']">
      <xsl:value-of select="concat('$',paragraph/text(),'$')"/>
</xsl:template>

<!-- ignore particular paragraphs  -->
<xsl:template match="commands[@name='documentclass']/mandatoryArgument/paragraph"/>
<xsl:template match="environments/optionalArgument/paragraph"/>
<xsl:template match="commands[@name='newenvironment']"/>

</xsl:stylesheet>
