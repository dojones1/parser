<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://xsltsl.org/string">
    <xsl:import href="../lib/string.xsl"/>
    <xsl:output method="html" indent="yes" encoding="UTF-16"/>

  <xsl:template match="/eventlist">
    <html>
      <head>
          <title>Data extracted from <xsl:value-of select="@name"/></title>
          <link rel="stylesheet" type="text/css" href="debug_ref.css" />
      </head>
      <frameset rows="130,100%">
          <frame>
              <xsl:attribute name="src"><xsl:value-of select="@lognamestub"/>topframe.html</xsl:attribute>
          </frame>
           <frame name="output">
               <xsl:attribute name="src"><xsl:value-of select="@lognamestub"/>0_msc.html</xsl:attribute>
          </frame>
      </frameset>
    </html>
  </xsl:template>


</xsl:stylesheet>
