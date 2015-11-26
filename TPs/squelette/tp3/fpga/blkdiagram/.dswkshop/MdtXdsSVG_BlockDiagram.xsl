<?xml version="1.0" standalone="no"?>
<xsl:stylesheet version="1.0"
           xmlns:svg="http://www.w3.org/2000/svg"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:exsl="http://exslt.org/common"
           xmlns:xlink="http://www.w3.org/1999/xlink">
		   
<xsl:include href="MdtXdsSVG_Colors.xsl"/>

<xsl:include href="MdtXdsSVG_BlkDBifDefs.xsl"/>
<xsl:include href="MdtXdsSVG_BlkDModuleDefs.xsl"/>

<xsl:include href="MdtXdsSVG_BlkdBusses.xsl"/>
<xsl:include href="MdtXdsSVG_BlkdIOPorts.xsl"/>
<xsl:include href="MdtXdsSVG_BlkdProcessors.xsl"/>
<xsl:include href="MdtXdsSVG_BlkDPeripherals.xsl"/>

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
	       doctype-public="-//W3C//DTD SVG 1.0//EN"
		   doctype-system="svg10.dtd"/>
		   
<!--
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
	       doctype-public="-//W3C//DTD SVG 1.0//EN"
		   doctype-system="http://www.w3.org/TR/SVG/DTD/svg10.dtd"/>
<xsl:variable name="BLKD_W"         select="1000"/>
<xsl:variable name="BLKD_H"         select="1000"/>				
-->

<xsl:variable name="BLKD_IORCHAN_H"     select="$BIF_H"/>
<xsl:variable name="BLKD_IORCHAN_W"     select="$BIF_H"/>
<xsl:variable name="BLKD_PRTCHAN_H"     select="($BIF_H * 2) + ceiling($BIF_H div 2)"/>
<xsl:variable name="BLKD_PRTCHAN_W"     select="($BIF_H * 2) + ceiling($BIF_H div 2) + 8"/>
<xsl:variable name="BLKD_DRAWAREA_MIN"  select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * 3) + ($MOD_BUCKET_G * 2)))"/>

<xsl:variable name="BLKD_KEY_W"         select="($BLKD_DRAWAREA_MIN + ceiling($BLKD_DRAWAREA_MIN div 2.5))"/>
<xsl:variable name="BLKD_KEY_H"         select="250"/>

<xsl:variable name="BLKD_SPECS_W"       select="300"/>
<xsl:variable name="BLKD_SPECS_H"       select="100"/>

<xsl:variable name="SBS2IP_GAP"         select="$periMOD_H"/>
<xsl:variable name="IP2UNK_GAP"         select="$periMOD_H"/>
<xsl:variable name="PROC2SBS_GAP"       select="($BIF_H * 2)"/>
<xsl:variable name="IOR2PROC_GAP"       select="$BIF_W"/>
<xsl:variable name="SPECS2KEY_GAP"      select="$BIF_W"/>
<xsl:variable name="BLKD2KEY_GAP"       select="ceiling($BIF_W div 3)"/>
<xsl:variable name="BLKD_INNER_GAP"     select="ceiling($periMOD_W div 2)"/>

<!--
<xsl:variable name="BLKD_IORCHAN_H" select="16"/>				
<xsl:variable name="BLKD_IORCHAN_W" select="16"/>				
<xsl:variable name="BLKD_PRTCHAN_H" select="40"/>				
<xsl:variable name="BLKD_PRTCHAN_W" select="40"/>				
-->

<!-- ======================= MAIN SVG BLOCK =============================== -->
<xsl:template match="EDKPROJECT">

<!-- =========================================================================== -->
<!-- Calculate the width of the Block Diagram based on the total number of       -->
<!-- buslanes and modules in the design 									     -->
<!-- =========================================================================== -->

	
<xsl:variable name="numSbs_"            select="count(BLKDSHAPES/SBSSHAPES/MODULE)"/>			
<xsl:variable name="numProcs_"          select="count(BLKDSHAPES/PROCSHAPES/MODULE)"/>
<xsl:variable name="numCmplxs_"         select="count(BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[not(@PROCESSOR)])"/>
<xsl:variable name="numSbsBuckets_"     select="count(BLKDSHAPES/SBSBUCKETS/SBSBUCKET[not(@PROCESSOR)])"/>

<!--
<xsl:variable name="maxProcBifsH_"      select="BLKDSHAPES/@LIMIT_PROC_BIFS_H"/>
<xsl:variable name="maxModsAbvSbs_"     select="BLKDSHAPES/@LIMIT_PMODS_ABOVE_SBS_H"/>
<xsl:variable name="maxModsBlwSbs_"     select="BLKDSHAPES/@LIMIT_PMODS_BELOW_SBS_H"/>

<xsl:variable name="maxSbsBktModsH_"    select="BLKDSHAPES/@LIMIT_SBSBKTMODS_H"/>
<xsl:variable name="maxSbsNumBktsH_"    select="BLKDSHAPES/@LIMIT_SBSNUMBKTS_H"/>

<xsl:variable name="maxModsAbvProcs_"   select="BLKDSHAPES/@LIMIT_MODS_ABOVE_PROCS_H"/>
<xsl:variable name="maxMemusAbvProcs_"  select="BLKDSHAPES/@LIMIT_MEMUS_ABOVE_PROCS_H"/>
-->


<xsl:variable name="numModsAcross_"     select="BLKDSHAPES/@MODS_W"/>
<xsl:variable name="numGapsAcross_"     select="BLKDSHAPES/@GAPS_W"/>
<xsl:variable name="numBusLanesAcross_" select="BLKDSHAPES/@BUS_LANES_W"/>

<xsl:variable name="numBktGapsAcross_"  select="BLKDSHAPES/@BKT_GAPS_W"/>
<xsl:variable name="numBktLanesAcross_" select="BLKDSHAPES/@BKT_LANES_W"/>

<xsl:variable name="totalGapsW_"        select="($numGapsAcross_     * $MOD_SHAPES_G)"/>
<xsl:variable name="totalModsW_"        select="($numModsAcross_     * $periMOD_W)"/>
<xsl:variable name="totalBusLanesW_"    select="($numBusLanesAcross_ * $BUS_LANE_W)"/>

<xsl:variable name="totalBktGapsW_"     select="($numBktGapsAcross_  * $MOD_BUCKET_G)"/>
<xsl:variable name="totalBktLanesW_"    select="($numBktLanesAcross_ * $MOD_BKTLANE_W)"/>

<xsl:variable name="BLKD_DRAWAREA_CLC"  select="$totalModsW_ + $totalGapsW_ +  $totalBusLanesW_ + $totalBktLanesW_ + $totalBktGapsW_ + ($BLKD_INNER_GAP * 2)"/>

<xsl:variable name="BLKD_DRAWAREA_W">    
	<xsl:if test="$BLKD_DRAWAREA_CLC &gt; ($BLKD_KEY_W + $BLKD_SPECS_W + $SPECS2KEY_GAP)">
		<xsl:value-of select="$BLKD_DRAWAREA_CLC"/>
	</xsl:if>
	<xsl:if test="not($BLKD_DRAWAREA_CLC &gt; ($BLKD_KEY_W + $BLKD_SPECS_W + $SPECS2KEY_GAP))">
		<xsl:value-of select="($BLKD_KEY_W + $BLKD_SPECS_W + $SPECS2KEY_GAP)"/>
	</xsl:if>
</xsl:variable>
<xsl:variable name="BLKD_W"             select="($BLKD_DRAWAREA_W + (($BLKD_PRTCHAN_W  + $BLKD_IORCHAN_W)* 2))"/>


<!-- =========================================================================== -->
<!-- Calculate the height of the Block Diagram based on the total number of      -->
<!-- buslanes and modules in the design. Take into account special shapes such   -->
<!-- as MultiProc shapes.													     -->
<!-- =========================================================================== -->

<xsl:variable name="max_Proc_H_">
	<xsl:call-template name="_calc_Proc_Max_Height"/>		
</xsl:variable>

<xsl:variable name="max_PStack_BlwSbs_H_">
	<xsl:call-template name="_calc_Proc_MaxBlwSbs_Height"/>		
</xsl:variable>


<xsl:variable name="max_PStack_AbvSbs_H_">
	<xsl:call-template name="_calc_Proc_MaxAbvSbs_Height"/>		
</xsl:variable>

<!--
<xsl:message>Found max blw as <xsl:value-of select="$max_PStack_BlwSbs_H_"/></xsl:message>
<xsl:message>Found max abv as <xsl:value-of select="$max_PStack_AbvSbs_H_"/></xsl:message>
<xsl:message>Found max blw as <xsl:value-of select="$max_PStack_BlwSbs_H_"/></xsl:message>
-->

<xsl:variable name="totalSbsH_"         select="($numSbs_ * $SBS_H)"/>

<xsl:variable name="max_MPStack_AbvSbs_H_">
	<xsl:call-template name="_calc_MaxMultiProcStack_Height"/>		
</xsl:variable>

<xsl:variable name="IpBktModsH_">
	<xsl:if test="BLKDSHAPES/IPBUCKET/@MODS_H"><xsl:value-of select="BLKDSHAPES/IPBUCKET/@MODS_H"/></xsl:if>
	<xsl:if test="not(BLKDSHAPES/IPBUCKET/@MODS_H)">0</xsl:if>
</xsl:variable>
<xsl:variable name="totalIpBktH_"       select="($IpBktModsH_ * ($periMOD_H + $BIF_H))"/>

<xsl:variable name="totalUnkBktH_">
	<xsl:if test="BLKDSHAPES/UNKBUCKET">
	
		<xsl:variable name="UnkBktModsH_">
			<xsl:if test="BLKDSHAPES/UNKBUCKET/@MODS_H"><xsl:value-of select="BLKDSHAPES/UNKBUCKET/@MODS_H"/></xsl:if>
			<xsl:if test="not(BLKDSHAPES/UNKBUCKET/@MODS_H)">0</xsl:if>
		</xsl:variable>
		<xsl:variable name="totalUnkModH_"       select="($UnkBktModsH_ * ($periMOD_H + $BIF_H))"/>
		
		<xsl:variable name="UnkBktBifsH_">
			<xsl:if test="BLKDSHAPES/UNKBUCKET/@BIFS_H"><xsl:value-of select="BLKDSHAPES/UNKBUCKET/@BIFS_H"/></xsl:if>
			<xsl:if test="not(BLKDSHAPES/UNKBUCKET/@BIFS_H)">0</xsl:if>
		</xsl:variable>
		<xsl:variable name="totalUnkBifH_"       select="($UnkBktBifsH_ * ($periMOD_H + $BIF_H))"/>
		
		<xsl:value-of select="($totalUnkBifH_ + $totalUnkModH_)"/>	
	</xsl:if>
	
	<xsl:if test="not(BLKDSHAPES/UNKBUCKET)">0</xsl:if>
</xsl:variable>

<!--
<xsl:message>Found max MPStack <xsl:value-of select="$max_MPStack_AbvSbs_H_"/></xsl:message>
<xsl:message>Found max  PStack <xsl:value-of select="$max_PStack_AbvSbs_H_"/></xsl:message>
<xsl:message>Found max Proc H  <xsl:value-of select="$max_Proc_H_"/></xsl:message>
-->

<xsl:variable name="BLKD_DRAWAREA_H"    select="($max_MPStack_AbvSbs_H_ + $max_PStack_AbvSbs_H_ + $max_Proc_H_ + $PROC2SBS_GAP + $totalSbsH_ + $max_PStack_BlwSbs_H_ + $SBS2IP_GAP + $totalIpBktH_ + $IP2UNK_GAP + $totalUnkBktH_ + ($BLKD_INNER_GAP * 2))"/>
<xsl:variable name="BLKD_H"             select="($BLKD_DRAWAREA_H + (($BLKD_PRTCHAN_H  + $BLKD_IORCHAN_H)* 2))"/>
<xsl:variable name="BLKD_TOTAL_H"       select="($BLKD_H + $BLKD2KEY_GAP + $BLKD_KEY_H)"/>

<!--specify a css for the file -->
<xsl:processing-instruction name="xml-stylesheet">href="MdtXdsSVG_Render.css" type="text/css"</xsl:processing-instruction>
<svg width="{$BLKD_W}" height="{$BLKD_TOTAL_H}">
	
<!-- =============================================== -->
<!--        Layout All the various definitions       -->
<!-- =============================================== -->
	<defs>
		<!-- Diagram Key Definition -->
		<xsl:call-template name="Define_BlkDiagram_Key"/>		
		
		<!-- Diagram Specs Definition -->
		<xsl:call-template name="Define_BlkDiagram_Specs">		
			<xsl:with-param name="blkd_arch"     select="@ARCH"/>
			<xsl:with-param name="blkd_part"     select="@PART"/>
			<xsl:with-param name="blkd_edkver"   select="@EDKVERSION"/>
			<xsl:with-param name="blkd_gentime"  select="@TIMESTAMP"/>
		</xsl:call-template>		
		
		<!-- IO Port Defs -->
		<xsl:call-template name="Define_IOPorts">		
			<xsl:with-param name="drawarea_w" select="$BLKD_DRAWAREA_W"/>
			<xsl:with-param name="drawarea_h" select="$BLKD_DRAWAREA_H"/>
		</xsl:call-template>	
		
		<!-- Interrupt Defs -->
<!--		
		<xsl:call-template name="Define_InterruptSymbols"/>		
