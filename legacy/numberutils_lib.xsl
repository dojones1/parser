<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
==========================================================================
 Stylesheet: numberutils_lib.xsl
    Version: 1.0 (2002-01-21)
     Author: Martin "Marrow" Rowlinson
     Notice: (c)2001,2002 MarrowSoft Limited.  ALL RIGHTS RESERVED.
             No limitation on use - except this code may not be published,
             in whole or in part, without prior written consent of copyright
             owner.
========================================================================== -->

<!-- ========================================================= -->
<!-- Function: Bin2Dec(<value>) => Decimal value               -->
<!-- Parameters:-                                              -->
<!--   <value>  - the binary string to be converted to decimal -->
<xsl:template name="Bin2Dec">
	<xsl:param name="value" select="'0'"/>
	<!-- the following paremeters are used only during recursion -->
	<xsl:param name="bin-power" select="number(1)"/>
	<xsl:param name="accum" select="number(0)"/>
	<!-- isolate last binary digit  -->
	<xsl:variable name="bin-digit" select="substring($value,string-length($value),1)"/>
	<!-- check that binary digit is valid -->
	<xsl:choose>
		<xsl:when test="not(contains('01',$bin-digit))">
			<!-- not a binary digit! -->
			<xsl:text>NaN</xsl:text>
		</xsl:when>
		<xsl:when test="string-length($bin-digit) = 0">
			<!-- unexpected end of hex string -->
			<xsl:text>0</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<!-- OK so far -->
			<xsl:variable name="remainder" select="substring($value,1,string-length($value)-1)"/>
			<xsl:variable name="this-digit-value" select="number($bin-digit) * $bin-power"/>
			<!-- determine whether this is the end of the hex string -->
			<xsl:choose>
				<xsl:when test="string-length($remainder) = 0">
					<!-- end - output final result -->
					<xsl:value-of select="$accum + $this-digit-value"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- recurse to self for next digit -->
					<xsl:call-template name="Bin2Dec">
						<xsl:with-param name="value" select="$remainder"/>
						<xsl:with-param name="bin-power" select="$bin-power * 2"/>
						<xsl:with-param name="accum" select="$accum + $this-digit-value"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ======================================================== -->
<!-- Function: Hex2Dec(<value>) => Decimal value              -->
<!-- Parameters:-                                             -->
<!--   <value>  - the hex string to be converted to decimal   -->
<!--              (case of hex string is unimportant)         -->
<xsl:template name="Hex2Dec">
	<xsl:param name="value" select="'0'"/>
	<!-- the following paremeters are used only during recursion -->
	<xsl:param name="hex-power" select="number(1)"/>
	<xsl:param name="accum" select="number(0)"/>
	<!-- isolate last hex digit (and convert it to upper case) -->
	<xsl:variable name="hex-digit" select="translate(substring($value,string-length($value),1),'abcdef','ABCDEF')"/>
	<!-- check that hex digit is valid -->
	<xsl:choose>
		<xsl:when test="not(contains('0123456789ABCDEF',$hex-digit))">
			<!-- not a hex digit! -->
			<xsl:text>NaN</xsl:text>
		</xsl:when>
		<xsl:when test="string-length($hex-digit) = 0">
			<!-- unexpected end of hex string -->
			<xsl:text>0</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<!-- OK so far -->
			<xsl:variable name="remainder" select="substring($value,1,string-length($value)-1)"/>
			<xsl:variable name="this-digit-value" select="string-length(substring-before('0123456789ABCDEF',$hex-digit)) * $hex-power"/>
			<!-- determine whether this is the end of the hex string -->
			<xsl:choose>
				<xsl:when test="string-length($remainder) = 0">
					<!-- end - output final result -->
					<xsl:value-of select="$accum + $this-digit-value"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- recurse to self for next digit -->
					<xsl:call-template name="Hex2Dec">
						<xsl:with-param name="value" select="$remainder"/>
						<xsl:with-param name="hex-power" select="$hex-power * 16"/>
						<xsl:with-param name="accum" select="$accum + $this-digit-value"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

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

