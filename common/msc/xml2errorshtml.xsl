<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://xsltsl.org/string">
    <xsl:import href="../lib/string.xsl"/>
    <xsl:output method="html" indent="yes" encoding="UTF-16"/>

  <xsl:template match="/eventlist">
    <html>
      <head>
          <title>MSc extracted from <xsl:value-of select="@name"/></title>
          <link rel="stylesheet" type="text/css" href="debug_ref.css" />
      </head>
      <body>
        <h3>Parser Errors:</h3>
        <table cellpadding="0" cellspacing="0" width="100%">
        <thead border="0" bgcolor="#66ffff">
            <tr>
            <th scope="col">Line</th>
            <th scope="col" class="odd" align="left">Desc</th>
            <!--<th scope="col">Text</th>-->
            </tr>
        </thead>
          <tbody>
            <xsl:for-each select="ERROR">
                <xsl:sort select="@line" data-type="number"/>
                <tr>
                <td align="right"><a target="output"><xsl:attribute name="href">file://<xsl:value-of select="../@name"/>.html#L<xsl:value-of select="@line"/></xsl:attribute><xsl:value-of select="@line"/></a></td>
                <td align="left" class="odd"><xsl:value-of select="@desc"/></td>
                <!--<td><xsl:value-of select="@text"/></td>-->
              </tr>
              </xsl:for-each>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>


</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="Neighbor List 2 KML" userelativepaths="yes" externalpreview="no" url="NodeData\HSAP10_NeighborList.xml" htmlbaseurl="" outputurl="NodeData\HSAP10_NeighborList.kml" processortype="msxml4" useresolver="no" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no" ><SourceSchema srcSchemaPath="NodeData\HSAP10_NeighborList.xml" srcSchemaRoot="HostHsap" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/></MapperInfo><MapperBlockPosition><template match="/"><block path="kml/xsl:for&#x2D;each" x="253" y="54"/><block path="kml/xsl:for&#x2D;each/Folder/Folder/xsl:for&#x2D;each" x="293" y="76"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[1]/Placemark/Style/LineStyle/color/xsl:call&#x2D;template" x="253" y="116"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[1]/Placemark/Style/PolyStyle/color/xsl:call&#x2D;template" x="293" y="116"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[1]/Placemark/Polygon/outerBoundaryIs/LinearRing/coordinates/xsl:call&#x2D;template" x="53" y="116"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[1]/xsl:for&#x2D;each" x="213" y="76"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[1]/xsl:for&#x2D;each/Placemark/Style/LineStyle/color/xsl:call&#x2D;template" x="213" y="116"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[1]/xsl:for&#x2D;each/Placemark/Style/PolyStyle/color/xsl:call&#x2D;template" x="173" y="116"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[1]/xsl:for&#x2D;each/Placemark/Polygon/outerBoundaryIs/LinearRing/coordinates/xsl:call&#x2D;template" x="13" y="116"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[2]/xsl:for&#x2D;each" x="173" y="76"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[2]/xsl:for&#x2D;each/Placemark/Style/LineStyle/color/xsl:call&#x2D;template" x="133" y="116"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[2]/xsl:for&#x2D;each/Placemark/LineString/coordinates/xsl:value&#x2D;of" x="53" y="76"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[2]/xsl:for&#x2D;each/Placemark/LineString/coordinates/xsl:value&#x2D;of[1]" x="13" y="76"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[2]/xsl:for&#x2D;each/Placemark/LineString/coordinates/xsl:value&#x2D;of[2]" x="293" y="36"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[3]/xsl:for&#x2D;each" x="133" y="76"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[3]/xsl:for&#x2D;each/Placemark/name/xsl:value&#x2D;of[1]" x="93" y="76"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[3]/xsl:for&#x2D;each/Placemark/Style/LineStyle/color/xsl:call&#x2D;template" x="93" y="116"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[3]/xsl:for&#x2D;each/Placemark/LineString/coordinates/xsl:value&#x2D;of" x="213" y="36"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[3]/xsl:for&#x2D;each/Placemark/LineString/coordinates/xsl:value&#x2D;of[1]" x="173" y="36"/><block path="kml/xsl:for&#x2D;each/Folder/Folder[3]/xsl:for&#x2D;each/Placemark/LineString/coordinates/xsl:value&#x2D;of[2]" x="133" y="36"/></template></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->