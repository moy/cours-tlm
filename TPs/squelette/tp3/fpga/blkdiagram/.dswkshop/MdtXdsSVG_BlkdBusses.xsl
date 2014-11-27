<?xml version="1.0" standalone="no"?>
<xsl:stylesheet version="1.0"
           xmlns:svg="http://www.w3.org/2000/svg"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:exsl="http://exslt.org/common"
           xmlns:xlink="http://www.w3.org/1999/xlink">
                
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
	       doctype-public="-//W3C//DTD SVG 1.0//EN"
		   doctype-system="http://www.w3.org/TR/SVG/DTD/svg10.dtd"/>
		
<xsl:variable name="BUS_ARROW_W"        select="ceiling($BIF_W div 4)"/>	
<xsl:variable name="BUS_ARROW_H"        select="ceiling($BIF_H div 2)"/>
<xsl:variable name="BUS_ARROW_G"        select="ceiling($BIF_W div 16)"/>

<xsl:variable name="BUS_LANE_W"         select="(ceiling($BIF_W div 2) + $BUS_ARROW_W)"/>	
<xsl:variable name="SBS_H"              select="($periMOD_H + ($BIF_H * 2))"/>

<xsl:template name="Define_Busses">
	<xsl:param name="drawarea_w"  select="500"/>
	<xsl:param name="drawarea_h"  select="500"/>
	
<!--   East West Arrows definitions -->	

	<xsl:call-template name="Define_BusArrowsEastWest"> 
		<xsl:with-param name="bus_col"     select="$COL_FSLBUS"/>
		<xsl:with-param name="bus_type"    select="'FSL'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsEastWest"> 
		<xsl:with-param name="bus_col"     select="$COL_XILBUS"/>
		<xsl:with-param name="bus_type"    select="'XIL'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsEastWest"> 
		<xsl:with-param name="bus_col"     select="$COL_OPBBUS"/>
		<xsl:with-param name="bus_type"    select="'OPB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsEastWest"> 
		<xsl:with-param name="bus_col"     select="$COL_PLBBUS"/>
		<xsl:with-param name="bus_type"    select="'PLB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsEastWest"> 
		<xsl:with-param name="bus_col"     select="$COL_KEY"/>
		<xsl:with-param name="bus_type"    select="'KEY'"/>
	</xsl:call-template>
	
<!--     End of East West Arrows definitions -->	
	
	
<!--   North South Arrows definitions -->	

	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'OPB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'LMB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'FSL'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'FCB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'XIL'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'TRS'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'DCR'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'DSOCM'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_BusArrowsNorthSouth"> 
		<xsl:with-param name="bus_type"    select="'ISOCM'"/>
	</xsl:call-template>
	
<!--     End of North South Arrows definitions -->	

	<xsl:call-template name="Define_SharedBus"> 
		<xsl:with-param name="bus_type"    select="'PLB'"/>
		<xsl:with-param name="drawarea_w"  select="$drawarea_w"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_SharedBus"> 
		<xsl:with-param name="bus_type"    select="'OPB'"/>
		<xsl:with-param name="drawarea_w"  select="$drawarea_w"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_SplitBusses"> 
		<xsl:with-param name="bus_type"    select="'FSL'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_SplitBusses"> 
		<xsl:with-param name="bus_type"    select="'XIL'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_SplitBusses"> 
		<xsl:with-param name="bus_type"    select="'DCR'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_SplitBusses"> 
		<xsl:with-param name="bus_type"    select="'FCB'"/>
	</xsl:call-template>
	
	<xsl:call-template name="Define_SharedBusses"/> 
	
</xsl:template>

<xsl:template name="Define_BusArrowsEastWest"> 
	<xsl:param name="bus_type"    select="'OPB'"/>
<!--	
	<xsl:param name="bus_arrow_w" select="$BUSARROW_W"/>
	<xsl:param name="bus_arrow_h" select="$BUSARROW_H"/>
	<xsl:param name="bus_col"     select="$BUS_OPBBUS"/>
-->	
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
	
	<symbol id="{$bus_type}_BusArrowEast">
		<path class="bus"
			  d="M   0,0
				 L     {$BUS_ARROW_W}, {ceiling($BUS_ARROW_H div 2)}
				 L   0,{$BUS_ARROW_H}, 
				 Z" style="stroke:none; fill:{$bus_col_}"/>
	</symbol>
	
	<symbol id="{$bus_type}_BusArrowWest">
		<use   x="0"   y="0"  xlink:href="#{$bus_type}_BusArrowEast" transform="scale(-1,1) translate({$BUS_ARROW_W * -1},0)"/>
	</symbol>
	
	<symbol id="{$bus_type}_BusArrowHInitiator">
		<rect x="0" 
		  	  y="{$BUS_ARROW_G}"  
		 	  width= "{$BUS_ARROW_W}" 
		 	  height="{$BUS_ARROW_W - ($BUS_ARROW_G * 2)}" 
		 	 style="stroke:none; fill:{$bus_col_}"/>
	</symbol>
	
</xsl:template>

<!--	
	<xsl:param name="bus_col"     select="'OPB'"/>
-->	

<xsl:template name="Define_BusArrowsNorthSouth">
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
	
	<symbol id="{$bus_type}_BusArrowSouth">
		<path class="bus"
			  d="M   0,0
				 L   {$BUS_ARROW_W},0
				 L   {ceiling($BUS_ARROW_W div 2)}, {$BUS_ARROW_H}
				 Z" style="stroke:none; fill:{$bus_col_}"/>
	</symbol>
	
	<symbol id="{$bus_type}_BusArrowNorth">
		<use   x="0"   y="0"  xlink:href="#{$bus_type}_BusArrowSouth" transform="scale(1,-1) translate(0,{$BUS_ARROW_H * -1})"/>
	</symbol>
	
	<symbol id="{$bus_type}_BusArrowInitiator">
		<rect x="{$BUS_ARROW_G}" 
		  	  y="0"  
		 	  width= "{$BUS_ARROW_W - ($BUS_ARROW_G * 2)}" 
		 	  height="{$BUS_ARROW_H}" 
		 	 style="stroke:none; fill:{$bus_col_}"/>
	</symbol>
	
</xsl:template>


<xsl:template name="Define_BusConnLanes">
	
	<xsl:param name="procInst"  select="'_processor_'"/>
	<xsl:param name="procY"     select="0"/>
	<xsl:param name="procH"     select="0"/>
	<xsl:param name="memUH"     select="0"/>
	<xsl:param name="pstackH"   select="0"/>
	<xsl:param name="pstackW"   select="0"/>
	<xsl:param name="sbsGap"    select="0"/>
	
<!--	
	<xsl:message>This width of the stack is <xsl:value-of select="$pstackW"/></xsl:message>
	<xsl:message>This width of the perimod is <xsl:value-of select="$periMOD_W"/></xsl:message>
	<xsl:message>This width of the stack is <xsl:value-of select="$pstackW"/></xsl:message>
-->	
	
	<xsl:variable name="busLaneW_"  select="($BUS_LANE_W * @BUSLANE_W)"/>
	<xsl:variable name="busLineW_"  select="($busLaneW_ + ceiling($pstackW div 2))"/>
	<xsl:variable name="procBifsY_" select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP)"/>
	
	<xsl:variable name="busLaneOri_" select="@ORIENTED"/>
	
	<symbol id="buslanes_{$procInst}_{@ORIENTED}">
		
<!--		
	<rect x="0" 
		  y="0"  
		  width= "{$busLaneW_}" 
		  height="{$pstackH}" 
		  style="stroke:none; fill:{$COL_WHITE}"/>
