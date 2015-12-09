<?xml version="1.0"?>
<!-- run this stylesheet with any input XML -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes" encoding="ISO-8859-1"/>
<xsl:include href="numberutils_lib.xsl"/>
<xsl:template match="/">
  <html>
    <head/>
    <body>
      <h3>XSLT Number Utils Test Page</h3>
      <table border="1" width="80%" align="center">
        <tr>
          <th width="50%">Conversion/Expression</th>
          <th width="50%">Result</th>
        </tr>
        <tr>
          <td>Binary 110100011 to Decimal</td>
          <td>
            <xsl:call-template name="Bin2Dec">
              <xsl:with-param name="value" select="'110100011'"/>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td>Binary 110100011 to Hexadecimal</td>
          <td>
            <xsl:call-template name="Dec2Hex">
              <xsl:with-param name="value">
                <xsl:call-template name="Bin2Dec">
                  <xsl:with-param name="value" select="'110100011'"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td>Hexadecimal $1A3 to Decimal</td>
          <td>
            <xsl:call-template name="Hex2Dec">
              <xsl:with-param name="value" select="'1A3'"/>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td>Hexadecimal $1A3 to Binary</td>
          <td>
            <xsl:call-template name="Dec2Bin">
              <xsl:with-param name="value">
                <xsl:call-template name="Hex2Dec">
                  <xsl:with-param name="value" select="'1A3'"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td>Decimal 419 to Hexadecimal</td>
          <td>
            <xsl:call-template name="Dec2Hex">
              <xsl:with-param name="digits" select="number(4)"/>
              <xsl:with-param name="value" select="number(419)"/>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td>Decimal 419 to Binary</td>
          <td>
            <xsl:call-template name="Dec2Bin">
              <xsl:with-param name="value" select="number(419)"/>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td colspan="2"></td>
        </tr>
        <tr>
          <td>419 AND 255</td>
          <td>
            <xsl:call-template name="BooleanAND">
              <xsl:with-param name="value1" select="number(419)"/>
              <xsl:with-param name="value2" select="number(255)"/>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td>419 OR 255</td>
          <td>
            <xsl:call-template name="BooleanOR">
              <xsl:with-param name="value1" select="number(419)"/>
              <xsl:with-param name="value2" select="number(255)"/>
            </xsl:call-template>
          </td>
        </tr>
        <tr>
          <td>419 XOR 255</td>
          <td>
            <xsl:call-template name="BooleanXOR">
              <xsl:with-param name="value1" select="number(419)"/>
              <xsl:with-param name="value2" select="number(255)"/>
            </xsl:call-template>
          </td>
        </tr>
        
      </table>
    </body>
  </html>
</xsl:template>
</xsl:stylesheet>