<?xml version="1.0" encoding="utf-8"?>
<!-- AXPT XML to MSc generator -->
<!-- Written by Donald Jones -->
<!-- 13th Oct 2006 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">

    <!-- Global Declarations -->
    <!-- Severity -->
        <xsl:variable name="sev_critical" select="0"/>
        <xsl:variable name="sev_major" select="1"/>
        <xsl:variable name="sev_minor" select="2"/>
        <xsl:variable name="sev_intermit" select="3"/>
        <xsl:variable name="sev_info" select="4"/>
        <xsl:variable name="sev_clear" select="5"/>

    <!-- Event Drawing -->
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

    <xsl:variable name="num_events" select="count(//event)"/>

    <!-- IFRAME handling -->
        <!-- handling for splitting MSCs across iFRAMES -->
        <xsl:variable name="max_events_per_iframe" select="500"/> 
        <!-- Any more than this will cause SVG to be too large for iframe to display -->
        <xsl:variable name="num_iframes" select="floor($num_events div $max_events_per_iframe) + 1" />
        <xsl:variable name="max_iframe_height" select="$max_events_per_iframe * $event_delta_y + 10"/>

    <!-- Band handling -->
        <xsl:variable name="max_bands" select="$max_events_per_iframe"/>
        <xsl:variable name="band_height" select="$event_delta_y"/>
        <xsl:variable name="row_band_min_x" select="10"/>

    <!-- Node Positioning -->
        <xsl:variable name="num_nodes" select="count(/eventlist/config/nodelist/node)"/>
    
        <!-- Left most node position -->
        <xsl:variable name="NodeMinX" select="$event_box_half_width+2"/>
        <!-- Detect optional fields -->
        <xsl:variable name="num_date" select="count(//event[@date])"/>
        <xsl:variable name="num_tag" select="count(//event[@tag])"/>
    
        <!-- Determine column heading positions -->
        <!-- X Position for Line column -->
        <xsl:variable name="line_x" select="20"/>
        <xsl:variable name="line_width" select="50"/>
    
        <!-- X Position for Date column -->
        <xsl:variable name="date_x" select="$line_x + $line_width"/>
        <xsl:variable name="date_width" select="150"/>
    
        <!-- X Position for TAG column -->
        <xsl:variable name="tag_x">
            <xsl:choose>
                <xsl:when test="$num_date">
                    <xsl:value-of select="$date_x + $date_width"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date_x"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
        <xsl:variable name="tag_width">
            <xsl:choose>
                <xsl:when test="$num_tag">70</xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
        <xsl:variable name="defaultBodyWidth" select="1100"/>
        <xsl:variable name="node_level_gap" select="5" />
    
        <!-- Determine some temporary variables -->
        <xsl:variable name="tmpNodeMaxX" select="$defaultBodyWidth - $tag_x - $tag_width"/>
    
        <!--<xsl:variable name="max_nodes_per_level" select="9"/>-->
        <xsl:variable name="tmpmax_nodes_per_level" select="($tmpNodeMaxX - $NodeMinX) div (2 * $node_box_half_width)" />
        <xsl:variable name="tmp_num_node_levels" select="floor($num_nodes div $tmpmax_nodes_per_level)+1"/>
    
    
        <!-- Check that we are not going to get too crowded -->
        <xsl:variable name="NodeMaxX">
            <xsl:choose>
                <xsl:when test="$tmp_num_node_levels &lt; 4"><xsl:value-of select="$tmpNodeMaxX"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$num_nodes * $node_box_half_width"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
        <xsl:variable name="NodeDelta" select="($NodeMaxX - $NodeMinX) div ($num_nodes - 1)"/>
        <xsl:variable name="max_nodes_per_level" select="($NodeMaxX - $NodeMinX) div (2 * $node_box_half_width)" />
        <xsl:variable name="num_node_levels" select="floor($num_nodes div $max_nodes_per_level)+1"/>

    <!-- Height determination -->
        <xsl:variable name="head_y" select="($num_node_levels + 0.5) * 2 * $node_box_half_height + ($num_node_levels * $node_level_gap)"/>

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
            <xsl:when test="$sev = $sev_info">white</xsl:when>
            <xsl:when test="$sev = $sev_clear">lightgreen</xsl:when>
        </xsl:choose>
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
<!--    <xsl:comment><xsl:value-of select="$num/>/<xsl:value-of select="$total_num"/></xsl:comment>-->
        <xsl:if test="$total_num &lt;= $max_bands">
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
                        <xsl:value-of select="($num * $event_delta_y)+25"/>
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
    
</xsl:stylesheet>
