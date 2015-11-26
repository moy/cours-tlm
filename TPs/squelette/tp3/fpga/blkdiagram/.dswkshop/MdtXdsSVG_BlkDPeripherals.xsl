<?xml version="1.0" standalone="no"?>
			
<xsl:stylesheet version="1.0"
           xmlns:svg="http://www.w3.org/2000/svg"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:math="http://exslt.org/math"
           xmlns:exsl="http://exslt.org/common"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           extension-element-prefixes="math">
				
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
	       doctype-public="-//W3C//DTD SVG 1.0//EN"
		   doctype-system="http://www.w3.org/TR/SVG/DTD/svg10.dtd"/>
			
<xsl:variable name="INF_H"   select="$BIF_H       + ceiling($BIF_H div 2)"/>				
<xsl:variable name="INF_W"   select="($BIF_W * 2) + $BIF_GAP"/>
<xsl:variable name="INTR_W"  select="18"/>
<xsl:variable name="INTR_H"  select="18"/>


<!-- ======================= DEF FUNCTIONS =================================== -->

<xsl:template name="Define_FreeCmplxModules">
	
	<xsl:for-each select="BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@IS_PROMOTED and not(@IS_PENALIZED) and not(@CSTACK_INDEX))]">	
		
		<xsl:variable name="cmplxId_" select="position()"/>
		
<!--		
		<xsl:message>Drawing free module <xsl:value-of select="$cmplxId_"/></xsl:message>
-->		
		
		<xsl:if test="@MODCLASS='MEMORY_UNIT'">
			<xsl:call-template name="Define_PeripheralMemory">
				<xsl:with-param name="periId" select="$cmplxId_"/>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="((@MODCLASS='MASTER_SLAVE') or (@MODCLASS = 'MONITOR'))">
			<xsl:variable name="modInst_" select="MODULE/@INSTANCE"/>
			<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst_]/@MODTYPE"/>
			<xsl:call-template name="Define_Peripheral">
				<xsl:with-param name="modInst"  select="$modInst_"/>
				<xsl:with-param name="modType"  select="$modType_"/>
			</xsl:call-template>		
		</xsl:if>
		
	</xsl:for-each>		
</xsl:template>	


<xsl:template name="Define_PenalizedModules">
	
	<xsl:for-each select="BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@IS_PROMOTED and @IS_PENALIZED)]">	
		
		<xsl:variable name="penalId_">unkmodule_<xsl:value-of select="@BKTROW"/>_<xsl:value-of select="@MODS_X"/></xsl:variable>
		
<!--		
		<xsl:message>Drawing penalized module <xsl:value-of select="$penalId_"/></xsl:message>
-->		
		
		<xsl:if test="@MODCLASS='MEMORY_UNIT'">
			<xsl:call-template name="Define_PeripheralMemory">
				<xsl:with-param name="periId" select="$penalId_"/>
			</xsl:call-template>
		</xsl:if>
		
<!--		
		<xsl:if test="((@MODCLASS='MASTER_SLAVE') or (@MODCLASS = 'MONITOR'))">
-->		
			<xsl:variable name="modInst_" select="MODULE/@INSTANCE"/>
			<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $modInst_)]/@MODTYPE"/>
			<xsl:call-template name="Define_Peripheral">
				<xsl:with-param name="modInst"  select="$modInst_"/>
				<xsl:with-param name="modType"  select="$modType_"/>
				<xsl:with-param name="unkInst"  select="$penalId_"/>
			</xsl:call-template>		
<!--			
		</xsl:if>
-->		
		
	</xsl:for-each>		
</xsl:template>	


<xsl:template name="Define_IPBucket">
			
	<xsl:for-each select="BLKDSHAPES/IPBUCKET">
		
		<xsl:for-each select="MODULE">	
			
			<xsl:call-template name="Define_IPBucketModule">
				<xsl:with-param name="ip_type"   select="@MODTYPE"/>
				<xsl:with-param name="ip_name"   select="@INSTANCE"/>
			</xsl:call-template>	
			
		</xsl:for-each>		
		
		<symbol id="ipbucket">
			<xsl:variable name="bucket_w_"  select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * @MODS_W) + ($MOD_BUCKET_G * (@MODS_W - 1))))"/>
			<xsl:variable name="bucket_h_"  select="(($MOD_BKTLANE_H * 2) + (($periMOD_H * @MODS_H) + ($MOD_BUCKET_G * (@MODS_H - 1))))"/>
		
		<rect x="0" 
		      y="0"  
			  rx="4"
			  ry="4"
		      width= "{$bucket_w_}" 
		      height="{$bucket_h_}" 
		      style="stroke-width:2; stroke:{$COL_BLACK}; fill:{$COL_IORING_LT}"/>
				 
			<xsl:variable name="bkt_mods_w_" select="@MODS_W"/>
			
			<xsl:for-each select="MODULE">	
				
				<xsl:variable name="clm_"   select="((     position() - 1)  mod $bkt_mods_w_)"/>
				<xsl:variable name="row_"   select="floor((position() - 1)  div $bkt_mods_w_)"/>
				
				<xsl:variable name="bk_x_"  select="$MOD_BKTLANE_W + ($clm_ * ($periMOD_W + $MOD_BUCKET_G))"/>
				<xsl:variable name="bk_y_"  select="$MOD_BKTLANE_H + ($row_ * ($periMOD_H + $MOD_BUCKET_G))"/>
				
					 
				<use x="{$bk_x_}"   
					 y="{$bk_y_}" 
					 xlink:href="#ipbktmodule_{@INSTANCE}"/>		  		  
					 
					 
			</xsl:for-each>		 
					 
	</symbol>		
	
</xsl:for-each>	
</xsl:template>	


