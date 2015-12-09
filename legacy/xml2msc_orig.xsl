<?xml version="1.0" encoding="utf-8"?>
<!-- AXPT XML to MSc generator -->
<!-- Written by Donald Jones -->
<!-- 13th Oct 2006 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
  <xsl:output doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" method="xml" indent="yes" encoding="utf-8"/>

  <!-- Global Declarations -->
  <xsl:variable name="sev_critical" select="0"/>
  <xsl:variable name="sev_major" select="1"/>
  <xsl:variable name="sev_minor" select="2"/>
  <xsl:variable name="sev_intermit" select="3"/>
  <xsl:variable name="sev_info" select="4"/>
  <xsl:variable name="sev_clear" select="5"/>

  <xsl:variable name="max_bands" select="3000"/>
  <xsl:variable name="event_delta_y" select="20"/>
  <xsl:variable name="event_x" select="300"/>
  <xsl:variable name="arrow_height" select="2"/>
  <xsl:variable name="arrow_width" select="10"/>
  <xsl:variable name="node_box_half_width" select="50"/>
  <xsl:variable name="node_box_half_height" select="10"/>
  <xsl:variable name="event_box_half_width" select="80"/>
  <xsl:variable name="event_box_half_height" select="8"/>
  <xsl:variable name="state_box_half_width" select="80"/>
  <xsl:variable name="state_box_half_height" select="8"/>



  <!-- Left most node position -->
  <xsl:variable name="NodeMinX">
      <xsl:choose>
          <xsl:when test="$num_tag"><xsl:value-of select="$tag_x + (2* $node_box_half_width) + $tag_width"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$tag_x + (2 * $node_box_half_width)"/></xsl:otherwise>
      </xsl:choose>
  </xsl:variable>

  <!-- Position of maximum y plotted -->
  <xsl:variable name="max_y" select="($num_events* $event_delta_y) + $head_y"/>

  <!-- Rightmost Node position -->
  <xsl:variable name="NodeMaxX" select="1160"/>
  <xsl:variable name="NodeDelta" select="($NodeMaxX - $NodeMinX) div ($numNodes - 1)"/>

  <xsl:variable name="node_level_gap" select="5" />
  <xsl:variable name="num_nodes" select="count(/eventlist/config/nodelist/node)"/>
  <!--<xsl:variable name="max_nodes_per_level" select="9"/>-->
  <xsl:variable name="max_nodes_per_level" select="($NodeMaxX - $NodeMinX) div (2 * $node_box_half_width)" />
  <xsl:variable name="num_node_levels" select="floor($num_nodes div $max_nodes_per_level)+1"/>
  <xsl:variable name="head_y" select="($num_node_levels + 1) * 2 * $node_box_half_height + ($num_node_levels * $node_level_gap)"/>

  <!-- Detect optional fields -->
  <xsl:variable name="num_date" select="count(//event[@date])"/>
  <xsl:variable name="num_tag" select="count(//event[@tag])"/>
  <xsl:variable name="num_events" select="count(//event)"/>

  <!-- Determine column heading positions -->
  <!-- X Position for Line column -->
  <xsl:variable name="line_x" select="20"/>

  <!-- X Position for Date column -->
  <xsl:variable name="date_x" select="70"/>
  <xsl:variable name="date_width" select="150"/>

  <!-- X Position for TAG column -->
  <xsl:variable name="tag_x">
      <xsl:choose>
          <xsl:when test="$num_date"><xsl:value-of select="$date_x + $date_width"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="$date_x"/></xsl:otherwise>
      </xsl:choose>
  </xsl:variable>
  <xsl:variable name="tag_width" select="70"/>

  <xsl:template match="/eventlist">
      <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>href="msc.css" type="text/css"</xsl:text>
    </xsl:processing-instruction>
    <xsl:comment>Created by XML to MSc generator</xsl:comment>
    <xsl:comment>Written by Donald Jones</xsl:comment>
    <xsl:comment>13th Oct 2006</xsl:comment>

    <!--<svg width="100%" version="1.1" xmlns="http://www.w3.org/2000/svg" onload="LoadHandler(evt)">-->
    <svg width="100%" version="1.1" xmlns="http://www.w3.org/2000/svg" onload="LoadHandler(evt)">
      <xsl:attribute name="height">
        <xsl:value-of select="$max_y"/>
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
          <xsl:attribute name="y"><xsl:value-of select="$head_y - 20"/></xsl:attribute>Line Num</text>
            
      <xsl:if test="$num_date">
          <text class="msghead">
              <xsl:attribute name="x"><xsl:value-of select="$date_x"/></xsl:attribute>
              <xsl:attribute name="y"><xsl:value-of select="$head_y - 20"/></xsl:attribute>Time</text>
          
      </xsl:if>
      <xsl:if test="$num_tag">
          <text class="msghead">
              <xsl:attribute name="x"><xsl:value-of select="$tag_x"/></xsl:attribute>
              <xsl:attribute name="y"><xsl:value-of select="$head_y - 20"/></xsl:attribute>Tag</text>
      </xsl:if>

      <!-- Draw alternate light / dark bands -->
      <xsl:comment>Draw alternate light/dark bands</xsl:comment>
      <xsl:call-template name="drawBands">
        <xsl:with-param name="from_x" select="10"/>
        <xsl:with-param name="to_x" select="$NodeMaxX + $event_box_half_width"/>
        <xsl:with-param name="total_num" select="$num_events"/>
        <xsl:with-param name="num" select="0"/>
      </xsl:call-template>

      <!-- Draw MSc Nodes -->
      <xsl:comment>Define MSc node Context Lines</xsl:comment>
      <xsl:for-each select="config/nodelist/node">
          <xsl:sort select="@idx" data-type="number"/>
        <xsl:call-template name="drawNodeLine">
          <xsl:with-param name="nodename" select="@name"/>
          <xsl:with-param name="max_y" select="$max_y"/>
          <xsl:with-param name="level" select="@idx mod $num_node_levels"/>
        </xsl:call-template>
      </xsl:for-each>

      <xsl:comment>Define MSc nodes</xsl:comment>
      <xsl:for-each select="config/nodelist/node">
          <xsl:sort select="@idx" data-type="number"/>
        <xsl:call-template name="drawNode">
          <xsl:with-param name="nodename" select="@name"/>
          <xsl:with-param name="max_y" select="$max_y"/>
          <xsl:with-param name="level" select="@idx mod $num_node_levels"/>
        </xsl:call-template>
      </xsl:for-each>

      <!-- Autogenerated content -->
      <xsl:comment>Autogenerated content from here on</xsl:comment>
      <xsl:for-each select="event">
        <xsl:sort select="@line" data-type="number"/>

        <!-- Establish local variables -->
        <xsl:variable name="temp_idx">
          <xsl:value-of select="position()"/>
        </xsl:variable>
        <xsl:variable name="event_idx" select="$temp_idx - 1"/>
        <xsl:variable name="event_y" select="$event_idx*$event_delta_y + $head_y"/>

        <g>
            <a target="output"><xsl:attribute name="xlink:href"><xsl:value-of select="../@logname"/>.html#L<xsl:value-of select="@line"/></xsl:attribute>
            <!-- Column data -->
            <text class="msgtext">
              <xsl:attribute name="x">
                <xsl:value-of select="$line_x"/>
              </xsl:attribute>
              <xsl:attribute name="y">
                <xsl:value-of select="$event_y"/>
              </xsl:attribute>
              <xsl:value-of select="@line"/>
            </text>
            <text class="msgtext">
              <xsl:attribute name="x">
                <xsl:value-of select="$date_x"/>
              </xsl:attribute>
              <xsl:attribute name="y">
                <xsl:value-of select="$event_y"/>
              </xsl:attribute>
              <xsl:value-of select="@date"/>
            </text>
            <text class="msgtext">
              <xsl:attribute name="x">
                <xsl:value-of select="$tag_x"/>
              </xsl:attribute>
              <xsl:attribute name="y">
                <xsl:value-of select="$event_y"/>
              </xsl:attribute>
              <xsl:value-of select="@tag"/>
            </text>
            </a>
        </g>

        <g>
            <a>
                <xsl:choose>
                    <xsl:when test="@url!=''">
                        <xsl:attribute name="target">_blank</xsl:attribute>
                        <xsl:attribute name="xlink:href"><xsl:value-of select="@url"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="target">output</xsl:attribute>
                        <xsl:attribute name="xlink:href"><xsl:value-of select="../@logname"/>.html#L<xsl:value-of select="@line"/></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>

            <xsl:choose>
              <xsl:when test="@type='msg'">
                <xsl:variable name="to_x">
                  <xsl:call-template name="getNodeX">
                    <xsl:with-param name="node" select="@to"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="from_x">
                  <xsl:call-template name="getNodeX">
                    <xsl:with-param name="node" select="@from"/>
                  </xsl:call-template>
                </xsl:variable>


                <xsl:call-template name="drawMsg">
                  <xsl:with-param name="from_x" select="$from_x"/>
                  <xsl:with-param name="to_x" select="$to_x"/>
                  <xsl:with-param name="arrow_y" select="$event_y"/>
                  <xsl:with-param name="msg" select="$event_y"/>
                </xsl:call-template>

              </xsl:when>
              <!-- State Change Event -->
              <xsl:when test="@type='sc'">
                <!-- Get the x for the rect -->
                <xsl:variable name="node_x">
                  <xsl:choose>
                    <xsl:when test="@node">
                      <xsl:call-template name="getNodeX">
                        <xsl:with-param name="node" select="@node"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="getNodeX">
                        <xsl:with-param name="node" select="@data"/>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <rect class="staterect" rx="1" ry="1">
                  <xsl:attribute name="width">
                    <xsl:value-of select="2 * $state_box_half_width"/>
                  </xsl:attribute>
                  <xsl:attribute name="height">
                    <xsl:value-of select="2 * $state_box_half_height"/>
                  </xsl:attribute>
                  <xsl:attribute name="x">
                    <xsl:value-of select="$node_x - $state_box_half_width"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$event_y - 13"/>
                  </xsl:attribute>
                </rect>

                <text class="eventtext" text-anchor="middle">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$node_x"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$event_y"/>
                  </xsl:attribute>
                  <xsl:value-of select="@state"/>
                </text>
              </xsl:when>
              <xsl:otherwise>
                <!-- need to colour code the box based upon the severity -->
                <!-- Get the x for the rect -->
                <xsl:variable name="node_x">
                  <xsl:choose>
                    <xsl:when test="@node">
                      <xsl:call-template name="getNodeX">
                        <xsl:with-param name="node" select="@node"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$event_x"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <g>
                  <rect class="eventrect" rx="1" ry="1">
                    <xsl:attribute name="style">
                      fill:
                      <xsl:call-template name="getSevColour">
                        <xsl:with-param name="sev" select="@sev"/>
                      </xsl:call-template>

                    </xsl:attribute>
                    <xsl:attribute name="width">
                      <xsl:value-of select="2 * $event_box_half_width"/>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                      <xsl:value-of select="2 * $event_box_half_height"/>
                    </xsl:attribute>
                    <xsl:attribute name="x">
                      <xsl:value-of select="$node_x - $event_box_half_width"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                      <xsl:value-of select="$event_y - 13"/>
                    </xsl:attribute>
                  </rect>

                  <text class="eventtext">
                      <xsl:choose>
                          <xsl:when test="string-length(@event)&lt;30">
                              <xsl:attribute name="text-anchor">middle</xsl:attribute>
                              <xsl:attribute name="x">
                                  <xsl:value-of select="$node_x"/>
                              </xsl:attribute>
                          </xsl:when>
                          <xsl:otherwise>
                              <xsl:attribute name="text-anchor">left</xsl:attribute>
                              <xsl:attribute name="x">
                                  <xsl:value-of select="$node_x - $event_box_half_width + 5"/>
                              </xsl:attribute>
                          </xsl:otherwise>
                      </xsl:choose>

                    <xsl:attribute name="y">
                      <xsl:value-of select="$event_y - 2"/>
                    </xsl:attribute>
                    <xsl:value-of select="@event"/>
                  </text>
                  <xsl:if test="@data">
                    <title>
                      <xsl:value-of select="normalize-space(@data)"/>
                    </title>
                  </xsl:if>
                </g>
              </xsl:otherwise>
            </xsl:choose>
            </a>
         </g>
      </xsl:for-each>

    </svg>

  </xsl:template>


  <!-- ================================================================================ -->
  <!-- Function: drawBands(<from_x>,<to_x>,<total_num>,<num>) => highlight bands        -->
  <!-- Parameters:-                                                                     -->
  <!--   <from_x, to_x>                   - Define width of the bands                   -->
  <!--   <radius>                         - Radius of cell range                        -->
  <!-- Draws a alternating horizontal rectangle for multiple nodes.                     -->
  <!-- Recursive function which will continue until the list of events is covered       -->
  <xsl:template name="drawBands">
    <xsl:param name="from_x"/>
    <xsl:param name="to_x"/>
    <xsl:param name="total_num"/>
    <xsl:param name="num"/>
    <!-- Only output the bands if it will not cause the XSL processor to overflow -->
    <xsl:if test="$total_num &lt; $max_bands">
      <!-- Check whether the iteration endstop has been reached -->
      <xsl:if test="$num &lt; $total_num">
        <rect class="oddrect" rx="1" ry="1">
          <xsl:attribute name="width">
            <xsl:value-of select="$to_x - $from_x"/>
          </xsl:attribute>
          <xsl:attribute name="height">
            <xsl:value-of select="$event_delta_y"/>
          </xsl:attribute>
          <xsl:attribute name="x">
            <xsl:value-of select="$from_x"/>
          </xsl:attribute>
          <xsl:attribute name="y">
            <xsl:value-of select="$head_y + ($num * $event_delta_y) - 15"/>
          </xsl:attribute>
        </rect>
        <xsl:call-template name="drawBands">
          <xsl:with-param name="from_x" select="$from_x"/>
          <xsl:with-param name="to_x" select="$to_x"/>
          <xsl:with-param name="total_num" select="$total_num"/>
          <xsl:with-param name="num" select="$num + 2"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================================ -->
  <!-- Function: drawNode(<nodename>,<max_y> => Draws the node heading and context line -->
  <!-- Parameters:-                                                                     -->
  <!--   <nodename>                   - Name of the node to draw                        -->
  <!--   <max_y>                      - End point of context line                       -->
  <xsl:template name="drawNode">
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
        <rect class="noderect" rx="10" ry="10">
          <xsl:attribute name="width">
            <xsl:value-of select="2 * $node_box_half_width"/>
          </xsl:attribute>
          <xsl:attribute name="height">
            <xsl:value-of select="2 * $node_box_half_height"/>
          </xsl:attribute>
          <xsl:attribute name="x">
            <xsl:value-of select="$node_x - $node_box_half_width"/>
          </xsl:attribute>
          <xsl:attribute name="y">
            <xsl:value-of select="($level * 2 * $node_box_half_height) + ($level * $node_level_gap)"/>
          </xsl:attribute>
        </rect>

        <text text-anchor="middle">
          <xsl:choose>
            <xsl:when test="string-length($nodename)&gt;8">
              <xsl:attribute name="class">nodetextsmall</xsl:attribute>
            </xsl:when>
            <xsl:when test="$num_nodes&gt;8">
              <xsl:attribute name="class">nodetextsmall</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">nodetext</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:attribute name="x">
            <!--<xsl:value-of select="$node_x - $node_box_half_width + 5"/>-->
            <xsl:value-of select="$node_x"/>
          </xsl:attribute>
          <xsl:attribute name="y">
            <xsl:value-of select="($level + 0.5) * 2 * $node_box_half_height + 3 + ($level * $node_level_gap)"/>
          </xsl:attribute>
          <xsl:value-of select="$nodename"/>
        </text>
    </g>
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

  <!-- Draws an arrow between from_x and to_x. -->
  <!-- This will also output the message name and the arrow head. -->
  <xsl:template name="drawMsg">
    <xsl:param name="from_x"/>
    <xsl:param name="to_x"/>
    <xsl:param name="arrow_y"/>
    <xsl:param name="msg"/>

    <xsl:variable name="arrow_head_x">
      <xsl:choose>
        <xsl:when test="$to_x &gt; $from_x">
          <xsl:value-of select="$to_x - $arrow_width"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$to_x + $arrow_width"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="msg_text_x">
      <xsl:choose>
        <xsl:when test="$to_x &gt; $from_x">
          <xsl:value-of select="$from_x + 15"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$to_x + 15"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <g><xsl:if test="@data">
        <title>
        <xsl:value-of select="normalize-space(@data)"/>
      </title>
    </xsl:if>
    <text class="msgtext">
      <xsl:attribute name="x">
        <xsl:value-of select="$msg_text_x + 15"/>
      </xsl:attribute>
      <xsl:attribute name="y">
        <xsl:value-of select="$arrow_y - 5"/>
      </xsl:attribute>
      <xsl:value-of select="@msg"/>
    </text>
    <line class="msgline">
      <xsl:attribute name="x1">
        <xsl:value-of select="$to_x"/>
      </xsl:attribute>
      <xsl:attribute name="x2">
        <xsl:value-of select="$from_x"/>
      </xsl:attribute>
      <xsl:attribute name="y1">
        <xsl:value-of select="$arrow_y"/>
      </xsl:attribute>
      <xsl:attribute name="y2">
        <xsl:value-of select="$arrow_y"/>
      </xsl:attribute>
    </line>
    <polygon class="msgarrow">
      <xsl:attribute name="points">
        <xsl:value-of select="$to_x"/>,<xsl:value-of select="$arrow_y"/><xsl:text> </xsl:text>
        <xsl:value-of select="$arrow_head_x"/>,<xsl:value-of select="$arrow_y + $arrow_height"/><xsl:text> </xsl:text>
        <xsl:value-of select="$arrow_head_x"/>,<xsl:value-of select="$arrow_y - $arrow_height"/>
      </xsl:attribute>
    </polygon>
    </g>

  </xsl:template>

  <xsl:variable name="numNodes" select="count(/eventlist/config/nodelist/node)"/>
  <xsl:template name="getNodeIndex">
    <xsl:param name="node"/>
    <xsl:for-each select="/eventlist/config/nodelist/node[@name=$node]">
      <xsl:value-of select="@idx"/>
    </xsl:for-each>
    <xsl:for-each select="//altname[@value=$node]">
      <xsl:value-of select="../@idx"/>
    </xsl:for-each>
    <xsl:for-each select="//altname[@idx=$node]">
      <xsl:value-of select="../@idx"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getNodeX">
    <xsl:param name="node"/>
    <xsl:variable name="NodeIndex">
      <xsl:call-template name="getNodeIndex">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="($NodeDelta * $NodeIndex) + $NodeMinX"/>
  </xsl:template>

  <xsl:template name="getSevColour">
    <xsl:param name="sev"/>
    <xsl:choose>
      <xsl:when test="$sev = $sev_critical">red</xsl:when>
      <xsl:when test="$sev = $sev_major">orange</xsl:when>
      <xsl:when test="$sev = $sev_minor">yellow</xsl:when>
      <xsl:when test="$sev = $sev_intermit">salmon</xsl:when>
      <xsl:when test="$sev = $sev_info">lightgreen</xsl:when>
      <xsl:when test="$sev = $sev_clear">white</xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
