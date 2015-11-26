<?xml version="1.0" standalone="no"?>
<xsl:stylesheet version="1.0"
           xmlns:svg="http://www.w3.org/2000/svg"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:exsl="http://exslt.org/common"
           xmlns:xlink="http://www.w3.org/1999/xlink">
           
<xsl:variable name="COL_RED"        select="'#AAAA00'"/>
<xsl:variable name="COL_GRAY"       select="'#E1E1E1'"/>
<xsl:variable name="COL_BLACK"      select="'#000000'"/>
<xsl:variable name="COL_WHITE"      select="'#FFFFFF'"/>
<xsl:variable name="COL_YELLOW"     select="'#FFFFDD'"/>
<xsl:variable name="COL_YELLOW_LT"  select="'#FFFFEE'"/>				
				
<xsl:variable name="COL_BG"          select="'#CCCCCC'"/>				
<xsl:variable name="COL_BG_LT"       select="'#EEEEEE'"/>				
<xsl:variable name="COL_UNK_BG"      select="'#DDDDDD'"/>				
<xsl:variable name="COL_PROC_BG"     select="'#FFCCCC'"/>				
<xsl:variable name="COL_PROC_BG_MB"  select="'#222222'"/>				
<xsl:variable name="COL_PROC_BG_PP"  select="'#90001C'"/>				
<xsl:variable name="COL_PROC_BG_USR" select="'#666699'"/>				

<xsl:variable name="COL_MOD_BG"      select="'#F0F0F0'"/>				
<xsl:variable name="COL_MOD_SPRT"    select="'#888888'"/>
<xsl:variable name="COL_MOD_MPRT"    select="'#888888'"/>

<xsl:variable name="COL_INTR_0"      select="'#FF9900'"/>
<xsl:variable name="COL_INTR_1"      select="'#00CCCC'"/>
<xsl:variable name="COL_INTR_2"      select="'#FF9933'"/>
<xsl:variable name="COL_INTR_3"      select="'#FF00CC'"/>
<xsl:variable name="COL_INTR_4"      select="'#99FF33'"/>
<xsl:variable name="COL_INTR_5"      select="'#0066CC'"/>
<xsl:variable name="COL_INTR_6"      select="'#9933FF'"/>
<xsl:variable name="COL_INTR_7"      select="'#3300FF'"/>
<xsl:variable name="COL_INTR_8"      select="'#00FF33'"/>
<xsl:variable name="COL_INTR_9"      select="'#FF3333'"/>

<!--
<xsl:variable name="COL_INTR_LT"    select="'#EEEEEE'"/>				
-->

<xsl:variable name="COL_IORING"     select="'#000088'"/>				
<xsl:variable name="COL_IORING_LT"  select="'#CCCCFF'"/>				
<xsl:variable name="COL_SYSPRT"     select="'#0000BB'"/>		        

<xsl:variable name="COL_KEY"        select="'#444444'"/>				
<xsl:variable name="COL_KEY_LT"     select="'#888888'"/>				

<xsl:variable name="COL_LMBBUS"     select="'#7777FF'"/>	
<xsl:variable name="COL_LMBBUS_LT"  select="'#DDDDFF'"/>

<xsl:variable name="COL_OPBBUS"     select="'#339900'"/>				
<xsl:variable name="COL_OPBBUS_LT"  select="'#CCDDCC'"/>				

<xsl:variable name="COL_FCBBUS"     select="'#3399FF'"/>				
<xsl:variable name="COL_FCBBUS_LT"  select="'#CCDDFF'"/>				

<xsl:variable name="COL_PLBBUS"     select="'#FFAA33'"/>				
<xsl:variable name="COL_PLBBUS_LT"  select="'#FFEE33'"/>	

<xsl:variable name="COL_FSLBUS"     select="'#CC00CC'"/>				
<xsl:variable name="COL_FSLBUS_LT"  select="'#FFBBFF'"/>		

<xsl:variable name="COL_TRSBUS"     select="'#009999'"/>				
<xsl:variable name="COL_TRSBUS_LT"  select="'#00CCCC'"/>		