<xsl:template name="Define_UNKBucket">
			
	<xsl:for-each select="BLKDSHAPES/UNKBUCKET">
	
		<symbol id="unkbucket">
			<xsl:variable name="bucket_w_"  select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * @MODS_W) + ($MOD_BUCKET_G * (@MODS_W - 1))))"/>
			<xsl:variable name="bucket_h_"  select="(($MOD_BKTLANE_H * 2) + (($periMOD_H * @MODS_H) + ($MOD_BUCKET_G * (@MODS_H - 1))))"/>
		
		<rect x="0" 
		      y="0"  
			  rx="4"
			  ry="4"
		      width= "{$bucket_w_}" 
		      height="{$bucket_h_}" 
		      style="stroke-width:2; stroke:{$COL_BLACK}; fill:{$COL_UNK_BG}"/>
				 
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@IS_PROMOTED and @IS_PENALIZED)]">	
			
			<xsl:variable name="bkt_mods_w_" select="@MODS_W"/>
				
				<xsl:variable name="mod_row_"    select="@BKTROW"/>	
				<xsl:variable name="row_mods_h_" select="/EDKPROJECT/BLKDSHAPES/UNKBUCKET/BKTROW[(@INDEX = $mod_row_)]/@MODS_H"/>	

<!--				
				<xsl:message>The row module is <xsl:value-of select="@BKTROW"/></xsl:message>
				<xsl:message>The height of the module is <xsl:value-of select="$row_mods_h_"/></xsl:message>
-->				
				
				
				<xsl:variable name="bk_x_"  select="$MOD_BKTLANE_W + (@MODS_X * ($periMOD_W + $MOD_BUCKET_G))"/>
				<xsl:variable name="bk_y_"  select="$MOD_BKTLANE_H + ($row_mods_h_ * ($periMOD_H + $MOD_BUCKET_G))"/>
				
				<use x="{$bk_x_}"   
					 y="{$bk_y_}" 
					 xlink:href="#symbol_unkmodule_{@BKTROW}_{@MODS_X}"/>		  		  
<!--				 
-->				 

			</xsl:for-each>		 

			
		</symbol>		
		
	</xsl:for-each>	
</xsl:template>	


		
<xsl:template name="Define_SBSBuckets">
	
	<xsl:for-each select="BLKDSHAPES/SBSBUCKETS/SBSBUCKET">	
		
		<xsl:variable name="bus_name_"   select="@BUSNAME"/>
		<xsl:variable name="bus_doma_"   select="BUSCONNS/BUSCONN/@BUSDOMAIN"/>
		<xsl:variable name="bus_conn_w_" select="BUSCONNS/@BUSLANE_W"/>
		
		<xsl:variable name="bucket_bg_col_">
			<xsl:call-template name="BusType2LightColor">
				<xsl:with-param name="busType" select="$bus_doma_"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="bucket_col_">
			<xsl:call-template name="BusType2Color">
				<xsl:with-param name="busType" select="$bus_doma_"/>
			</xsl:call-template>
		</xsl:variable>
		
		
		<xsl:for-each select="MODULE">	
			
		<xsl:sort data-type="text" select="@INSTANCE" order="ascending"/>
		
			<xsl:call-template name="Define_SBSBucketModule">
				<xsl:with-param name="bif_type"  select="$bus_doma_"/>
				<xsl:with-param name="ip_type"   select="@MODTYPE"/>
				<xsl:with-param name="ip_name"   select="@INSTANCE"/>
			</xsl:call-template>	
			
		</xsl:for-each>		
		
		<symbol id="sbsbucket_{$bus_name_}">
			<xsl:variable name="bucket_w_"  select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * @MODS_W) + ($MOD_BUCKET_G * (@MODS_W - 1))))"/>
			<xsl:variable name="bucket_h_"  select="(($MOD_BKTLANE_H * 2) + (($periMOD_H * @MODS_H) + ($MOD_BUCKET_G * (@MODS_H - 1))))"/>
			
			<rect x="0"
			      y="0"  
				  rx="4"
				  ry="4"
			      width= "{$bucket_w_}" 
			      height="{$bucket_h_}" 
			      style="stroke-width:2; stroke:{$bucket_col_}; fill:{$bucket_bg_col_}"/>
				 
			<xsl:variable name="bkt_mods_w_" select="@MODS_W"/>
			
			<xsl:for-each select="MODULE">	
				
				<xsl:sort data-type="text" select="@INSTANCE" order="ascending"/>
				
				<xsl:variable name="clm_"   select="((     position() - 1)  mod $bkt_mods_w_)"/>
				<xsl:variable name="row_"   select="floor((position() - 1)  div $bkt_mods_w_)"/>
				
				<xsl:variable name="bk_x_"  select="$MOD_BKTLANE_W + ($clm_ * ($periMOD_W + $MOD_BUCKET_G))"/>
				<xsl:variable name="bk_y_"  select="$MOD_BKTLANE_H + ($row_ * ($periMOD_H + $MOD_BUCKET_G))"/>
				
					 
				<use x="{$bk_x_}"   
					 y="{$bk_y_}" 
					 xlink:href="#sbsbktmodule_{@INSTANCE}"/>		  
				
			</xsl:for-each>
			
		</symbol>
		
	</xsl:for-each>		
	
	
</xsl:template>	
	
