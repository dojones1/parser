<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://xsltsl.org/string">
    <xsl:import href="../lib/string.xsl"/>
    <xsl:output method="html" indent="yes" encoding="UTF-16"/>

  <xsl:template match="/eventlist">
     <html>
         <head>
             <title>Data extracted from <xsl:value-of select="@name"/></title>
             <link rel="stylesheet" type="text/css" href="debug_ref.css" />
         </head>
         <body>
             <table class="tbl2">
              <tr class="tr2">
                  <td class="td2">
					<table class="tbl2">
					  <tr>
                        <td class="td2">
                          <b>Log:</b>
                        </td>
                        <td class="td2">
                          <xsl:value-of select="@name"/>
                        </td>
                      </tr>
                      <tr>
                        <td class="td2">
                          <b>Parser:</b>
                        </td>
                        <td class="td2">
                          <xsl:value-of select="@parser"/>
                        </td>
                      </tr>
                      <tr>
                        <td class="td2">
                          <b>Login:</b>
                        </td>
                        <td class="td2">
                          <xsl:value-of select="@login"/>
                        </td>
                      </tr>
                      <tr>
                        <td class="td2">
                          <b>Date:</b>
                        </td>
                        <td class="td2">
                          <xsl:value-of select="normalize-space(@date)"/><xsl:text> </xsl:text><xsl:value-of select="normalize-space(@time)"/>
                        </td>
                      </tr>
                      <xsl:if test="@info">
                        <tr>
                          <td class="td2">
                            <b>Info:</b>
                          </td>
                          <td class="td2" align="left" text-align="left" font-weight="italic" font-color="blue">
                            <xsl:value-of select="@info"/>
                            <tr></tr>
                          </td>
                        </tr>
                      </xsl:if>

                      <tr class="tr2">
                          <td class="td2" valign="top"><b>Outputs:</b></td>
                          <td class="td3" align="left" paddding="3"><ul id="outputlink">
                              <xsl:for-each select="config/outputs/output">
                                  <xsl:sort data-type="number" select="@title"/>
                                  <li>
                                      <a target="output">
                                          <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
                                          <xsl:value-of select="@title"/>
                                      </a>
                                  </li>
                              </xsl:for-each>
                          </ul>
                          </td>
                      </tr>

                    </table>
                  </td>
                  <td class="td3">
                      <table class="tbl3" width="100%">
                          <tr class="tr3">
                              <td class="td3" align="right">
                                  Developed by <b><a href="mailto:donald.starquality@gmail.com">DONALD JONES</a></b>
                              </td>
                          </tr>
                          <tr class="tr3">
                              <td class="td3" align="right">
                                    PUT REFERENCE LINKS HERE
                              </td>
                          </tr>
                          <tr class="tr3">
                             <td class="td3" align="right">
                                 <a><xsl:attribute name="href">mailto:donald.starquality@gmail.com?CC=akinros1@email.mot.com
&amp;Subject=Parser Question
&amp;Body=Parser: <xsl:value-of select="//eventlist/@parser"/>%0D
User: <xsl:value-of select="//eventlist/@login"/>%0D
Log: <xsl:value-of select="//eventlist/@name"/>%0D</xsl:attribute>Any corrections/updates</a>
                             </td>
                         </tr>
                      </table>
                  </td>
              </tr>
          </table>


         </body>
     </html>
  </xsl:template>


</xsl:stylesheet>
