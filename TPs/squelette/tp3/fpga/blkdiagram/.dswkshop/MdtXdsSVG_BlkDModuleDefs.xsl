<?xml version="1.0" standalone="no"?>
<xsl:stylesheet version="1.0"
           xmlns:svg="http://www.w3.org/2000/svg"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:exsl="http://exslt.org/common"
           xmlns:xlink="http://www.w3.org/1999/xlink">
                
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
	       doctype-public="-//W3C//DTD SVG 1.0//EN"
		   doctype-system="http://www.w3.org/TR/SVG/DTD/svg10.dtd"/>
			
<xsl:variable name="MOD_LABEL_W"   select="(($BIF_W * 2) + $BIF_GAP)"/>
<xsl:variable name="MOD_LABEL_H"   select="(($BIF_H * 2) + ceiling($BIF_H div 3))"/>
<!--
<xsl:variable name="MOD_LABEL_H"   select="(($BIF_H * 2) + ceiling($BIF_H div 2))"/>
-->

<xsl:variable name="MOD_LANE_W"    select="ceiling($BIF_W div 3)"/>
<xsl:variable name="MOD_LANE_H"    select="ceiling($BIF_H div 4)"/>
<xsl:variable name="MOD_EDGE_W"    select="ceiling($MOD_LANE_W div 2)"/>
<xsl:variable name="MOD_SHAPES_G"  select="($BIF_W + $BIF_W)"/>
<xsl:variable name="MOD_BKTLANE_H" select="$BIF_H"/>
<xsl:variable name="MOD_BKTLANE_W" select="$BIF_H"/>
<xsl:variable name="MOD_BUCKET_G"  select="ceiling($BIF_W div 2)"/>


<!--
<xsl:variable name="MOD_LABEL_W"   select="68"/>
<xsl:variable name="MOD_LABEL_H"   select="24"/>
<xsl:variable name="MOD_LANE_W"    select="11"/>
<xsl:variable name="MOD_LANE_H"    select="4"/>
<xsl:variable name="MOD_EDGE_W"    select="6"/>
<xsl:variable name="MOD_SHAPES_G"  select="64"/>
<xsl:variable name="MOD_BKTLANE_H" select="16"/>
<xsl:variable name="MOD_BKTLANE_W" select="16"/>
<xsl:variable name="MOD_BUCKET_G"  select="16"/>
-->


<xsl:variable name="periMOD_W"  select="(               ($BIF_W * 2) + ($BIF_GAP * 1) + ($MOD_LANE_W * 2))"/>
<xsl:variable name="periMOD_H"  select="($MOD_LABEL_H + ($BIF_H * 1) + ($BIF_GAP * 1) + ($MOD_LANE_H * 2))"/>

<xsl:template name="Print_BlkdModuleDefs">
	<xsl:message>MOD_LABEL_W  : <xsl:value-of select="$MOD_LABEL_W"/></xsl:message>
	<xsl:message>MOD_LABEL_H  : <xsl:value-of select="$MOD_LABEL_H"/></xsl:message>
	
	<xsl:message>MOD_LANE_W   : <xsl:value-of select="$MOD_LANE_W"/></xsl:message>
	<xsl:message>MOD_LANE_H   : <xsl:value-of select="$MOD_LANE_H"/></xsl:message>
	
	<xsl:message>MOD_EDGE_W   : <xsl:value-of select="$MOD_EDGE_W"/></xsl:message>
	<xsl:message>MOD_SHAPES_G : <xsl:value-of select="$MOD_SHAPES_G"/></xsl:message>
	
	<xsl:message>MOD_BKTLANE_W   : <xsl:value-of select="$MOD_BKTLANE_W"/></xsl:message>
	<xsl:message>MOD_BKTLANE_H   : <xsl:value-of select="$MOD_BKTLANE_H"/></xsl:message>
	<xsl:message>MOD_BUCKET_G    : <xsl:value-of select="$MOD_BUCKET_G"/></xsl:message>
	
</xsl:template>	

</xsl:stylesheet>
