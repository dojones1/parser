<?xml version="1.0"?>
<!--
==========================================================================
 Stylesheet: kml_lib.xsl
    Version: 0.1
     Author: Donald Jones
     Notice: Copyright (c)2006 D.Novatchev  ALL RIGHTS RESERVED.
             No limitation on use - except this code may not be published,
             in whole or in part, without prior written consent of the
             copyright owner.
========================================================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- ================================================================================ -->
    <!-- Function: stripSpaces(<instring>) => outstring                                   -->
    <!-- Parameters:-                                                                     -->
    <!--   <instring>  - string to be stripped                                            -->
    <xsl:template name="stripSpaces">
        <xsl:param name="instring" />
        <xsl:value-of select="$instring"/>
    </xsl:template>

    <!-- ================================================================================ -->
    <!-- Function: genCircle(<latitude>,<longitude>,<altitude>,<radius>) => Circle Coords -->
    <!-- Parameters:-                                                                     -->
    <!--   <longitude, latitude, altitude>  - Positional information for circle centre    -->
    <!--   <radius>                         - Radius of cell range                        -->
    <xsl:template name="genCircle">
        <xsl:param name="longitude"/>
        <xsl:param name="latitude"/>
        <xsl:param name="altitude"/>
        <xsl:param name="radius"/>
        <!-- the following paremeters are used only during recursion -->
        <xsl:param name="deg"/>
        <xsl:param name="inc"/>
        <xsl:variable name="cosLat">
            <xsl:call-template name="cos">
                <xsl:with-param name="pX" select="$latitude"/>
                <xsl:with-param name="pUnit" select="'deg'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="cosX">
            <xsl:call-template name="cos">
                <xsl:with-param name="pX" select="$deg"/>
                <xsl:with-param name="pUnit" select="'deg'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="sinX">
            <xsl:call-template name="sin">
                <xsl:with-param name="pX" select="$deg"/>
                <xsl:with-param name="pUnit" select="'deg'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="earth_radius" select="6370"/>
        <!--<xsl:variable name="earth_circ" select="40008"/> -->
        <xsl:variable name="earth_circ" select="2*$pi*$earth_radius"/>
    <!-- Convert deg into delta x/y in degrees -->
        <xsl:variable name="lat_circ" select="$earth_radius * $cosLat * 2 * $pi"/>
        <!--lat_circ: <xsl:value-of select="$lat_circ"/>
        earth_circ: <xsl:value-of select="$earth_circ"/>-->
        <xsl:variable name="dx" select="($radius*$cosX * 360) div $lat_circ"/>

        <xsl:variable name="dy" select="($radius*$sinX * 360) div $earth_circ"/>

        <!-- only output digit if:                        -->
        <!--     non-zero has already been encountered OR -->
        <!--     on the last digit                        -->
        <xsl:if test="$deg &lt; 361">
            <xsl:value-of select="$longitude + $dx"/>,<xsl:value-of select="$latitude + $dy"/>,0
            <xsl:call-template name="genCircle">
                <xsl:with-param name="longitude" select="$longitude"/>
                <xsl:with-param name="latitude" select="$latitude"/>
                <xsl:with-param name="altitude" select="$altitude"/>
                <xsl:with-param name="radius" select="$radius"/>
                <xsl:with-param name="deg" select="$deg + $inc"/>
                <xsl:with-param name="inc" select="$inc"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- ================================================================================ -->
    <!-- Function: dumpRawCoords(<latitude>,<longitude>,<altitude>) => Coords             -->
    <!-- Parameters:-                                                                     -->
    <!--   <longitude, latitude, altitude>  - Positional information for coordinates      -->
    <xsl:template name="dumpRawCoords">
        <xsl:param name="lat" />
        <xsl:param name="long" />
        <xsl:param name="alt" />
        <xsl:value-of select="$long+0"/>,<xsl:value-of select="$lat+0"/>,<xsl:value-of select="$alt+0"/>
    </xsl:template>

    <!-- ================================================================================ -->
    <!-- Function: dumpSingleCoords(<latitude>,<longitude>,<altitude>) => Coords          -->
    <!-- Parameters:-                                                                     -->
    <!--   <longitude, latitude, altitude>  - Positional information for coordinates      -->
    <xsl:template name="dumpSingleCoords">
        <xsl:param name="lat" />
        <xsl:param name="long" />
        <xsl:param name="alt" />
        <coordinates>
            <xsl:call-template name="dumpRawCoords">
                <xsl:with-param name="lat" select="$lat"/>
                <xsl:with-param name="long" select="$long"/>
                <xsl:with-param name="alt" select="$alt"/>
            </xsl:call-template>                                
        </coordinates>
    </xsl:template>
</xsl:stylesheet>