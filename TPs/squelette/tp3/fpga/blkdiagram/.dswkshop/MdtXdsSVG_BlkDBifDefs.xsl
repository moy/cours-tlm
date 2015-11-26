<?xml version="1.0" standalone="no"?>
<xsl:stylesheet version="1.0"
           xmlns:svg="http://www.w3.org/2000/svg"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:exsl="http://exslt.org/common"
           xmlns:xlink="http://www.w3.org/1999/xlink">
                
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
	       doctype-public="-//W3C//DTD SVG 1.0//EN"
		   doctype-system="http://www.w3.org/TR/SVG/DTD/svg10.dtd"/>
			
<xsl:param name="BIF_H"     select="16"/>				
<xsl:param name="BIF_W"     select="32"/>				
<xsl:param name="BIF_GAP"   select="ceiling($BIF_H div 4)"/>				

<!--
<xsl:param name="BIF_GAP"   select="16"/>				
<xsl:param name="BIFC_H"    select="16"/>				
<xsl:param name="BIFC_W"    select="16"/>				
<xsl:param name="BIFC_dx"   select="4"/>				
<xsl:param name="BIFC_dy"   select="4"/>				

<xsl:param name="BIF_MC_H"  select="8"/>				
<xsl:param name="BIF_MC_W"  select="8"/>				
<xsl:param name="BIF_SC_R"  select="ceiling($BIF_MC_H div 2) + 1"/>				
<xsl:param name="BIFC_Hi"   select="($BIFC_H - ($BIFC_dy *2))"/>	
<xsl:param name="BIFC_Wi"   select="($BIFC_W - ($BIFC_dx *2))"/>
-->

<!--
<xsl:param name="BIFC_H"    select="$BIF_H"/>				
<xsl:param name="BIFC_W"    select="ceiling($BIF_W  div 2)"/>				
-->

<xsl:param name="BIFC_H"    select="20"/>				
<xsl:param name="BIFC_W"    select="20"/>				

<xsl:param name="BIFC_dx"   select="ceiling($BIFC_W div 4)"/>
<xsl:param name="BIFC_dy"   select="ceiling($BIFC_H div 4)"/>
<xsl:param name="BIFC_Hi"   select="($BIFC_H - ($BIFC_dy * 2))"/>	
<xsl:param name="BIFC_Wi"   select="($BIFC_W - ($BIFC_dx * 2))"/>


<!-- ======================= DEF BLOCK =================================== -->
<xsl:template name="Define_BifTypes">
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'OPB'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'OPB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'PLB'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'PLB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'LMB'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'LMB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'FSL'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'FSL'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'FCB'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'FCB'"/>
	</xsl:call-template>

	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'XIL'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'XIL'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'TRS'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'TRS'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'DCR'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'DCR'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'DSOCM'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'DSOCM'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'ISOCM'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'ISOCM'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'TRANSPARENT'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'TRANSPARENT'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BifType"> 
		<xsl:with-param name="bus_type"    select="'KEY'"/>
	</xsl:call-template>
	<xsl:call-template name="Define_BifBusConnectors"> 
		<xsl:with-param name="bus_type"    select="'KEY'"/>
	</xsl:call-template>

</xsl:template>


<xsl:template name="Define_BifType"> 
	
	<xsl:param name="bus_type"    select="'OPB'"/>
	
	<xsl:variable name="bus_col_">
		<xsl:call-template name="BusType2Color">
			<xsl:with-param name="busType" select="$bus_type"/>
		</xsl:call-template>	
	</xsl:variable>
			
    <symbol id="{$bus_type}_Bif">
		<rect x="0"  
			  y="0" 
			  rx="3"
			  ry="3"
			  width= "{$BIF_W}" 
			  height="{$BIF_H}" 
			  style="fill:{$bus_col_}; stroke:black; stroke-width:1"/> 
	</symbol>
	
</xsl:template>