<!-- ======================= END DEF BLOCK ============================ -->
<xsl:template name="Define_SBSBucketModule">
	
	<xsl:param name="bif_type"  select="'OPB'"/>
	<xsl:param name="ip_name"   select="'ip_type'"/>
	<xsl:param name="ip_type"   select="'ip_name'"/>
	
	<xsl:variable name="bif_y_">
		<xsl:value-of select="$MOD_LANE_H"/>	
	</xsl:variable>

	<xsl:variable name="label_y_">
		<xsl:value-of select="$MOD_LANE_H + $BIF_H + $BIF_GAP"/>	
	</xsl:variable>
	
	
    <symbol id="sbsbktmodule_{$ip_name}">

		<rect x="0"
		      y="0"
			  rx="6" 
			  ry="6" 
		      width = "{$periMOD_W}"
		      height= "{$periMOD_H}"
			  style="fill:{$COL_BG}; stroke:{$COL_WHITE}; stroke-width:2"/>		
			  
		<rect x="{ceiling($periMOD_W div 2) - ceiling($MOD_LABEL_W div 2)}"
		      y="{$label_y_}"
			  rx="3" 
			  ry="3" 
		      width= "{$MOD_LABEL_W}"
		      height="{$MOD_LABEL_H}"
			  style="fill:{$COL_WHITE}; stroke:none;"/>		
			  
			  
	  	<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$ip_name]/@GPORT_GROUP">
	  	
			<rect x="{ceiling($periMOD_W div 2) - ceiling($MOD_LABEL_W div 2)}"
		      	  y="{$label_y_ + $BIF_H + ceiling($BIF_H div 3) - 2}"
			      rx="3" 
			      ry="3" 
		      	  width= "{$MOD_LABEL_W}"
		          height="{$BIF_H}"
			  	  style="fill:{$COL_IORING_LT}; stroke:none;"/>		
			  
	
	   	   <text class="ioplblgrp" 
			  	  x="{ceiling($periMOD_W div 2)}"
		          y="{$label_y_ + $BIF_H + ceiling($BIF_H div 3) + 12}">
			   <xsl:value-of select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$ip_name]/@GPORT_GROUP"/>
	   		</text>
	   
	  	</xsl:if> 
	   
		<text class="bciptype" 
			  x="{ceiling($periMOD_W div 2)}"
			  y="{$label_y_ + 8}">
				<xsl:value-of select="$ip_type"/>
		</text>
				
		<text class="bciplabel" 
			  x="{ceiling($periMOD_W div 2)}"
			  y="{$label_y_ + 16}">
				<xsl:value-of select="$ip_name"/>
	   </text>
	   
		<xsl:for-each select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$ip_name]/BUSINTERFACE">
			
			<xsl:variable name="bif_dom_">
				<xsl:choose>
					<xsl:when test="@BUSDOMAIN">
						<xsl:value-of select="@BUSDOMAIN"/>	
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'TRS'"/>	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="bif_name_">
				<xsl:choose>
					<xsl:when test="string-length(@BIFNAME) &lt;= 5">
						<xsl:value-of select="@BIFNAME"/>	
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring(@BIFNAME,0,5)"/>	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
	
		    <xsl:variable name="bif_x_"  select="ceiling($periMOD_W div 2) - ceiling($BIF_W div 2)"/>
			
			<use  x="{$bif_x_}"   y="{$bif_y_}"  xlink:href="#{$bif_dom_}_Bif"/>
				
			<text class="biflabel" 
				  x="{$bif_x_ + ceiling($BIF_W div 2)}"
				  y="{$bif_y_ + ceiling($BIF_H div 2) + 3}">
					<xsl:value-of select="$bif_name_"/>
			</text>
			
		</xsl:for-each>
		
		<xsl:if test="@INTCINDEX">
			<xsl:variable name="intr_col_">
				<xsl:call-template name="intcIdx2Color">
					<xsl:with-param name="intcIdx" select="@INTCINDEX"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:call-template name="_draw_InterruptCntrl">
				<xsl:with-param name="intr_col" select="$intr_col_"/>
				<xsl:with-param name="intr_x"   select="($periMOD_W - ceiling($INTR_W div 2))"/>
				<xsl:with-param name="intr_y"   select="3"/>
				<xsl:with-param name="intr_idx" select="@INTCINDEX"/>
			</xsl:call-template>	
		</xsl:if>
		
		      
		<xsl:for-each select="INTERRUPTTRGS/INTRTRG">
			
			<xsl:variable name="intr_col_">
				<xsl:call-template name="intcIdx2Color">
					<xsl:with-param name="intcIdx" select="@INTCINDEX"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:call-template name="_draw_InterruptSource">
				<xsl:with-param name="intr_col" select="$intr_col_"/>
				<xsl:with-param name="intr_x"   select="($periMOD_W - $INTR_W)"/>
				<xsl:with-param name="intr_y"   select="((position() - 1) * (ceiling($INTR_H div 2) + 3))"/>
				<xsl:with-param name="intr_pri" select="@INTRPRI"/>
				<xsl:with-param name="intr_idx" select="@INTCINDEX"/>
			</xsl:call-template>	
			
		</xsl:for-each>
		
	</symbol>			  
	
</xsl:template>	

<xsl:template name="Define_IPBucketModule">
	
	<xsl:param name="ip_name"   select="'ip_type'"/>
	<xsl:param name="ip_type"   select="'ip_name'"/>
	
	<xsl:variable name="bif_y_">
		<xsl:value-of select="$MOD_LANE_H"/>	
	</xsl:variable>

	<xsl:variable name="label_y_">
		<xsl:value-of select="(ceiling($periMOD_H div 2) - ceiling($MOD_LABEL_H div 2))"/>	
	</xsl:variable>
	
    <symbol id="ipbktmodule_{$ip_name}">

		<rect x="0"
		      y="0"
			  rx="6" 
			  ry="6" 
		      width = "{$periMOD_W}"
		      height= "{$periMOD_H}"
			  style="fill:{$COL_BG}; stroke:{$COL_BLACK}; stroke-width:2"/>		
			  
		<rect x="{ceiling($periMOD_W div 2) - ceiling($MOD_LABEL_W div 2)}"
		      y="{$label_y_}"
			  rx="3" 
			  ry="3" 
		      width= "{$MOD_LABEL_W}"
		      height="{$MOD_LABEL_H}"
			  style="fill:{$COL_WHITE}; stroke:none;"/>		
			  
<!--
			  y="{$label_y_ + ceiling($MOD_LABEL_H div 2) - 4}"
			  y="{$label_y_ + ceiling($MOD_LABEL_H div 2) + 4}"
-->			  

		<text class="bciptype" 
			  x="{ceiling($periMOD_W div 2)}"
			  y="{$label_y_ + 8}">
				<xsl:value-of select="$ip_type"/>
		</text>
				
		<text class="bciplabel" 
			  x="{ceiling($periMOD_W div 2)}"
			  y="{$label_y_ + 16}">
				<xsl:value-of select="$ip_name"/>
	   </text>
	   
	  	<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$ip_name]/@GPORT_GROUP">
	  	
		<rect x="{ceiling($periMOD_W div 2) - ceiling($MOD_LABEL_W div 2)}"
		      y="{$label_y_ + $BIF_H + ceiling($BIF_H div 3) - 2}"
			  rx="3" 
			  ry="3" 
		      width= "{$MOD_LABEL_W}"
		      height="{$BIF_H}"
			  style="fill:{$COL_IORING_LT}; stroke:none;"/>		
			  
	
	   	   <text class="ioplblgrp" 
			  x="{ceiling($periMOD_W div 2)}"
		      y="{$label_y_ + $BIF_H + ceiling($BIF_H div 3) + 12}">
			   <xsl:value-of select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$ip_name]/@GPORT_GROUP"/>
	   		</text>
	   
	  	</xsl:if> 
	  	
		<xsl:for-each select="INTERRUPTTRGS/INTRTRG">
			
			<xsl:variable name="intr_col_">
				<xsl:call-template name="intcIdx2Color">
					<xsl:with-param name="intcIdx" select="@INTCINDEX"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:call-template name="_draw_InterruptSource">
				<xsl:with-param name="intr_col" select="$intr_col_"/>
				<xsl:with-param name="intr_x"   select="($periMOD_W - $INTR_W)"/>
				<xsl:with-param name="intr_y"   select="((position() - 1) * (ceiling($INTR_H div 2) + 3))"/>
				<xsl:with-param name="intr_pri" select="@INTRPRI"/>
				<xsl:with-param name="intr_idx" select="@INTCINDEX"/>
			</xsl:call-template>	
			
		</xsl:for-each>
		
	   
	   
	</symbol>			  
	