<!-- ======================================================== -->
<!-- Function: BinAND(<bin1>,<bin2>) => Binary string         -->
<!-- Parameters:-                                             -->
<!--   <bin1>  - the first binary string number to be ANDed   -->
<!--   <bin2>  - the second binary string number to be ANDed  -->
<xsl:template name="BinAND">
	<xsl:param name="bin1" select="'0'"/>
	<xsl:param name="bin2" select="'0'"/>
	<!-- param used for recursion iteration -->
	<xsl:param name="i" select="number(1)"/>
	<xsl:variable name="max-len">
		<xsl:choose>
			<xsl:when test="string-length($bin1) &gt; string-length($bin2)"><xsl:value-of select="string-length($bin1)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="string-length($bin2)"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="sbin1" select="substring(concat(substring('00000000000000000000000000000000',1,$max-len - string-length($bin1)),$bin1),$i,1)"/>
	<xsl:variable name="sbin2" select="substring(concat(substring('00000000000000000000000000000000',1,$max-len - string-length($bin2)),$bin2),$i,1)"/>
	<xsl:choose>
		<xsl:when test="$sbin1 = '1' and $sbin2 = '1'"><xsl:text>1</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$i &lt; $max-len">
		<xsl:call-template name="BinAND">
			<xsl:with-param name="bin1" select="$bin1"/>
			<xsl:with-param name="bin2" select="$bin2"/>
			<xsl:with-param name="i" select="$i + 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- ======================================================== -->
<!-- Function: BinOR(<bin1>,<bin2>) => Binary string          -->
<!-- Parameters:-                                             -->
<!--   <bin1>  - the first binary string number to be ORed    -->
<!--   <bin2>  - the second binary string number to be ORed   -->
<xsl:template name="BinOR">
	<xsl:param name="bin1" select="'0'"/>
	<xsl:param name="bin2" select="'0'"/>
	<!-- param used for recursion iteration -->
	<xsl:param name="i" select="number(1)"/>
	<xsl:variable name="max-len">
		<xsl:choose>
			<xsl:when test="string-length($bin1) &gt; string-length($bin2)"><xsl:value-of select="string-length($bin1)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="string-length($bin2)"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="sbin1" select="substring(concat(substring('00000000000000000000000000000000',1,$max-len - string-length($bin1)),$bin1),$i,1)"/>
	<xsl:variable name="sbin2" select="substring(concat(substring('00000000000000000000000000000000',1,$max-len - string-length($bin2)),$bin2),$i,1)"/>
	<xsl:choose>
		<xsl:when test="$sbin1 = '1' or $sbin2 = '1'"><xsl:text>1</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$i &lt; $max-len">
		<xsl:call-template name="BinOR">
			<xsl:with-param name="bin1" select="$bin1"/>
			<xsl:with-param name="bin2" select="$bin2"/>
			<xsl:with-param name="i" select="$i + 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- ======================================================== -->
<!-- Function: BinXOR(<bin1>,<bin2>) => Binary string         -->
<!-- Parameters:-                                             -->
<!--   <bin1>  - the first binary string number to be XORed   -->
<!--   <bin2>  - the second binary string number to be XORed  -->
<xsl:template name="BinXOR">
	<xsl:param name="bin1" select="'0'"/>
	<xsl:param name="bin2" select="'0'"/>
	<!-- param used for recursion iteration -->
	<xsl:param name="i" select="number(1)"/>
	<xsl:variable name="max-len">
		<xsl:choose>
			<xsl:when test="string-length($bin1) &gt; string-length($bin2)"><xsl:value-of select="string-length($bin1)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="string-length($bin2)"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="sbin1" select="substring(concat(substring('00000000000000000000000000000000',1,$max-len - string-length($bin1)),$bin1),$i,1)"/>
	<xsl:variable name="sbin2" select="substring(concat(substring('00000000000000000000000000000000',1,$max-len - string-length($bin2)),$bin2),$i,1)"/>
	<xsl:choose>
		<xsl:when test="$sbin1 = '1' and $sbin2 = '1'"><xsl:text>0</xsl:text></xsl:when>
		<xsl:when test="$sbin1 = '1' or $sbin2 = '1'"><xsl:text>1</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$i &lt; $max-len">
		<xsl:call-template name="BinXOR">
			<xsl:with-param name="bin1" select="$bin1"/>
			<xsl:with-param name="bin2" select="$bin2"/>
			<xsl:with-param name="i" select="$i + 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- ======================================================== -->
<!-- Function: BinNOT(<bin>) => Binary string                 -->
<!-- Parameters:-                                             -->
<!--   <bin>  - the binary string number to be NOTed          -->
<xsl:template name="BinNOT">
	<xsl:param name="bin" select="'0'"/>
	<xsl:param name="max-bits" select="number(32)"/>
	<xsl:variable name="not1" select="translate($bin,'01','10')"/>
	<xsl:value-of select="concat(substring('11111111111111111111111111111111',1,$max-bits - string-length($not1)),$not1)"/>
</xsl:template>