-->		
			
		<!-- BIF Defs -->
		<xsl:call-template name="Define_BifTypes"/>		
		
		<!-- Bus Defs -->
		<xsl:call-template name="Define_Busses">		
			<xsl:with-param name="drawarea_w" select="$BLKD_DRAWAREA_W"/>
			<xsl:with-param name="drawarea_h" select="$BLKD_DRAWAREA_H"/>
		</xsl:call-template>	
		
		<!-- Shared Bus Buckets Defs -->
		<xsl:call-template name="Define_SBSBuckets"/>		
		
		<!-- IP Bucket Defs -->
		<xsl:call-template name="Define_IPBucket"/>		
		
		<!-- UNK Bucket Defs -->
		<xsl:call-template name="Define_UNKBucket"/>		
		
		<xsl:call-template name="Define_CmplxStacks"/>		
		
		<!-- Processors Defs -->
		<xsl:call-template name="Define_ProcessorStacks">		
			<xsl:with-param name="drawarea_w" select="$BLKD_DRAWAREA_W"/>
			<xsl:with-param name="drawarea_h" select="$BLKD_DRAWAREA_H"/>
		</xsl:call-template>	
		
		<!-- non processor accociated complex modules  -->
		<xsl:call-template name="Define_FreeCmplxModules"/>		
		
		<!-- non accociated complex modules- i.e. modules that dont fit in any context  -->
		<xsl:call-template name="Define_PenalizedModules"/>		
		
	</defs>
	
<!-- =============================================== -->
<!--             Draw Outlines                       -->
<!-- =============================================== -->
	
	 <!-- The surrounding black liner -->
     <rect x="0"  
		   y="0" 
		   width ="{$BLKD_W}"
		   height="{$BLKD_TOTAL_H}" style="fill:{$COL_WHITE}; stroke:{$COL_BLACK};stroke-width:4"/>
		   
	 <!-- The outer IO channel -->
     <rect x="{$BLKD_PRTCHAN_W}"  
		   y="{$BLKD_PRTCHAN_H}" 
		   width= "{$BLKD_W - ($BLKD_PRTCHAN_W * 2)}" 
		   height="{$BLKD_H - ($BLKD_PRTCHAN_H * 2)}" style="fill:{$COL_IORING}"/>
		   
	 <!-- The Diagram's drawing area -->
     <rect x="{$BLKD_PRTCHAN_W + $BLKD_IORCHAN_W}"  
		   y="{$BLKD_PRTCHAN_H + $BLKD_IORCHAN_H}" 
		   width= "{$BLKD_DRAWAREA_W}"
		   height="{$BLKD_DRAWAREA_H}" rx="8" ry="8" style="fill:{$COL_BG}"/>
		   
<!-- =============================================== -->
<!--        Draw All the various components          -->
<!-- =============================================== -->
	
	
	<!--   Layout the IO Ports    -->	
	<xsl:call-template name="Draw_IOPorts">		
		<xsl:with-param name="drawarea_w" select="$BLKD_DRAWAREA_W"/>
		<xsl:with-param name="drawarea_h" select="$BLKD_DRAWAREA_H"/>
	</xsl:call-template>	
	
	<!--   Layout the Shapes      -->	

	<xsl:call-template name="Draw_BlkdShapes">		
		<xsl:with-param name="blkd_w"     select="$BLKD_W"/>
		<xsl:with-param name="blkd_h"     select="$BLKD_H"/>
		<xsl:with-param name="drawarea_w" select="$BLKD_DRAWAREA_W"/>
		<xsl:with-param name="drawarea_h" select="$BLKD_DRAWAREA_H"/>
	</xsl:call-template>	
	
<!--	
	<xsl:call-template name="Draw_BlkDiagram_Key">		
		<xsl:with-param name="blkd_w"     select="$BLKD_W"/>
		<xsl:with-param name="blkd_h"     select="$BLKD_H"/>
		<xsl:with-param name="drawarea_w" select="$BLKD_DRAWAREA_W"/>
		<xsl:with-param name="drawarea_h" select="$BLKD_DRAWAREA_H"/>
	</xsl:call-template>	
-->	
		
</svg>

<!-- ======================= END MAIN SVG BLOCK =============================== -->
</xsl:template>

<xsl:template name="Draw_BlkdShapes">
	<xsl:param name="blkd_w"     select="820"/>
	<xsl:param name="blkd_h"     select="520"/>
	<xsl:param name="drawarea_w" select="800"/>
	<xsl:param name="drawarea_h" select="500"/>
	
	<xsl:variable name="inner_X_" select="($BLKD_PRTCHAN_W  + $BLKD_IORCHAN_W + $BLKD_INNER_GAP)"/>
	<xsl:variable name="inner_Y_" select="($BLKD_PRTCHAN_H  + $BLKD_IORCHAN_H + $BLKD_INNER_GAP)"/>
	
	<xsl:variable name="lmt_slvsabv_sbs_h_" select="BLKDSHAPES/@LIMIT_PMODS_ABOVE_SBS_H"/>
	<xsl:variable name="lmt_proc_bifs_h_"   select="BLKDSHAPES/@LIMIT_PROC_BIFS_H"/>
	
	<xsl:variable name="lmt_modsAbvProcsH_"  select="BLKDSHAPES/@LIMIT_MODS_ABOVE_PROCS_H"/>
	<xsl:variable name="lmt_memusAbvProcsH_" select="BLKDSHAPES/@LIMIT_MEMUS_ABOVE_PROCS_H"/>
	
<!--	
	<xsl:message>Number mods above procs <xsl:value-of  select="$lmt_modsAbvProcsH_"/></xsl:message>
	<xsl:message>Number memus above procs <xsl:value-of select="$lmt_memusAbvProcsH_"/></xsl:message>
-->	

	<xsl:variable name="lmt_MPModsH_"      select="($lmt_modsAbvProcsH_   * ($periMOD_H + $BIF_H))"/>
	<xsl:variable name="lmt_MPMemusH_"     select="($lmt_memusAbvProcsH_  * (($periMOD_H * 2) + $BIF_H))"/>
	
	<xsl:variable name="lmt_proc_h_"  select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * $lmt_proc_bifs_h_) + ($MOD_LABEL_H + $BIF_GAP))"/>	
	<xsl:variable name="lmt_slvs_h_"  select="($lmt_slvsabv_sbs_h_  * ( $periMOD_H      + $BIF_H))"/>
	
	<xsl:variable name="numSbs_"    select="count(BLKDSHAPES/SBSSHAPES/MODULE)"/>			
	<xsl:variable name="numProcs_"  select="count(BLKDSHAPES/PROCSHAPES/MODULE)"/>			
	
	<xsl:variable name="sbs_h_"     select="($numSbs_  * $SBS_H)"/>
	<xsl:variable name="sbs_y_"     select="($inner_Y_ + $lmt_MPModsH_ + $lmt_MPMemusH_ + $lmt_proc_h_ + $lmt_slvs_h_ + $PROC2SBS_GAP)"/>
	
	
<!-- Draw the Bridges, if any-->	
	<xsl:for-each select="BLKDSHAPES/BRIDGESHAPES/MODULE">	
	
		<xsl:variable name="master_"      select="@MASTER"/>	
		<xsl:variable name="mstIndex_"    select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE = $master_]/@BUSINDEX"/>	
		<xsl:variable name="gaps_right_"  select="(@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mods_right_"  select="(@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="lanes_right_" select="(@BUS_LANES_X * $BUS_LANE_W)"/>	
		
		<xsl:variable name="mstY_"        select="($sbs_y_ + ($mstIndex_ * $SBS_H))"/>	
		<xsl:variable name="brdgDy_"      select="ceiling(($SBS_H - $periMOD_H) div 2)"/>	
		
		<xsl:variable name="periDy_"      select="$MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + ceiling($BIF_H div 2)"/>	
		
		<xsl:variable name="westBw_"      select="BUSCONNS[@ORIENTED = 'WEST']/@BUSLANE_W"/>
		<xsl:variable name="westDx_"      select="($westBw_ * $BUS_LANE_W)"/>
		
		<xsl:variable name="brdgX_"       select="($inner_X_ + $gaps_right_ +  $mods_right_ + $lanes_right_)"/>	
	
<!--	
		<xsl:message>Master is <xsl:value-of select="$master_"/></xsl:message>
		<xsl:message>Master Index is <xsl:value-of select="$mstIndex_"/></xsl:message>
		<xsl:variable name="eastX_"       select="BUSCONNS[@ORIENTED = 'EAST']/@BUSLANE_W"/>
		<xsl:variable name="eastDx_"      select="($eastX_ * $BUS_LANE_W)"/>
-->		
		<use  x="{$brdgX_ + $westDx_}"  y="{$mstY_ + $brdgDy_}"  xlink:href="#symbol_{@INSTANCE}"/>	
		
		<xsl:for-each select="BUSCONNS[@ORIENTED = 'WEST']/BUSCONN">
			
			<xsl:variable name="mstSbsCX_"    select="($brdgX_ + $westDx_) - ((@BUSLANE_X + 1) * $BUS_LANE_W)"/>
			<xsl:variable name="mstSbsCTop_"  select="$sbs_y_ + ((@BUSINDEX * $SBS_H) - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2))"/>
			<xsl:variable name="mstSbsCBot_"  select="$mstY_  + $brdgDy_ + $periDy_"/>
			<xsl:variable name="mstSbsCColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>
			
			
			<line x1="{$mstSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$mstSbsCTop_ + ceiling($BIFC_H div 2)}" 
				  x2="{$mstSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y2="{$mstSbsCBot_}" 
				  style="stroke:{$mstSbsCColor_};stroke-width:1"/>
				  
			<line x1="{$mstSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$mstSbsCBot_}" 
				  x2="{$brdgX_      + $westDx_ + $MOD_LANE_W}" 
				  y2="{$mstSbsCBot_}" 
				  style="stroke:{$mstSbsCColor_};stroke-width:1"/>
				  
			<use   x="{$mstSbsCX_}"   y="{$mstSbsCTop_}"  xlink:href="#{@BUSDOMAIN}_busconn_{@BIFRANK}"/>
			
		</xsl:for-each>
		
		<xsl:for-each select="BUSCONNS[@ORIENTED = 'EAST']/BUSCONN">
			
			<xsl:variable name="eastDx_"      select="((../@BUSLANE_W) * $BUS_LANE_W)"/>
			
			<xsl:variable name="slvSbsCX_"    select="($brdgX_ + $westDx_ + $periMOD_W) + ((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W"/>
			<xsl:variable name="slvSbsCBot_"  select="$sbs_y_  + ((@BUSINDEX * $SBS_H) - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2))"/>
			<xsl:variable name="slvSbsCTop_"  select="$mstY_ + $brdgDy_ + $periDy_"/>
			<xsl:variable name="slvSbsCColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>
			
			
			<line x1="{$slvSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$slvSbsCTop_}" 
				  x2="{$slvSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y2="{$slvSbsCBot_ + ceiling($BIFC_W div 2)}" 
				  style="stroke:{$slvSbsCColor_};stroke-width:1"/>
				  
			<line x1="{$slvSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$slvSbsCTop_}" 
				  x2="{$brdgX_      + $westDx_ + $periMOD_W - $MOD_LANE_W}" 
				  y2="{$slvSbsCTop_}" 
				  style="stroke:{$slvSbsCColor_};stroke-width:1"/>
				  
			<use   x="{$slvSbsCX_}"   y="{$slvSbsCBot_}"  xlink:href="#{@BUSDOMAIN}_busconn_{@BIFRANK}"/>
			
		</xsl:for-each>
		
	</xsl:for-each>
	
<!-- Draw the Processor stacks -->	
	<xsl:for-each select="BLKDSHAPES/PROCSHAPES/MODULE">			
		
		<xsl:variable name="procInst_"    select="@INSTANCE"/>
		<xsl:variable name="proc_bifs_h_" select="@BIFS_H"/>
		<xsl:variable name="proc_h_"      select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * $proc_bifs_h_) + ($MOD_LABEL_H + $BIF_GAP))"/>	
		
<!--		
		<xsl:variable name="numMemCs_"    select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and (@MODCLASS='MEMORY_UNIT'))])"/>	
		<xsl:variable name="numSlvsAbv_"  select="@PMODS_ABOVE_SBS_H"/>
		<xsl:variable name="numSlvsBlw_"  select="@PMODS_BELOW_SBS_H"/>
		<xsl:variable name="memCH_"       select="($numMemCs_   * (($periMOD_H * 2) + $BIF_H))"/>
		<xsl:variable name="slavesH_"     select="($numSlvsAbv_ * ( $periMOD_H      + $BIF_H))"/>