-->		  

		<!-- ================================================ -->
		<!-- Draw connections from the processor bifs to     -->
		<!-- the shared busses							      -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[not(@PSTACK_MODS_Y) and (@PBIF_Y) and (@BUSINDEX) and (@BUSLANE_X)]">	
			<xsl:variable name="sbus_y_" select="( $procY  + $procH  + $PROC2SBS_GAP + (@BUSINDEX * $SBS_H) - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2))"/>
			<xsl:variable name="proc_y_" select="(($procY  + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2))"/>
			
			<xsl:variable name="sbus_color_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>
			
			
			<xsl:variable name="sbus_vl_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			
			<xsl:variable name="bifRank_" >
				<xsl:if test="(@BIFRANK)">
					<xsl:value-of select="@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(@BIFRANK)">MASTER</xsl:if>
			</xsl:variable>  
		
			<xsl:if test="(@BUSDOMAIN)">
				<use   x="{$sbus_vl_x_}"   y="{$sbus_y_}"  xlink:href="#{@BUSDOMAIN}_busconn_{$bifRank_}"/>
			</xsl:if>
			
			<!-- The vertical line -->
			<line x1="{$sbus_vl_x_   + ceiling($BIFC_W div 2)}" 
				  y1="{$proc_y_      + ceiling($BIFC_H div 2)}" 
				  x2="{$sbus_vl_x_   + ceiling($BIFC_W div 2)}" 
				  y2="{$sbus_y_  + ceiling($BIFC_H div 2)}" 
				  style="stroke:{$sbus_color_};stroke-width:1"/>
				  
		</xsl:for-each>
		
		
		<!-- ================================================ -->
		<!-- Draw connections from the peripheral bifs to     -->
		<!-- the processor bifs							      -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[((@PSTACK_MODS_Y) and not(@CSTACK_INDEX) and (@PBIF_Y) and (@BUSLANE_X))]">	
			
			<xsl:variable name="peri_bc_y_">
				<xsl:call-template name="_calc_Proc_Shape_Y">
					<xsl:with-param name="procInst" select="$procInst"/>
					<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
					<xsl:with-param name="sbsGap"   select="$sbsGap"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="periInst_" select="@INSTANCE"/>
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="peri_bif_dy_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y">
					<xsl:value-of select="(($BIF_H + $BIF_GAP)  * (/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y))"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y)">0</xsl:if>
			</xsl:variable>
			
			
			<xsl:variable name="peri_bc_dy_">
				<xsl:if test="not(@IS_MEMBIF)">
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
				</xsl:if>
				
				<xsl:if test="@IS_MEMBIF">
					<xsl:value-of select="($periMOD_H +  $MOD_LANE_H  +            $peri_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
				</xsl:if>
			</xsl:variable>
			
				
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="proc_bc_y_"   select="(($procY + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2))"/>
			
			
			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="periRank_">
				<xsl:choose>
					<xsl:when test="$periBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$periBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$periBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="procBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[(@BUSNAME = $busName_) and @BUSDOMAIN]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="procRank_">
				<xsl:choose>
					<xsl:when test="$procBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$procBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$procBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
		
			<xsl:if test="(not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN) and (@BUSDOMAIN))">	
				<use   x="{$bc_x_}"   y="{$peri_bc_y_ + $peri_bc_dy_}"  xlink:href="#{@BUSDOMAIN}_busconn_{$periRank_}"/>
				<use   x="{$bc_x_}"   y="{$proc_bc_y_}"                 xlink:href="#{@BUSDOMAIN}_busconn_{$procRank_}"/>
			</xsl:if>
			
			<xsl:if test="(($peri_bc_y_ + $peri_bc_dy_) &lt; $proc_bc_y_)">
				<xsl:if test="(not(@BIFRANK = 'TARGET') and not(@BIFRANK = 'INITIATOR') and not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN))">	
					<xsl:call-template name="Draw_P2PBus">
						<xsl:with-param name="busX"    select="$bc_x_"/>
						<xsl:with-param name="busTop"  select="($peri_bc_y_ + $peri_bc_dy_)"/>
						<xsl:with-param name="topRnk"  select="$periRank_"/>
						<xsl:with-param name="busBot"  select="$proc_bc_y_"/>
						<xsl:with-param name="botRnk"  select="$procRank_"/>
						<xsl:with-param name="busDom"  select="@BUSDOMAIN"/>
						<xsl:with-param name="busName" select="@BUSNAME"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			
			<xsl:if test="not(($peri_bc_y_ + $peri_bc_dy_) &lt; $proc_bc_y_)">
				<xsl:if test="(not(@BIFRANK = 'TARGET') and not(@BIFRANK = 'INITIATOR') and not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN))">	
					<xsl:call-template name="Draw_P2PBus">
						<xsl:with-param name="busX"    select="$bc_x_"/>
						<xsl:with-param name="busTop"  select="$proc_bc_y_"/>
						<xsl:with-param name="topRnk"  select="$procRank_"/>
						<xsl:with-param name="busBot"  select="($peri_bc_y_ + $peri_bc_dy_)"/>
						<xsl:with-param name="botRnk"  select="$periRank_"/>
						<xsl:with-param name="busDom"  select="@BUSDOMAIN"/>
						<xsl:with-param name="busName" select="@BUSNAME"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			
			
			<xsl:if test="((@BIFRANK = 'TARGET') or (@BIFRANK = 'INITIATOR') or (@BIFRANK = 'TRANSPARENT') or (@IS_BKTCONN))">	
				<xsl:variable name="busType_">
					<xsl:if test="@BUSDOMAIN">
						<xsl:value-of select="@BUSDOMAIN"/>
					</xsl:if>
					<xsl:if test="not(@BUSDOMAIN)">
						<xsl:value-of select="@BIFRANK"/>
					</xsl:if>
				</xsl:variable>			
				
				<xsl:variable name="busColor_">
					<xsl:call-template name="BusType2Color">
						<xsl:with-param name="busType" select="$busType_"/>
					</xsl:call-template>	
				</xsl:variable>			
			
				<line x1="{$bc_x_      + ceiling($BIFC_W div 2)}" 
				      y1="{$peri_bc_y_ + ceiling($BIFC_H div 2) + $peri_bc_dy_}" 
				      x2="{$bc_x_      + ceiling($BIFC_W div 2)}" 
				      y2="{$proc_bc_y_ + ceiling($BIFC_H div 2)}" 
				      style="stroke:{$busColor_};stroke-width:1"/>
			</xsl:if>
			
		</xsl:for-each>
		
		<!-- ================================================ -->
		<!-- Draw connections from the peripheral bifs on     -->
		<!-- complex shapes to the processor bifs			  -->
		<!-- ================================================ -->
		
		<xsl:for-each select="BUSCONN[((@PSTACK_MODS_Y) and (@CSTACK_INDEX) and (@CSTACK_MODS_Y) and (@BIF_Y) and (@PBIF_Y) and (@BUSLANE_X))]">	
		
		
			
			<xsl:variable name="peri_bc_y_">
				<xsl:call-template name="_calc_Proc_Shape_Y">
					<xsl:with-param name="procInst" select="$procInst"/>
					<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
					<xsl:with-param name="sbsGap"   select="$sbsGap"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="peri_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
					
					<xsl:with-param name="cstackModY"   select="@CSTACK_MODS_Y"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="periInst_" select="@INSTANCE"/>
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="peri_bif_dy_">
					<xsl:value-of select="(($BIF_H + $BIF_GAP)  * @BIF_Y)"/>
<!--			
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y">
					<xsl:value-of select="(($BIF_H + $BIF_GAP)  * (/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y))"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y)">0</xsl:if>
