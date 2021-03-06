<?xml version="1.0" encoding="utf-8"?>
<!-- AXPT XML to MSc generator -->
<!-- Written by Donald Jones -->
<!-- 13th Oct 2006 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:param name="index" select="0"/>
    <xsl:output doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" method="xml" indent="yes" encoding="utf-8"/>
    <xsl:include href="msc_const.xsl"/>

            <xsl:variable name="min_event_idx" select="$index * $max_events_per_iframe"/>
            <xsl:variable name="max_event_idx" select="(($index + 1) * $max_events_per_iframe) - 1"/>

    <xsl:variable name="events_this_iframe">
    	<xsl:choose>
	    	<xsl:when test="(($index + 1) * $max_events_per_iframe) &lt; $num_events">
	    		<xsl:value-of select="$max_events_per_iframe"/>
	    	</xsl:when>
	    	<xsl:otherwise>
	    		<xsl:value-of select="$num_events mod $max_events_per_iframe"/>
	    	</xsl:otherwise>
	    </xsl:choose>
    </xsl:variable>

    <!-- Position of maximum y plotted for body of diagram-->
    <xsl:variable name="max_y" select="($events_this_iframe * $event_delta_y)+25"/>

    <xsl:template match="/eventlist">
        <xsl:processing-instruction name="xml-stylesheet">
            <xsl:text>href="msc.css" type="text/css"</xsl:text>
        </xsl:processing-instruction>
        <xsl:comment>Created by XML to MSc generator</xsl:comment>
        <xsl:comment>Written by Donald Jones</xsl:comment>
        <xsl:comment>13th Oct 2006</xsl:comment>

        <!--<svg width="100%" version="1.1" xmlns="http://www.w3.org/2000/svg" onload="LoadHandler(evt)">-->
        <svg version="1.1" xmlns="http://www.w3.org/2000/svg" onload="LoadHandler(evt)">
            <!-- height="2880" width="1000" -->
            <xsl:attribute name="height">
                <xsl:value-of select="$max_y"/>
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

            <!-- Draw alternate light / dark bands -->
            <xsl:comment>Draw alternate light/dark bands</xsl:comment>
            <xsl:call-template name="drawBands">
                <xsl:with-param name="from_x" select="-5"/>
                <xsl:with-param name="to_x" select="$NodeMaxX + $event_box_half_width"/>
                <xsl:with-param name="total_num" select="$events_this_iframe"/>
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
            
            <xsl:comment>min_event_idx: <xsl:value-of select="$min_event_idx"></xsl:value-of></xsl:comment>
            <xsl:comment>max_event_idx: <xsl:value-of select="$max_event_idx"></xsl:value-of></xsl:comment>
                       

            <!-- Autogenerated content -->
            <xsl:comment>Autogenerated content from here on</xsl:comment>
            <xsl:for-each select="event">
                <xsl:sort select="@line" data-type="number"/>
		   		<xsl:if test="position() &gt;= $min_event_idx and position() &lt;= $max_event_idx">

	                <!-- Establish local variables -->
	                <xsl:variable name="temp_idx">
	                    <xsl:value-of select="position() - $min_event_idx"/>
	                </xsl:variable>
	                <xsl:variable name="event_idx" select="$temp_idx - 1"/>
	                <xsl:variable name="event_y" select="($event_idx*$event_delta_y) + 40"/>
	
	                <g>
	                    <a>
	                        <xsl:choose>
	                            <xsl:when test="@url!=''">
	                                <xsl:attribute name="target">_blank</xsl:attribute>
	                                <xsl:attribute name="xlink:href">
	                                    <xsl:value-of select="@url"/>
	                                </xsl:attribute>
	                            </xsl:when>
	                            <xsl:otherwise>
	                                <xsl:attribute name="target">output</xsl:attribute>
	                                <xsl:attribute name="xlink:href">
	                                    <xsl:value-of select="../@logname"/>.html#L<xsl:value-of select="@line"/>
	                                </xsl:attribute>
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
	                                        <xsl:attribute name="style">fill:<xsl:call-template name="getSevColour">
	                                                <xsl:with-param name="sev" select="@sev"/>
	                                            </xsl:call-template></xsl:attribute>
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
	            </xsl:if>
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
                    <xsl:value-of select="0"/>
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
        <g>
            <xsl:if test="@data">
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
                    <xsl:value-of select="$to_x"/><xsl:text>,</xsl:text>
                    <xsl:value-of select="$arrow_y"/><xsl:text> </xsl:text>
                    <xsl:value-of select="$arrow_head_x"/><xsl:text>,</xsl:text>
                    <xsl:value-of select="$arrow_y + $arrow_height"/><xsl:text> </xsl:text>
                    <xsl:value-of select="$arrow_head_x"/><xsl:text>,</xsl:text>
                    <xsl:value-of select="$arrow_y - $arrow_height"/>
                </xsl:attribute>
            </polygon>
        </g>
    </xsl:template>
</xsl:stylesheet>