-->		

		<xsl:variable name="numMemUs_"    select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and (@MODCLASS = 'MEMORY_UNIT'))])"/>	
		<xsl:variable name="numPerisBlw_" select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and (@MODCLASS = 'PERIPHERAL') and    (@HAS_SBSBIF))])"/>	
		<xsl:variable name="numPerisAbv_" select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and (@MODCLASS = 'PERIPHERAL') and not(@HAS_SBSBIF))])"/>	
		
		<xsl:variable name="gapsAbv_h_"   select="(($numMemUs_ + $numPerisAbv_) * $BIF_H)"/>
		<xsl:variable name="perisAbv_h_">
			<xsl:call-template name="_calc_Proc_PerisAbvSbs_Height">
				<xsl:with-param name="procInst"  select="$procInst_"/>
			</xsl:call-template>	
		</xsl:variable>
		
		<xsl:variable name="memUs_h_">
			<xsl:call-template name="_calc_Proc_MemoryUnits_Height">
				<xsl:with-param name="procInst" select="$procInst_"/>
			</xsl:call-template>	
		</xsl:variable>
		
		<xsl:variable name="pabv_h_"          select="($proc_h_ + $perisAbv_h_ + $memUs_h_ + $gapsAbv_h_)"/>
		<xsl:variable name="proc_y_"          select="($sbs_y_ - ($PROC2SBS_GAP   + $pabv_h_))"/>
		
		<xsl:variable name="gaps_right_"      select="(@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mods_right_"      select="(@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="lanes_right_"     select="(@BUS_LANES_X * $BUS_LANE_W)"/>
		
		<xsl:variable name="bkt_lanes_right_" select="(@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="bkt_gaps_right_"  select="(@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		
		<xsl:variable name="proc_x_"          select="($inner_X_ + $gaps_right_ +  $mods_right_ + $bkt_lanes_right_ + $bkt_gaps_right_ + $lanes_right_)"/>
	
		<use   x="{$proc_x_}"  
		       y="{$proc_y_}" 
		       xlink:href="#pgroup_{$procInst_}"/> 
		
		<xsl:variable name="numProcMods_" select="($numPerisAbv_ + $numPerisBlw_ + $numMemUs_)"/>
		
		<xsl:if test="$numProcMods_ = 0">
			
			<xsl:variable name="pbktW_"       select="@PSTACK_BKT_W"/>
			<xsl:variable name="pmodW_"       select="@PSTACK_MOD_W"/>
			<xsl:variable name="numSbsBkts_"  select="count(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[   (@PROCESSOR = $procInst_)])"/>		
			
			<xsl:variable name="bktModsW_">
				<xsl:if test="($numSbsBkts_ &gt; 0)">
					<xsl:value-of select="(($MOD_BKTLANE_W * 2) + ($periMOD_W * $pbktW_) + ($MOD_BUCKET_G * ($pbktW_ - 1)))"/>	
				</xsl:if>
				<xsl:if test="not($numSbsBkts_ &gt; 0)">0</xsl:if>
			</xsl:variable> 
		
			<xsl:variable name="pstkModsW_" select="$periMOD_W"/>	
			
			<xsl:variable name="pstackW_">
				<xsl:if test="$bktModsW_ &gt; $pstkModsW_">
					<xsl:value-of select="$bktModsW_"/>
				</xsl:if>
				<xsl:if test="not($bktModsW_ &gt; $pstkModsW_)">
					<xsl:value-of select="$pstkModsW_"/>
				</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="busLaneWestW_">
				<xsl:if test="(BUSCONNS[@ORIENTED = 'WEST'])">
					<xsl:value-of select="((BUSCONNS[@ORIENTED ='WEST']/@BUSLANE_W) * $BUS_LANE_W)"/>
				</xsl:if>
				<xsl:if test="not(BUSCONNS[@ORIENTED = 'WEST'])">0</xsl:if>
			</xsl:variable>
			
		
			<xsl:if test="not(@IS_LIKEPROC = 'TRUE')">	  
				<text class="procclass"
						x="{($proc_x_  + $busLaneWestW_ + ceiling($pstackW_ div 2))}" 
						y="{$proc_y_ - 4}">PROCESSOR</text>			
			</xsl:if>
		
			<xsl:if test="@IS_LIKEPROC = 'TRUE'">	  
				<text class="procclass"
						x="{($proc_x_  + $busLaneWestW_ + ceiling($pstackW_ div 2))}" 
						y="{$proc_y_ - 4}">USER</text>			
			</xsl:if>
		</xsl:if>		
			
		<!-- Draw the multiproc stacks for this processor, if any-->	
		<xsl:if test="@PSTACK_BLKD_X">
			<xsl:variable name="stackBlkd_X_" select="(@PSTACK_BLKD_X + 1)"/>	
			
			<xsl:variable name="numPerisInStack_" select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = $stackBlkd_X_) and (@MODCLASS = 'PERIPHERAL'))])"/>	
			<xsl:variable name="numMemusInStack_" select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = $stackBlkd_X_) and (@MODCLASS = 'MEMORY_UNIT'))])"/>	
			
			<xsl:if test="(($numPerisInStack_ + $numMemusInStack_) &gt; 0)">
<!--				
				<xsl:message>Peris are <xsl:value-of select="$numPerisInStack_"/></xsl:message>
				<xsl:message>Memus are <xsl:value-of select="$numMemusInStack_"/></xsl:message>
-->				
				
<!--				
				<xsl:variable name="mp_peris_h_"         select="($numPerisInStack_  * ($periMOD_H + $BIF_H))"/>
				<xsl:variable name="mp_memus_h_"         select="($numMemusInStack_  * (($periMOD_H * 2) + $BIF_H))"/>
				<xsl:variable name="mp_stack_h_"         select="($mp_peris_h_ + $mp_memus_h_)"/>
-->				
				<xsl:variable name="mp_stack_h_">
					<xsl:call-template name="_calc_MultiProcStack_Height">
						<xsl:with-param name="mpstack_blkd_x" select="(@PSTACK_BLKD_X + 1)"/>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:variable name="mp_gaps_right_"      select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = $stackBlkd_X_)]/@GAPS_X 	   * $MOD_SHAPES_G)"/>
				<xsl:variable name="mp_mods_right_"      select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = $stackBlkd_X_)]/@MODS_X      * $periMOD_W)"/>
				<xsl:variable name="mp_lanes_right_"     select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = $stackBlkd_X_)]/@BUS_LANES_X * $BUS_LANE_W)"/>
				<xsl:variable name="mp_bkt_lanes_right_" select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = $stackBlkd_X_)]/@BKT_LANES_X * $MOD_BKTLANE_W)"/>
				<xsl:variable name="mp_bkt_gaps_right_"  select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = $stackBlkd_X_)]/@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
				
				<xsl:variable name="mpstack_x_"  select="($inner_X_ + $mp_gaps_right_ +  $mp_mods_right_ + $mp_bkt_lanes_right_ + $mp_bkt_gaps_right_ + $mp_lanes_right_)"/>
				<xsl:variable name="mpstack_y_"  select="($sbs_y_ - ($PROC2SBS_GAP + $lmt_proc_h_ + $lmt_slvs_h_ + $mp_stack_h_))"/>
				
				<use   x="{$mpstack_x_}"  y="{$mpstack_y_}" xlink:href="#mpstack_{$stackBlkd_X_}"/> 
				
			</xsl:if>
		</xsl:if>	
		
	</xsl:for-each>		
	
	<xsl:for-each select="BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@IS_PROMOTED and not(@IS_PENALIZED) and (@CSTACK_INDEX))]">
	
		<xsl:variable name="gaps_right_"      select="(@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mods_right_"      select="(@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="lanes_right_"     select="(@BUS_LANES_X * $BUS_LANE_W)"/>
		
		<xsl:variable name="bkt_lanes_right_" select="(@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="bkt_gaps_right_"  select="(@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		
		<xsl:variable name="cstack_x_"          select="($inner_X_ + $gaps_right_ +  $mods_right_ + $bkt_lanes_right_ + $bkt_gaps_right_ + $lanes_right_)"/>
		<xsl:variable name="cstack_y_"          select="($sbs_y_)"/>
	
		<use   x="{$cstack_x_}"  
		       y="{$cstack_y_}" 
		       xlink:href="#cgroup_{@CSTACK_INDEX}"/> 
		       
	</xsl:for-each>		
		
	
<!-- Draw non processor complex modules -->	
	<xsl:for-each select="BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@IS_PROMOTED and not(@IS_PENALIZED) and not(@CSTACK_INDEX))]">
		
		<xsl:variable name="gaps_right_"      select="(@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mods_right_"      select="(@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="lanes_right_"     select="(@BUS_LANES_X * $BUS_LANE_W)"/>
		<xsl:variable name="bkt_lanes_right_" select="(@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="bkt_gaps_right_"  select="(@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
	
		<xsl:variable name="cmplxBusLaneWest_w_">
			<xsl:if test="BUSCONNS[@ORIENTED = 'WEST']">
				 <xsl:value-of select="((BUSCONNS[@ORIENTED = 'WEST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(BUSCONNS[@ORIENTED = 'WEST'])">0</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="cmplxBusLaneEast_w_">
			<xsl:if test="BUSCONNS[@ORIENTED = 'EAST']">
				 <xsl:value-of select="((BUSCONNS[@ORIENTED = 'EAST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(BUSCONNS[@ORIENTED = 'EAST'])">0</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="cmplx_x_"  select="($inner_X_ + $gaps_right_ + $mods_right_ + $lanes_right_ + $bkt_lanes_right_ + $bkt_gaps_right_)"/>
		
		<xsl:variable name="cmplx_y_">
			<xsl:choose>
				<xsl:when test="((@MODCLASS = 'MASTER_SLAVE') or (@MODCLASS = 'MONITOR'))">
					<xsl:value-of select="($sbs_y_ - ($PROC2SBS_GAP + $periMOD_H))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="($sbs_y_ + $sbs_h_)"/>
				</xsl:otherwise>		
			</xsl:choose>
		</xsl:variable>  
		
	    <xsl:if test="(@MODCLASS)">
			<text class="ipclass"
				x="{$cmplx_x_ + $cmplxBusLaneWest_w_}" 
				y="{$cmplx_y_ - 4}">
					<xsl:value-of select="@MODCLASS"/>
			</text>	
	    </xsl:if>
		
		<xsl:choose>
			<xsl:when test="((@MODCLASS = 'MASTER_SLAVE') or (@MODCLASS = 'MONITOR'))">
				<use   x="{$cmplx_x_ + $cmplxBusLaneWest_w_}"  y="{$cmplx_y_}" xlink:href="#symbol_{MODULE/@INSTANCE}"/> 
			</xsl:when>	
			<xsl:otherwise>	
				<use   x="{$cmplx_x_ + $cmplxBusLaneWest_w_}"  y="{$cmplx_y_}" xlink:href="#symbol_peripheral_{position()}"/> 
			</xsl:otherwise>
		</xsl:choose>		
		
		<xsl:variable name="cmplx_Dy_"      select="$MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + ceiling($BIF_H div 2)"/>	
		
		<xsl:for-each select="BUSCONNS[@ORIENTED = 'WEST']/BUSCONN[@IS_SBSBIF]">
			
			<xsl:variable name="westSbsCX_"    select="($cmplx_x_ + $cmplxBusLaneWest_w_) - ((@BUSLANE_X + 1) * $BUS_LANE_W)"/>
			<xsl:variable name="westSbsBusY_"  select="($sbs_y_    + (@BUSINDEX * $SBS_H))"/>
			<xsl:variable name="westSbsBifY_"  select="($cmplx_y_ + $cmplx_Dy_)"/>
			
			<xsl:variable name="cmplxBif_Dx_">
				<xsl:choose>
					<xsl:when test="(@IS_CENTERED = 'TRUE')">
						<xsl:value-of select="(ceiling($periMOD_W div 2) - ceiling($BIF_W div 2))"/>
					</xsl:when>	
					<xsl:otherwise>	
						<xsl:value-of select="$MOD_LANE_W"/>
					</xsl:otherwise>
				</xsl:choose>		
			</xsl:variable>
			
			
			<xsl:variable name="westSbsCColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<line x1="{$westSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$westSbsBifY_}" 
				  x2="{$westSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y2="{$westSbsBusY_}" 
				  style="stroke:{$westSbsCColor_};stroke-width:1"/>
				  
			<line x1="{$westSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$westSbsBifY_ }" 
				  x2="{$cmplx_x_     + $cmplxBusLaneWest_w_ + $cmplxBif_Dx_}" 
				  y2="{$westSbsBifY_}" 
				  style="stroke:{$westSbsCColor_};stroke-width:1"/>
				  
			<use   x="{$westSbsCX_}"   y="{$westSbsBusY_ - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2)}"  xlink:href="#{@BUSDOMAIN}_busconn_{@BIFRANK}"/>
		</xsl:for-each>
		
		<xsl:for-each select="BUSCONNS[@ORIENTED = 'EAST']/BUSCONN[@IS_SBSBIF]">
			
			<xsl:variable name="eastSbsCX_"    select="($cmplx_x_ + $cmplxBusLaneWest_w_ + $periMOD_W +  ((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
			<xsl:variable name="eastSbsBusY_"  select="($sbs_y_    + (@BUSINDEX * $SBS_H))"/>
			<xsl:variable name="eastSbsBifY_"  select="($cmplx_y_ + $cmplx_Dy_)"/>
			
			<xsl:variable name="eastSbsCColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:variable name="cmplxBif_Dx_">
				<xsl:choose>
					<xsl:when test="(@IS_CENTERED = 'TRUE')">
						<xsl:value-of select="(ceiling($periMOD_W div 2) - ceiling($BIF_W div 2))"/>
					</xsl:when>	
					<xsl:otherwise>	
						<xsl:value-of select="$MOD_LANE_W"/>
					</xsl:otherwise>
				</xsl:choose>		
			</xsl:variable>
			
			<line x1="{$eastSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$eastSbsBifY_}" 
				  x2="{$eastSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y2="{$eastSbsBusY_}" 
				  style="stroke:{$eastSbsCColor_};stroke-width:1"/>
				  
			<line x1="{$eastSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$eastSbsBifY_ }" 
				  x2="{$cmplx_x_     + $cmplxBusLaneWest_w_ + $periMOD_W - $cmplxBif_Dx_}" 
				  y2="{$eastSbsBifY_}" 
				  style="stroke:{$eastSbsCColor_};stroke-width:1"/>
				  
			<use   x="{$eastSbsCX_}"   y="{$eastSbsBusY_ - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2)}"  xlink:href="#{@BUSDOMAIN}_busconn_{@BIFRANK}"/>
			
		</xsl:for-each>
		
	</xsl:for-each>		
	
	

<!-- Draw the shared bus buckets -->	
	<xsl:for-each select="BLKDSHAPES/SBSBUCKETS/SBSBUCKET[not(@PROCESSOR)]">			
		
		<xsl:variable name="ownerBus_"   select="@BUSNAME"/>
	
		<xsl:variable name="bkt_y_"  select="($sbs_y_ + $sbs_h_)"/>
		
		<xsl:variable name="gaps_right_"  select="(@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mods_right_"  select="(@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="lanes_right_" select="(@BUS_LANES_X * $BUS_LANE_W)"/>
	
		<xsl:variable name="bktBusLane_w_"  select="((BUSCONNS/@BUSLANE_W) * $BUS_LANE_W)"/>
		
		<xsl:variable name="bkt_x_"  select="($bktBusLane_w_ + $inner_X_ + $gaps_right_ +  $mods_right_ + $lanes_right_)"/>
		
		<text class="ipclass"
			x="{$bkt_x_}" 
			y="{$bkt_y_ - 4}">
				SLAVES of <xsl:value-of select="ownerBus_"/>
		</text>	
		
		<use   x="{$bkt_x_}"  y="{$bkt_y_}" xlink:href="#sbsbucket_{$ownerBus_}"/> 
		
		<!-- next draw connections to the shared busses from the slave buckets-->		  
		<xsl:for-each select="BUSCONNS/BUSCONN[(@IS_BKTCONN)]">	
			
			<xsl:variable name="bktSbsCColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:variable name="bktSbsCX_" >
				<xsl:value-of select="($bkt_x_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
			</xsl:variable>
			
			<xsl:variable name="bktSbsCTop_"  select="($sbs_y_ + (@BUSINDEX * $SBS_H) - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2))"/>
			<xsl:variable name="bktSbsCBot_"  select="($bkt_y_ + $MOD_BKTLANE_H + ceiling($periMOD_H div 2))"/>
			
			<line x1="{$bktSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$bktSbsCTop_ + ceiling($BIFC_H div 2)}" 
				  x2="{$bktSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y2="{$bktSbsCBot_ + ceiling($BIFC_H div 2)}" 
				  style="stroke:{$bktSbsCColor_};stroke-width:1"/>
				  
			<line x1="{$bktSbsCX_   + ceiling($BIFC_W div 2)}" 
				  y1="{$bktSbsCBot_ + ceiling($BIFC_H div 2)}" 
				  x2="{$bkt_x_}" 
				  y2="{$bktSbsCBot_ + ceiling($BIFC_H div 2)}" 
				  style="stroke:{$bktSbsCColor_};stroke-width:1"/>
				  
				  
			<use   x="{$bktSbsCX_}"   y="{$bktSbsCTop_}"  xlink:href="#{@BUSDOMAIN}_busconn_SLAVE"/>
			
		</xsl:for-each>		  
		
	</xsl:for-each>		
	
	
	
	<!-- Draw IP Bucket -->	
	<xsl:for-each select="BLKDSHAPES/IPBUCKET">
		
		<xsl:variable name="sbsBktModsH_"    select="../@LIMIT_SBSBKTMODS_H"/>
		<xsl:variable name="sbsNumBktsH_"    select="../@LIMIT_SBSNUMBKTS_H"/>
		<xsl:variable name="modsBlwH_"       select="../@LIMIT_PMODS_BELOW_SBS_H"/>
		
		<xsl:variable name="totalSbsBktsH_">
			<xsl:if test="$sbsBktModsH_ &gt; 0">
				<xsl:value-of select="((($MOD_BKTLANE_H * 2) *  $sbsNumBktsH_) + ($periMOD_H * $sbsBktModsH_) + (($sbsNumBktsH_ - 1) * $BIF_H) + ($MOD_BUCKET_G * ($sbsBktModsH_ - 1)))"/>
			</xsl:if> 
			<xsl:if test="not($sbsBktModsH_ &gt; 0)">0</xsl:if> 
		</xsl:variable>  
		
<!--		
		<xsl:message>Num mods <xsl:value-of select="$sbsBktModsH_"/></xsl:message>
		<xsl:message>Num bkts <xsl:value-of select="$sbsNumBktsH_"/></xsl:message>
-->		
<!--
		<xsl:variable name="totalModsBlwH_"        select="($modsBlwH_  * ($periMOD_H + $BIF_H))"/>
-->		

		<xsl:variable name="totalModsBlwH_">
			<xsl:call-template name="_calc_Proc_MaxBlwSbs_Height"/>		
		</xsl:variable>
	
		<xsl:variable name="bucket_w_"  select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * @MODS_W) + ($MOD_BUCKET_G * (@MODS_W - 1))))"/>
		<xsl:variable name="bucket_h_"  select="(($MOD_BKTLANE_H * 2) + (($periMOD_H * @MODS_H) + ($MOD_BUCKET_G * (@MODS_H - 1))))"/>
		