</xsl:template>	
	
	
<xsl:template name="Define_Peripheral"> 
	
<!-- when the module is oriented normal its label goes above the bifs -->	
<!-- when the module is oriented rot180, (part of a processor memory controller for example) its label goes below the bifs -->	

	<xsl:param name="modVori"  select="'normal'"/>
	<xsl:param name="modInst"  select="'_instance_'"/>
	<xsl:param name="modType"  select="'_modtype_'"/>
	<xsl:param name="unkInst"  select="'_unknown_'"/>
	
	<xsl:variable name="modName_">
		<xsl:choose>
			<xsl:when test="$unkInst = '_unknown_'">
				<xsl:value-of select="$modInst"/>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$unkInst"/>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
<!--	
	<xsl:message>The name of the module is <xsl:value-of select="$modName"/></xsl:message>
-->	
	
	<xsl:variable name="bifs_h_">	
		<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE/MODULE[(@INSTANCE = $modInst)]/@BIFS_H) and not(/EDKPROJECT/BLKDSHAPES/BRIDGESHAPES/MODULE[(@INSTANCE = $modInst)]/@BIFS_H)">0</xsl:if>
	
		<xsl:if test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE/MODULE[@INSTANCE = $modInst]/@BIFS_H)">
			<xsl:value-of select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE/MODULE[(@INSTANCE = $modInst)]/@BIFS_H"/>
		</xsl:if>
	
		<xsl:if test="(/EDKPROJECT/BLKDSHAPES/BRIDGESHAPES/MODULE[@INSTANCE = $modInst]/@BIFS_H)">
			<xsl:value-of select="/EDKPROJECT/BLKDSHAPES/BRIDGESHAPES/MODULE[(@INSTANCE = $modInst)]/@BIFS_H"/>
		</xsl:if>
	</xsl:variable>		
	
	<xsl:variable name="label_y_">
		<xsl:choose>
			<xsl:when test="$modVori = 'rot180'">
				<xsl:value-of select="($MOD_LANE_H + (($BIF_H + $BIF_GAP) * $bifs_h_))"/>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$MOD_LANE_H"/>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="bif_dy_">
		<xsl:choose>
			<xsl:when test="$modVori = 'rot180'">
				<xsl:value-of select="$MOD_LANE_H"/>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP)"/>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="peri_stroke_col_">
		<xsl:choose>
			<xsl:when test="((@MODCLASS = 'MASTER_SLAVE') or (@MODCLASS = 'MONITOR')) and BUSCONNS/BUSCONN">
				<xsl:call-template name="BusType2Color">
					<xsl:with-param name="busType" select="BUSCONNS/BUSCONN/@BUSDOMAIN"/>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:value-of select="$COL_WHITE"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="modHeight_">
		<xsl:call-template name="_calc_PeriShape_Height">
			<xsl:with-param name="shapeInst"  select="$modName_"/>
		</xsl:call-template>	
	</xsl:variable>		
	
    <symbol id="symbol_{$modName_}">

		<rect x="0"
		      y="0"
			  rx="6" 
			  ry="6" 
		      width = "{$periMOD_W}"
		      height= "{$modHeight_}"
			  style="fill:{$COL_BG}; stroke:{$peri_stroke_col_}; stroke-width:2"/>		
			  
		<rect x="{ceiling($periMOD_W div 2) - ceiling($MOD_LABEL_W div 2)}"
		      y="{$label_y_}"
			  rx="3" 
			  ry="3" 
		      width= "{$MOD_LABEL_W}"
		      height="{$MOD_LABEL_H}"
			  style="fill:{$COL_WHITE}; stroke:none;"/>		
			  
<!--			  
			  y="{$label_y_ + ceiling($MOD_LABEL_H div 2) - 4}">
			  y="{$label_y_ + ceiling($MOD_LABEL_H div 2) + 4}">
-->
			  
		<text class="bciptype" 
			  x="{ceiling($periMOD_W div 2)}"
			  y="{$label_y_ + 8}">
				<xsl:value-of select="$modType"/>
		</text>
				
		<text class="bciplabel" 
			  x="{ceiling($periMOD_W div 2)}"
			  y="{$label_y_ + 16}">
				<xsl:value-of select="$modInst"/>
	   </text>
	   
	  	<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst]/@GPORT_GROUP">
	  	
		<rect x="{ceiling($periMOD_W div 2) - ceiling($MOD_LABEL_W div 2)}"
		      y="{$label_y_ + $BIF_H + ceiling($BIF_H div 3) - 2}"
			  rx="3" 
			  ry="3" 
		      width= "{$MOD_LABEL_W}"
		      height="{$BIF_H}"
			  style="fill:{$COL_IORING_LT}; stroke:none;"/>		
			  
	   	   <text class="ioplblgrp" 
			  x="{ceiling($periMOD_W div 2)}"
		      y="{$label_y_ + $BIF_H + ceiling($BIF_H div 3) + 12}">
			   <xsl:value-of select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst]/@GPORT_GROUP"/>
	   		</text>
	   
	  	</xsl:if> 
	   
<!--			
			<xsl:variable name="bif_dom_"   select="@BUSDOMAIN"/>
			<xsl:variable name="bif_name_"  select="@BIFNAME"/>
			<xsl:if test="(@BIF_X and @BIF_Y)">	
		    </xsl:if>
