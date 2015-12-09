<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html"
                encoding="UTF-8"/>

    <xsl:variable name="sev_critical" select="0"/>
    <xsl:variable name="sev_major" select="1"/>
    <xsl:variable name="sev_minor" select="2"/>
    <xsl:variable name="sev_intermit" select="3"/>
    <xsl:variable name="sev_info" select="4"/>
    <xsl:variable name="sev_clear" select="5"/>
    <xsl:variable name="num_date" select="count(//event[@date])"/>
    <xsl:variable name="num_event" select="count(//event[@event])"/>
    <xsl:variable name="num_tag" select="count(//event[@tag])"/>
    <xsl:variable name="num_from" select="count(//event[@from])"/>
    <xsl:variable name="num_msgs" select="count(//event[@msg])"/>

    <xsl:variable name="oddeven_line" select="'odd'"/>

    <xsl:variable name="oddeven_date">
      <xsl:choose>
        <xsl:when test="$num_date = 0">odd</xsl:when>
        <xsl:when test="$oddeven_line='odd'"> </xsl:when>  <!-- oddeven_line is always odd -->
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oddeven_sev">
      <xsl:choose>
        <xsl:when test="$oddeven_date='odd'"> </xsl:when>
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oddeven_event">
      <xsl:choose>
        <xsl:when test="$num_event = 0"><xsl:value-of select="$oddeven_sev"/></xsl:when>
        <xsl:when test="$oddeven_sev='odd'"> </xsl:when>
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oddeven_tag">
      <xsl:choose>
        <xsl:when test="$num_tag = 0"><xsl:value-of select="$oddeven_event"/></xsl:when>
        <xsl:when test="$oddeven_event='odd'"> </xsl:when>
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oddeven_msg">
      <xsl:choose>
        <xsl:when test="$num_msgs = 0"><xsl:value-of select="$oddeven_tag"/></xsl:when>
        <xsl:when test="$oddeven_tag='odd'"> </xsl:when>
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oddeven_from">
      <xsl:choose>
        <xsl:when test="$num_from = 0"><xsl:value-of select="$oddeven_msg"/></xsl:when>
        <xsl:when test="$oddeven_msg='odd'"> </xsl:when>
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oddeven_to">
      <xsl:choose>
        <xsl:when test="$oddeven_from='odd'"> </xsl:when>
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oddeven_data_hdr">
      <xsl:choose>
        <xsl:when test="$oddeven_to='odd'"> </xsl:when>
        <xsl:otherwise>odd</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oddeven_data_body">
      <xsl:choose>
        <xsl:when test="$oddeven_to='odd'">alignleft</xsl:when>
        <xsl:otherwise>oddleft</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:template match="/eventlist">

    <html>
      <head>
        <title>MSc extracted from <xsl:value-of select="@name"/></title>
        <link rel="stylesheet" type="text/css" href="debug_ref.css" />
      </head>
      <!--<body style="font-family: arial, geneva;font-size: 8pt">-->
        <h1>Events:</h1>
        <div>
          <!--<table width="100%" cellpadding="0" cellspacing="1">-->
          <table class="tbl1" cellpadding="0" cellspacing="0">
            <!--<thead border="1" bgcolor="#66ffff">-->
            <thead>
              <th scope="col">
                <xsl:attribute name="class">
                  <xsl:value-of select="$oddeven_line"/>
                </xsl:attribute>Line
              </th>

              <xsl:if test="$num_date">
                <th scope="col">
                  <xsl:attribute name="class">
                    <xsl:value-of select="$oddeven_date"/>
                  </xsl:attribute>Date
                </th>
              </xsl:if>

              <th scope="col">
                <xsl:attribute name="class">
                  <xsl:value-of select="$oddeven_sev"/>
                </xsl:attribute>Severity
              </th>

              <xsl:if test="$num_event">
                <th scope="col">
                  <xsl:attribute name="class">
                    <xsl:value-of select="$oddeven_event"/>
                  </xsl:attribute>Event
                </th>
              </xsl:if>

              <xsl:if test="$num_tag">
                <th scope="col">
                  <xsl:attribute name="class">
                    <xsl:value-of select="$oddeven_tag"/>
                  </xsl:attribute>Tag
                </th>
              </xsl:if>

              <xsl:if test="$num_msgs">
                <th scope="col">
                  <xsl:attribute name="class">
                    <xsl:value-of select="$oddeven_msg"/>
                  </xsl:attribute>Message
                </th>
              </xsl:if>

              <xsl:if test="$num_from">
                <th scope="col">
                  <xsl:attribute name="class">
                    <xsl:value-of select="$oddeven_from"/>
                  </xsl:attribute>From
                </th>
              </xsl:if>

              <th scope="col">
                <xsl:attribute name="class">
                  <xsl:value-of select="$oddeven_to"/>
                </xsl:attribute>To
              </th>

              <th scope="col">
                <xsl:attribute name="class">
                  <xsl:value-of select="$oddeven_data_hdr"/>
                </xsl:attribute>Data
              </th>

              <!--<th>Text</th>-->

            </thead>
            <tbody>
              <xsl:for-each select="event">
                <xsl:sort select="@line" data-type="number"/>
                <tr>
                  <td>
                    <xsl:attribute name="class">
                      <xsl:value-of select="$oddeven_line"/>
                    </xsl:attribute><a target="output"><xsl:attribute name="href"><xsl:value-of select="../@logname"/>.html#L<xsl:value-of select="@line"/></xsl:attribute><xsl:value-of select="@line"/></a>
                  </td>

                  <!-- Only print dates if there are any in the xml-->
                  <xsl:if test="$num_date">
                    <td>
                      <xsl:attribute name="class">
                        <xsl:value-of select="$oddeven_date"/>
                      </xsl:attribute>
                      <xsl:choose>
                        <xsl:when test="string(@date)"><xsl:value-of select="@date"/></xsl:when>
                        <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </xsl:if>

                  <td>
                    <xsl:choose>
                      <!-- do not set table cell class to odd if using get sev colour -->
                      <xsl:when test="not(@type='sc|msg')">
                        <xsl:variable name="sev_colour">
                          <xsl:call-template name="getSevColour">
                            <xsl:with-param name="sev" select="@sev"/>
                          </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                          <!-- set table background to sev colour -->
                          <xsl:when test="string($sev_colour)">
                            <xsl:attribute name="bgcolor">
                              <xsl:value-of select="$sev_colour"/>
                            </xsl:attribute>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:attribute name="class">
                              <xsl:value-of select="$oddeven_sev"/>
                            </xsl:attribute>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="class">
                          <xsl:value-of select="$oddeven_sev"/>
                        </xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="@type='sc|msg'">
                        <xsl:choose>
                          <xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
                          <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="@sev"><xsl:value-of select="@sev"/></xsl:when>
                          <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>

                  <!-- Only print events if there are any in the xml-->
                  <xsl:if test="$num_event">
                    <td>
                      <xsl:attribute name="class">
                        <xsl:value-of select="$oddeven_event"/>
                      </xsl:attribute>
                      <xsl:choose>
                        <xsl:when test="@type='ev'">
                          <xsl:choose>
                            <xsl:when test="@url">
                              <a target="_blank"><xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute><xsl:value-of select="@event"/></a>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:choose>
                                <xsl:when test="@event"><xsl:value-of select="@event"/></xsl:when>
                                <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                              </xsl:choose>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:choose>
                            <xsl:when test="@event"><xsl:value-of select="@event"/></xsl:when>
                            <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                          </xsl:choose>
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </xsl:if>

                  <!-- Only print tags if there are any in the xml-->
                  <xsl:if test="$num_tag">
                    <td>
                      <xsl:attribute name="class">
                        <xsl:value-of select="$oddeven_tag"/>
                      </xsl:attribute>
                      <xsl:choose>
                        <xsl:when test="@tag"><xsl:value-of select="@tag"/></xsl:when>
                        <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </xsl:if>

                  <!-- Only print messages if there are any in the xml-->
                  <xsl:if test="$num_msgs">
                    <td>
                      <xsl:attribute name="class">
                        <xsl:value-of select="$oddeven_msg"/>
                      </xsl:attribute>
                      <xsl:choose>
                        <xsl:when test="@url">
                          <xsl:choose>
                            <xsl:when test="@msg">
                              <a target="_blank"><xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute><xsl:value-of select="@msg"/></a>
                            </xsl:when>
                            <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:choose>
                            <xsl:when test="@msg"><xsl:value-of select="@msg"/></xsl:when>
                            <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                          </xsl:choose>
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </xsl:if>

                  <!-- Only print from field if there are any in the xml-->
                  <xsl:if test="$num_from">
                    <td>
                      <xsl:attribute name="class">
                        <xsl:value-of select="$oddeven_from"/>
                      </xsl:attribute>
                      <xsl:choose>
                        <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                        <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </xsl:if>

                  <td>
                    <xsl:attribute name="class">
                      <xsl:value-of select="$oddeven_to"/>
                    </xsl:attribute>
                    <xsl:choose>
                      <xsl:when test="@type = 'msg'" >
                        <xsl:choose>
                          <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                          <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="@node"><xsl:value-of select="@node"/></xsl:when>
                          <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>

                  <td>
                    <xsl:attribute name="class">
                      <xsl:value-of select="$oddeven_data_body"/>
                    </xsl:attribute>
                    <xsl:choose>
                      <xsl:when test="@type='sc'">
                        <xsl:choose>
                          <xsl:when test="@state"><xsl:value-of select="@state"/></xsl:when>
                          <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="@data"><xsl:value-of select="@data"/></xsl:when>
                          <xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>

                </tr>
              </xsl:for-each>
            </tbody>
          </table>
        </div>
      <!--</body>-->
    </html>
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

</xsl:stylesheet>