<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>
    <!-- include trig functions -->
    <xsl:include href="conv_lib.xsl"/>
    <xsl:include href="trig_lib.xsl"/>
    <xsl:include href="kml_lib.xsl"/>

    <xsl:template name="draw_placemark" match="loc_no[@data_line_num]">
        <xsl:variable name="current_pos" select="position()"/>
    <Placemark>
      <name><span style="color:#007824;">Pt_<xsl:value-of select="position()"/></span></name>
      <LineString>
        <altitudeMode>relativeToGround</altitudeMode>
        <coordinates>
            <xsl:call-template name="dumpRawCoords">
                <xsl:with-param name="lat" select="@lat"/>
				<xsl:with-param name="long" select="@lon"/>
				<xsl:with-param name="alt" select="@rssi"/>
			</xsl:call-template>,
			<xsl:call-template name="dumpRawCoords">
				<xsl:with-param name="lat" select="@lat"/>
				<xsl:with-param name="long" select="@lon"/>
				<xsl:with-param name="alt" select="@rssi"/>
			</xsl:call-template>
        </coordinates>
        <extrude>1</extrude>
        <tessellate>1</tessellate>
      </LineString>
      <Style>
        <LineStyle>
          <color>FF247887</color>
          <width>4</width>
        </LineStyle>
      </Style>
      <Timestamp>
          <when><xsl:value-of select="@when"/></when>
      </Timestamp>
      <description><![CDATA[]]></description>
    </Placemark>

    </xsl:template>

    <xsl:template match="/">
       <xsl:variable name="max_rssi" select="fn:max((//loc_no[@data_line_num]/@rssi))"/>
       <xsl:variable name="min_rssi" select="fn:min((//loc_no[@data_line_num]/@rssi))"/>
<!--            <xsl:for-each select="//HandoverHandOut">
                <xsl:sort select="." data-type="number" order="descending" />
                <xsl:if test="position() = 1">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>-->
       <xsl:apply-templates/>
    </xsl:template>

    <xsl:template name="getMaxValue" match="wimax_data" >

        <xsl:variable name="max_handin">
            <xsl:for-each select="//HandoverHandIn">
                <xsl:sort select="." data-type="number" order="descending" />
                <xsl:if test="position() = 1">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <kml xmlns="http://earth.google.com/kml/2.0">
            <Document>
                <name><xsl:value-of select="@kml_file"/></name>
                <Folder>
                    <name>Legend: RSSI (dBm)</name>
                    <open>1</open>
                    <visibility>1</visibility>
                </Folder>
                <Folder>
                    <name>Data points</name>
                    <xsl:apply-templates>
                        <xsl:sort select="@when"/>
                    </xsl:apply-templates>
                    <!--<xsl:for-each select="loc_no">
                        
                    </xsl:for-each>-->
                </Folder>
            </Document>
        </kml>
    </xsl:template>
  



    <xsl:template name="calc_alpha">
        <xsl:param name="num_hand_in"/>
        <xsl:param name="max_hand_in" />
        <xsl:value-of select="($num_hand_in * 255) div $max_hand_in"/>
    </xsl:template>
</xsl:stylesheet>