-->				
			</xsl:variable>
			
			<xsl:variable name="peri_bc_dy_">
				<xsl:if test="not(@IS_MEMBIF)">
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
				</xsl:if>
				
				<xsl:if test="@IS_MEMBIF">
					<xsl:value-of select="($periMOD_H +  $MOD_LANE_H  +            $peri_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
				</xsl:if>
			</xsl:variable>
			
				
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="proc_bc_y_"   select="(($procY + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2))"/>
			
			
			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="periRank_">
				<xsl:choose>
					<xsl:when test="$periBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$periBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$periBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="procBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[(@BUSNAME = $busName_) and @BUSDOMAIN]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="procRank_">
				<xsl:choose>
					<xsl:when test="$procBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$procBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$procBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
		
			<xsl:if test="(not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN) and (@BUSDOMAIN))">	
				<use   x="{$bc_x_}"   y="{$peri_bc_y_ + $peri_bc_dy_ + $peri_cstk_y_}"  xlink:href="#{@BUSDOMAIN}_busconn_{$periRank_}"/>
				<use   x="{$bc_x_}"   y="{$proc_bc_y_}"                                 xlink:href="#{@BUSDOMAIN}_busconn_{$procRank_}"/>
			</xsl:if>
			
			<xsl:if test="(($peri_bc_y_ + $peri_bc_dy_ + $peri_cstk_y_) &lt; $proc_bc_y_)">
				<xsl:if test="(not(@BIFRANK = 'TARGET') and not(@BIFRANK = 'INITIATOR') and not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN))">	
					<xsl:call-template name="Draw_P2PBus">
						<xsl:with-param name="busX"    select="$bc_x_"/>
						<xsl:with-param name="busTop"  select="($peri_bc_y_ + $peri_bc_dy_ + $peri_cstk_y_)"/>
						<xsl:with-param name="busBot"  select="$proc_bc_y_"/>
						<xsl:with-param name="busDom"  select="@BUSDOMAIN"/>
						<xsl:with-param name="busName" select="@BUSNAME"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			
			<xsl:if test="not(($peri_bc_y_ + $peri_bc_dy_ + $peri_cstk_y_) &lt; $proc_bc_y_)">
				<xsl:if test="(not(@BIFRANK = 'TARGET') and not(@BIFRANK = 'INITIATOR') and not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN))">	
					<xsl:call-template name="Draw_P2PBus">
						<xsl:with-param name="busX"    select="$bc_x_"/>
						<xsl:with-param name="busTop"  select="$proc_bc_y_"/>
						<xsl:with-param name="busBot"  select="($peri_bc_y_ + $peri_bc_dy_ + $peri_cstk_y_)"/>
						<xsl:with-param name="busDom"  select="@BUSDOMAIN"/>
						<xsl:with-param name="busName" select="@BUSNAME"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			
			
			<xsl:if test="((@BIFRANK = 'TARGET') or (@BIFRANK = 'INITIATOR') or (@BIFRANK = 'TRANSPARENT') or (@IS_BKTCONN))">	
				<xsl:variable name="busType_">
					<xsl:if test="@BUSDOMAIN">
						<xsl:value-of select="@BUSDOMAIN"/>
					</xsl:if>
					<xsl:if test="not(@BUSDOMAIN)">
						<xsl:value-of select="@BIFRANK"/>
					</xsl:if>
				</xsl:variable>			
				
				<xsl:variable name="busColor_">
					<xsl:call-template name="BusType2Color">
						<xsl:with-param name="busType" select="$busType_"/>
					</xsl:call-template>	
				</xsl:variable>			
			
				<line x1="{$bc_x_      + ceiling($BIFC_W div 2)}" 
				      y1="{$peri_bc_y_ + ceiling($BIFC_H div 2) + $peri_bc_dy_}" 
				      x2="{$bc_x_      + ceiling($BIFC_W div 2)}" 
				      y2="{$proc_bc_y_ + ceiling($BIFC_H div 2)}" 
				      style="stroke:{$busColor_};stroke-width:1"/>
			</xsl:if>
			
		</xsl:for-each>
		
		
		<!-- ================================================ -->
		<!-- Draw connections from the peripheral bifs        -->
		<!-- and the buckets to the shared busses			  -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[not(@PBIF_Y) and not(@CSTACK_MODS_Y) and not(@CSTACK_INDEX) and (@PSTACK_MODS_Y) and (@BUSINDEX) and (@BUSLANE_X)]">	
		
			<xsl:variable name="periInst_" select="@INSTANCE"/>
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="peri_y_">
				<xsl:call-template name="_calc_Proc_Shape_Y">
					<xsl:with-param name="procInst" select="$procInst"/>
					<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
					<xsl:with-param name="sbsGap"   select="$sbsGap"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="peri_dy_">
				<xsl:if test="not(@IS_BKTCONN)">
					<xsl:variable name="bif_y_">
						<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y">
							<xsl:value-of select="(($BIF_H + $BIF_GAP)  * (/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y))"/>
						</xsl:if>
						<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y)">0</xsl:if>
					</xsl:variable>
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP  + $bif_y_ + ceiling($BIF_H div 2))- ceiling($BIFC_H div 2)"/>
				</xsl:if>
				
				<xsl:if test="@IS_BKTCONN">
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + ceiling($BIF_H div 2))- ceiling($BIFC_H div 2)"/>
				</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="bus_bc_rank_">
				<xsl:choose>
					<xsl:when test="$periBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$periBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:when test="$periBifRank_ = 'TRANSPARENT'">SLAVE</xsl:when>
					<xsl:otherwise><xsl:value-of select="$periBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="bus_bc_y_"  select="($procY  + $procH  + $PROC2SBS_GAP  + (@BUSINDEX * $SBS_H) - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2))"/>
			<xsl:variable name="bus_color_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>

			
			<line x1="{$bc_x_       +             ceiling($BIFC_W div 2)}" 
				  y1="{$bus_bc_y_   +             ceiling($BIFC_H div 2)}" 
				  x2="{$bc_x_       +             ceiling($BIFC_W div 2)}" 
				  y2="{$peri_y_     + $peri_dy_ + ceiling($BIFC_H div 2)}" 
				  style="stroke:{$bus_color_};stroke-width:1"/>
				  
			<xsl:if test="(@BUSDOMAIN)">
				<use   x="{$bc_x_}"  y="{$bus_bc_y_}"  xlink:href="#{@BUSDOMAIN}_busconn_{$bus_bc_rank_}"/>
			</xsl:if>				  
			
		</xsl:for-each>
		
		
		<!-- ================================================ -->
		<!-- Draw connections from the complex peripheral     -->
		<!-- bifs to the shared busses			              -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[not(@PBIF_Y) and (@BIF_Y) and (@CSTACK_MODS_Y) and (@CSTACK_INDEX) and (@BUSINDEX) and (@BUSLANE_X)]">	
		
			<xsl:variable name="periInst_" select="@INSTANCE"/>
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="peri_y_">
				<xsl:if test="(@PSTACK_MODS_Y)">
					<xsl:call-template name="_calc_Proc_Shape_Y">
						<xsl:with-param name="procInst" select="$procInst"/>
						<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
						<xsl:with-param name="sbsGap"   select="$sbsGap"/>
					</xsl:call-template>	
				</xsl:if>
				<xsl:if test="not(@PSTACK_MODS_Y)"><xsl:value-of select="$sbsGap"/></xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="proc_sbs_gap_">
				<xsl:if test="(@PSTACK_MODS_Y)"><xsl:value-of select="$PROC2SBS_GAP"/></xsl:if>
				<xsl:if test="not(@PSTACK_MODS_Y)">0</xsl:if>
			</xsl:variable>			
			
			
			<xsl:variable name="peri_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="@CSTACK_MODS_Y"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="peri_dy_">
				<xsl:variable name="bif_y_">
					<xsl:value-of select="(($BIF_H + $BIF_GAP)  * @BIF_Y)"/>
				</xsl:variable>
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP  + $bif_y_ + ceiling($BIF_H div 2))- ceiling($BIFC_H div 2)"/>
			</xsl:variable>
			
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="bus_bc_rank_">
				<xsl:choose>
					<xsl:when test="$periBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$periBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:when test="$periBifRank_ = 'TRANSPARENT'">SLAVE</xsl:when>
					<xsl:otherwise><xsl:value-of select="$periBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="bus_bc_y_"  select="($procY  + $procH  + $proc_sbs_gap_  + (@BUSINDEX * $SBS_H) - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2))"/>
			<xsl:variable name="bus_color_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>

			<line x1="{$bc_x_       +             ceiling($BIFC_W div 2)}" 
				  y1="{$bus_bc_y_   +             ceiling($BIFC_H div 2)}" 
				  x2="{$bc_x_       +             ceiling($BIFC_W div 2)}" 
				  y2="{$peri_y_     + $peri_dy_ + ceiling($BIFC_H div 2) + $peri_cstk_y_}" 
				  style="stroke:{$bus_color_};stroke-width:1"/>
				  
			<xsl:if test="(@BUSDOMAIN)">
				<use   x="{$bc_x_}"  y="{$bus_bc_y_}"  xlink:href="#{@BUSDOMAIN}_busconn_{$bus_bc_rank_}"/>
			</xsl:if>				  
			
		</xsl:for-each>
		
		<!-- ================================================ -->
		<!-- Draw connections between p2p bifs on the         -->
		<!-- complex stacks							          -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[((@CSTACK_INDEX) and (@BUSLANE_X) and not(@PBIF_Y) and (@BUSNAME) and (@BUSDOMAIN) and (BUSCONNSEG))]">	
		
			<xsl:variable name="peri_bc_y_">
				<xsl:if test="(@PSTACK_MODS_Y)">	
					<xsl:call-template name="_calc_Proc_Shape_Y">
						<xsl:with-param name="procInst" select="$procInst"/>
						<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
						<xsl:with-param name="sbsGap"   select="$sbsGap"/>
					</xsl:call-template>	
				</xsl:if>
				<xsl:if test="not(@PSTACK_MODS_Y)">	
					<xsl:if test="not(@PSTACK_MODS_Y)"><xsl:value-of select="$sbsGap"/></xsl:if>
				</xsl:if>
			</xsl:variable>			
			
		<xsl:variable name="busName_"  select="@BUSNAME"/>
		
		<xsl:for-each select="BUSCONNSEG[((@CSTACK_MODS_Y1) and (@CSTACK_MODS_Y2) and (@BIF_Y1) and (@BIF_Y2) and (@BIFRANK1) and (@BIFRANK2))]">	
			
			<xsl:variable name="mods_y_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="mods_y_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y2"/>
				</xsl:if>
			</xsl:variable>			
	
			<xsl:variable name="bif_y_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_y_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_top_rank_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_bot_rank_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="peri_top_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="../@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="$mods_y_top_"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="peri_bot_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="../@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="$mods_y_bot_"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="peri_top_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * $bif_y_top_)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_bot_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * $bif_y_bot_)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_top_bc_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_top_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_bot_bc_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_bot_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
			</xsl:variable>
			
				
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((../@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((../@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="use_top_rank_">
				<xsl:choose>
					<xsl:when test="$bif_top_rank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$bif_top_rank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$bif_top_rank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="use_bot_rank_">
				<xsl:choose>
					<xsl:when test="$bif_bot_rank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$bif_bot_rank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$bif_bot_rank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:if test="(not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN) and (../@BUSDOMAIN))">	
				<use   x="{$bc_x_}"   y="{$peri_bc_y_ + $peri_top_bc_dy_ + $peri_top_cstk_y_}"  xlink:href="#{../@BUSDOMAIN}_busconn_{$use_top_rank_}"/>
				<use   x="{$bc_x_}"   y="{$peri_bc_y_ + $peri_bot_bc_dy_ + $peri_bot_cstk_y_}"  xlink:href="#{../@BUSDOMAIN}_busconn_{$use_bot_rank_}"/>
			</xsl:if>
			
			<xsl:if test="not(@IS_BKTCONN)">	
				<xsl:call-template name="Draw_P2PBus">
					<xsl:with-param name="busX"    select="$bc_x_"/>
					<xsl:with-param name="busTop"  select="($peri_bc_y_ + $peri_top_bc_dy_ + $peri_top_cstk_y_)"/>
					<xsl:with-param name="busBot"  select="($peri_bc_y_ + $peri_bot_bc_dy_ + $peri_bot_cstk_y_)"/>
					<xsl:with-param name="busDom"  select="../@BUSDOMAIN"/>
					<xsl:with-param name="busName" select="../@BUSNAME"/>
				</xsl:call-template>
			</xsl:if>
			
<!--			
			
			<xsl:if test="not(($peri_bc_y_ + $peri_bc_dy_) &lt; $proc_bc_y_)">
				<xsl:if test="(not(@BIFRANK = 'TARGET') and not(@BIFRANK = 'INITIATOR') and not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN))">	
					<xsl:call-template name="Draw_P2PBus">
						<xsl:with-param name="busX"    select="$bc_x_"/>
						<xsl:with-param name="busTop"  select="$proc_bc_y_"/>
						<xsl:with-param name="busBot"  select="($peri_bc_y_ + $peri_bc_dy_)"/>
						<xsl:with-param name="busDom"  select="@BUSDOMAIN"/>
						<xsl:with-param name="busName" select="@BUSNAME"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			
			<xsl:if test="((@BIFRANK = 'TARGET') or (@BIFRANK = 'INITIATOR') or (@BIFRANK = 'TRANSPARENT') or (@IS_BKTCONN))">	
				<xsl:variable name="busType_">
					<xsl:if test="../@BUSDOMAIN">
						<xsl:value-of select="../@BUSDOMAIN"/>
					</xsl:if>
					<xsl:if test="not(@BUSDOMAIN)">
						<xsl:value-of select="@BIFRANK"/>
					</xsl:if>
				</xsl:variable>			
				
				<xsl:variable name="busColor_">
					<xsl:call-template name="BusType2Color">
						<xsl:with-param name="busType" select="$busType_"/>
					</xsl:call-template>	
				</xsl:variable>			
			
				<line x1="{$bc_x_      + ceiling($BIFC_W div 2)}" 
				      y1="{$peri_bc_y_ + ceiling($BIFC_H div 2) + $peri_bc_dy_}" 
				      x2="{$bc_x_      + ceiling($BIFC_W div 2)}" 
				      y2="{$proc_bc_y_ + ceiling($BIFC_H div 2)}" 
				      style="stroke:{$busColor_};stroke-width:1"/>
			</xsl:if>
-->			
			
		</xsl:for-each>
		
			
		</xsl:for-each>	
		
		
		
		<xsl:for-each select="BUSCONN[((@PSTACK_MODS_Y) and (@CSTACK_INDEX) and (@BUSLANE_X) and not(@PBIF_Y) and (@BUSNAME) and (@BUSDOMAIN) and (@BIF_Y1) and (@BIF_Y2) and (@BIFRANK1) and (@BIFRANK2) and (@CSTACK_MODS_Y1) and (@CSTACK_MODS_Y2))]">	
		
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="peri_bc_y_">
				<xsl:call-template name="_calc_Proc_Shape_Y">
					<xsl:with-param name="procInst" select="$procInst"/>
					<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
					<xsl:with-param name="sbsGap"   select="$sbsGap"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="mods_y_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="mods_y_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y2"/>
				</xsl:if>
			</xsl:variable>			
	
			<xsl:variable name="bif_y_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_y_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_top_rank_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_bot_rank_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="peri_top_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="@mods_y_top_"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="peri_bot_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="$mods_y_bot_"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="peri_top_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * $bif_y_top_)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_bot_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * $bif_y_bot_)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_top_bc_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_top_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_bot_bc_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_bot_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
			</xsl:variable>
			
				
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="use_top_rank_">
				<xsl:choose>
					<xsl:when test="$bif_top_rank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$bif_top_rank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$bif_top_rank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="use_bot_rank_">
				<xsl:choose>
					<xsl:when test="$bif_bot_rank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$bif_bot_rank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$bif_bot_rank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:if test="(not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN) and (@BUSDOMAIN))">	
				<use   x="{$bc_x_}"   y="{$peri_bc_y_ + $peri_top_bc_dy_ + $peri_top_cstk_y_}"  xlink:href="#{@BUSDOMAIN}_busconn_{$use_top_rank_}"/>
				<use   x="{$bc_x_}"   y="{$peri_bc_y_ + $peri_bot_bc_dy_ + $peri_bot_cstk_y_}"  xlink:href="#{@BUSDOMAIN}_busconn_{$use_bot_rank_}"/>
			</xsl:if>
			
			<xsl:if test="(not(@BIFRANK = 'TARGET') and not(@BIFRANK = 'INITIATOR') and not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN))">	
				<xsl:call-template name="Draw_P2PBus">
					<xsl:with-param name="busX"    select="$bc_x_"/>
					<xsl:with-param name="busTop"  select="($peri_bc_y_ + $peri_top_bc_dy_ + $peri_top_cstk_y_)"/>
					<xsl:with-param name="busBot"  select="($peri_bc_y_ + $peri_bot_bc_dy_ + $peri_bot_cstk_y_)"/>
					<xsl:with-param name="busDom"  select="@BUSDOMAIN"/>
					<xsl:with-param name="busName" select="@BUSNAME"/>
				</xsl:call-template>
			</xsl:if>
			