-->			
	   
		<xsl:for-each select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst]/BUSINTERFACE[(@BIF_X and @BIF_Y)]">
			
			<xsl:variable name="bif_dom_">
				<xsl:choose>
					<xsl:when test="@BUSDOMAIN">
						<xsl:value-of select="@BUSDOMAIN"/>	
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'TRS'"/>	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="bif_y_">
				<xsl:value-of select="(($BIF_H + $BIF_GAP)  * @BIF_Y)"/>
			</xsl:variable>
			
			<xsl:variable name="bif_name_">
				<xsl:choose>
					<xsl:when test="not(@BIFNAME)">'UNK'</xsl:when>
					<xsl:when test="string-length(@BIFNAME) &lt;= 5">
						<xsl:value-of select="@BIFNAME"/>	
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring(@BIFNAME,0,5)"/>	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
	
			<xsl:variable name="bif_x_" >
				<xsl:if test="not(@ORIENTED='CENTER')">
					<xsl:value-of select="(($BIF_W * @BIF_X) + ($BIF_GAP * @BIF_X) + ($MOD_LANE_W * 1))"/>
				</xsl:if>
				<xsl:if test="(@ORIENTED='CENTER')">
					<xsl:value-of select="ceiling($periMOD_W div 2) - ceiling($BIF_W div 2)"/>
				</xsl:if>
			</xsl:variable> 
			
			<use  x="{$bif_x_}"   y="{$bif_y_ + $bif_dy_}"  xlink:href="#{$bif_dom_}_Bif"/>
				
			<text class="biflabel" 
				  x="{$bif_x_  + ceiling($BIF_W div 2)}"
				  y="{$bif_y_ + $bif_dy_ + ceiling($BIF_H div 2) + 3}">
					<xsl:value-of select="$bif_name_"/>
			</text>
			
		</xsl:for-each>
		
		<xsl:if test="@INTCINDEX">
			<xsl:variable name="intr_col_">
				<xsl:call-template name="intcIdx2Color">
					<xsl:with-param name="intcIdx" select="@INTCINDEX"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:call-template name="_draw_InterruptCntrl">
				<xsl:with-param name="intr_col" select="$intr_col_"/>
				<xsl:with-param name="intr_x"   select="($periMOD_W - ceiling($INTR_W div 2))"/>
				<xsl:with-param name="intr_y"   select="3"/>
				<xsl:with-param name="intr_idx" select="@INTCINDEX"/>
			</xsl:call-template>	
		</xsl:if>
		
		<xsl:for-each select="INTERRUPTTRGS/INTRTRG">
			
			<xsl:variable name="intr_col_">
				<xsl:call-template name="intcIdx2Color">
					<xsl:with-param name="intcIdx" select="@INTCINDEX"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:call-template name="_draw_InterruptSource">
				<xsl:with-param name="intr_col" select="$intr_col_"/>
				<xsl:with-param name="intr_x"   select="($periMOD_W - $INTR_W)"/>
				<xsl:with-param name="intr_y"   select="((position() - 1) * (ceiling($INTR_H div 2) + 3))"/>
				<xsl:with-param name="intr_pri" select="@INTRPRI"/>
				<xsl:with-param name="intr_idx" select="@INTCINDEX"/>
			</xsl:call-template>	
			
		</xsl:for-each>
		
	</symbol>			  
</xsl:template>	

<xsl:template name="Define_PeripheralMemory"> 
	
	<xsl:param name="periId" select="0"/>
	
	<xsl:variable name="mods_h_"  select="@MODS_H"/>
	<xsl:variable name="mods_w_"  select="@MODS_W"/>
	
	<xsl:variable name="peri_col_">
		
		<xsl:if test="BUSCONNS/BUSCONN/@BUSDOMAIN">
			<xsl:call-template name="BusType2Color">
				<xsl:with-param name="busType" select="BUSCONNS/BUSCONN/@BUSDOMAIN"/>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="not(BUSCONNS/BUSCONN/@BUSDOMAIN)">
			<xsl:value-of select="$COL_BLACK"/>
		</xsl:if>
		
	</xsl:variable>  
	
	<!-- first define its symbols as individual modules -->	
	<xsl:for-each select="MODULE[@MODCLASS='MEMORY']">
		<xsl:variable name="modInst_" select="@INSTANCE"/>
		<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst_]/@MODTYPE"/>
		
		<xsl:call-template name="Define_Peripheral"> 
			<xsl:with-param name="modVori"  select="'rot180'"/>
			<xsl:with-param name="modInst"  select="$modInst_"/>
			<xsl:with-param name="modType"  select="$modType_"/>
		</xsl:call-template>		
	</xsl:for-each>	
	
	<xsl:for-each select="MODULE[@MODCLASS='MEMORY_CONTROLLER']">
		<xsl:variable name="modInst_" select="@INSTANCE"/>
		<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst_]/@MODTYPE"/>
		
		<xsl:call-template name="Define_Peripheral"> 
			<xsl:with-param name="modVori"  select="'normal'"/>
			<xsl:with-param name="modInst"  select="$modInst_"/>
			<xsl:with-param name="modType"  select="$modType_"/>
		</xsl:call-template>		
	</xsl:for-each>	
	
	<xsl:variable name="memW_" select="($periMOD_W * $mods_w_)"/>
	<xsl:variable name="memH_" select="($periMOD_H * $mods_h_)"/>
		
    <symbol id="symbol_peripheral_{$periId}">
		
		<rect x="0"
		      y="0"
			  rx="6" 
			  ry="6" 
		      width = "{$memW_ + 4}"
		      height= "{$memH_ + 4}"
			  style="fill:{$peri_col_}; stroke:{$peri_col_}; stroke-width:2"/>		
			  

		<!-- Draw the memory block-->		  
		<xsl:for-each select="MODULE[@MODCLASS='MEMORY']">	
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			
			 <use  x="2"  
				   y="{$periMOD_H + 2}"  
				   xlink:href="#symbol_{$modInst_}"/> 
		</xsl:for-each>
		
		<xsl:for-each select="MODULE[(@MODCLASS='MEMORY_CONTROLLER') and (@ORIENTED = 'WEST')]">	
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			
			 <use  x="{ceiling($memW_ div 2) - ($periMOD_W div 2) + 2}"  
				   y="2"  
				   xlink:href="#symbol_{$modInst_}"/> 
				   
		</xsl:for-each>
		
		<xsl:for-each select="MODULE[(@MODCLASS='MEMORY_CONTROLLER') and (@ORIENTED = 'EAST')]">	
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			
			 <use  x="2"  
				   y="{$periMOD_H + 2}"  
				   xlink:href="#symbol_{$modInst_}"/> 
		</xsl:for-each>
		
			  
	</symbol>			  
	