<!--		
		<xsl:variable name="bucket_y_"  select="($sbs_y_ + $sbs_h_ + $totalSbsBktsH_ + $totalModsBlwH_ + $SBS2IP_GAP)"/>
-->		
		<xsl:variable name="bucket_y_"  select="($sbs_y_ + $sbs_h_ + $totalModsBlwH_ + $SBS2IP_GAP)"/>
		<xsl:variable name="bucket_x_"  select="(ceiling($blkd_w div 2) - ceiling($bucket_w_ div 2))"/>
<!--		
		<xsl:variable name="bucket_x_"  select="(ceiling($drawarea_w div 2) - ceiling($bucket_w_ div 2))"/>
-->		
		
		<text class="ipclass"
			x="{$bucket_x_}" 
			y="{$bucket_y_ - 4}">
				IP
		</text>
		
		<use   x="{$bucket_x_}"   y="{$bucket_y_}"  xlink:href="#ipbucket"/>
		
	</xsl:for-each>
	
	
	<!-- Draw Unknown Bucket -->	
	<xsl:for-each select="BLKDSHAPES/UNKBUCKET">
		
		<xsl:variable name="sbsBktModsH_"    select="../@LIMIT_SBSBKTMODS_H"/>
		<xsl:variable name="sbsNumBktsH_"    select="../@LIMIT_SBSNUMBKTS_H"/>
		<xsl:variable name="modsBlwH_"       select="../@LIMIT_PMODS_BELOW_SBS_H"/>
		
		<xsl:variable name="totalSbsBktsH_">
			<xsl:if test="$sbsBktModsH_ &gt; 0">
				<xsl:value-of select="((($MOD_BKTLANE_H * 2) *  $sbsNumBktsH_) + ($periMOD_H * $sbsBktModsH_) + (($sbsNumBktsH_ - 1) * $BIF_H) + ($MOD_BUCKET_G * ($sbsBktModsH_ - 1)))"/>
			</xsl:if> 
			<xsl:if test="not($sbsBktModsH_ &gt; 0)">0</xsl:if> 
		</xsl:variable>  
		
		<xsl:variable name="totalIpBktsH_">
			<xsl:if test="/EDKPROJECT/BLKDSHAPES/IPBUCKET">
				<xsl:value-of select="(($MOD_BKTLANE_H * 2) + (($periMOD_H * /EDKPROJECT/BLKDSHAPES/IPBUCKET/@MODS_H) + ($MOD_BUCKET_G * (/EDKPROJECT/BLKDSHAPES/IPBUCKET/@MODS_H - 1))) + $IP2UNK_GAP)"/>
			</xsl:if> 
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/IPBUCKET)"></xsl:if> 
		</xsl:variable>  
		
		<xsl:variable name="totalModsBlwH_"        select="($modsBlwH_  * ($periMOD_H + $BIF_H))"/>
	
		<xsl:variable name="bucket_w_"  select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * @MODS_W) + ($MOD_BUCKET_G * (@MODS_W - 1))))"/>
		<xsl:variable name="bucket_h_"  select="(($MOD_BKTLANE_H * 2) + (($periMOD_H * @MODS_H) + ($MOD_BUCKET_G * (@MODS_H - 1))))"/>
		
		<xsl:variable name="bucket_y_"  select="($sbs_y_ + $sbs_h_ + $totalSbsBktsH_ + $totalModsBlwH_ + $totalIpBktsH_ + $IP2UNK_GAP)"/>
		<xsl:variable name="bucket_x_"  select="(ceiling($drawarea_w div 2) - ceiling($bucket_w_ div 2))"/>
		
		<text class="ipclass"
			x="{$bucket_x_}" 
			y="{$bucket_y_ - 4}">
				UNASSOCIATED
		</text>
		
		<use   x="{$bucket_x_}"   y="{$bucket_y_}"  xlink:href="#unkbucket"/>
		
	</xsl:for-each>
	
	
<!--
	====================================================================================
		Draw special, (e.g. Processor to Processor) BUS Connections between the modules.
	====================================================================================
-->
	
	
	<!-- Draw the processor to processor connections split connections -->	
	<xsl:for-each select="BLKDSHAPES/PROCSHAPES/MODULE/BUSCONNS/BUSCONN[(@IS_PROC2PROC = 'TRUE') and (@IS_SPLITCONN = 'TRUE')]">
			
		<xsl:variable name="oriented_"        select="../@ORIENTED"/>
		<xsl:variable name="procInst_"        select="../../@INSTANCE"/>
		
		<xsl:variable name="numMemCs_"        select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and (@MODCLASS='MEMORY_UNIT'))])"/>	
		<xsl:variable name="numSbsBkts_"      select="count(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[   (@PROCESSOR = $procInst_)])"/>	
		
		<xsl:variable name="proc_bifs_h_"     select="../../@BIFS_H"/>
		<xsl:variable name="numSlvsAbv_"      select="../../@PMODS_ABOVE_SBS_H"/>
		<xsl:variable name="numSlvsBlw_"      select="../../@PMODS_BELOW_SBS_H"/>
		<xsl:variable name="gaps_right_"      select="(../../@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mods_right_"      select="(../../@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="lanes_right_"     select="(../../@BUS_LANES_X * $BUS_LANE_W)"/>
		<xsl:variable name="bkt_lanes_right_" select="(../../@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="bkt_gaps_right_"  select="(../../@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		
		<xsl:variable name="pbifsW_"          select="../../@BIFS_W"/>
		<xsl:variable name="pbktW_"           select="../../@PSTACK_BKT_W"/>
		<xsl:variable name="pmodW_"           select="../../@PSTACK_MOD_W"/>
		
		<xsl:variable name="pbifsH_"          select="../../@BIFS_H"/>
		<xsl:variable name="pbktH_"           select="../../@PSTACK_BKT_H"/>
		<xsl:variable name="pmodH_"           select="../../@PSTACK_MOD_H"/>
		
		<xsl:variable name="memCH_"           select="($numMemCs_   * (($periMOD_H * 2) + $BIF_H))"/>
		<xsl:variable name="slavesH_"         select="($numSlvsAbv_ * ( $periMOD_H      + $BIF_H))"/>
		<xsl:variable name="proc_h_"          select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * $proc_bifs_h_) + ($MOD_LABEL_H + $BIF_GAP))"/>	
		<xsl:variable name="pabv_h_"          select="($proc_h_ + $memCH_ + $slavesH_)"/>
		
		<xsl:variable name="proc_y_"          select="($sbs_y_ - ($PROC2SBS_GAP + $proc_h_))"/>
		<xsl:variable name="proc_x_"          select="($inner_X_ + $gaps_right_ +  $mods_right_ + $bkt_lanes_right_ + $bkt_gaps_right_ + $lanes_right_)"/>
		
		<xsl:variable name="busLaneWestW_">
			<xsl:if test="(../../BUSCONNS[@ORIENTED = 'WEST'])">
				<xsl:value-of select="((../../BUSCONNS[@ORIENTED ='WEST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(../../BUSCONNS[@ORIENTED = 'WEST'])">0</xsl:if>
		</xsl:variable>
			
		<xsl:variable name="busLaneEastW_">
			<xsl:if test="(../../BUSCONNS[@ORIENTED = 'EAST'])">
				<xsl:value-of select="((../../BUSCONNS[@ORIENTED ='EAST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(../../BUSCONNS[@ORIENTED = 'EAST'])">0</xsl:if>
		</xsl:variable>
		
<!--		
		<xsl:message>Bus lane west <xsl:value-of select="$busLaneWestW_"/></xsl:message>
		<xsl:message>Bus lane east <xsl:value-of select="$busLaneEastW_"/></xsl:message>
