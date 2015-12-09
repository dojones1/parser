<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://xsltsl.org/string"
    xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:import href="../lib/string.xsl"/>
    <xsl:param name="index" select="0"/>
    <xsl:output method="html" indent="yes" encoding="UTF-16"/>

    <xsl:include href="msc_const.xsl"/>

    <!-- Position of maximum y plotted -->
    <xsl:variable name="col1_width" select="$tag_x + $tag_width"/>
    <xsl:variable name="col2_width" select="$NodeMaxX + 1.5 * $event_box_half_width"/>
    <xsl:variable name="row1_height" select="$head_y"/>
    <xsl:variable name="max_y" select="($num_events * $event_delta_y)+25"/>
    <xsl:variable name="row2_height">
        <xsl:choose>
            <xsl:when test="$max_y &lt; $max_iframe_height"><xsl:value-of select="$max_y"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$max_iframe_height"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/eventlist">
        <html>
            <head>
                <title>MSc extracted from
                    <xsl:value-of select="@name"/>
                </title>
                <link rel="stylesheet" type="text/css" href="debug_ref.css" />
                <base target="_self"/>
                <script language="JavaScript" type="text/javascript">
                    <![CDATA[   
	// Begins
	var titlediv;
	var topdiv;
	var rowdiv;
	var bodydiv;
	var	IE     = (document.all) ? true : false;
	var	last_x = 0;
	var	last_y = 0;
	
	function synchronizeScroll() {
		topdiv.scrollLeft     = bodydiv.scrollLeft;
		rowdiv.scrollTop      = bodydiv.scrollTop;
	}
	
	function LayoutDiv() {
	
		var 	bodyHeight,
				bodyWidth;
		
		//if (rowdiv.parentElement.clientHeight < (titlediv.offsetHeight*2)) {
		//	topdiv.document.parentWindow.status = "Too Short!!";
		//	return;
		//}
		//if (rowdiv.parentElement.clientWidth <  (titlediv.offsetWidth*2)) {
		//	topdiv.document.parentWindow.status = "Too Narrow!!";
		//	return;
		//}
		topdiv.document.parentWindow.status = "";
	
		// Position top div and body div to right of row div 
		topdiv.style.top     = titlediv.offsetTop;
		topdiv.style.left    = titlediv.offsetLeft;
		rowdiv.style.left    = titlediv.offsetLeft;
		rowdiv.style.top     = topdiv.offsetTop+topdiv.offsetHeight;
		bodyHeight           = rowdiv.parentElement.clientHeight-(rowdiv.offsetTop+(rowdiv.style.border*4)+(0 *(bodydiv.offsetHeight-bodydiv.clientHeight)));
		if (bodyHeight > 0) bodydiv.style.height = bodyHeight;
		rowdiv.style.height  = bodydiv.clientHeight+(bodydiv.style.borderWidth*2);
		bodyWidth            = rowdiv.parentElement.clientWidth -(rowdiv.offsetLeft+rowdiv.offsetWidth+(rowdiv.style.border*4)+ (0 *(bodydiv.offsetWidth-bodydiv.clientWidth)));
		if (bodyWidth > 0) bodydiv.style.width  = bodyWidth;
		bodydiv.style.left   = rowdiv.offsetLeft+rowdiv.offsetWidth+rowdiv.style.border;
		bodydiv.style.top    = rowdiv.offsetTop;
	
		// Force width of top section
		topdiv.style.left    = bodydiv.style.left;
		topdiv.style.width   = bodydiv.clientWidth+(topdiv.style.borderWidth*2);
	
	}
	
	// Ends
	      ]]>
                </script>
            </head>
            <body style="overflow:hidden"
                  onScroll="synchronizeScroll();"
                  onLoad="if (!IE) window.setInterval('synchronizeScroll()',100);"
                  onresize="LayoutDiv();" >
                <div id="titlediv">
                    <xsl:attribute name="style">width:<xsl:value-of select="$col1_width"/>px;height:<xsl:value-of select="$row1_height"/>px;position:absolute;overflow:hidden;left:0;top:0;</xsl:attribute>
                    <iframe id ="titleiframe" marginheight="0" marginwidth="0" frameborder="0" name="title_hdr">
                        <xsl:attribute name="height">
                            <xsl:value-of select="$row1_height"/>
                        </xsl:attribute>
                        <xsl:attribute name="width">
                            <xsl:value-of select="$col1_width"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="@lognamestub"/>title.svg</xsl:attribute>
                    </iframe>
                </div>

                <div id="topdiv">
                    <xsl:attribute name="style">width:100%;height:<xsl:value-of select="$row1_height"/>px;position:absolute;overflow:hidden</xsl:attribute>
	

                    <iframe id="topiframe" marginheight="0" marginwidth="0" frameborder="0" name="msc_hdr">
                        <xsl:attribute name="height">
                            <xsl:value-of select="$row1_height"/>
                        </xsl:attribute>
                        <xsl:attribute name="width">
                            <xsl:value-of select="$col2_width"/>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="@lognamestub"/>hdr.svg</xsl:attribute>
                    </iframe>
                </div>

                <div id="rowdiv">
                    <xsl:attribute name="style">width:<xsl:value-of select="$col1_width"/>px;height:100%;position:absolute;overflow:hidden</xsl:attribute>
 	                <xsl:call-template name="buildRowIframe"/>
                </div>

                <div id="bodydiv"
                    style="width:100%;height:100%;position:absolute;overflow:scroll"
                    onScroll="synchronizeScroll()">
 	
                    <xsl:call-template name="buildBodyIframe"/>
                </div>

                <script language="JavaScript" type="text/javascript">
	// Setup global elements
	titlediv  = document.getElementById('titlediv');
	topdiv    = document.getElementById('topdiv');
	bodydiv   = document.getElementById('bodydiv');
	rowdiv    = document.getElementById('rowdiv');

	// Layout for current browser dimensions
	LayoutDiv();

                </script>

            </body>
        </html>
    </xsl:template>

    <!-- ================================================================================ -->
    <!-- Function: buildBodyIframe() => Frames for the number of iframes in the log       -->
    <!-- Function which builds the iframe declarations to display the MSC                 -->
    <xsl:template name="buildBodyIframe">
        
        <xsl:variable name="events_this_iframe">
	    	<xsl:choose>
		    	<xsl:when test="($index + 1) * $max_events_per_iframe &lt; $num_events+1">
		    		<xsl:value-of select="$max_events_per_iframe"/>
		    	</xsl:when>
		    	<xsl:otherwise>
		    		<xsl:value-of select="$num_events mod $max_events_per_iframe"/>
		    	</xsl:otherwise>
		    </xsl:choose>
	    </xsl:variable>
        <!-- Check whether the iteration endstop has been reached -->
        <xsl:if test="$index &lt; $num_iframes">
            <iframe marginheight="0" marginwidth="0" frameborder="0" >
                <xsl:attribute name="height">
                	<xsl:value-of select="($events_this_iframe * $event_delta_y)+25"/>
                </xsl:attribute>
                <xsl:attribute name="width">
                    <xsl:value-of select="$col2_width"/>
                </xsl:attribute>
                <xsl:attribute name="src">
                    <xsl:value-of select="@lognamestub"/><xsl:value-of select="$index"/>_body.svg</xsl:attribute>
            </iframe>
        </xsl:if>
    </xsl:template>

    <!-- ================================================================================ -->
    <!-- Function: buildRowIframe() => Frames for the number of iframes in the log        -->
    <!-- Function which builds the iframe declarations to display the MSC                 -->
    <xsl:template name="buildRowIframe">
        
        <xsl:variable name="row_events_this_iframe">
	    	<xsl:choose>
		    	<xsl:when test="(($index + 1) * $max_events_per_iframe) &lt; $num_events+1">
		    		<xsl:value-of select="$max_events_per_iframe"/>
		    	</xsl:when>
		    	<xsl:otherwise>
		    		<xsl:value-of select="$num_events mod $max_events_per_iframe"/>
		    	</xsl:otherwise>
		    </xsl:choose>
	    </xsl:variable>

		<!--<xsl:comment>num: <xsl:value-of select="$num"/></xsl:comment>
		<xsl:comment>row_events_this_iframe: <xsl:value-of select="$row_events_this_iframe"/></xsl:comment>
		<xsl:comment>max_events_per_iframe: <xsl:value-of select="$max_events_per_iframe"/></xsl:comment>
		<xsl:comment>num_events: <xsl:value-of select="$num_events"/></xsl:comment>-->
        <!-- Check whether the iteration endstop has been reached -->
        <xsl:if test="$index &lt; $num_iframes">
            <iframe marginheight="0" marginwidth="0" frameborder="0" >
                <xsl:attribute name="height"><xsl:value-of select="($row_events_this_iframe * $event_delta_y) + 25"/></xsl:attribute>
                <xsl:attribute name="width">
                    <xsl:value-of select="$col1_width"/>
                </xsl:attribute>
                <xsl:attribute name="src">
                    <xsl:value-of select="@lognamestub"/><xsl:value-of select="$index"/>_row.svg</xsl:attribute>
            </iframe>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