</xsl:template>	

<!-- ======================= END DEF FUNCTIONS ============================ -->

<!-- ======================= UTILITY FUNCTIONS ============================ -->

<xsl:template name="_draw_InterruptSource">

	<xsl:param name="intr_col" select="$COL_INTR_0"/>
	<xsl:param name="intr_x"   select="0"/>
	<xsl:param name="intr_y"   select="0"/>
	<xsl:param name="intr_pri" select="0"/>
	<xsl:param name="intr_idx" select="0"/>
	
		<rect  
			x="{$intr_x}"
			y="{$intr_y}"
			rx="3"
			ry="3"
			width= "{$INTR_W}" 
			height="{ceiling($INTR_H div 2)}" style="fill:{$intr_col}; stroke:none; stroke-width:1"/> 
			
		<line x1="{$intr_x + ceiling($INTR_W div 2)}" 
			  y1="{$intr_y}"
			  x2="{$intr_x + ceiling($INTR_W div 2)}" 
			  y2="{$intr_y + ceiling($INTR_H div 2)}" 
			  style="stroke:{$COL_BLACK};stroke-width:1"/>
			  
		<xsl:variable name="txt_ofs_">
			<xsl:if test="($intr_pri &gt; 9)">4.5</xsl:if>
			<xsl:if test="not($intr_pri &gt; 9)">0</xsl:if>
		</xsl:variable>	  
		
		<text class="intrsymbol" 
			  x="{$intr_x + 2 - $txt_ofs_}"
			  y="{$intr_y + 8}">
				<xsl:value-of select="$intr_pri"/>
		</text>
			
		<text class="intrsymbol" 
			  x="{$intr_x + 2 + ceiling($INTR_W div 2)}"
			  y="{$intr_y + 8}">
				<xsl:value-of select="$intr_idx"/>
		</text>
			
</xsl:template>

<xsl:template name="_draw_InterruptCntrl">

	<xsl:param name="intr_col" select="$COL_INTR_0"/>
	<xsl:param name="intr_x"   select="0"/>
	<xsl:param name="intr_y"   select="0"/>
	<xsl:param name="intr_idx" select="0"/>
	
		<rect  
			x="{$intr_x}"
			y="{$intr_y}"
			rx="3"
			ry="3"
			width= "{ceiling($INTR_W div 2)}" 
			height="{$INTR_H}" style="fill:{$intr_col}; stroke:none; stroke-width:1"/> 
			
		<line x1="{$intr_x}" 
			  y1="{$intr_y + ceiling($INTR_H div 4)}"
			  x2="{$intr_x + ceiling($INTR_W div 2)}" 
			  y2="{$intr_y + ceiling($INTR_H div 4)}" 
			  style="stroke:{$COL_BLACK};stroke-width:2"/>
			  
		<text class="intrsymbol" 
			  x="{$intr_x + 2}"
			  y="{$intr_y + 8 + ceiling($INTR_H div 2)}">
				<xsl:value-of select="$intr_idx"/>
		</text>
			
</xsl:template>


<xsl:template name="_draw_InterruptedProc">

	<xsl:param name="intr_col" select="$COL_INTR_0"/>
	<xsl:param name="intr_x"   select="0"/>
	<xsl:param name="intr_y"   select="0"/>
	<xsl:param name="intr_idx" select="0"/>
	
		<rect  
			x="{$intr_x}"
			y="{$intr_y}"
			rx="3"
			ry="3"
			width= "{ceiling($INTR_W div 2)}" 
			height="{$INTR_H}" style="fill:{$intr_col}; stroke:none; stroke-width:1"/> 
			
		<line x1="{$intr_x}" 
			  y1="{$intr_y + ceiling($INTR_H div 4) - 2}"
			  x2="{$intr_x + ceiling($INTR_W div 2)}" 
			  y2="{$intr_y + ceiling($INTR_H div 4) - 2}" 
			  style="stroke:{$COL_BLACK};stroke-width:1"/>
			  
		<line x1="{$intr_x}" 
			  y1="{$intr_y + ceiling($INTR_H div 4) + 2}"
			  x2="{$intr_x + ceiling($INTR_W div 2)}" 
			  y2="{$intr_y + ceiling($INTR_H div 4) + 2}" 
			  style="stroke:{$COL_BLACK};stroke-width:1"/>
			  
		<text class="intrsymbol" 
			  x="{$intr_x + 2}"
			  y="{$intr_y + 8 + ceiling($INTR_H div 2)}">
				<xsl:value-of select="$intr_idx"/>
		</text>
			
</xsl:template>

<xsl:template name="_calc_CStackShapesAbv_Height">
	<xsl:param name="cstackModY"   select="100"/>
	<xsl:param name="cstackIndex"  select="100"/>
	
<!--	
	<xsl:message>Stack Index <xsl:value-of select="$cstackIndex"/></xsl:message>
	<xsl:message>Stack Y <xsl:value-of select="$cstackModY"/></xsl:message>
-->	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@CSTACK_INDEX = $cstackIndex)])">0</xsl:if>
	
	<xsl:if test="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@CSTACK_INDEX = $cstackIndex)]">
	
		<xsl:variable name="shapesAbv_Heights_">
			<CSTACK_MOD HEIGHT="0"/>
			
			<!-- Store the all peripherals above this one heights in a variable -->
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@CSTACK_INDEX = $cstackIndex)]/MODULE[(@CSTACK_MODS_Y &lt; $cstackModY)]">
				<xsl:variable name="shapeHeight_">
					<xsl:call-template name="_calc_PeriShape_Height">	
						<xsl:with-param name="shapeInst" select="@INSTANCE"/>
					</xsl:call-template>	
				</xsl:variable>
				
<!--				
				<xsl:message>Calculated height of cstack shape as <xsl:value-of select="$shapeHeight_"/></xsl:message>