-->		
		
		<xsl:variable name="bktModsW_">
			<xsl:if test="($numSbsBkts_ &gt; 0)">
				<xsl:value-of select="(($MOD_BKTLANE_W * 2) + ($periMOD_W * $pbktW_) + ($MOD_BUCKET_G * ($pbktW_ - 1)))"/>	
			</xsl:if>
			<xsl:if test="not($numSbsBkts_ &gt; 0)">0</xsl:if>
		</xsl:variable> 
		<xsl:variable name="pstkModsW_" select="($pmodW_ * $periMOD_W)"/>
		
		<xsl:variable name="pstackW_">
			<xsl:if test="$bktModsW_ &gt; $pstkModsW_">
				<xsl:value-of select="$bktModsW_"/>
			</xsl:if>
			<xsl:if test="not($bktModsW_ &gt; $pstkModsW_)">
				<xsl:value-of select="$pstkModsW_"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="splbus_w_" select="$BUS_ARROW_W + $BIFC_W + $BIFC_Wi"/>
		
		<xsl:variable name="proc2procX_" >
			<xsl:if test="$oriented_= 'WEST'"><xsl:value-of select="$proc_x_ + $busLaneWestW_  + ceiling($pstackW_ div 2) - (ceiling($periMOD_W div 2) + $BIFC_W + $splbus_w_)"/></xsl:if>	
			<xsl:if test="$oriented_= 'EAST'"><xsl:value-of select="$proc_x_ + $busLaneWestW_  + ceiling($pstackW_ div 2) + ceiling($periMOD_W div 2) + $BIFC_W"/></xsl:if>	
		</xsl:variable>  
		
		<xsl:variable name="pr2prNumX_" >
			<xsl:if test="$oriented_= 'WEST'"><xsl:value-of select="$proc2procX_ + ceiling($BIFC_Wi div 2) + 4"/></xsl:if>	
			<xsl:if test="$oriented_= 'EAST'"><xsl:value-of select="$proc2procX_ + $BUS_ARROW_W + $BIFC_W + ceiling($BIFC_Wi div 2) - 4"/></xsl:if>	
		</xsl:variable>  
		
		<xsl:variable name="pr2prLabelX_" >
			<xsl:if test="$oriented_= 'WEST'"><xsl:value-of select="$proc2procX_ - (string-length(@BUSNAME) * 6)"/></xsl:if>	
			<xsl:if test="$oriented_= 'EAST'"><xsl:value-of select="$proc2procX_ + $splbus_w_"/></xsl:if>	
		</xsl:variable>  
		
		<xsl:variable name="proc2procY_"   select="(($proc_y_ + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2))"/>
		<xsl:variable name="proc2procDy_"  select="(ceiling($BIF_H div 2) - ceiling($BUS_ARROW_G div 2))"/>
		
		<use   x="{$proc2procX_}"   y="{$proc2procY_ + $proc2procDy_}"  xlink:href="#{@BUSDOMAIN}_SplitBus_{$oriented_}"/>
		
		<text class="splitbustxt"
              x="{$pr2prNumX_} "
			  y="{$proc2procY_ + $proc2procDy_ + 8}">
			 <xsl:value-of select="@SPLITCNT"/> 
		</text>		  
		
		<text class="horizp2pbuslabel"
              x="{$pr2prLabelX_} "
			  y="{$proc2procY_ + $proc2procDy_ + 8}">
			 <xsl:value-of select="@BUSNAME"/> 
		</text>		  
		
	</xsl:for-each>		
	
	<xsl:for-each select="BLKDSHAPES/PROCSHAPES/MODULE/BUSCONNS/BUSCONN[(@IS_PROC2PROC = 'TRUE') and (@BIFRANK = 'MASTER') and not(@IS_SPLITCONN = 'TRUE')]">
			
<!--  MASTER VALUES -->		
		<xsl:variable name="mst_oriented_"        select="../@ORIENTED"/>
		<xsl:variable name="mst_procInst_"        select="../../@INSTANCE"/>
		<xsl:variable name="busName_"             select="@BUSNAME"/>
		
		<xsl:variable name="mst_numMemCs_"        select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $mst_procInst_) and (@MODCLASS='MEMORY_UNIT'))])"/>	
		<xsl:variable name="mst_numSbsBkts_"      select="count(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[   (@PROCESSOR = $mst_procInst_)])"/>	
		
		<xsl:variable name="mst_proc_bifs_h_"     select="../../@BIFS_H"/>
		<xsl:variable name="mst_numSlvsAbv_"      select="../../@PMODS_ABOVE_SBS_H"/>
		<xsl:variable name="mst_numSlvsBlw_"      select="../../@PMODS_BELOW_SBS_H"/>
		
		<xsl:variable name="mst_gaps_right_"      select="(../../@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mst_mods_right_"      select="(../../@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="mst_lanes_right_"     select="(../../@BUS_LANES_X * $BUS_LANE_W)"/>
		<xsl:variable name="mst_bkt_lanes_right_" select="(../../@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="mst_bkt_gaps_right_"  select="(../../@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		
		<xsl:variable name="mst_pbifsW_"          select="../../@BIFS_W"/>
		<xsl:variable name="mst_pbktW_"           select="../../@PSTACK_BKT_W"/>
		<xsl:variable name="mst_pmodW_"           select="../../@PSTACK_MOD_W"/>
		
		<xsl:variable name="mst_pbifsH_"          select="../../@BIFS_H"/>
		<xsl:variable name="mst_pbktH_"           select="../../@PSTACK_BKT_H"/>
		<xsl:variable name="mst_pmodH_"           select="../../@PSTACK_MOD_H"/>
		
		<xsl:variable name="mst_memCH_"           select="($mst_numMemCs_   * (($periMOD_H * 2) + $BIF_H))"/>
		<xsl:variable name="mst_slavesH_"         select="($mst_numSlvsAbv_ * ( $periMOD_H      + $BIF_H))"/>
		<xsl:variable name="mst_proc_h_"          select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * $mst_proc_bifs_h_) + ($MOD_LABEL_H + $BIF_GAP))"/>	
		<xsl:variable name="mst_pabv_h_"          select="($mst_proc_h_ + $mst_memCH_ + $mst_slavesH_)"/>
		
		<xsl:variable name="mst_proc_y_"          select="($sbs_y_ - ($PROC2SBS_GAP + $mst_proc_h_))"/>
		<xsl:variable name="mst_proc_x_"          select="($inner_X_ + $mst_gaps_right_ +  $mst_mods_right_ + $mst_bkt_lanes_right_ + $mst_bkt_gaps_right_ + $mst_lanes_right_)"/>
		
		<xsl:variable name="mst_busLaneWestW_">
			<xsl:if test="(../../BUSCONNS[@ORIENTED = 'WEST'])">
				<xsl:value-of select="((../../BUSCONNS[@ORIENTED ='WEST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(../../BUSCONNS[@ORIENTED = 'WEST'])">0</xsl:if>
		</xsl:variable>
			
		<xsl:variable name="mst_busLaneEastW_">
			<xsl:if test="(../../BUSCONNS[@ORIENTED = 'EAST'])">
				<xsl:value-of select="((../../BUSCONNS[@ORIENTED ='EAST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(../../BUSCONNS[@ORIENTED = 'EAST'])">0</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mst_bktModsW_">
			<xsl:if test="($mst_numSbsBkts_ &gt; 0)">
				<xsl:value-of select="(($MOD_BKTLANE_W * 2) + ($periMOD_W * $mst_pbktW_) + ($MOD_BUCKET_G * ($mst_pbktW_ - 1)))"/>	
			</xsl:if>
			<xsl:if test="not($mst_numSbsBkts_ &gt; 0)">0</xsl:if>
		</xsl:variable> 
		
		<xsl:variable name="mst_pstkModsW_" select="($mst_pmodW_ * $periMOD_W)"/>
		
		<xsl:variable name="mst_pstackW_">
			<xsl:if test="$mst_bktModsW_ &gt; $mst_pstkModsW_">
				<xsl:value-of select="$mst_bktModsW_"/>
			</xsl:if>
			<xsl:if test="not($mst_bktModsW_ &gt; $mst_pstkModsW_)">
				<xsl:value-of select="$mst_pstkModsW_"/>
			</xsl:if>
		</xsl:variable>
		
<!--  SLAVE VALUES -->		
		
		<xsl:variable name="slaveInst_"           select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[not(@INSTANCE = $mst_procInst_) and BUSCONNS/BUSCONN[@BUSNAME = $busName_]]/@INSTANCE"/>	
		<xsl:variable name="slv_numMemCs_"        select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $slaveInst_) and (@MODCLASS='MEMORY_UNIT'))])"/>
		<xsl:variable name="slv_numSbsBkts_"      select="count(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[   (@PROCESSOR = $slaveInst_)])"/>
		
		<xsl:variable name="slv_proc_bifs_h_"     select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@BIFS_H"/>
		<xsl:variable name="slv_numSlvsAbv_"      select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@PMODS_ABOVE_SBS_H"/>
		<xsl:variable name="slv_numSlvsBlw_"      select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@PMODS_BELOW_SBS_H"/>
		
		<xsl:variable name="slv_gaps_right_"      select="(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="slv_mods_right_"      select="(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="slv_lanes_right_"     select="(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@BUS_LANES_X * $BUS_LANE_W)"/>
		<xsl:variable name="slv_bkt_lanes_right_" select="(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="slv_bkt_gaps_right_"  select="(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		
		<xsl:variable name="slv_pbifsW_"          select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@BIFS_W"/>
		<xsl:variable name="slv_pbktW_"           select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@PSTACK_BKT_W"/>
		<xsl:variable name="slv_pmodW_"           select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@PSTACK_MOD_W"/>
		
		<xsl:variable name="slv_pbifsH_"          select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@BIFS_H"/>
		<xsl:variable name="slv_pbktH_"           select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@PSTACK_BKT_H"/>
		<xsl:variable name="slv_pmodH_"           select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/@PSTACK_MOD_H"/>
		
		<xsl:variable name="slv_memCH_"           select="($slv_numMemCs_   * (($periMOD_H * 2) + $BIF_H))"/>
		<xsl:variable name="slv_slavesH_"         select="($slv_numSlvsAbv_ * ( $periMOD_H      + $BIF_H))"/>
		<xsl:variable name="slv_proc_h_"          select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * $slv_proc_bifs_h_) + ($MOD_LABEL_H + $BIF_GAP))"/>	
		<xsl:variable name="slv_pabv_h_"          select="($slv_proc_h_ + $slv_memCH_ + $slv_slavesH_)"/>
		
		<xsl:variable name="slv_proc_y_"          select="($sbs_y_ - ($PROC2SBS_GAP + $slv_proc_h_))"/>
		<xsl:variable name="slv_proc_x_"          select="($inner_X_ + $slv_gaps_right_ +  $slv_mods_right_ + $slv_bkt_lanes_right_ + $slv_bkt_gaps_right_ + $slv_lanes_right_)"/>
		
		<xsl:variable name="slv_busLaneWestW_">
			<xsl:if test="(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/BUSCONNS[@ORIENTED = 'WEST'])">
				<xsl:value-of select="((/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/BUSCONNS[@ORIENTED ='WEST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/BUSCONNS[@ORIENTED = 'WEST'])">0</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mstArrow_">
			<xsl:choose>
				<xsl:when test="(@BUSDOMAIN = 'FSL')">BusArrowHInitiator</xsl:when>
				<xsl:otherwise>BusArrowWest</xsl:otherwise> 
			</xsl:choose>		
		</xsl:variable>
		
			
		<xsl:variable name="slv_busLaneEastW_">
			<xsl:if test="(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/BUSCONNS[@ORIENTED = 'EAST'])">
				<xsl:value-of select="((/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/BUSCONNS[@ORIENTED ='EAST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[@INSTANCE = $slaveInst_]/BUSCONNS[@ORIENTED = 'EAST'])">0</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="slv_bktModsW_">
			<xsl:if test="($slv_numSbsBkts_ &gt; 0)">
				<xsl:value-of select="(($MOD_BKTLANE_W * 2) + ($periMOD_W * $slv_pbktW_) + ($MOD_BUCKET_G * ($slv_pbktW_ - 1)))"/>	
			</xsl:if>
			<xsl:if test="not($slv_numSbsBkts_ &gt; 0)">0</xsl:if>
		</xsl:variable> 
		
		<xsl:variable name="slv_pstkModsW_" select="($slv_pmodW_ * $periMOD_W)"/>
		
		<xsl:variable name="slv_pstackW_">
			<xsl:if test="$slv_bktModsW_ &gt; $slv_pstkModsW_">
				<xsl:value-of select="$slv_bktModsW_"/>
			</xsl:if>
			<xsl:if test="not($slv_bktModsW_ &gt; $slv_pstkModsW_)">
				<xsl:value-of select="$slv_pstkModsW_"/>
			</xsl:if>
		</xsl:variable>
		
<!--		
		<xsl:message>Slave bus lane west <xsl:value-of select="$slv_busLaneWestW_"/></xsl:message>
		<xsl:message>Slave bus lane east <xsl:value-of select="$slv_busLaneEastW_"/></xsl:message>