<!-- ======================================================== -->
<!-- Function: BooleanOR(<value1>,<value2>) => number         -->
<!-- Parameters:-                                             -->
<!--   <value1>  - the first number to be ORed                -->
<!--   <value2>  - the second number to be ORed               -->
<!-- NB. Only works with positive numbers!                    -->
<xsl:template name="BooleanOR">
	<xsl:param name="value1" select="number(0)"/>
	<xsl:param name="value2" select="number(0)"/>
	<!-- recurse parameters -->
	<xsl:param name="bitval" select="number(2147483648)"/>
	<xsl:param name="accum" select="number(0)"/>
	<!-- calc bits present on values -->
	<xsl:variable name="bit1" select="floor($value1 div $bitval)"/>
	<xsl:variable name="bit2" select="floor($value2 div $bitval)"/>
	<!-- do the OR on the bits -->
	<xsl:variable name="thisbit">
		<xsl:choose>
			<xsl:when test="($bit1 != 0) or ($bit2 != 0)"><xsl:value-of select="$bitval"/></xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- if last recurse then output the value -->
	<xsl:choose>
		<xsl:when test="$bitval = 1"><xsl:value-of select="$accum + $thisbit"/></xsl:when>
		<xsl:otherwise>
			<!-- recurse required -->
			<xsl:call-template name="BooleanOR">
				<xsl:with-param name="value1" select="$value1 mod $bitval"/>
				<xsl:with-param name="value2" select="$value2 mod $bitval"/>
				<xsl:with-param name="bitval" select="$bitval div 2"/>
				<xsl:with-param name="accum" select="$accum + $thisbit"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ======================================================== -->
<!-- Function: BooleanAND(<value1>,<value2>) => number        -->
<!-- Parameters:-                                             -->
<!--   <value1>  - the first number to be ANDed               -->
<!--   <value2>  - the second number to be ANDed              -->
<!-- NB. Only works with positive numbers!                    -->
<xsl:template name="BooleanAND">
	<xsl:param name="value1" select="number(0)"/>
	<xsl:param name="value2" select="number(0)"/>
	<!-- recurse parameters -->
	<xsl:param name="bitval" select="number(2147483648)"/>
	<xsl:param name="accum" select="number(0)"/>
	<!-- calc bits present on values -->
	<xsl:variable name="bit1" select="floor($value1 div $bitval)"/>
	<xsl:variable name="bit2" select="floor($value2 div $bitval)"/>
	<!-- do the OR on the bits -->
	<xsl:variable name="thisbit">
		<xsl:choose>
			<xsl:when test="($bit1 != 0) and ($bit2 != 0)"><xsl:value-of select="$bitval"/></xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- if last recurse then output the value -->
	<xsl:choose>
		<xsl:when test="$bitval = 1"><xsl:value-of select="$accum + $thisbit"/></xsl:when>
		<xsl:otherwise>
			<!-- recurse required -->
			<xsl:call-template name="BooleanAND">
				<xsl:with-param name="value1" select="$value1 mod $bitval"/>
				<xsl:with-param name="value2" select="$value2 mod $bitval"/>
				<xsl:with-param name="bitval" select="$bitval div 2"/>
				<xsl:with-param name="accum" select="$accum + $thisbit"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ======================================================== -->
<!-- Function: BooleanXOR(<value1>,<value2>) => number        -->
<!-- Parameters:-                                             -->
<!--   <value1>  - the first number to be XORed               -->
<!--   <value2>  - the second number to be XORed              -->
<!-- NB. Only works with positive numbers!                    -->
<xsl:template name="BooleanXOR">
	<xsl:param name="value1" select="number(0)"/>
	<xsl:param name="value2" select="number(0)"/>
	<!-- recurse parameters -->
	<xsl:param name="bitval" select="number(2147483648)"/>
	<xsl:param name="accum" select="number(0)"/>
	<!-- calc bits present on values -->
	<xsl:variable name="bit1" select="floor($value1 div $bitval)"/>
	<xsl:variable name="bit2" select="floor($value2 div $bitval)"/>
	<!-- do the XOR on the bits -->
	<xsl:variable name="thisbit">
		<xsl:choose>
			<xsl:when test="(($bit1 != 0) and ($bit2 = 0)) or (($bit1 = 0) and ($bit2 != 0))"><xsl:value-of select="$bitval"/></xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- if last recurse then output the value -->
	<xsl:choose>
		<xsl:when test="$bitval = 1"><xsl:value-of select="$accum + $thisbit"/></xsl:when>
		<xsl:otherwise>
			<!-- recurse required -->
			<xsl:call-template name="BooleanXOR">
				<xsl:with-param name="value1" select="$value1 mod $bitval"/>
				<xsl:with-param name="value2" select="$value2 mod $bitval"/>
				<xsl:with-param name="bitval" select="$bitval div 2"/>
				<xsl:with-param name="accum" select="$accum + $thisbit"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>