-->				
				
				<CSTACK_MOD HEIGHT="{$shapeHeight_ + $BIF_H}"/>
			</xsl:for-each>
		</xsl:variable>
		
<!--		
		<xsl:message>Calculated height of cstack as <xsl:value-of select="sum(exsl:node-set($shapesAbv_Heights_)/CSTACK_MOD/@HEIGHT)"/></xsl:message>
-->		
		
		<xsl:value-of select="sum(exsl:node-set($shapesAbv_Heights_)/CSTACK_MOD/@HEIGHT)"/>
	</xsl:if>
	
</xsl:template>


<xsl:template name="_calc_PeriShape_Height">
	<xsl:param name="shapeInst"  select="_shape_"/>
	
<!--	
	<xsl:message>Calculating height of <xsl:value-of select="$shapeInst"/></xsl:message>
-->	
	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE/MODULE[(@INSTANCE = $shapeInst)]/@BIFS_H) and not(/EDKPROJECT/BLKDSHAPES/BRIDGESHAPES/MODULE[(@INSTANCE = $shapeInst)]/@BIFS_H)">0</xsl:if>
	
	<xsl:if test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE/MODULE[@INSTANCE = $shapeInst]/@BIFS_H)">
		<xsl:variable name="bifs_h_" select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE/MODULE[(@INSTANCE = $shapeInst)]/@BIFS_H"/>
		
		<xsl:value-of select="($MOD_LABEL_H + ($BIF_H * $bifs_h_) + ($BIF_GAP * $bifs_h_) + ($MOD_LANE_H * 2))"/>
	</xsl:if>
	
	<xsl:if test="(/EDKPROJECT/BLKDSHAPES/BRIDGESHAPES/MODULE[@INSTANCE = $shapeInst]/@BIFS_H)">
		<xsl:variable name="bifs_h_" select="/EDKPROJECT/BLKDSHAPES/BRIDGESHAPES/MODULE[(@INSTANCE = $shapeInst)]/@BIFS_H"/>
		
		<xsl:value-of select="($MOD_LABEL_H + ($BIF_H * $bifs_h_) + ($BIF_GAP * $bifs_h_) + ($MOD_LANE_H * 2))"/>
	</xsl:if>
	
</xsl:template>


<xsl:template name="_calc_ProcMemoryUnit_Height">
	<xsl:param name="unitId"  select="_memory_unit_"/>
	
	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_MODS_Y = $unitId)])">0</xsl:if>
	
	<xsl:if test="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_MODS_Y = $unitId)]">
	
		<!-- Store the memory controller heights in a variable -->	
		<xsl:variable name="memC_heights_">	
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_MODS_Y = $unitId)]/MODULE[(@MODCLASS = 'MEMORY_CONTROLLER')])">
				<MEM_CNTLR INSTANCE="{@INSTANCE}" HEIGHT="0"/>
			</xsl:if>
			
			<xsl:if test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_MODS_Y = $unitId)]/MODULE[(@MODCLASS = 'MEMORY_CONTROLLER')])">
				<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_MODS_Y = $unitId)]/MODULE[(@MODCLASS = 'MEMORY_CONTROLLER')]">
					<xsl:variable name="memC_height_">
						<xsl:call-template name="_calc_PeriShape_Height">	
							<xsl:with-param name="shapeInst" select="@INSTANCE"/>
						</xsl:call-template>
					</xsl:variable>
					<MEM_CNTLR INSTANCE="{@INSTANCE}" HEIGHT="{$memC_height_}"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		
		<!-- Store the bram heights in a variable -->	
		<xsl:variable name="bram_heights_">	
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_MODS_Y = $unitId)]/MODULE[not(@MODCLASS = 'MEMORY_CONTROLLER')])">
				<BRAM INSTANCE="{@INSTANCE}" HEIGHT="0"/>
			</xsl:if>
			<xsl:if test="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_MODS_Y = $unitId)]/MODULE[not(@MODCLASS = 'MEMORY_CONTROLLER')]">
				<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_MODS_Y = $unitId)]/MODULE[not(@MODCLASS = 'MEMORY_CONTROLLER')]">
					<xsl:variable name="bram_height_">
						<xsl:call-template name="_calc_PeriShape_Height">	
							<xsl:with-param name="shapeInst" select="@INSTANCE"/>
						</xsl:call-template>
					</xsl:variable>
					<BRAM INSTANCE="{@INSTANCE}" HEIGHT="{$bram_height_}"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		
		<!-- Select the maximum of them -->
		<xsl:variable name="max_bram_height_" select="math:max(exsl:node-set($bram_heights_)/BRAM/@HEIGHT)"/>
		<xsl:variable name="max_memC_height_" select="math:max(exsl:node-set($memC_heights_)/MEM_CNTLR/@HEIGHT)"/>
		
<!--		
		<xsl:message>Calculated maximum height of bram as <xsl:value-of select="$max_bram_height_"/></xsl:message>
		<xsl:message>Calculated maximum height of memory controllers as <xsl:value-of select="$max_memC_height_"/></xsl:message>
-->		
		<xsl:value-of select="$max_bram_height_ + $max_memC_height_"/>
	</xsl:if>

</xsl:template>

