<?xml version="1.0" encoding="utf-8"?>
<!-- AXPT XML to MSc generator -->
<!-- Written by Donald Jones -->
<!-- 13th Oct 2006 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
  <xsl:output doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" method="xml" indent="yes" encoding="utf-8"/>
  <xsl:include href="msc_const.xsl"/>

  <xsl:template match="/eventlist">
      <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>href="msc.css" type="text/css"</xsl:text>
    </xsl:processing-instruction>
    <xsl:comment>Created by XML to MSc generator</xsl:comment>
    <xsl:comment>Written by Donald Jones</xsl:comment>
    <xsl:comment>13th Oct 2006</xsl:comment>

    <!--<svg width="100%" version="1.1" xmlns="http://www.w3.org/2000/svg" onload="LoadHandler(evt)">-->
    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" onload="LoadHandler(evt)">
      <!-- width="1000" height="100"  -->
      <xsl:attribute name="height">
        <xsl:value-of select="$head_y"/>
      </xsl:attribute>
      <xsl:attribute name="width">
          <xsl:value-of select="$NodeMaxX + 1.5 * $event_box_half_width"/>
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

      <!-- Draw MSc Nodes -->
      <xsl:comment>Define MSc node Context Lines</xsl:comment>
      <xsl:for-each select="config/nodelist/node">
          <xsl:sort select="@idx" data-type="number"/>
        <xsl:call-template name="drawNodeLine">
          <xsl:with-param name="nodename" select="@name"/>
          <xsl:with-param name="max_y" select="$head_y"/>
          <xsl:with-param name="level" select="@idx mod $num_node_levels"/>
        </xsl:call-template>
      </xsl:for-each>

      <xsl:comment>Define MSc nodes</xsl:comment>
      <xsl:for-each select="config/nodelist/node">
          <xsl:sort select="@idx" data-type="number"/>
        <xsl:call-template name="drawNode">
          <xsl:with-param name="nodename" select="@name"/>
          <xsl:with-param name="max_y" select="$head_y"/>
          <xsl:with-param name="level" select="@idx mod $num_node_levels"/>
        </xsl:call-template>
      </xsl:for-each>
    </svg>
  </xsl:template>

  <!-- ================================================================================ -->
  <!-- Function: drawNodeLine(<nodename>,<max_y> => Draws the node context line         -->
  <!-- Parameters:-                                                                     -->
  <!--   <nodename>                   - Name of the node to draw                        -->
  <!--   <max_y>                      - End point of context line                       -->
  <xsl:template name="drawNodeLine">
    <xsl:param name="nodename"/>
    <xsl:param name="max_y"/>
    <xsl:param name="level" select="0"/>

    <!-- Get the x for the centre of the node -->
    <xsl:variable name="node_x">
      <xsl:call-template name="getNodeX">
        <xsl:with-param name="node" select="$nodename"/>
      </xsl:call-template>
    </xsl:variable>


    <g>
        <!-- Title for Tooltip -->
        <title>
            <xsl:value-of select="$nodename"/>
        </title>
        <line class="nodeline" >
          <xsl:attribute name="x1">
            <xsl:value-of select="$node_x"/>
          </xsl:attribute>
          <xsl:attribute name="y1">
            <xsl:value-of select="($level + 1) * 2 * $node_box_half_height + ($level * $node_level_gap)"/>
          </xsl:attribute>
          <xsl:attribute name="x2">
            <xsl:value-of select="$node_x"/>
          </xsl:attribute>
          <xsl:attribute name="y2">
            <xsl:value-of select="$max_y"/>
          </xsl:attribute>

        </line>
    </g>
  </xsl:template>

</xsl:stylesheet>