-->		
		
		<xsl:variable name="proc2procBegX_" select="$mst_proc_x_ + $mst_busLaneWestW_  + ceiling($mst_pstackW_ div 2) + ceiling($periMOD_W div 2) + $BIFC_W"/>
		<xsl:variable name="proc2procEndX_" select="$slv_proc_x_ + $slv_busLaneWestW_  + ceiling($slv_pstackW_ div 2) - (ceiling($periMOD_W div 2) + $BIFC_W + $BUS_ARROW_W)"/>
		
		<xsl:variable name="proc2procBegY_" select="(($mst_proc_y_ + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2))"/>
		<xsl:variable name="proc2procDy_"   select="(ceiling($BIF_H div 2) - ceiling($BUS_ARROW_G div 2))"/>
		<xsl:variable name="proc2procY_"    select="($proc2procBegY_ + $proc2procDy_)"/>
		<xsl:variable name="bus_col_">
			<xsl:call-template name="BusType2Color">
				<xsl:with-param name="busType" select="@BUSDOMAIN"/>
			</xsl:call-template>	
		</xsl:variable>
		
		<use  x="{$proc2procBegX_}" y="{$proc2procY_}"  xlink:href="#{@BUSDOMAIN}_{$mstArrow_}"/>
		<use  x="{$proc2procEndX_}" y="{$proc2procY_}"  xlink:href="#{@BUSDOMAIN}_BusArrowEast"/>	
		<rect x="{$proc2procBegX_ + $BUS_ARROW_W}" 
			  y="{$proc2procY_ + $BUS_ARROW_G}"  
			  width= "{($proc2procEndX_  - $proc2procBegX_ - $BUS_ARROW_W)}" 
			  height="{$BUS_ARROW_H - (2 * $BUS_ARROW_G)}" style="stroke:none; fill:{$bus_col_}"/>
			  
		<text class="horizp2pbuslabel"
              x="{$proc2procBegX_ + 8} "
			  y="{$proc2procY_    - 2}">
			 <xsl:value-of select="@BUSNAME"/> 
		</text>		  
		
		<text class="horizp2pbuslabel"
              x="{$proc2procEndX_ - (string-length(@BUSNAME) * 6)} "
			  y="{$proc2procY_    - 2}">
			 <xsl:value-of select="@BUSNAME"/> 
		</text>		  
		
<!--		
		<xsl:variable name="pr2prLabelX_" >
			<xsl:if test="$oriented_= 'WEST'"><xsl:value-of select="$proc2procX_ - (string-length(@BUSNAME) * 6)"/></xsl:if>	
			<xsl:if test="$oriented_= 'EAST'"><xsl:value-of select="$proc2procX_ + $splbus_w_"/></xsl:if>	
		</xsl:variable>  
		
		<use   x="{$proc2procX_}"   y="{$proc2procY_ + $proc2procDy_}"  xlink:href="#{@BUSDOMAIN}_SplitBus_{$oriented_}"/>
		
		<text class="splitp2pbuslabel"
              x="{$pr2prLabelX_} "
			  y="{$proc2procY_ + $proc2procDy_ + 8}">
			 <xsl:value-of select="@BUSNAME"/> 
		</text>		  
-->		
		
	</xsl:for-each>		
	
	<!-- ============================================================ -->	
	<!-- Draw Multiproc connections to the processor bifs  -->
	<!-- ============================================================ -->	
	<xsl:for-each select="BLKDSHAPES/PROCSHAPES/MODULE/BUSCONNS/BUSCONN[(@IS_MULTIPROC = 'TRUE') and not(@IS_SPLITCONN = 'TRUE') and not(@IS_SBSBIF)]">
			
		<xsl:variable name="oriented_"         select="../@ORIENTED"/>
		<xsl:variable name="busName_"          select="@BUSNAME"/>
		
		<xsl:variable name="busColor_">
			<xsl:if test="(@BUSDOMAIN)">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:if>
			<xsl:if test="not(@BUSDOMAIN)">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="'TRANSPARENT'"/>
				</xsl:call-template>	
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mp_proc_inst_"    select="../../@INSTANCE"/>
		<xsl:variable name="mp_proc_bifs_h_"  select="../../@BIFS_H"/>
		<xsl:variable name="mp_proc_bifs_w_"  select="../../@BIFS_W"/>
		<xsl:variable name="mp_proc_pbktW_"   select="../../@PSTACK_BKT_W"/>
		<xsl:variable name="mp_proc_pbktH_"   select="../../@PSTACK_BKT_H"/>
		<xsl:variable name="mp_proc_pmodW_"   select="../../@PSTACK_MOD_W"/>
		<xsl:variable name="mp_proc_pmodH_"   select="../../@PSTACK_MOD_H"/>
		
		<xsl:variable name="mp_proc_gaps_right_"      select="(../../@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mp_proc_mods_right_"      select="(../../@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="mp_proc_lanes_right_"     select="(../../@BUS_LANES_X * $BUS_LANE_W)"/>
		<xsl:variable name="mp_proc_bkt_lanes_right_" select="(../../@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="mp_proc_bkt_gaps_right_"  select="(../../@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		
		<xsl:variable name="mp_proc_h_"  select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * $mp_proc_bifs_h_) + ($MOD_LABEL_H + $BIF_GAP))"/>	
		<xsl:variable name="mp_proc_y_"  select="($sbs_y_ - ($PROC2SBS_GAP + $mp_proc_h_))"/>
		<xsl:variable name="mp_proc_x_"  select="($inner_X_ + $mp_proc_gaps_right_ +  $mp_proc_mods_right_ + $mp_proc_bkt_lanes_right_ + $mp_proc_bkt_gaps_right_ + $mp_proc_lanes_right_)"/>
		
		<xsl:variable name="mp_proc_numMemCs_"    select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $mp_proc_inst_) and (@MODCLASS='MEMORY_UNIT'))])"/>	
		<xsl:variable name="mp_proc_numSbsBkts_"  select="count(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[   (@PROCESSOR = $mp_proc_inst_)])"/>	
		
		<xsl:variable name="mp_proc_bktModsW_">
			<xsl:if test="($mp_proc_numSbsBkts_ &gt; 0)">
				<xsl:value-of select="(($MOD_BKTLANE_W * 2) + ($periMOD_W * $mp_proc_pbktW_) + ($MOD_BUCKET_G * ($mp_proc_pbktW_ - 1)))"/>	
			</xsl:if>
			<xsl:if test="not($mp_proc_numSbsBkts_ &gt; 0)">0</xsl:if>
		</xsl:variable> 
		
		<xsl:variable name="mp_proc_pstkModsW_" select="($mp_proc_pmodW_ * $periMOD_W)"/>
		
		<xsl:variable name="mp_pstackW_">
			<xsl:if test="$mp_proc_bktModsW_ &gt; $mp_proc_pstkModsW_">
				<xsl:value-of select="$mp_proc_bktModsW_"/>
			</xsl:if>
			<xsl:if test="not($mp_proc_bktModsW_ &gt; $mp_proc_pstkModsW_)">
				<xsl:value-of select="$mp_proc_pstkModsW_"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mp_stack_numMods_"         select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = @PSTACK_BLKD_X) and (@MODCLASS = 'PERIPHERAL'))])"/>	
		<xsl:variable name="mp_stack_numMemus_"        select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = @PSTACK_BLKD_X) and (@MODCLASS = 'MEMORY_UNIT'))])"/>	
		
		<xsl:variable name="mp_stack_h_">
			<xsl:call-template name="_calc_MultiProcStack_Height">
				<xsl:with-param name="mpstack_blkd_x" select="(@PSTACK_BLKD_X)"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="mp_stack_y_"			   select="($sbs_y_ - ($PROC2SBS_GAP + $lmt_proc_h_ + $lmt_slvs_h_ + $mp_stack_h_))"/>

		<xsl:variable name="mp_stack_gaps_right_"      select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@GAPS_X 	  * $MOD_SHAPES_G)"/>
		<xsl:variable name="mp_stack_mods_right_"      select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="mp_stack_lanes_right_"     select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@BUS_LANES_X * $BUS_LANE_W)"/>
		<xsl:variable name="mp_stack_bkt_lanes_right_" select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="mp_stack_bkt_gaps_right_"  select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		<xsl:variable name="mp_stack_x_"               select="($inner_X_ + $mp_stack_gaps_right_ +  $mp_stack_mods_right_ + $mp_stack_bkt_lanes_right_ + $mp_stack_bkt_gaps_right_ + $mp_stack_lanes_right_)"/>
		
		<xsl:variable name="mp_stack_w_">
			<xsl:if test="($mp_stack_numMemus_ &gt; 0)">
				<xsl:value-of select="($periMOD_W * 2)"/>
			</xsl:if>
			<xsl:if test="not($mp_stack_numMemus_ &gt; 0)">
				<xsl:value-of select="$periMOD_W"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mp_busLaneWestW_">
			<xsl:if test="(../../BUSCONNS[@ORIENTED = 'WEST'])">
				<xsl:value-of select="((../../BUSCONNS[@ORIENTED ='WEST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(../../BUSCONNS[@ORIENTED = 'WEST'])">0</xsl:if>
		</xsl:variable>
			
		<xsl:variable name="mp_busLaneEastW_">
			<xsl:if test="(../../BUSCONNS[@ORIENTED = 'EAST'])">
				<xsl:value-of select="((../../BUSCONNS[@ORIENTED ='EAST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(../../BUSCONNS[@ORIENTED = 'EAST'])">0</xsl:if>
		</xsl:variable>
		
		
		<xsl:variable name="mp_stack_dx_" >
			
			<xsl:if test="$oriented_= 'WEST'">
				<xsl:if test="@IS_MEMBIF= 'TRUE'">
					<xsl:value-of select="(($mp_stack_w_ div 2) + ($periMOD_W - $MOD_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="not(@IS_MEMBIF= 'TRUE')">
					<xsl:value-of select="(($mp_stack_w_ div 2) + (($periMOD_W div 2) - $MOD_LANE_W))"/>
				</xsl:if>	
			</xsl:if>
			
			<xsl:if test="$oriented_= 'EAST'">
				<xsl:if test="@IS_MEMBIF= 'TRUE'">
					<xsl:value-of select="(($mp_stack_w_ div 2) - ($periMOD_W - $MOD_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="not(@IS_MEMBIF= 'TRUE')">
					<xsl:value-of select="(($mp_stack_w_ div 2) - (($periMOD_W div 2) - $MOD_LANE_W))"/>
				</xsl:if>	
			</xsl:if>	
			
		</xsl:variable>  
		

		<!-- processor bif busconn coordinates -->	
		<xsl:if test="@BUSLANE_X and @MPSTACK_MEMUS_Y and @MPSTACK_MODS_Y and @BIF_Y">
		
		<xsl:variable name="mp_proc_dy_"   select="(($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2))"/>
			
		<xsl:variable name="mp_proc_begX_" >
			<xsl:if test="$oriented_= 'WEST'">
				<xsl:value-of select="($mp_proc_x_ + $mp_busLaneWestW_ + ($mp_pstackW_ div 2) - ($periMOD_W div 2) + $MOD_LANE_W)"/>
			</xsl:if>	
				
			<xsl:if test="$oriented_= 'EAST'">
				<xsl:value-of select="$mp_proc_x_ + ($mp_busLaneWestW_ + ($mp_pstackW_ div 2) + ($periMOD_W div 2) - $MOD_LANE_W)"/>
			</xsl:if>	
		</xsl:variable>  
		
		<xsl:variable name="mp_proc_endX_" >
			<xsl:if test="$oriented_= 'WEST'">
				<xsl:value-of select="$mp_proc_x_ +  $mp_busLaneWestW_ -  (((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
			</xsl:if>	
				
			<xsl:if test="$oriented_= 'EAST'">
				<xsl:value-of select="$mp_proc_x_ + ($mp_busLaneWestW_ + $mp_pstackW_ + (((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W))"/>
			</xsl:if>	
		</xsl:variable>  
		
		

		<!-- mpstack  bif busconn coordinates -->	
		<xsl:variable name="mp_stack_mod_y_"   select="$mp_stack_y_ + ((@MPSTACK_MEMUS_Y * (($periMOD_H * 2) + $BIF_H)) + (@MPSTACK_MODS_Y * ($periMOD_H + $BIF_H)))"/>
		
		<xsl:variable name="mp_stack_mod_dy_" >
			<xsl:if test="not(@IS_MEMBIF)">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + (@BIF_Y * ($BIF_H + $BIF_GAP)) + ceiling($BIF_H div 2))"/>
			</xsl:if>
				
			<xsl:if test="@IS_MEMBIF">
				<xsl:value-of select="($periMOD_H +  $MOD_LANE_H + ceiling($BIF_H div 2))"/>
			</xsl:if>
		</xsl:variable>  

		<xsl:variable name="mp_stack_mod_begX_" >
			<xsl:if test="$oriented_= 'WEST'">
				<xsl:value-of select="$mp_stack_x_ + $mp_stack_dx_"/>
			</xsl:if>	
				
			<xsl:if test="$oriented_= 'EAST'">
				<xsl:value-of select="$mp_proc_endX_"/>
			</xsl:if>	
		</xsl:variable>  
		
		<xsl:variable name="mp_stack_mod_endX_" >
			<xsl:if test="$oriented_= 'WEST'">
				<xsl:value-of select="$mp_proc_endX_"/>
			</xsl:if>	
				
			<xsl:if test="$oriented_= 'EAST'">
				<xsl:value-of select="$mp_stack_x_ + $mp_stack_dx_"/>
			</xsl:if>	
		</xsl:variable>  
		
		
		<line x1="{$mp_proc_begX_}" 
			  y1="{$mp_proc_y_  + $mp_proc_dy_}" 
			  x2="{$mp_proc_endX_}" 
			  y2="{$mp_proc_y_  + $mp_proc_dy_}" 
			  style="stroke:{$busColor_};stroke-width:1"/>
		
		<line x1="{$mp_stack_mod_begX_}" 
			  y1="{$mp_stack_mod_y_  + $mp_stack_mod_dy_}" 
			  x2="{$mp_stack_mod_endX_}" 
			  y2="{$mp_stack_mod_y_  + $mp_stack_mod_dy_}" 
			  style="stroke:{$busColor_};stroke-width:1"/>
		  
		
<!--			  
		<xsl:message>==============================================</xsl:message>
		<xsl:message>Busname <xsl:value-of select="$busName_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_proc_y_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_y_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_h_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_mod_y_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_mod_dy_"/></xsl:message>
		<xsl:message>=============================================</xsl:message>