<!--			
			
			<xsl:if test="not(($peri_bc_y_ + $peri_bc_dy_) &lt; $proc_bc_y_)">
				<xsl:if test="(not(@BIFRANK = 'TARGET') and not(@BIFRANK = 'INITIATOR') and not(@BIFRANK = 'TRANSPARENT') and not(@IS_BKTCONN))">	
					<xsl:call-template name="Draw_P2PBus">
						<xsl:with-param name="busX"    select="$bc_x_"/>
						<xsl:with-param name="busTop"  select="$proc_bc_y_"/>
						<xsl:with-param name="busBot"  select="($peri_bc_y_ + $peri_bc_dy_)"/>
						<xsl:with-param name="busName" select="@BUSNAME"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			
			<xsl:if test="((@BIFRANK = 'TARGET') or (@BIFRANK = 'INITIATOR') or (@BIFRANK = 'TRANSPARENT') or (@IS_BKTCONN))">	
				<xsl:variable name="busType_">
					<xsl:if test="@BUSDOMAIN">
						<xsl:value-of select="@BUSDOMAIN"/>
					</xsl:if>
					<xsl:if test="not(@BUSDOMAIN)">
						<xsl:value-of select="@BIFRANK"/>
					</xsl:if>
				</xsl:variable>			
				
				<xsl:variable name="busColor_">
					<xsl:call-template name="BusType2Color">
						<xsl:with-param name="busType" select="$busType_"/>
					</xsl:call-template>	
				</xsl:variable>			
			
				<line x1="{$bc_x_      + ceiling($BIFC_W div 2)}" 
				      y1="{$peri_bc_y_ + ceiling($BIFC_H div 2) + $peri_bc_dy_}" 
				      x2="{$bc_x_      + ceiling($BIFC_W div 2)}" 
				      y2="{$proc_bc_y_ + ceiling($BIFC_H div 2)}" 
				      style="stroke:{$busColor_};stroke-width:1"/>
			</xsl:if>
-->			
			
		</xsl:for-each>
		
	</symbol>
	
</xsl:template>

<xsl:template name="Define_BusConnLines">
	
	<xsl:param name="procInst"  select="'_processor_'"/>
	<xsl:param name="procY"     select="0"/>
	<xsl:param name="procH"     select="0"/>
	<xsl:param name="procW"     select="0"/>
	<xsl:param name="memUH"     select="0"/>
	<xsl:param name="pstackW"   select="0"/>
	<xsl:param name="pstackH"   select="0"/>
	<xsl:param name="sbsGap"    select="0"/>
	
	<xsl:variable name="busLaneW_"  select="($BUS_LANE_W * @BUSLANE_W)"/>
	<xsl:variable name="busLineW_"  select="($busLaneW_ + ceiling($pstackW div 2))"/>
	<xsl:variable name="procBifsY_" select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP)"/>
	
	<xsl:variable name="busLaneOri_" select="@ORIENTED"/>
	
	<symbol id="buslines_{$procInst}_{@ORIENTED}">
		
<!--		
		<rect x="0" 
			  y="0"  
			  width= "{$busLineW_}" 
			  height="{$pstackH}" 
			  style="stroke:none; fill:{$COL_WHITE}"/>