<xsl:template name="Define_BifBusConnectors"> 
	
	<xsl:param name="bus_type"    select="'OPB'"/>
	
	<xsl:variable name="bus_col_">
		<xsl:call-template name="BusType2Color">
			<xsl:with-param name="busType" select="$bus_type"/>
		</xsl:call-template>	
	</xsl:variable>
	
	<xsl:variable name="bus_col_lt_">
		<xsl:call-template name="BusType2LightColor">
			<xsl:with-param name="busType" select="$bus_type"/>
		</xsl:call-template>	
	</xsl:variable>
	
	<xsl:variable name="bifc_wi_" select="ceiling($BIFC_W div 3)"/>
	<xsl:variable name="bifc_hi_" select="ceiling($BIFC_H div 3)"/>
	
    <symbol id="{$bus_type}_busconn_MASTER">
		<rect x="0"  
			  y="0" 
			  width= "{$BIFC_W}" 
			  height="{$BIFC_H}" 
			  style="fill:{$bus_col_lt_}; stroke:{$bus_col_}; stroke-width:1"/> 
			  
		<rect x="{$BIFC_dx + 0.5}"  
			  y="{$BIFC_dy}" 
			  width= "{$BIFC_Wi}" 
			  height="{$BIFC_Hi}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
	</symbol>
	
    <symbol id="{$bus_type}_busconn_INITIATOR">
		<rect x="0"  
			  y="0" 
			  width= "{$BIFC_W}" 
			  height="{$BIFC_H}" 
			  style="fill:{$bus_col_lt_}; stroke:{$bus_col_}; stroke-width:1"/> 
			  
		<rect x="{$BIFC_dx + 0.5}"  
			  y="{$BIFC_dy}" 
			  width= "{$BIFC_Wi}" 
			  height="{$BIFC_Hi}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
	</symbol>
	
    <symbol id="{$bus_type}_busconn_SLAVE">
		<circle 
			  cx="{ceiling($BIFC_W div 2)}"  
			  cy="{ceiling($BIFC_H div 2)}" 
			  r="{ceiling($BIFC_W  div 2)}" 
			  style="fill:{$bus_col_lt_}; stroke:{$bus_col_}; stroke-width:1"/> 
			  
		<circle 
			  cx="{ceiling($BIFC_W div 2) + 0.5}"  
			  cy="{ceiling($BIFC_H div 2)}" 
			  r="{ceiling($BIFC_Wi div 2)}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
	</symbol>
	
    <symbol id="{$bus_type}_busconn_TARGET">
		<circle 
			  cx="{ceiling($BIFC_W div 2)}"  
			  cy="{ceiling($BIFC_H div 2)}" 
			  r="{ceiling($BIFC_W  div 2)}" 
			  style="fill:{$bus_col_lt_}; stroke:{$bus_col_}; stroke-width:1"/> 
			  
		<circle 
			  cx="{ceiling($BIFC_W div 2) + 0.5}"  
			  cy="{ceiling($BIFC_H div 2)}" 
			  r="{ceiling($BIFC_Wi div 2)}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
	</symbol>
	
	
    <symbol id="{$bus_type}_busconn_MASTER_SLAVE">
		<circle 
			  cx="{ceiling($BIFC_W div 2)}"  
			  cy="{ceiling($BIFC_H div 2)}" 
			  r="{ceiling($BIFC_W  div 2)}" 
			  style="fill:{$bus_col_lt_}; stroke:{$bus_col_}; stroke-width:1"/> 
			  
		<circle 
			  cx="{ceiling($BIFC_W div 2) + 0.5}"  
			  cy="{ceiling($BIFC_H div 2)}" 
			  r="{ceiling($BIFC_Wi div 2)}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
			  
		<rect x="0"  
			  y="{ceiling($BIFC_H div 2)}" 
			  width= "{$BIFC_W}" 
			  height="{ceiling($BIFC_H div 2)}" 
			  style="fill:{$bus_col_lt_}; stroke:{$bus_col_}; stroke-width:1"/> 
			  
		<rect x="{$BIFC_dx + 0.5}"  
			  y="{ceiling($BIFC_H div 2)}" 
			  width= "{$BIFC_Wi}" 
			  height="{ceiling($BIFC_Hi div 2)}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
			  
	</symbol>

    <symbol id="{$bus_type}_busconn_MONITOR">
		
		<rect x="0"  
			  y="0.5" 
			  width= "{$BIFC_W}" 
			  height="{ceiling($BIFC_Hi div 2)}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
			  
		<rect x="0"  
			  y="{ceiling($BIFC_H div 2) + 4}" 
			  width= "{$BIFC_W}" 
			  height="{ceiling($BIFC_Hi div 2)}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
			  
	</symbol>
	
    <symbol id="{$bus_type}_busconn_TRANSPARENT">
    
		<circle 
			  cx="{ceiling($BIFC_W div 2)}"  
			  cy="{ceiling($BIFC_H div 2)}" 
			  r="{ceiling($BIFC_W  div 2)}" 
			  style="fill:{$bus_col_lt_}; stroke:{$bus_col_}; stroke-width:1"/> 
			  
		<circle 
			  cx="{ceiling($BIFC_W div 2) + 0.5}"  
			  cy="{ceiling($BIFC_H div 2)}" 
			  r="{ceiling($BIFC_Wi div 2)}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 
		
	</symbol>
	
	
</xsl:template>

</xsl:stylesheet>