<xsl:variable name="COL_DCRBUS"     select="'#6699FF'"/>				
<xsl:variable name="COL_DCRBUS_LT"  select="'#BBDDFF'"/>	

<xsl:variable name="COL_XILBUS"     select="'#990066'"/>				
<xsl:variable name="COL_XILBUS_LT"  select="'#CC3399'"/>	

<xsl:variable name="COL_SOCMBUS"     select="'#0000DD'"/>				
<xsl:variable name="COL_SOCMBUS_LT"  select="'#9999DD'"/>	

<xsl:variable name="COL_DSOCMBUS"    select="'#0000DD'"/>				
<xsl:variable name="COL_DSOCMBUS_LT" select="'#9999DD'"/>	

<xsl:variable name="COL_ISOCMBUS"    select="'#0000DD'"/>				
<xsl:variable name="COL_ISOCMBUS_LT" select="'#9999DD'"/>

<xsl:variable name="COL_BUSSES">
	<COLORS>
		<COLOR BUS="OPB">
			<RGB><xsl:value-of select="$COL_OPBBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_OPBBUS_LT"/></RGB_LT>
		</COLOR>		
		<COLOR BUS="PLB">
			<RGB><xsl:value-of select="$COL_PLBBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_PLBBUS_LT"/></RGB_LT>
		</COLOR>		
		<COLOR BUS="LMB">
			<RGB><xsl:value-of select="$COL_LMBBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_LMBBUS_LT"/></RGB_LT>
		</COLOR>		
		<COLOR BUS="FSL">
			<RGB><xsl:value-of select="$COL_FSLBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_FSLBUS_LT"/></RGB_LT>
		</COLOR>		
		<COLOR BUS="DCR">
			<RGB><xsl:value-of select="$COL_DCRBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_DCRBUS_LT"/></RGB_LT>
		</COLOR>		
		<COLOR BUS="XIL">
			<RGB><xsl:value-of select="$COL_XILBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_XILBUS_LT"/></RGB_LT>
		</COLOR>		
		<COLOR BUS="TRS">
			<RGB><xsl:value-of select="$COL_TRSBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_TRSBUS_LT"/></RGB_LT>
		</COLOR>		
		<COLOR BUS="FCB">
			<RGB><xsl:value-of select="$COL_FCBBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_FCBBUS_LT"/></RGB_LT>
		</COLOR>		
		<COLOR BUS="SOCM">
			<RGB><xsl:value-of select="$COL_SOCMBUS"/></RGB>
			<RGB_LT><xsl:value-of select="$COL_SOCMBUS_LT"/></RGB_LT>
		</COLOR>		
	</COLORS>
</xsl:variable>