-->
			  
		<xsl:if test="(@BUSDOMAIN)">
		
			<xsl:variable name="procBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $mp_proc_inst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK">
					<xsl:value-of select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $mp_proc_inst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $mp_proc_inst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK)">SLAVE</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[not(@INSTANCE = $mp_proc_inst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK">
					<xsl:value-of select="/EDKPROJECT/MHSINFO/MODULES/MODULE[not(@INSTANCE = $mp_proc_inst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[not(@INSTANCE = $mp_proc_inst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK)">MASTER</xsl:if>
			</xsl:variable>
			
<!--			
			<xsl:message>Proc <xsl:value-of select="$procBifRank_"/></xsl:message>
			<xsl:message>Peri <xsl:value-of select="$periBifRank_"/></xsl:message>
-->			
			
			<use   x="{$mp_proc_endX_   - ($BIFC_W div 2)}"                                                y="{$mp_proc_y_ + $mp_proc_dy_ - ($BIFC_H div 2)}"                 xlink:href="#{@BUSDOMAIN}_busconn_{$procBifRank_}"/>
			<use   x="{($mp_proc_endX_  - ($BIFC_W div 2)) +  (($BIFC_W div 2) - ($BUS_ARROW_W div 2))}"   y="{$mp_proc_y_ + $mp_proc_dy_ - ($BIFC_H div 2) - $BUS_ARROW_H}"  xlink:href="#{@BUSDOMAIN}_BusArrowSouth"/>
		
			<use   x="{$mp_proc_endX_   - ($BIFC_W div 2)}"                                                y="{$mp_stack_mod_y_ + $mp_stack_mod_dy_ - ($BIFC_H div 2)}"       xlink:href="#{@BUSDOMAIN}_busconn_{$periBifRank_}"/>
			<use   x="{($mp_proc_endX_  - ($BIFC_W div 2)) +  (($BIFC_W div 2) - ($BUS_ARROW_W div 2))}"   y="{$mp_stack_mod_y_ + $mp_stack_mod_dy_ + ($BIFC_H div 2)}"       xlink:href="#{@BUSDOMAIN}_BusArrowNorth"/>
		 
			<rect x="{($mp_proc_endX_  - ($BIFC_W div 2)) +  (($BIFC_W div 2) - ($BUS_ARROW_W div 2)) + $BUS_ARROW_G}" 
				  y="{$mp_stack_mod_y_ + $mp_stack_mod_dy_ + ($BIFC_H div 2) + $BUS_ARROW_H}"
			      width="{$BUS_ARROW_W - (2 * $BUS_ARROW_G)}" 
			      height="{($mp_proc_y_ + $mp_proc_dy_ - ($BIFC_H div 2) - $BUS_ARROW_H) - ($mp_stack_mod_y_ + $mp_stack_mod_dy_ + $BIFC_H div 2) - $BUS_ARROW_H}" 
			      style="stroke:none; fill:{$busColor_}"/>
			      
		</xsl:if>			  
		
		<xsl:if test="not(@BUSDOMAIN)">
			<line x1="{$mp_proc_endX_}"
				  y1="{$mp_stack_mod_y_  + $mp_stack_mod_dy_}" 
			      x2="{$mp_proc_endX_}"
				  y2="{$mp_proc_y_       + $mp_proc_dy_}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
			</xsl:if>			  
			
			<xsl:variable name="busMid_">
			  <xsl:value-of select="ceiling((($mp_proc_y_ + $mp_proc_dy_) - ($mp_stack_mod_y_  + $mp_stack_mod_dy_)) div 2)"/>
			</xsl:variable>
		
			<text class="mpbuslabel" 
			  x="{$mp_proc_endX_    + 6}"
			  y="{$mp_stack_mod_y_  + $busMid_ + 12}">
				<xsl:value-of select="$busName_"/>
			</text>
		
		</xsl:if>		
		
	</xsl:for-each>		
	
	<!-- ============================================================ -->	
	<!-- Draw Multiproc connections to the shared busses -->	
	<!-- ============================================================ -->	
	<xsl:for-each select="BLKDSHAPES/PROCSHAPES/MODULE/BUSCONNS/BUSCONN[(@IS_MULTIPROC and not(@IS_SPLITCONN) and @BUSINDEX and @BIF_Y and @BIF_X)]">
			
		<xsl:variable name="oriented_"         select="../@ORIENTED"/>
		<xsl:variable name="busName_"          select="@BUSNAME"/>
		
		<xsl:variable name="busColor_">
			<xsl:if test="(@BUSDOMAIN)">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:if>
			<xsl:if test="not(@BUSDOMAIN)">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="'TRANSPARENT'"/>
				</xsl:call-template>	
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mp_proc_inst_"    select="../../@INSTANCE"/>
		<xsl:variable name="mp_proc_bifs_h_"  select="../../@BIFS_H"/>
		<xsl:variable name="mp_proc_bifs_w_"  select="../../@BIFS_W"/>
		<xsl:variable name="mp_proc_pbktW_"   select="../../@PSTACK_BKT_W"/>
		<xsl:variable name="mp_proc_pbktH_"   select="../../@PSTACK_BKT_H"/>
		<xsl:variable name="mp_proc_pmodW_"   select="../../@PSTACK_MOD_W"/>
		<xsl:variable name="mp_proc_pmodH_"   select="../../@PSTACK_MOD_H"/>
		
		<xsl:variable name="mp_proc_gaps_right_"      select="(../../@GAPS_X      * $MOD_SHAPES_G)"/>
		<xsl:variable name="mp_proc_mods_right_"      select="(../../@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="mp_proc_lanes_right_"     select="(../../@BUS_LANES_X * $BUS_LANE_W)"/>
		<xsl:variable name="mp_proc_bkt_lanes_right_" select="(../../@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="mp_proc_bkt_gaps_right_"  select="(../../@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		
		<xsl:variable name="mp_proc_h_"  select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * $mp_proc_bifs_h_) + ($MOD_LABEL_H + $BIF_GAP))"/>	
		<xsl:variable name="mp_proc_y_"  select="($sbs_y_ - ($PROC2SBS_GAP + $mp_proc_h_))"/>
		<xsl:variable name="mp_proc_x_"  select="($inner_X_ + $mp_proc_gaps_right_ +  $mp_proc_mods_right_ + $mp_proc_bkt_lanes_right_ + $mp_proc_bkt_gaps_right_ + $mp_proc_lanes_right_)"/>
		
		<xsl:variable name="mp_proc_numMemCs_"    select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $mp_proc_inst_) and (@MODCLASS='MEMORY_UNIT'))])"/>	
		<xsl:variable name="mp_proc_numSbsBkts_"  select="count(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[   (@PROCESSOR = $mp_proc_inst_)])"/>	
		
		<xsl:variable name="mp_proc_bktModsW_">
			<xsl:if test="($mp_proc_numSbsBkts_ &gt; 0)">
				<xsl:value-of select="(($MOD_BKTLANE_W * 2) + ($periMOD_W * $mp_proc_pbktW_) + ($MOD_BUCKET_G * ($mp_proc_pbktW_ - 1)))"/>	
			</xsl:if>
			<xsl:if test="not($mp_proc_numSbsBkts_ &gt; 0)">0</xsl:if>
		</xsl:variable> 
		
		<xsl:variable name="mp_proc_pstkModsW_" select="($mp_proc_pmodW_ * $periMOD_W)"/>
		
		<xsl:variable name="mp_pstackW_">
			<xsl:if test="$mp_proc_bktModsW_ &gt; $mp_proc_pstkModsW_">
				<xsl:value-of select="$mp_proc_bktModsW_"/>
			</xsl:if>
			<xsl:if test="not($mp_proc_bktModsW_ &gt; $mp_proc_pstkModsW_)">
				<xsl:value-of select="$mp_proc_pstkModsW_"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mp_stack_numMods_"         select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = @PSTACK_BLKD_X) and (@MODCLASS = 'PERIPHERAL'))])"/>	
		<xsl:variable name="mp_stack_numMemus_"        select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = @PSTACK_BLKD_X) and (@MODCLASS = 'MEMORY_UNIT'))])"/>	
		
		<xsl:variable name="mp_stack_h_">
			<xsl:call-template name="_calc_MultiProcStack_Height">
				<xsl:with-param name="mpstack_blkd_x" select="(@PSTACK_BLKD_X)"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="sbus_bc_y_" 			   select="($sbs_y_ + (@BUSINDEX * $SBS_H))"/>
		<xsl:variable name="mp_stack_y_"			   select="($sbs_y_ - ($PROC2SBS_GAP + $lmt_proc_h_ + $lmt_slvs_h_ + $mp_stack_h_))"/>

		<xsl:variable name="mp_stack_gaps_right_"      select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@GAPS_X 	  * $MOD_SHAPES_G)"/>
		<xsl:variable name="mp_stack_mods_right_"      select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@MODS_X      * $periMOD_W)"/>
		<xsl:variable name="mp_stack_lanes_right_"     select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@BUS_LANES_X * $BUS_LANE_W)"/>
		<xsl:variable name="mp_stack_bkt_lanes_right_" select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@BKT_LANES_X * $MOD_BKTLANE_W)"/>
		<xsl:variable name="mp_stack_bkt_gaps_right_"  select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = @PSTACK_BLKD_X)]/@BKT_GAPS_X  * $MOD_BUCKET_G)"/>
		<xsl:variable name="mp_stack_x_"               select="($inner_X_ + $mp_stack_gaps_right_ +  $mp_stack_mods_right_ + $mp_stack_bkt_lanes_right_ + $mp_stack_bkt_gaps_right_ + $mp_stack_lanes_right_)"/>
		
		<xsl:variable name="mp_stack_w_">
			<xsl:if test="($mp_stack_numMemus_ &gt; 0)">
				<xsl:value-of select="($periMOD_W * 2)"/>
			</xsl:if>
			<xsl:if test="not($mp_stack_numMemus_ &gt; 0)">
				<xsl:value-of select="$periMOD_W"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mp_busLaneWestW_">
			<xsl:if test="(../../BUSCONNS[@ORIENTED = 'WEST'])">
				<xsl:value-of select="((../../BUSCONNS[@ORIENTED ='WEST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(../../BUSCONNS[@ORIENTED = 'WEST'])">0</xsl:if>
		</xsl:variable>
			
		<xsl:variable name="mp_busLaneEastW_">
			<xsl:if test="(../../BUSCONNS[@ORIENTED = 'EAST'])">
				<xsl:value-of select="((../../BUSCONNS[@ORIENTED ='EAST']/@BUSLANE_W) * $BUS_LANE_W)"/>
			</xsl:if>
			<xsl:if test="not(../../BUSCONNS[@ORIENTED = 'EAST'])">0</xsl:if>
		</xsl:variable>
		
		
		<xsl:variable name="mp_stack_dx_" >
			
			<xsl:if test="$oriented_= 'WEST'">
				<xsl:if test="@IS_MEMBIF= 'TRUE'">
					<xsl:value-of select="(($mp_stack_w_ div 2) + ($periMOD_W - $MOD_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="not(@IS_MEMBIF= 'TRUE')">
					<xsl:value-of select="(($mp_stack_w_ div 2) + (($periMOD_W div 2) - $MOD_LANE_W))"/>
				</xsl:if>	
			</xsl:if>
			
			<xsl:if test="$oriented_= 'EAST'">
				<xsl:if test="@IS_MEMBIF= 'TRUE'">
					<xsl:value-of select="(($mp_stack_w_ div 2) - ($periMOD_W - $MOD_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="not(@IS_MEMBIF= 'TRUE')">
					<xsl:value-of select="(($mp_stack_w_ div 2) - (($periMOD_W div 2) - $MOD_LANE_W))"/>
				</xsl:if>	
			</xsl:if>	
			
		</xsl:variable>  
		
	<!-- processor bif busconn coordinates -->	
		<xsl:if test="@BUSLANE_X and @MPSTACK_MEMUS_Y and @MPSTACK_MODS_Y and @BIF_Y">
			
			<xsl:variable name="mp_proc_begX_" >
				<xsl:if test="$oriented_= 'WEST'">
					<xsl:value-of select="($mp_proc_x_ + $mp_busLaneWestW_ + ($mp_pstackW_ div 2) - ($periMOD_W div 2) + $MOD_LANE_W)"/>
				</xsl:if>	
				
				<xsl:if test="$oriented_= 'EAST'">
					<xsl:value-of select="$mp_proc_x_ + ($mp_busLaneWestW_ + ($mp_pstackW_ div 2) + ($periMOD_W div 2) - $MOD_LANE_W)"/>
				</xsl:if>	
			</xsl:variable>  
		
			<xsl:variable name="mp_proc_endX_" >
				<xsl:if test="$oriented_= 'WEST'">
					<xsl:value-of select="$mp_proc_x_ +  $mp_busLaneWestW_ -  (((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
				
				<xsl:if test="$oriented_= 'EAST'">
					<xsl:value-of select="$mp_proc_x_ + ($mp_busLaneWestW_ + $mp_pstackW_ + (((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W))"/>
				</xsl:if>	
			</xsl:variable>  

	<!-- mpstack  bif busconn coordinates -->	
			<xsl:variable name="mp_stack_mod_y_"   select="$mp_stack_y_ + ((@MPSTACK_MEMUS_Y * (($periMOD_H * 2) + $BIF_H)) + (@MPSTACK_MODS_Y * ($periMOD_H + $BIF_H)))"/>
		
			<xsl:variable name="mp_stack_mod_dy_" >
				<xsl:if test="not(@IS_MEMBIF)">
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + (@BIF_Y * ($BIF_H + $BIF_GAP)) + ceiling($BIF_H div 2))"/>
				</xsl:if>
				
				<xsl:if test="@IS_MEMBIF">
					<xsl:value-of select="($periMOD_H +  $MOD_LANE_H + ceiling($BIF_H div 2))"/>
				</xsl:if>
			</xsl:variable>  

			<xsl:variable name="mp_stack_mod_begX_" >
				<xsl:if test="$oriented_= 'WEST'">
					<xsl:value-of select="$mp_stack_x_ + $mp_stack_dx_"/>
				</xsl:if>	
				
				<xsl:if test="$oriented_= 'EAST'">
					<xsl:value-of select="$mp_proc_endX_"/>
				</xsl:if>	
			</xsl:variable>  
		
			<xsl:variable name="mp_stack_mod_endX_" >
				<xsl:if test="$oriented_= 'WEST'">
					<xsl:value-of select="$mp_proc_endX_"/>
				</xsl:if>	
				
				<xsl:if test="$oriented_= 'EAST'">
					<xsl:value-of select="$mp_stack_x_ + $mp_stack_dx_"/>
				</xsl:if>	
			</xsl:variable>  
		
		
		<!-- Horizontal line out from module -->		
		<line x1="{$mp_stack_mod_begX_}" 
			  y1="{$mp_stack_mod_y_  + $mp_stack_mod_dy_}" 
			  x2="{$mp_stack_mod_endX_}" 
			  y2="{$mp_stack_mod_y_  + $mp_stack_mod_dy_}" 
			  style="stroke:{$busColor_};stroke-width:1"/>
			  
		<!-- Vertical line down to shared bus -->		
		<line x1="{$mp_stack_mod_begX_}" 
			  y1="{$mp_stack_mod_y_  + $mp_stack_mod_dy_}" 
			  x2="{$mp_stack_mod_begX_}" 
			  y2="{$sbus_bc_y_}" 
			  style="stroke:{$busColor_};stroke-width:1"/>
			  
		<use   x="{$mp_stack_mod_begX_ - ceiling($BIFC_W div 2)}"    
		       y="{$sbus_bc_y_         - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2)}"   
		       xlink:href="#{@BUSDOMAIN}_busconn_{@BIFRANK}"/>