-->			  
	
		<!-- ================================================ -->
		<!-- Draw connections from the processor bifs to      -->
		<!-- the shared busses							      -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[not(@PSTACK_MODS_Y) and (@PBIF_Y) and (@BUSINDEX) and (@BUSLANE_X)]">	
			
			<xsl:variable name="proc_y_"  select="(($procY  + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)))"/>
			<xsl:variable name="sbus_y_"  select="( $procY  + $procH  + $PROC2SBS_GAP + (@BUSINDEX * $SBS_H))"/>
			
			<xsl:variable name="sbus_color_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:variable name="sbus_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="ceiling($procW div 2) - $MOD_LANE_W"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="sbus_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - ceiling($periMOD_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="ceiling($pstackW div 2)  + (((@BUSLANE_X + 1) * $BUS_LANE_W) - ceiling($BIFC_W div 2))"/>
				</xsl:if>	
			</xsl:variable>  
			
			<line x1="{$sbus_x1_}" 
				  y1="{$proc_y_}" 
				  x2="{$sbus_x2_}" 
				  y2="{$proc_y_}" 
				  style="stroke:{$sbus_color_};stroke-width:1"/>
		</xsl:for-each>
		
		<!-- ================================================ -->
		<!-- Draw connections from the peripheral bifs to     -->
		<!-- the processor bifs							      -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[((@PSTACK_MODS_Y) and not(@CSTACK_INDEX) and (@PBIF_Y) and (@BUSLANE_X))]">	
		
			
			<xsl:variable name="peri_bc_y_">
				<xsl:call-template name="_calc_Proc_Shape_Y">
					<xsl:with-param name="procInst" select="$procInst"/>
					<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
					<xsl:with-param name="sbsGap"   select="$sbsGap"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="periInst_" select="@INSTANCE"/>
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="busType_">
				<xsl:if test="@BUSDOMAIN">
					<xsl:value-of select="@BUSDOMAIN"/>
				</xsl:if>
				<xsl:if test="not(@BUSDOMAIN)">
					<xsl:value-of select="@BIFRANK"/>
				</xsl:if>
			</xsl:variable>			
				
			<xsl:variable name="busColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="$busType_"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="peri_bif_dy_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y">
					<xsl:value-of select="(($BIF_H + $BIF_GAP)  * (/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y))"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y)">0</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="peri_bc_dy_">
				<xsl:if test="not(@IS_MEMBIF)">
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
				</xsl:if>
				
				<xsl:if test="@IS_MEMBIF">
					<xsl:value-of select="($periMOD_H +  $MOD_LANE_H  +            $peri_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
				</xsl:if>
			</xsl:variable>
				
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="proc_bc_y_"   select="(($procY + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2))"/>
			
			<xsl:variable name="proc_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="ceiling($procW div 2) - $MOD_LANE_W"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="proc_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - ceiling($periMOD_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="ceiling($pstackW div 2)  + (((@BUSLANE_X + 1) * $BUS_LANE_W) - ceiling($BIFC_W div 2))"/>
				</xsl:if>	
			</xsl:variable>  
			
			
			<xsl:variable name="peri_dx_">
	
				<xsl:if test="not(@IS_MEMBIF)">
					<xsl:value-of select="ceiling($periMOD_W div 2)"/>
				</xsl:if>
				
				<xsl:if test="@IS_MEMBIF">
				
					<xsl:variable name="memCInst_" select="@INSTANCE"/>
					<xsl:variable name="memCW_"    select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[MODULE[(@INSTANCE = $memCInst_)]]/@MODS_W"/>
					
					<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[MODULE[(@INSTANCE = $memCInst_)]]/@MODS_W)">
						<xsl:value-of select="$periMOD_W"/>
					</xsl:if>
					<xsl:if test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[MODULE[(@INSTANCE = $memCInst_)]]/@MODS_W)">
						<xsl:value-of select="ceiling($periMOD_W * ($memCW_ div 2))"/>
					</xsl:if>
				</xsl:if>
			</xsl:variable>
			
		
			<xsl:variable name="peri_bus_dx_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="((@BUSLANE_X + 1) * $BUS_LANE_W)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
	
			
			<xsl:variable name="peri_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ - ($peri_bus_dx_  + ceiling($pstackW div 2))) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="$peri_dx_ - $MOD_LANE_W"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="peri_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - $peri_dx_)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(ceiling($pstackW div 2) + ((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			
			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="periRank_">
				<xsl:choose>
					<xsl:when test="$periBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$periBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$periBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="procBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[(@BUSNAME = $busName_) and @BUSDOMAIN]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="procRank_">
				<xsl:choose>
					<xsl:when test="$procBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$procBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$procBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
		
			<line x1="{$proc_x1_}" 
			      y1="{$proc_bc_y_ + ceiling($BIFC_H div 2)}" 
			      x2="{$proc_x2_}" 
			      y2="{$proc_bc_y_ + ceiling($BIFC_H div 2)}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
			
			<line x1="{$peri_x1_}" 
			      y1="{$peri_bc_y_ + ceiling($BIFC_H div 2) + $peri_bc_dy_}" 
			      x2="{$peri_x2_}" 
			      y2="{$peri_bc_y_ + ceiling($BIFC_H div 2) + $peri_bc_dy_}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
			
		</xsl:for-each>
		
		<!-- ================================================ -->
		<!-- Draw connections from the peripheral bifs        -->
		<!-- that are part of complex shapes to the 		  -->
		<!-- processor bifs									  -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[((@PSTACK_MODS_Y) and (@CSTACK_INDEX) and (@CSTACK_MODS_Y) and (@PBIF_Y) and (@BIF_Y) and (@BUSLANE_X))]">	
			
			<xsl:variable name="peri_bc_y_">
				<xsl:call-template name="_calc_Proc_Shape_Y">
					<xsl:with-param name="procInst" select="$procInst"/>
					<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
					<xsl:with-param name="sbsGap"   select="$sbsGap"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="peri_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="@CSTACK_MODS_Y"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="periInst_" select="@INSTANCE"/>
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="busType_">
				<xsl:if test="@BUSDOMAIN">
					<xsl:value-of select="@BUSDOMAIN"/>
				</xsl:if>
				<xsl:if test="not(@BUSDOMAIN)">
					<xsl:value-of select="@BIFRANK"/>
				</xsl:if>
			</xsl:variable>			
				
			<xsl:variable name="busColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="$busType_"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="peri_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * @BIF_Y)"/>
<!--			
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y">
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y)">0</xsl:if>
-->				
			</xsl:variable>
			
			<xsl:variable name="peri_bc_dy_">
				<xsl:if test="not(@IS_MEMBIF)">
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
				</xsl:if>
				
				<xsl:if test="@IS_MEMBIF">
					<xsl:value-of select="($periMOD_H +  $MOD_LANE_H  +            $peri_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
				</xsl:if>
			</xsl:variable>
				
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="proc_bc_y_"   select="(($procY + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2))"/>
			
			<xsl:variable name="proc_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="ceiling($procW div 2) - $MOD_LANE_W"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="proc_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - ceiling($periMOD_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="ceiling($pstackW div 2)  + (((@BUSLANE_X + 1) * $BUS_LANE_W) - ceiling($BIFC_W div 2))"/>
				</xsl:if>	
			</xsl:variable>  
			
			
			<xsl:variable name="peri_dx_">
	
				<xsl:if test="not(@IS_MEMBIF)">
					<xsl:value-of select="ceiling($periMOD_W div 2)"/>
				</xsl:if>
				
				<xsl:if test="@IS_MEMBIF">
				
					<xsl:variable name="memCInst_" select="@INSTANCE"/>
					<xsl:variable name="memCW_"    select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[MODULE[(@INSTANCE = $memCInst_)]]/@MODS_W"/>
					
					<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[MODULE[(@INSTANCE = $memCInst_)]]/@MODS_W)">
						<xsl:value-of select="$periMOD_W"/>
					</xsl:if>
					<xsl:if test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[MODULE[(@INSTANCE = $memCInst_)]]/@MODS_W)">
						<xsl:value-of select="ceiling($periMOD_W * ($memCW_ div 2))"/>
					</xsl:if>
				</xsl:if>
			</xsl:variable>
			
		
			<xsl:variable name="peri_bus_dx_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="((@BUSLANE_X + 1) * $BUS_LANE_W)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
	
			
			<xsl:variable name="peri_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ - ($peri_bus_dx_  + ceiling($pstackW div 2))) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="$peri_dx_ - $MOD_LANE_W"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="peri_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - $peri_dx_)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(ceiling($pstackW div 2) + ((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			
			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="periRank_">
				<xsl:choose>
					<xsl:when test="$periBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$periBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$periBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="procBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[(@BUSNAME = $busName_) and @BUSDOMAIN]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $procInst)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="procRank_">
				<xsl:choose>
					<xsl:when test="$procBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$procBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:otherwise><xsl:value-of select="$procBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
		
			<line x1="{$proc_x1_}" 
			      y1="{$proc_bc_y_ + ceiling($BIFC_H div 2)}" 
			      x2="{$proc_x2_}" 
			      y2="{$proc_bc_y_ + ceiling($BIFC_H div 2)}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
			
			<line x1="{$peri_x1_}" 
			      y1="{$peri_bc_y_ + ceiling($BIFC_H div 2) + $peri_bc_dy_ + $peri_cstk_y_}" 
			      x2="{$peri_x2_}" 
			      y2="{$peri_bc_y_ + ceiling($BIFC_H div 2) + $peri_bc_dy_ + $peri_cstk_y_}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
			
		</xsl:for-each>
		
		<!-- ================================================ -->
		<!-- Draw connections from the peripheral bifs        -->
		<!-- and the buckets to the shared busses			  -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[not(@PBIF_Y) and not(@CSTACK_MODS_Y) and not(@CSTACK_INDEX) and (@PSTACK_MODS_Y) and (@BUSINDEX) and (@BUSLANE_X)]">	
		
			<xsl:variable name="periInst_" select="@INSTANCE"/>
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="peri_y_">
				<xsl:call-template name="_calc_Proc_Shape_Y">
					<xsl:with-param name="procInst" select="$procInst"/>
					<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
					<xsl:with-param name="sbsGap"   select="$sbsGap"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="peri_dy_">
				<xsl:if test="not(@IS_BKTCONN)">
					<xsl:variable name="bif_y_">
						<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y">
							<xsl:value-of select="(($BIF_H + $BIF_GAP)  * (/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y))"/>
						</xsl:if>
						<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIF_Y)">0</xsl:if>
					</xsl:variable>
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP  + $bif_y_ + ceiling($BIF_H div 2))- ceiling($BIFC_H div 2)"/>
				</xsl:if>
				
				<xsl:if test="@IS_BKTCONN">
					<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + ceiling($BIF_H div 2))- ceiling($BIFC_H div 2)"/>
				</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="peri_dx_">
	
				<xsl:if test="not(@IS_BKTCONN)">
					<xsl:value-of select="ceiling($periMOD_W div 2)"/>
				</xsl:if>
				
				<xsl:if test="(@IS_BKTCONN)">
					<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@BUSNAME = $busName_)]/@MODS_W)">
						<xsl:value-of select="ceiling($periMOD_W div 2)"/>
					</xsl:if>
					<xsl:if test="(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@BUSNAME = $busName_)]/@MODS_W)">
						<xsl:variable name="bktModsW_"   select="/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@BUSNAME = $busName_)]/@MODS_W"/>
						<xsl:variable name="bktW_"       select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * $bktModsW_) + ($MOD_BUCKET_G * ($bktModsW_ - 1))))"/>
						<xsl:value-of select="ceiling($bktW_ div 2)"/>
					</xsl:if>
				</xsl:if>
			</xsl:variable>
			
		
			<xsl:variable name="peri_bus_dx_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="((@BUSLANE_X + 1) * $BUS_LANE_W)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
	
			
			<xsl:variable name="peri_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ - ($peri_bus_dx_  + ceiling($pstackW div 2))) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:if test="not(@IS_BKTCONN)">
						<xsl:value-of select="$peri_dx_ - $MOD_LANE_W"/>
					</xsl:if>	
					<xsl:if test="(@IS_BKTCONN)">
						<xsl:value-of select="$peri_dx_ - $MOD_BKTLANE_W"/>
					</xsl:if>	
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="peri_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:if test="not(@IS_BKTCONN)">
						<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - $peri_dx_)"/>
					</xsl:if>		
					<xsl:if test="(@IS_BKTCONN)">
						<xsl:value-of select="($busLineW_ - $peri_dx_)"/>
					</xsl:if>		
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(ceiling($pstackW div 2) + (((@BUSLANE_X + 1) * $BUS_LANE_W) - ceiling($BIFC_W div 2)))"/>
				</xsl:if>	
			</xsl:variable>  
		
		
			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="bus_bc_rank_">
				<xsl:choose>
					<xsl:when test="$periBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$periBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:when test="$periBifRank_ = 'TRANSPARENT'">SLAVE</xsl:when>
					<xsl:otherwise><xsl:value-of select="$periBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="bus_bc_y_"  select="($procY  + $procH  + $PROC2SBS_GAP  + (@BUSINDEX * $SBS_H) - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2))"/>
			<xsl:variable name="bus_color_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>

			
			<line x1="{$peri_x1_}"
				  y1="{$peri_y_     + $peri_dy_ + ceiling($BIFC_H div 2)}" 
				  x2="{$peri_x2_}"
				  y2="{$peri_y_     + $peri_dy_ + ceiling($BIFC_H div 2)}" 
				  style="stroke:{$bus_color_};stroke-width:1"/>
				  
		</xsl:for-each>
		
		<!-- ================================================ -->
		<!-- Draw connections from the complex peripheral     -->
		<!-- bifs to the shared busses			  		      -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[not(@PBIF_Y) and (@BIF_Y) and (@CSTACK_MODS_Y) and (@CSTACK_INDEX) and (@BUSINDEX) and (@BUSLANE_X)]">	
		
			<xsl:variable name="periInst_" select="@INSTANCE"/>
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="peri_y_">
				<xsl:if test="@PSTACK_MODS_Y">	
					<xsl:call-template name="_calc_Proc_Shape_Y">
						<xsl:with-param name="procInst" select="$procInst"/>
						<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
						<xsl:with-param name="sbsGap"   select="$sbsGap"/>
					</xsl:call-template>	
				</xsl:if>
				<xsl:if test="not(@PSTACK_MODS_Y)"><xsl:value-of select="$sbsGap"/></xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="peri_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="@CSTACK_MODS_Y"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="peri_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP  + (($BIF_H + $BIF_GAP) * @BIF_Y) + ceiling($BIF_H div 2))- ceiling($BIFC_H div 2)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_dx_">
	
				<xsl:if test="not(@IS_BKTCONN)">
					<xsl:value-of select="ceiling($periMOD_W div 2)"/>
				</xsl:if>
				
				<xsl:if test="(@IS_BKTCONN)">
					<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@BUSNAME = $busName_)]/@MODS_W)">
						<xsl:value-of select="ceiling($periMOD_W div 2)"/>
					</xsl:if>
					<xsl:if test="(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@BUSNAME = $busName_)]/@MODS_W)">
						<xsl:variable name="bktModsW_"   select="/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@BUSNAME = $busName_)]/@MODS_W"/>
						<xsl:variable name="bktW_"       select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * $bktModsW_) + ($MOD_BUCKET_G * ($bktModsW_ - 1))))"/>
						<xsl:value-of select="ceiling($bktW_ div 2)"/>
					</xsl:if>
				</xsl:if>
			</xsl:variable>
			
		
			<xsl:variable name="peri_bus_dx_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="((@BUSLANE_X + 1) * $BUS_LANE_W)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
	
			
			<xsl:variable name="peri_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ - ($peri_bus_dx_  + ceiling($pstackW div 2))) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:if test="not(@IS_BKTCONN)">
						<xsl:value-of select="$peri_dx_ - $MOD_LANE_W"/>
					</xsl:if>	
					<xsl:if test="(@IS_BKTCONN)">
						<xsl:value-of select="$peri_dx_ - $MOD_BKTLANE_W"/>
					</xsl:if>	
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="peri_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:if test="not(@IS_BKTCONN)">
						<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - $peri_dx_)"/>
					</xsl:if>		
					<xsl:if test="(@IS_BKTCONN)">
						<xsl:value-of select="($busLineW_ - $peri_dx_)"/>
					</xsl:if>		
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(ceiling($pstackW div 2) + (((@BUSLANE_X + 1) * $BUS_LANE_W) - ceiling($BIFC_W div 2)))"/>
				</xsl:if>	
			</xsl:variable>  

			<xsl:variable name="periBifRank_">
				<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK">
					<xsl:value-of  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[(@BUSNAME = $busName_)]/@BIFRANK"/>
				</xsl:if>
				<xsl:if test="not(/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $periInst_)]/BUSINTERFACE[((@BUSNAME = $busName_) and @BUSDOMAIN)]/@BIFRANK)">TRANSPARENT</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="bus_bc_rank_">
				<xsl:choose>
					<xsl:when test="$periBifRank_ = 'TARGET'">SLAVE</xsl:when>
					<xsl:when test="$periBifRank_ = 'INITIATOR'">MASTER</xsl:when>
					<xsl:when test="$periBifRank_ = 'TRANSPARENT'">SLAVE</xsl:when>
					<xsl:otherwise><xsl:value-of select="$periBifRank_"/></xsl:otherwise> 
				</xsl:choose>		
			</xsl:variable>
			
			<xsl:variable name="bus_bc_y_"  select="($procY  + $procH  + $PROC2SBS_GAP  + (@BUSINDEX * $SBS_H) - ceiling($BIFC_H div 2) + ($BUS_ARROW_G * 2))"/>
			<xsl:variable name="bus_color_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>

			
			<line x1="{$peri_x1_}"
				  y1="{$peri_y_     + $peri_dy_ + ceiling($BIFC_H div 2) + $peri_cstk_y_}" 
				  x2="{$peri_x2_}"
				  y2="{$peri_y_     + $peri_dy_ + ceiling($BIFC_H div 2) + $peri_cstk_y_}" 
				  style="stroke:{$bus_color_};stroke-width:1"/>
				  
		</xsl:for-each>
		
		
		<!-- ================================================ -->
		<!-- Draw connections between processor to            -->
		<!-- processor bifs       			  				  -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[(@IS_PROC2PROC and @BUSDOMAIN and @BIFRANK and @PBIF_Y)]">	
			
			<xsl:variable name="proc2procBusColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:variable>
			<xsl:variable name="proc2procDy_" select="ceiling($BIFC_H div 2)"/>
			
			<xsl:variable name="proc2procX_" >
				<xsl:if test="$busLaneOri_= 'WEST'"><xsl:value-of select="(($busLaneW_  + ceiling($pstackW div 2)) - (ceiling($periMOD_W div 2) + $BIFC_W))"/></xsl:if>	
				<xsl:if test="$busLaneOri_= 'EAST'"><xsl:value-of select="ceiling($periMOD_W div 2)"/></xsl:if>	
			</xsl:variable>  
			<xsl:variable name="proc2procY_"   select="(($procY + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP) + (($BIF_H + $BIF_GAP) * @PBIF_Y) + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2))"/>
			
			<xsl:variable name="proc2procBegX_" >
				<xsl:if test="$busLaneOri_= 'WEST'"><xsl:value-of select="$proc2procX_ + $BIFC_W"/></xsl:if>	
				<xsl:if test="$busLaneOri_= 'EAST'"><xsl:value-of select="$proc2procX_ - $MOD_LANE_W"/></xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="proc2procEndX_" >
				<xsl:if test="$busLaneOri_= 'WEST'"><xsl:value-of select="$proc2procBegX_ + $MOD_LANE_W"/></xsl:if>	
				<xsl:if test="$busLaneOri_= 'EAST'"><xsl:value-of select="$proc2procX_"/></xsl:if>	
			</xsl:variable>  
			
			<line x1="{$proc2procBegX_}" 
				  y1="{$proc2procY_ + $proc2procDy_}" 
				  x2="{$proc2procEndX_}" 
				  y2="{$proc2procY_ + $proc2procDy_}" 
				  style="stroke:{$proc2procBusColor_};stroke-width:1"/>
			
			<xsl:if test="(@BUSDOMAIN)">	
				<use   x="{$proc2procX_}"   y="{$proc2procY_}"  xlink:href="#{@BUSDOMAIN}_busconn_{@BIFRANK}"/>
			</xsl:if>	
		</xsl:for-each>
		
		
		<!-- ================================================ -->
		<!-- Draw connections between p2p bifs 			      -->
		<!-- on the complex stacks						      -->
		<!-- ================================================ -->
		<xsl:for-each select="BUSCONN[((@CSTACK_INDEX) and (@BUSLANE_X) and not(@PBIF_Y) and (@BUSNAME) and (@BUSDOMAIN) and (BUSCONNSEG))]">
		
			<xsl:variable name="peri_bc_y_">
				<xsl:if test="@PSTACK_MODS_Y">
					<xsl:call-template name="_calc_Proc_Shape_Y">
						<xsl:with-param name="procInst" select="$procInst"/>
						<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
						<xsl:with-param name="sbsGap"   select="$sbsGap"/>
					</xsl:call-template>	
				</xsl:if>
				<xsl:if test="not(@PSTACK_MODS_Y)"><xsl:value-of select="$sbsGap"/></xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="busType_">
				<xsl:value-of select="@BUSDOMAIN"/>
			</xsl:variable>			
				
			<xsl:variable name="busColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="$busType_"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:for-each select="BUSCONNSEG[((@BIFRANK1) and (@BIFRANK2) and (@CSTACK_MODS_Y1) and (@CSTACK_MODS_Y2))]">	
			
			<xsl:variable name="mods_y_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="mods_y_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y2"/>
				</xsl:if>
			</xsl:variable>			
	
			<xsl:variable name="bif_y_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_y_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_rank_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_rank_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="peri_top_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="../@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="$mods_y_top_"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="peri_bot_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="../@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="$mods_y_bot_"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			
			<xsl:variable name="peri_top_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * $bif_y_top_)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_bot_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * $bif_y_bot_)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_top_bc_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_top_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_bot_bc_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_bot_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
			</xsl:variable>
				
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((../@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((../@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="peri_dx_">
				<xsl:value-of select="ceiling($periMOD_W div 2)"/>
			</xsl:variable>
			
		
			<xsl:variable name="peri_bus_dx_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="((../@BUSLANE_X + 1) * $BUS_LANE_W)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(((../@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
	
			<xsl:variable name="peri_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ - ($peri_bus_dx_  + ceiling($pstackW div 2))) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="$peri_dx_ - $MOD_LANE_W"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="peri_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - $peri_dx_)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(ceiling($pstackW div 2) + ((../@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<line x1="{$peri_x1_}" 
			      y1="{$peri_bc_y_ + $peri_top_bc_dy_ + ceiling($BIFC_H div 2) + $peri_top_cstk_y_}" 
			      x2="{$peri_x2_}" 
			      y2="{$peri_bc_y_ + $peri_top_bc_dy_ + ceiling($BIFC_H div 2) + $peri_top_cstk_y_}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
			
			<line x1="{$peri_x1_}" 
			      y1="{$peri_bc_y_ + $peri_bot_bc_dy_ + ceiling($BIFC_H div 2) +  $peri_bot_cstk_y_}" 
			      x2="{$peri_x2_}" 
			      y2="{$peri_bc_y_ + $peri_bot_bc_dy_ + ceiling($BIFC_H div 2) +  $peri_bot_cstk_y_}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
		</xsl:for-each>
		
		</xsl:for-each>
		
		<xsl:for-each select="BUSCONN[((@PSTACK_MODS_Y) and (@CSTACK_INDEX) and (@BUSLANE_X) and not(@PBIF_Y) and (@BUSNAME) and (@BUSDOMAIN) and (@BIF_Y1) and (@BIF_Y2) and (@BIFRANK1) and (@BIFRANK2) and (@CSTACK_MODS_Y1) and (@CSTACK_MODS_Y2))]">	
		
			<xsl:variable name="peri_bc_y_">
				<xsl:call-template name="_calc_Proc_Shape_Y">
					<xsl:with-param name="procInst" select="$procInst"/>
					<xsl:with-param name="shapeIdx" select="@PSTACK_MODS_Y"/>
					<xsl:with-param name="sbsGap"   select="$sbsGap"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="mods_y_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="mods_y_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@CSTACK_MODS_Y2"/>
				</xsl:if>
			</xsl:variable>			
	
			<xsl:variable name="bif_y_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_y_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIF_Y2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_rank_top_">
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="bif_rank_bot_">
				<xsl:if test="@CSTACK_MODS_Y1 &gt; @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK1"/>
				</xsl:if>
				<xsl:if test="@CSTACK_MODS_Y1 &lt;= @CSTACK_MODS_Y2">
					<xsl:value-of select="@BIFRANK2"/>
				</xsl:if>
			</xsl:variable>			
			
			<xsl:variable name="peri_top_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="@mods_y_top_"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="peri_bot_cstk_y_">
				<xsl:call-template name="_calc_CStackShapesAbv_Height">
					<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
					<xsl:with-param name="cstackModY"   select="$mods_y_bot_"/>
				</xsl:call-template>	
			</xsl:variable>	
			
			<xsl:variable name="busName_"  select="@BUSNAME"/>
			
			<xsl:variable name="busType_">
				<xsl:value-of select="@BUSDOMAIN"/>
			</xsl:variable>			
				
			<xsl:variable name="busColor_">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="$busType_"/>
				</xsl:call-template>	
			</xsl:variable>			
			
			<xsl:variable name="peri_top_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * $bif_y_top_)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_bot_bif_dy_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * $bif_y_bot_)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_top_bc_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_top_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
			</xsl:variable>
			
			<xsl:variable name="peri_bot_bc_dy_">
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP + $peri_bot_bif_dy_ + ceiling($BIF_H div 2)) - ceiling($BIFC_H div 2)"/>
			</xsl:variable>
				
			<xsl:variable name="bc_x_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="($busLaneW_ - ((@BUSLANE_X + 1) * $BUS_LANE_W))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of  select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="peri_dx_">
				<xsl:value-of select="ceiling($periMOD_W div 2)"/>
			</xsl:variable>
			
		
			<xsl:variable name="peri_bus_dx_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="((@BUSLANE_X + 1) * $BUS_LANE_W)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
	
			<xsl:variable name="peri_x1_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ - ($peri_bus_dx_  + ceiling($pstackW div 2))) + ceiling($BIFC_W div 2))"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="$peri_dx_ - $MOD_LANE_W"/>
				</xsl:if>	
			</xsl:variable>  
			
			<xsl:variable name="peri_x2_" >
				<xsl:if test="$busLaneOri_= 'WEST'">
					<xsl:value-of select="(($busLineW_ + $MOD_LANE_W) - $peri_dx_)"/>
				</xsl:if>	
				
				<xsl:if test="$busLaneOri_= 'EAST'">
					<xsl:value-of select="(ceiling($pstackW div 2) + ((@BUSLANE_X + 1) * $BUS_LANE_W) - $BIFC_W)"/>
				</xsl:if>	
			</xsl:variable>  
			
			<line x1="{$peri_x1_}" 
			      y1="{$peri_bc_y_ + $peri_top_bc_dy_ + ceiling($BIFC_H div 2) + $peri_top_cstk_y_}" 
			      x2="{$peri_x2_}" 
			      y2="{$peri_bc_y_ + $peri_top_bc_dy_ + ceiling($BIFC_H div 2) + $peri_top_cstk_y_}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
			
			<line x1="{$peri_x1_}" 
			      y1="{$peri_bc_y_ + $peri_bot_bc_dy_ + ceiling($BIFC_H div 2) +  $peri_bot_cstk_y_}" 
			      x2="{$peri_x2_}" 
			      y2="{$peri_bc_y_ + $peri_bot_bc_dy_ + ceiling($BIFC_H div 2) +  $peri_bot_cstk_y_}" 
			      style="stroke:{$busColor_};stroke-width:1"/>
		</xsl:for-each>
		
	</symbol>
	
</xsl:template>

<xsl:template name="Draw_P2PBus">
	
	<xsl:param name="busX"    select="0"/>
	<xsl:param name="busTop"  select="0"/>
	<xsl:param name="busBot"  select="0"/>
	<xsl:param name="botRnk"  select="'_unk_'"/>
	<xsl:param name="topRnk"  select="'_unk_'"/>
	<xsl:param name="busDom"  select="'_dom_'"/>
	<xsl:param name="busName" select="'_p2pbus_'"/>
	
	<xsl:variable name="busCol_">
		<xsl:choose>
			
			<xsl:when test="@BUSDOMAIN">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="@BUSDOMAIN"/>
				</xsl:call-template>	
			</xsl:when>
			
			<xsl:when test="not($busDom = '_dom_')">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="$busDom"/>
				</xsl:call-template>	
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:value-of select="$COL_OPBBUS"/>	
			</xsl:otherwise>
			
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="p2pH_" select="($busBot - $busTop) - ($BUS_ARROW_H * 2)"/>

	<xsl:variable name="botArrow_">
		<xsl:choose>
			<xsl:when test="((($botRnk = 'INITIATOR') or ($botRnk = 'MASTER')) and ($busDom = 'FSL'))">BusArrowInitiator</xsl:when>
			<xsl:otherwise>BusArrowSouth</xsl:otherwise> 
		</xsl:choose>		
	</xsl:variable>
	
	<xsl:variable name="topArrow_">
		<xsl:choose>
			<xsl:when test="((($topRnk = 'INITIATOR') or ($topRnk = 'MASTER')) and ($busDom = 'FSL'))">BusArrowInitiator</xsl:when>
			<xsl:otherwise>BusArrowNorth</xsl:otherwise> 
		</xsl:choose>		
	</xsl:variable>
	
	<xsl:if test="@BUSDOMAIN">		
		<use  x="{($busX + ceiling($BIFC_W div 2)) - ceiling($BUS_ARROW_W div 2)}"  
		      y="{$busTop + ($BIFC_H  - $BUS_ARROW_H) + $BUS_ARROW_H}"  
		      xlink:href="#{@BUSDOMAIN}_{$topArrow_}"/>	
		  
		<use  x="{($busX + ceiling($BIFC_W div 2)) - ceiling($BUS_ARROW_W div 2)}"  
		      y="{$busBot - $BUS_ARROW_H}"  
		      xlink:href="#{@BUSDOMAIN}_{$botArrow_}"/>	
	</xsl:if>		  
	
	<xsl:if test="(not(@BUSDOMAIN) and not($busDom = '_dom_'))">		
		<use  x="{($busX + ceiling($BIFC_W div 2)) - ceiling($BUS_ARROW_W div 2)}"  
		      y="{$busTop + ($BIFC_H  - $BUS_ARROW_H) + $BUS_ARROW_H}"  
		      xlink:href="#{$busDom}_{$topArrow_}"/>	
		  
		<use  x="{($busX + ceiling($BIFC_W div 2)) - ceiling($BUS_ARROW_W div 2)}"  
		      y="{$busBot - $BUS_ARROW_H}"  
		      xlink:href="#{$busDom}_{$botArrow_}"/>	
	</xsl:if>		  
	
	
	<rect x="{($busX + ceiling($BIFC_W div 2)) - ceiling($BUS_ARROW_W div 2) + $BUS_ARROW_G}"  
		  y="{$busTop + $BIFC_H + $BUS_ARROW_H}"  
		  height= "{$p2pH_  - ($BUS_ARROW_H * 2)}" 
		  width="{$BUS_ARROW_W - ($BUS_ARROW_G * 2)}" 
		  style="stroke:none; fill:{$busCol_}"/>
		  
	<text class="p2pbuslabel" 
			  x="{$busX   + $BUS_ARROW_W + ceiling($BUS_ARROW_W div 2) + ceiling($BUS_ARROW_W div 4) + 4}"
			  y="{$busTop + ($BUS_ARROW_H * 3)}">
			<xsl:value-of select="$busName"/>
	</text>
	
  	<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE = $busName]/@GPORT_GROUP">
	  	
   	   <text class="ioplblgrp" 
		  x="{$busX   + $BUS_ARROW_W + ceiling($BUS_ARROW_W div 2) + ceiling($BUS_ARROW_W div 4) + 6}"
		  y="{$busTop + ($BUS_ARROW_H * 10)}">
			   <xsl:value-of select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$busName]/@GPORT_GROUP"/>
   		</text>
	   
  	</xsl:if> 	
		
</xsl:template>

<xsl:template name="Define_SharedBus"> 
	
	<xsl:param name="bus_type"    select="'OPB'"/>
	<xsl:param name="drawarea_w"  select="500"/>
	
	<xsl:variable name="sharedbus_w_"  select="($drawarea_w - ($BLKD_INNER_GAP * 2))"/>
	
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
	
	 <symbol id="{$bus_type}_SharedBus">
		<use  x="0"                            y="0"    xlink:href="#{$bus_type}_BusArrowWest"/>	
		<use  x="{$sharedbus_w_ - $BUS_ARROW_W}" y="0"  xlink:href="#{$bus_type}_BusArrowEast"/>	
		
		<rect x="{$BUS_ARROW_W}" 
			  y="{$BUS_ARROW_G}"  
			  width= "{$sharedbus_w_  - ($BUS_ARROW_W * 2)}" 
			  height="{$BUS_ARROW_H - (2 * $BUS_ARROW_G)}" style="stroke:none; fill:{$bus_col_}"/>
	</symbol>
</xsl:template>

	
<xsl:template name="Define_SplitBusses"> 
	
	<xsl:param name="bus_type"    select="'FSL'"/>
	
	<xsl:variable name="bus_col_">
		<xsl:call-template name="BusType2Color">
			<xsl:with-param name="busType" select="$bus_type"/>
		</xsl:call-template>	
	</xsl:variable>
	
	<xsl:variable name="bifc_r_" select="ceiling($BIFC_W div 3)"/>
	
	 <symbol id="{$bus_type}_SplitBus_EAST">
		<use  x="0"  y="0"    xlink:href="#{$bus_type}_BusArrowWest"/>	
		
		<rect x="{$BUS_ARROW_W}" 
			  y="{$BUS_ARROW_G}"  
			  width= "{$BIFC_W}" 
			  height="{$BUS_ARROW_H - (2 * $BUS_ARROW_G)}" style="stroke:none; fill:{$bus_col_}"/>
		<circle 
			  cx="{$BUS_ARROW_W + $BIFC_W}"  
			  cy="{ceiling($BIFC_Wi div 2)}" 
			  r="{ceiling($BIFC_Wi div 2)}" 
			  style="fill:{$bus_col_}; stroke:none;"/> 	  
	</symbol>
	
	<xsl:variable name="splbus_w_" select="($BUS_ARROW_W + $BIFC_W + $BIFC_Wi)"/>
	
	 <symbol id="{$bus_type}_SplitBus_WEST">
		<use   x="0"   y="0"  xlink:href="#{$bus_type}_SplitBus_EAST" transform="scale(-1,1) translate({$splbus_w_ * -1},0)"/>
	</symbol>
	
</xsl:template>


<xsl:template name="Define_SharedBusses"> 

<!-- The Bridges go into the shared bus shape -->
	<xsl:for-each select="BLKDSHAPES/BRIDGESHAPES/MODULE">	
	
		<xsl:variable name="modInst_" select="@INSTANCE"/>
		<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst_]/@MODTYPE"/>
		
		<xsl:call-template name="Define_Peripheral"> 
			<xsl:with-param name="modVori"  select="'normal'"/>
			<xsl:with-param name="modInst"  select="$modInst_"/>
			<xsl:with-param name="modType"  select="$modType_"/>
		</xsl:call-template>
	
	</xsl:for-each>
	
 <symbol id="group_sharedBusses">
	
	<!-- Draw the shared bus shapes first -->	
	<xsl:for-each select="BLKDSHAPES/SBSSHAPES/MODULE">	
		<xsl:variable name="instance_"  select="@INSTANCE"/>
		
		<xsl:variable name="busType_"   select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$instance_]/@BUSTYPE"/>	
		<xsl:variable name="busIndex_"  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$instance_]/@BUSINDEX"/>	
		
		<xsl:variable name="busY_"  select="($busIndex_ * $SBS_H)"/>	
		
		<use  x="0"  y="{$busY_}"  xlink:href="#{$busType_}_SharedBus"/>	
		
		<text class="sharedbuslabel" 
			  x="4"
			  y="{$busY_ + 12}">
			<xsl:value-of select="$instance_"/>
		</text>
		
	</xsl:for-each>
</symbol>	

 <symbol id="KEY_SharedBus">
	<use  x="0"  y="0"  xlink:href="#KEY_BusArrowWest"/>	
	<use  x="30" y="0"  xlink:href="#KEY_BusArrowEast"/>	
		
	<rect x="{$BUS_ARROW_W}" 
		  y="{$BUS_ARROW_G}"  
		  width= "{30 - $BUS_ARROW_W}" 
		  height="{$BUS_ARROW_H - (2 * $BUS_ARROW_G)}" style="stroke:none; fill:{$COL_KEY}"/>
</symbol>

	
</xsl:template>

</xsl:stylesheet>