<xsl:template name="_calc_MProcMemoryUnit_Height">
	<xsl:param name="blkd_x" select="100"/>
	<xsl:param name="memu_y" select="100"/>
	<xsl:param name="mods_y" select="100"/>
	<xsl:param name="unitId" select="100"/>
	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@HAS_MULTIPROCCONNS and (@MODCLASS = 'MEMORY_UNIT') and (@PSTACK_BLKD_X = $blkd_x) and (@MPSTACK_MEMUS_Y = $memu_y) and (@MPSTACK_MODS_Y = $mods_y))])">0</xsl:if>
	
	<xsl:if test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@HAS_MULTIPROCCONNS and (@MODCLASS = 'MEMORY_UNIT') and (@PSTACK_BLKD_X = $blkd_x) and (@MPSTACK_MEMUS_Y = $memu_y) and (@MPSTACK_MODS_Y = $mods_y))])">
	
		<!-- Store the memory controller heights in a variable -->	
		<xsl:variable name="memC_heights_">	
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@HAS_MULTIPROCCONNS and (@MODCLASS = 'MEMORY_UNIT') and (@PSTACK_BLKD_X = $blkd_x) and (@MPSTACK_MEMUS_Y = $memu_y) and (@MPSTACK_MODS_Y = $mods_y))]/MODULE[(@MODCLASS = 'MEMORY_CONTROLLER')])">
				<MEM_CNTLR INSTANCE="{@INSTANCE}" HEIGHT="0"/>
			</xsl:if>
			
			<xsl:if test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@HAS_MULTIPROCCONNS and (@MODCLASS = 'MEMORY_UNIT') and (@PSTACK_BLKD_X = $blkd_x) and (@MPSTACK_MEMUS_Y = $memu_y) and (@MPSTACK_MODS_Y = $mods_y))]/MODULE[(@MODCLASS = 'MEMORY_CONTROLLER')])">
				<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@HAS_MULTIPROCCONNS and (@MODCLASS = 'MEMORY_UNIT') and (@PSTACK_BLKD_X = $blkd_x) and (@MPSTACK_MEMUS_Y = $memu_y) and (@MPSTACK_MODS_Y = $mods_y))]/MODULE[(@MODCLASS = 'MEMORY_CONTROLLER')]">
					<xsl:variable name="memC_height_">
						<xsl:call-template name="_calc_PeriShape_Height">	
							<xsl:with-param name="shapeInst" select="@INSTANCE"/>
						</xsl:call-template>
					</xsl:variable>
					<MEM_CNTLR INSTANCE="{@INSTANCE}" HEIGHT="{$memC_height_}"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		
		<!-- Store the bram heights in a variable -->	
		<xsl:variable name="bram_heights_">	
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@HAS_MULTIPROCCONNS and (@MODCLASS = 'MEMORY_UNIT') and (@PSTACK_BLKD_X = $blkd_x) and (@MPSTACK_MEMUS_Y = $memu_y) and (@MPSTACK_MODS_Y = $mods_y))]/MODULE[not(@MODCLASS = 'MEMORY_CONTROLLER')])">
				<BRAM INSTANCE="{@INSTANCE}" HEIGHT="0"/>
			</xsl:if>
			<xsl:if test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@HAS_MULTIPROCCONNS and (@MODCLASS = 'MEMORY_UNIT') and (@PSTACK_BLKD_X = $blkd_x) and (@MPSTACK_MEMUS_Y = $memu_y) and (@MPSTACK_MODS_Y = $mods_y))]/MODULE[not(@MODCLASS = 'MEMORY_CONTROLLER')])">
				<xsl:for-each select="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@HAS_MULTIPROCCONNS and (@MODCLASS = 'MEMORY_UNIT') and (@PSTACK_BLKD_X = $blkd_x) and (@MPSTACK_MEMUS_Y = $memu_y) and (@MPSTACK_MODS_Y = $mods_y))]/MODULE[not(@MODCLASS = 'MEMORY_CONTROLLER')])">
					<xsl:variable name="bram_height_">
						<xsl:call-template name="_calc_PeriShape_Height">	
							<xsl:with-param name="shapeInst" select="@INSTANCE"/>
						</xsl:call-template>
					</xsl:variable>
					<BRAM INSTANCE="{@INSTANCE}" HEIGHT="{$bram_height_}"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		
		<!-- Select the maximum of them -->
		<xsl:variable name="max_bram_height_" select="math:max(exsl:node-set($bram_heights_)/BRAM/@HEIGHT)"/>
		<xsl:variable name="max_memC_height_" select="math:max(exsl:node-set($memC_heights_)/MEM_CNTLR/@HEIGHT)"/>
		
<!--		
		<xsl:message>Calculated maximum height of bram as <xsl:value-of select="$max_bram_height_"/></xsl:message>
		<xsl:message>Calculated maximum height of memory controllers as <xsl:value-of select="$max_memC_height_"/></xsl:message>
-->		
		<xsl:value-of select="$max_bram_height_ + $max_memC_height_"/>
	</xsl:if>

</xsl:template>


<xsl:template name="_calc_SbsBucket_Height">
	<xsl:param name="bucketId"  select="100"/>
	
<!--	
	<xsl:message>Looking of height of bucket <xsl:value-of select="$bucketId"/></xsl:message>
-->	
	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@PSTACK_MODS_Y = $bucketId)])">0</xsl:if>
	
	<xsl:if test="/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@PSTACK_MODS_Y = $bucketId)]">
		<xsl:variable name="mods_h_" select="/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@PSTACK_MODS_Y = $bucketId)]/@MODS_H"/>
		
		<xsl:value-of select="(($MOD_BKTLANE_H * 2) + (($periMOD_H * $mods_h_) + ($MOD_BUCKET_G * ($mods_h_ - 1))))"/>
	</xsl:if>
</xsl:template>

<!-- ======================= END UTILITY FUNCTIONS  ======================= -->

<!--
		<xsl:message>Calculating height of memory unit <xsl:value-of select="$unitId"/></xsl:message>
		<xsl:message>Calculating height of memory unit <xsl:value-of select="$unitId"/></xsl:message>
		<xsl:message>Calculated maximum height of memory controllers as <xsl:value-of select="$max_memC_height_"/></xsl:message>
			<xsl:for-each select="exsl:node-set($memC_heights_)/MEM_CNTLR">
				<xsl:message>Found memory controller <xsl:value-of select="@INSTANCE"/> of height <xsl:value-of select="@HEIGHT"/></xsl:message>
			</xsl:for-each>
			<MEM_CNTLR INSTANCE="{@INSTANCE}"><xsl:value-of select="$memC_height_"/></MEM_CNTLR>
			<xsl:message>Found memory controller <xsl:value-of select="@INSTANCE"/></xsl:message>
			<xsl:variable name="num_memC_heights_" select="count(exsl:node-set($memC_heights_)/MEM_CNTRL)"/>
			<xsl:message>Found this many memory controllers <xsl:value-of select="$num_memC_heights_"/></xsl:message>
			<xsl:message>Calculated height of memory controller <xsl:value-of select="$memC_height_"/></xsl:message>
			<xsl:variable name="max_memC_height_" select="math:max(exsl:node-set($memC_heights_)/@HEIGHT)"/>
		<xsl:value-of select="max(exsl:node-set($memC_heights_)/@HEIGHT)"/>
-->

</xsl:stylesheet>

