<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

		<!-- ===================================================== -->
	<!-- Function: Dec2Hex(<value>[,<digits>]) => Hex string   -->
	<!-- Parameters:-                                          -->
	<!--   <value>  - the decimal value to be converted to hex -->
	<!--              (must be a positive)                     -->
	<!--   <digits> - the number of hex digits required        -->
	<!--              If this parameter is omitted then the    -->
	<!--              hex string returned is as long as reqd.  -->
	<!--              If the number of digits required exceeds -->
	<!--              the value specified by this parameter    -->
	<!--              then the hex string is as long as reqd.  -->
	<xsl:template name="Dec2Hex">
		<xsl:param name="value" select="number(0)"/>
		<xsl:param name="digits" select="number(-1)"/>
		<!-- the following paremeters are used only during recursion -->
		<xsl:param name="hex" select="number(268435456)"/>
		<xsl:param name="hex-power" select="number(28)"/>
		<xsl:param name="nonzero-encounters" select="false()"/>
		<!-- calculate the left over value to be passed to next recursion -->
		<xsl:variable name="remainder" select="floor($value) mod $hex"/>
		<!-- calculate the value of this nybble (this hex digit) -->
		<xsl:variable name="this-nybble" select="(floor($value) - $remainder) div ($hex)"/>
		<!-- determine whether a non-zero digit has been encountered yet -->
		<xsl:variable name="nonzero-encountered" select="boolean($nonzero-encounters or ($this-nybble &gt; 0))"/>
		<!-- only output hex digit if:-                   -->
		<!--     non-zero has already been encountered OR -->
		<!--     on the last digit OR                     -->
		<!--     the number of required digits says so    -->
		<xsl:if test="$nonzero-encountered or ($hex-power = 0) or ((($hex-power div 4) + 1) &lt;= $digits)">
			<xsl:value-of select="substring('0123456789ABCDEF',($this-nybble)+1,1)"/>
		</xsl:if>
		<!-- recursive call until all digits have been dealt with -->
		<xsl:if test="$hex-power &gt; 0">
			<xsl:call-template name="Dec2Hex">
				<xsl:with-param name="value" select="$remainder"/>
				<xsl:with-param name="hex" select="$hex div 16"/>
				<xsl:with-param name="hex-power" select="$hex-power - 4"/>
				<xsl:with-param name="digits" select="$digits"/>
				<xsl:with-param name="nonzero-encounters" select="$nonzero-encountered"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- ======================================================== -->
	<!-- Function: Dec2Bin(<value>) => Binary string              -->
	<!-- Parameters:-                                             -->
	<!--   <value>  - the decimal value to be converted to binary -->
	<!--              (must be a positive)                        -->
	<xsl:template name="Dec2Bin">
		<xsl:param name="value" select="number(0)"/>
		<!-- the following paremeters are used only during recursion -->
		<xsl:param name="bin" select="number(2147483648)"/>
		<xsl:param name="bin-power" select="number(31)"/>
		<xsl:param name="one-encounters" select="false()"/>
		<!-- calculate the left over value to be passed to next recursion -->
		<xsl:variable name="remainder" select="$value mod $bin"/>
		<!-- calculate the value of this bit (this binary digit) -->
		<xsl:variable name="this-bit" select="$value - $remainder"/>
		<!-- determine whether a non-zero digit has been encountered yet -->
		<xsl:variable name="one-encountered" select="boolean($one-encounters or ($this-bit &gt; 0))"/>
		<!-- only output digit if:                        -->
		<!--     non-zero has already been encountered OR -->
		<!--     on the last digit                        -->
		<xsl:if test="$one-encountered or ($bin-power = 0)">
			<xsl:value-of select="substring('01',($this-bit div $bin)+1,1)"/>
		</xsl:if>
		<!-- recursive call until all digits have been dealt with -->
		<xsl:if test="$bin-power &gt; 0">
			<xsl:call-template name="Dec2Bin">
				<xsl:with-param name="value" select="$remainder"/>
				<xsl:with-param name="bin" select="$bin div 2"/>
				<xsl:with-param name="bin-power" select="$bin-power - 1"/>
				<xsl:with-param name="one-encounters" select="$one-encountered"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->