<xsl:template name="BusType2Color">
	<xsl:param name="busType"  select="'OPB'"/>
	<xsl:choose>
		
		<xsl:when test="$busType = 'OPB'"><xsl:value-of select="$COL_OPBBUS"/></xsl:when>
		<xsl:when test="$busType = 'PLB'"><xsl:value-of select="$COL_PLBBUS"/></xsl:when>
		<xsl:when test="$busType = 'FSL'"><xsl:value-of select="$COL_FSLBUS"/></xsl:when>
		<xsl:when test="$busType = 'FCB'"><xsl:value-of select="$COL_FCBBUS"/></xsl:when>
		<xsl:when test="$busType = 'XIL'"><xsl:value-of select="$COL_XILBUS"/></xsl:when>
		<xsl:when test="$busType = 'LMB'"><xsl:value-of select="$COL_LMBBUS"/></xsl:when>
		<xsl:when test="$busType = 'TRS'"><xsl:value-of select="$COL_TRSBUS"/></xsl:when>
		<xsl:when test="$busType = 'DCR'"><xsl:value-of select="$COL_DCRBUS"/></xsl:when>
		<xsl:when test="$busType = 'DSOCM'"><xsl:value-of select="$COL_DSOCMBUS"/></xsl:when>
		<xsl:when test="$busType = 'ISOCM'"><xsl:value-of select="$COL_ISOCMBUS"/></xsl:when>
		<xsl:when test="$busType = 'TARGET'"><xsl:value-of select="$COL_TRSBUS"/></xsl:when>
		<xsl:when test="$busType = 'INITIATOR'"><xsl:value-of select="$COL_TRSBUS"/></xsl:when>
		<xsl:when test="$busType = 'TRANSPARENT'"><xsl:value-of select="$COL_TRSBUS"/></xsl:when>
		
		<xsl:when test="$busType = 'KEY'"><xsl:value-of select="$COL_KEY"/></xsl:when>
		
		<xsl:otherwise>
			<xsl:value-of select="$COL_OPBBUS"/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="BusType2LightColor">
	<xsl:param name="busType"  select="'OPB'"/>
	<xsl:choose>
		<xsl:when test="$busType = 'OPB'"><xsl:value-of select="$COL_OPBBUS_LT"/></xsl:when>
		<xsl:when test="$busType = 'PLB'"><xsl:value-of select="$COL_PLBBUS_LT"/></xsl:when>
		<xsl:when test="$busType = 'FSL'"><xsl:value-of select="$COL_FSLBUS_LT"/></xsl:when>
		<xsl:when test="$busType = 'FCB'"><xsl:value-of select="$COL_FCBBUS_LT"/></xsl:when>
		<xsl:when test="$busType = 'XIL'"><xsl:value-of select="$COL_XILBUS_LT"/></xsl:when>
		<xsl:when test="$busType = 'LMB'"><xsl:value-of select="$COL_LMBBUS_LT"/></xsl:when>
		<xsl:when test="$busType = 'TRS'"><xsl:value-of select="$COL_BG"/></xsl:when>
		<xsl:when test="$busType = 'DCR'"><xsl:value-of select="$COL_WHITE"/></xsl:when>
		<xsl:when test="$busType = 'DSOCM'"><xsl:value-of select="$COL_WHITE"/></xsl:when>
		<xsl:when test="$busType = 'ISOCM'"><xsl:value-of select="$COL_WHITE"/></xsl:when>
		<xsl:when test="$busType = 'TARGET'"><xsl:value-of select="$COL_TRSBUS_LT"/></xsl:when>
		<xsl:when test="$busType = 'INITIATOR'"><xsl:value-of select="$COL_TRSBUS_LT"/></xsl:when>
		<xsl:when test="$busType = 'TRANSPARENT'"><xsl:value-of select="$COL_TRSBUS_LT"/></xsl:when>
		
		<xsl:when test="$busType = 'KEY'"><xsl:value-of select="$COL_KEY_LT"/></xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$COL_OPBBUS_LT"/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="intcIdx2Color">
	<xsl:param name="intcIdx"  select="'0'"/>

	<xsl:variable name="idx_" select="$intcIdx mod 9"/>
	
	<xsl:choose>
		<xsl:when test="$idx_ = '0'"><xsl:value-of select="$COL_INTR_0"/></xsl:when>
		<xsl:when test="$idx_ = '1'"><xsl:value-of select="$COL_INTR_1"/></xsl:when>
		<xsl:when test="$idx_ = '2'"><xsl:value-of select="$COL_INTR_2"/></xsl:when>
		<xsl:when test="$idx_ = '3'"><xsl:value-of select="$COL_INTR_3"/></xsl:when>
		<xsl:when test="$idx_ = '4'"><xsl:value-of select="$COL_INTR_4"/></xsl:when>
		<xsl:when test="$idx_ = '5'"><xsl:value-of select="$COL_INTR_5"/></xsl:when>
		<xsl:when test="$idx_ = '6'"><xsl:value-of select="$COL_INTR_6"/></xsl:when>
		<xsl:when test="$idx_ = '7'"><xsl:value-of select="$COL_INTR_7"/></xsl:when>
		<xsl:when test="$idx_ = '8'"><xsl:value-of select="$COL_INTR_8"/></xsl:when>
		<xsl:when test="$idx_ = '9'"><xsl:value-of select="$COL_INTR_9"/></xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$COL_INTR_0"/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>
