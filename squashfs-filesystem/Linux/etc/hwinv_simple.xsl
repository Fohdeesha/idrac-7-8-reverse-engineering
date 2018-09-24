<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/CIM">
    <Inventory>
      <xsl:attribute name="version">
        <xsl:value-of select="@CIMVERSION"/>
      </xsl:attribute>
      <xsl:apply-templates select="MESSAGE/SIMPLEREQ/VALUE.NAMEDINSTANCE"/>
    </Inventory>
  </xsl:template>
  <xsl:template match="MESSAGE/SIMPLEREQ/VALUE.NAMEDINSTANCE">
    <xsl:variable name="csname">
      <xsl:value-of select="INSTANCENAME/@CLASSNAME"/>
    </xsl:variable>
      <Component>
        <xsl:attribute name="Classname">
          <xsl:value-of select="INSTANCENAME/@CLASSNAME"/>
        </xsl:attribute>
        <xsl:attribute name="Key">
          <xsl:value-of select="INSTANCENAME/KEYBINDING/KEYVALUE"/>
        </xsl:attribute>
        <xsl:apply-templates select="INSTANCE/PROPERTY"/>
      </Component>
  </xsl:template>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
