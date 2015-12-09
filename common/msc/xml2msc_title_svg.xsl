<?xml version="1.0" encoding="utf-8"?>
<!-- AXPT XML to MSc generator -->
<!-- Written by Donald Jones -->
<!-- 13th Oct 2006 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
  <xsl:output doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" method="xml" indent="yes" encoding="utf-8"/>
  <xsl:include href="msc_const.xsl"/>

  <!-- Position of maximum y plotted -->
   <xsl:template match="/eventlist">
      <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>href="msc.css" type="text/css"</xsl:text>
    </xsl:processing-instruction>
    <xsl:comment>Created by XML to MSc generator</xsl:comment>
    <xsl:comment>Written by Donald Jones</xsl:comment>
    <xsl:comment>13th Oct 2006</xsl:comment>

    <!--<svg width="100%" version="1.1" xmlns="http://www.w3.org/2000/svg" onload="LoadHandler(evt)">-->
    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" onload="LoadHandler(evt)">
        <!-- width="200" height="100" -->
      <xsl:attribute name="height">
        <xsl:value-of select="$head_y"/>
      </xsl:attribute>
      <xsl:attribute name="width">
          <xsl:value-of select="$tag_x + $tag_width"/>
      </xsl:attribute>

      <script xlink:href="Title.js" />
      <script>
        <![CDATA[
      function LoadHandler(event)
      {
         new Title(event.getTarget().getOwnerDocument(), 12);
      }
   ]]>
      </script>

      <xsl:comment>Predefined content</xsl:comment>

      <xsl:comment>Column Headings</xsl:comment>
      <text class="msghead">
          <xsl:attribute name="x"><xsl:value-of select="$line_x"/></xsl:attribute>
          <xsl:attribute name="y"><xsl:value-of select="$head_y - 10"/></xsl:attribute>Line Num</text>
            
      <xsl:if test="$num_date">
          <text class="msghead">
              <xsl:attribute name="x"><xsl:value-of select="$date_x"/></xsl:attribute>
              <xsl:attribute name="y"><xsl:value-of select="$head_y - 10"/></xsl:attribute>Time</text>
          
      </xsl:if>
      <xsl:if test="$num_tag">
          <text class="msghead">
              <xsl:attribute name="x"><xsl:value-of select="$tag_x"/></xsl:attribute>
              <xsl:attribute name="y"><xsl:value-of select="$head_y - 10"/></xsl:attribute>Tag</text>
      </xsl:if>


    </svg>

  </xsl:template>


</xsl:stylesheet>