<!--			  
		<xsl:message>==============================================</xsl:message>
		<xsl:message>Busname <xsl:value-of select="$busName_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_h_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_proc_y_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_y_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_mod_begX_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_mod_endX_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_mod_y_"/></xsl:message>
		<xsl:message>====<xsl:value-of select="$mp_stack_mod_dy_"/></xsl:message>
		<xsl:message>=============================================</xsl:message>
-->
			      
	</xsl:if>		
		
	</xsl:for-each>		
	
	
	<!-- ============================================================ -->	
	<!-- Draw the shared busses -->	
	<!-- ============================================================ -->	
	<use   x="{$inner_X_}"    y="{$sbs_y_}"  xlink:href="#group_sharedBusses"/> 
	
	<!-- ============================================================ -->	
	<!-- Draw the Key -->	
	<!-- ============================================================ -->	
	<use   x="{$blkd_w - $BLKD_KEY_W - $BLKD_PRTCHAN_W}"   y="{$blkd_h + $BLKD2KEY_GAP - 8}"  xlink:href="#BlkDiagram_Key"/> 
	
	<!-- ============================================================ -->	
	<!-- Draw the Specs -->	
	<!-- ============================================================ -->	
	<use   x="{$BLKD_PRTCHAN_W}"                           y="{$blkd_h + $BLKD2KEY_GAP - 8}"  xlink:href="#BlkDiagram_Specs"/> 
</xsl:template>
	
<xsl:template name="Draw_BlkDiagram_Key">
	<xsl:param name="blkd_w"     select="820"/>
	<xsl:param name="blkd_h"     select="520"/>
	<xsl:param name="drawarea_w" select="800"/>
	<xsl:param name="drawarea_h" select="500"/>
	<use   x="{ceiling($blkd_w div 2) - ceiling($BLKD_KEY_W div 2)}"   y="0"  xlink:href="#BlkDiagram_Key"/> 
</xsl:template>

<xsl:template name="Define_BlkDiagram_Key">
			
	<symbol id="BlkDiagram_Key">
		<rect 
              x="0"
			  y="0"
		      width= "{$BLKD_KEY_W}"
		      height="{$BLKD_KEY_H}"
			  style="fill:{$COL_BG}; stroke:;"/>		
			  
		<rect 
              x="0"
			  y="0"
		      width= "{$BLKD_KEY_W}"
		      height="16"
			  style="fill:{$COL_BG}; stroke:none;"/>		
			  
		<text class="keytitle"
              x="{ceiling($BLKD_KEY_W div 2)} "
			  y="14">KEY</text>		  
			  
		<rect 
              x="0"
			  y="16"
		      width= "{$BLKD_KEY_W}"
		      height="16"
			  style="fill:{$COL_BG_LT}; stroke:none;"/>		
			  
		<text class="keyheader"
              x="{ceiling($BLKD_KEY_W div 2)} "
			  y="30">SYMBOLS</text>		  
			  
   		<use  x="32"  y="47"  xlink:href="#KEY_Bif" transform="scale(0.75)"/> 
		<text class="keylabel"
              x="12"
			  y="60">bus interface</text>		  
			  
   		<use   x="20"  y="68"  xlink:href="#KEY_SharedBus"/> 
		<text class="keylabel"
              x="12"
			  y="85">shared bus</text>		  
			  
		<text class="keylblul"
              x="110"
			  y="47">Bus connections</text>		  
			  
   		<use   x="110"  y="58"  xlink:href="#KEY_busconn_MASTER"/> 
		<text class="keylabel"
              x="140"
			  y="72">master or initiator</text>		  
			  
   		<use   x="110"  y="{58 + (($BIFC_H  + 4) * 1)}"  xlink:href="#KEY_busconn_SLAVE"/> 
		<text class="keylabel"
              x="140"
			  y="{72 + (($BIFC_H + 4) * 1)}">slave or target</text>		  
			  
   		<use   x="110"  y="{58 + (($BIFC_H  + 4) * 2)}"  xlink:href="#KEY_busconn_MASTER_SLAVE"/> 
		<text class="keylabel"
              x="140"
			  y="{72 + (($BIFC_H + 4) * 2)}">master slave</text>		  
			  
   		<use   x="110"  y="{58 + (($BIFC_H  + 4) * 3)}"  xlink:href="#KEY_busconn_MONITOR"/>
		<text class="keylabel"
              x="140"
			  y="{72 + (($BIFC_H + 4) * 3)}">monitor</text>		  
			  
		<text class="keylblul"
              x="258"
			  y="47">External Ports</text>		  
   		<use   x="258"  y="58"  xlink:href="#KEY_INPort"/> 
		<text class="keylabel"
              x="288"
			  y="72">input</text>		  
			  
   		<use   x="258"  y="{58 + ($IOP_H * 1) + 4}"  xlink:href="#KEY_OUTPort"/> 
		<text class="keylabel"
              x="288"
			  y="{72 + ($IOP_H * 1) + 4}">output</text>		  
			  
   		<use   x="258" y="{58 + ($IOP_H * 2) + 8}"  xlink:href="#KEY_INOUTPort"/> 
		<text class="keylabel"
              x="288"
			  y="{72 + ($IOP_H * 2) + 8}">inout</text>		  
			  
		<rect 
              x="0"
			  y="160"
		      width= "{$BLKD_KEY_W}"
		      height="16"
			  style="fill:{$COL_BG_LT}; stroke:none;"/>		
			  
		<text class="keyheader"
              x="{ceiling($BLKD_KEY_W div 2)} "
			  y="172">COLORS</text>		  
			  
		<text class="keylblul"
              x="110"
			  y="190">Bus Standards</text>		  
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 0)}"
			  y="200"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_DCRBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12 + $BIFC_W + 4}"
			  y="{200 + (($BIF_H + 4) * 1)}">DCR</text>		  
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 0)}"
			  y="{200 + (($BIFC_H + 4) * 1)}"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_FCBBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12 + $BIFC_W + 4}"
			  y="{200 + (($BIF_H + 4) * 2)}">FCB</text>		  
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 1)}"
			  y="200"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_FSLBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12  + ($BIFC_W + 4) + ((12 + $BIFC_W + 36) * 1)}"
			  y="{200 + (($BIF_H + 4) * 1)}">FSL</text>		  
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 1)}"
			  y="{200 + (($BIFC_H + 4) * 1)}"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_LMBBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12  + ($BIFC_W + 4) + ((12 + $BIFC_W + 36) * 1)}"
			  y="{200 + (($BIF_H + 4) * 2)}">LMB</text>		  
			  
			  
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 2)}"
			  y="200"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_OPBBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12  + ($BIFC_W + 4) + ((12 + $BIFC_W + 36) * 2)}"
			  y="{200 + (($BIF_H + 4) * 1)}">OPB</text>		  
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 2)}"
			  y="{200 + (($BIFC_H + 4) * 1)}"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_PLBBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12  + ($BIFC_W + 4) + ((12 + $BIFC_W + 36) * 2)}"
			  y="{200 + (($BIF_H + 4) * 2)}">PLB</text>		  
			 
			  
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 3)}"
			  y="200"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_SOCMBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12  + ($BIFC_W + 4) + ((12 + $BIFC_W + 36) * 3)}"
			  y="{200 + (($BIF_H + 4) * 1)}">SOCM</text>
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 3)}"
			  y="{200 + (($BIFC_H + 4) * 1)}"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_XILBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12  + ($BIFC_W + 4) + ((12 + $BIFC_W + 36) * 3)}"
			  y="{200 + (($BIF_H + 4) * 2)}">XIL (prefix) P2P</text>		  
			 
			  
			  
		<rect 
              x="{12 + ((12 + $BIFC_W + 36) * 4)}"
			  y="200"
		      width= "{$BIFC_H}"
		      height="{$BIFC_W}"
			  style="fill:{$COL_TRSBUS}; stroke:none;"/>		
		<text class="keylabel"
              x="{12  + ($BIFC_W + 4) + ((12 + $BIFC_W + 36) * 4)}"
			  y="{200 + (($BIF_H + 4) * 1)}">GEN. P2P, USER, etc</text>		  
			  
</symbol>	
</xsl:template>

<xsl:template name="Define_BlkDiagram_Specs">

	<xsl:param name="blkd_arch"     select="'NA'"/>
	<xsl:param name="blkd_part"     select="'NA'"/>
	<xsl:param name="blkd_edkver"   select="'NA'"/>
	<xsl:param name="blkd_gentime"  select="'NA'"/>
			
	<symbol id="BlkDiagram_Specs">
		<rect 
              x="0"
			  y="0"
		      width= "{$BLKD_SPECS_W}"
		      height="{$BLKD_SPECS_H}"
			  style="fill:{$COL_BG}; stroke:;"/>		
			  
		<rect 
              x="0"
			  y="0"
		      width= "{$BLKD_SPECS_W}"
		      height="16"
			  style="fill:{$COL_BG}; stroke:none;"/>		
			  
		<text class="keytitle"
              x="{ceiling($BLKD_SPECS_W div 2)} "
			  y="14">SPECS</text>
			  
		<rect 
              x="0"
			  y="20"
		      width= "{$BLKD_SPECS_W}"
		      height="16"
			  style="fill:{$COL_BG_LT}; stroke:none;"/>		
			  
		<text class="specsheader"
              x="4"
			  y="32">EDK VERSION</text>
			  
		<text class="specsvalue"
              x="{($BLKD_SPECS_W + 1) - (string-length($blkd_edkver) * 6.5)}"
			  y="32"><xsl:value-of select="$blkd_edkver"/></text>
			  
		<rect 
              x="0"
			  y="40"
		      width= "{$BLKD_SPECS_W}"
		      height="16"
			  style="fill:{$COL_BG_LT}; stroke:none;"/>		
			  
		<text class="specsheader"
              x="4"
			  y="52">ARCH</text>
			  
		<text class="specsvalue"
              x="{($BLKD_SPECS_W + 1) - (string-length($blkd_arch) * 6.5)}"
			  y="52"><xsl:value-of select="$blkd_arch"/></text>
			  
		<rect 
              x="0"
			  y="60"
		      width= "{$BLKD_SPECS_W}"
		      height="16"
			  style="fill:{$COL_BG_LT}; stroke:none;"/>		
			  
		<text class="specsheader"
              x="4"
			  y="72">PART</text>
			  
		<text class="specsvalue"
              x="{($BLKD_SPECS_W  + 1) - ((string-length($blkd_part) + 2) * 6.5)}"
			  y="72"><xsl:value-of select="$blkd_part"/></text>
			  
		<rect 
              x="0"
			  y="80"
		      width= "{$BLKD_SPECS_W}"
		      height="16"
			  style="fill:{$COL_BG_LT}; stroke:none;"/>		
			  
		<text class="specsheader"
              x="4"
			  y="92">GENERATED</text>
			  
		<text class="specsvalue"
              x="{($BLKD_SPECS_W  + 1) - (string-length($blkd_gentime) * 6.5)}"
			  y="92"><xsl:value-of select="$blkd_gentime"/></text>
			  
			  
	</symbol>	
</xsl:template>

</xsl:stylesheet>

