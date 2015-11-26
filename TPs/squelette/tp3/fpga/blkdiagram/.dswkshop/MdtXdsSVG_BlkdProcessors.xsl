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
			
<!--
<xsl:variable name="BIF_GAP" select="4"/>				
<xsl:variable name="INF_H"   select="ceiling($BIF_H div 2)"/>				
<CPS><xsl:value-of select="@MODCLASS"/></CPS>
-->


<!-- ======================= DEF BLOCK =================================== -->
<xsl:template name="Define_ProcessorStacks"> 
	
	<xsl:for-each select="BLKDSHAPES/PROCSHAPES/MODULE">	
		
		
		<xsl:variable name="procInst_" select="@INSTANCE"/>
		<xsl:variable name="pbifsW_"   select="@BIFS_W"/>
		<xsl:variable name="pbifsH_"   select="@BIFS_H"/>
		
		<xsl:variable name="pbktH_"   select="@PSTACK_BKT_H"/>
		<xsl:variable name="pbktW_"   select="@PSTACK_BKT_W"/>
		<xsl:variable name="pmodH_"   select="@PSTACK_MOD_H"/>
		<xsl:variable name="pmodW_"   select="@PSTACK_MOD_W"/>
		
<!--		
		<xsl:variable name="pmodsH_"   select="@PSTACK_MOD_H"/>
		<xsl:message>Number of Sbs Buckets <xsl:value-of select="$numSbsBkts_"/></xsl:message>
		<xsl:message>Found a processor stack beside <xsl:value-of select="@PSTACK_BLKD_X"/></xsl:message>
		<xsl:message>Found a processor stack beside <xsl:value-of select="@PSTACK_BLKD_X"/></xsl:message>
		<xsl:message>The number of shapes in the stack <xsl:value-of select="$numInStack_"/></xsl:message>
-->		
				
		<!-- First define the processor itself-->	
		<xsl:call-template name="Define_Processor"/>		
		
		<xsl:if test="@PSTACK_BLKD_X">
			<xsl:variable name="stackBlkd_X_"  select="(@PSTACK_BLKD_X + 1)"/>	
			<xsl:variable name="numInStack_"  select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@PSTACK_BLKD_X = $stackBlkd_X_)])"/>	
			
			<xsl:if test="($numInStack_ &gt; 0)">
				<xsl:call-template name="Define_MultiProcessorStack">		
					<xsl:with-param name="stackBlkd_X" select="$stackBlkd_X_"/>
				</xsl:call-template>
			</xsl:if>
			
		</xsl:if>
 
		<!-- Make an inventory of all the things in this processor's stack -->
		<xsl:variable name="numSBSs_"     select="count(/EDKPROJECT/BLKDSHAPES/SBSSHAPES/MODULE)"/>	
		<xsl:variable name="numMemUs_"    select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and    (@MODCLASS='MEMORY_UNIT'))])"/>	
		<xsl:variable name="numPeris_"    select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and not(@MODCLASS='MEMORY_UNIT'))])"/>	
		<xsl:variable name="numPAbvs_"    select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and not(@MODCLASS='MEMORY_UNIT') and not(@HAS_SBSBIF))])"/>	
		<xsl:variable name="numSbsBkts_"  select="count(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[   (@PROCESSOR = $procInst_)])"/>	
		
		<!-- Then define the processor's peripheral shapes -->	
		
		<!-- Define the processor's peripheral shapes-->	
		<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and (@MODCLASS='PERIPHERAL'))]">	
			<xsl:for-each select="MODULE">
				<xsl:variable name="modInst_" select="@INSTANCE"/>
				<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst_]/@MODTYPE"/>
				<xsl:call-template name="Define_Peripheral"> 
					<xsl:with-param name="modInst" select="$modInst_"/>
					<xsl:with-param name="modType" select="$modType_"/>
				</xsl:call-template>		
			</xsl:for-each>	
		</xsl:for-each>
		
		<!-- Define the processor's memory shapes-->	
		<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_) and (@MODCLASS='MEMORY_UNIT'))]">	
			<xsl:call-template name="Define_ProcessorMemory"> 
				<xsl:with-param name="procInst"  select="$procInst_"/>
				<xsl:with-param name="shapeIdx"  select="@PSTACK_MODS_Y"/>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:variable name="bktLanesH_"  select="(($MOD_BKTLANE_H * 2) * $numSbsBkts_)"/>
		
		<xsl:variable name="bktModsH_">
			<xsl:if test="($pbktH_ &gt; 0)">
				<xsl:value-of select="(($periMOD_H * $pbktH_) + ($MOD_BUCKET_G * ($pbktH_ - 1)))"/>	
			</xsl:if>
			<xsl:if test="not($pbktH_ &gt; 0)">0</xsl:if>
		</xsl:variable> 
		
		<xsl:variable name="bktModsW_">
			<xsl:if test="($numSbsBkts_ &gt; 0)">
				<xsl:value-of select="(($MOD_BKTLANE_W * 2) + ($periMOD_W * $pbktW_) + ($MOD_BUCKET_G * ($pbktW_ - 1)))"/>	
			</xsl:if>
			<xsl:if test="not($numSbsBkts_ &gt; 0)">0</xsl:if>
		</xsl:variable> 
		
		<xsl:variable name="pstkModsW_" select="($pmodW_ * $periMOD_W)"/>


		<!-- Calculate the heights of various things -->
		<xsl:variable name="total_memUsH_">
			<xsl:call-template name="_calc_Proc_MemoryUnits_Height"> 
				<xsl:with-param name="procInst"  select="$procInst_"/>
			</xsl:call-template>
		</xsl:variable>	
		
		<xsl:variable name="total_perisH_">
			<xsl:call-template name="_calc_Proc_Peripherals_Height"> 
				<xsl:with-param name="procInst"  select="$procInst_"/>
			</xsl:call-template>
		</xsl:variable>	
		
		<xsl:variable name="total_bktsH_">
			<xsl:call-template name="_calc_Proc_SbsBuckets_Height"> 
				<xsl:with-param name="procInst"  select="$procInst_"/>
			</xsl:call-template>
		</xsl:variable>	
		
		<xsl:variable name="total_perisAbvH_">
			<xsl:call-template name="_calc_Proc_PerisAbvSbs_Height"> 
				<xsl:with-param name="procInst"  select="$procInst_"/>
			</xsl:call-template>
		</xsl:variable>	
		
		
		<xsl:variable name="memUsH_"   select="(($numMemUs_    * $BIF_H) + $total_memUsH_)"/>
		<xsl:variable name="perisH_"   select="(($numPeris_    * $BIF_H) + $total_perisH_)"/>
		<xsl:variable name="pAbvsH_"   select="(($numPAbvs_    * $BIF_H) + $total_perisAbvH_)"/>
		<xsl:variable name="SbsBktsH_" select="(($numSbsBkts_  * $BIF_H) + $total_bktsH_)"/>
		
		<xsl:variable name="sbsH_"     select="($numSBSs_   * $SBS_H)"/>
		
		<xsl:variable name="procH_"    select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * @BIFS_H) + ($MOD_LABEL_H + $BIF_GAP))"/>	
		<xsl:variable name="procY_"    select="($memUsH_ + $pAbvsH_)"/>
		<xsl:variable name="pstackH_"  select="($perisH_ + $memUsH_ + $procH_ + $PROC2SBS_GAP + $sbsH_ + $SbsBktsH_)"/>
		
		<xsl:variable name="pstackW_">
			<xsl:if test="$bktModsW_ &gt; $pstkModsW_">
				<xsl:value-of select="$bktModsW_"/>
			</xsl:if>
			<xsl:if test="not($bktModsW_ &gt; $pstkModsW_)">
				<xsl:value-of select="$pstkModsW_"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="procW_"    select="$periMOD_W"/>
		<xsl:variable name="procX_"    select="(ceiling($pstackW_ div 2) - ceiling($procW_ div 2))"/>
		<xsl:variable name="sbsGap_"   select="($procH_ + $PROC2SBS_GAP + $sbsH_)"/>
		
		<!-- Define the processor's bus lanes and lines -->	
		<xsl:for-each select="BUSCONNS">	
			
			<xsl:call-template name="Define_BusConnLanes">		
				<xsl:with-param name="procInst" select="$procInst_"/>
				<xsl:with-param name="procH"    select="$procH_"/>
				<xsl:with-param name="procW"    select="$procW_"/>
				<xsl:with-param name="procY"    select="$procY_"/>
				<xsl:with-param name="memUH"    select="$memUsH_"/>
				<xsl:with-param name="sbsGap"   select="$sbsGap_"/>
				<xsl:with-param name="pstackH"  select="$pstackH_"/>
				<xsl:with-param name="pstackW"  select="$pstackW_"/>
			</xsl:call-template>		
			
			<xsl:call-template name="Define_BusConnLines">		
				<xsl:with-param name="procInst" select="$procInst_"/>
				<xsl:with-param name="procH"    select="$procH_"/>
				<xsl:with-param name="procW"    select="$procW_"/>
				<xsl:with-param name="procY"    select="$procY_"/>
				<xsl:with-param name="memUH"    select="$memUsH_"/>
				<xsl:with-param name="sbsGap"   select="$sbsGap_"/>
				<xsl:with-param name="pstackH"  select="$pstackH_"/>
				<xsl:with-param name="pstackW"  select="$pstackW_"/>
			</xsl:call-template>		
			
		</xsl:for-each>
		
		<!-- Now use all this stuff to draw the processor stack-->	
		<symbol id="pstack_{$procInst_}">
			<rect x="0"
				  y="0"
			      rx="6" 
			      ry="6" 
		          width = "{$pstackW_}"
		          height= "{$pstackH_}"
			      style="fill:{$COL_BG}; stroke:none;"/>
			
			<!--  Define the  processor stack            -->	
		
			<!-- First draw the the processor's peripherals-->	
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst_))]">
				<xsl:sort select="@PSTACK_MODS_Y" data-type="number"/>
			
				<xsl:variable name="shapeInst_">
					<xsl:if test="   (@MODCLASS = 'MEMORY_UNIT')"><xsl:value-of select="@PSTACK_MODS_Y"/></xsl:if>
					<xsl:if test="not(@MODCLASS = 'MEMORY_UNIT')"><xsl:value-of select="MODULE/@INSTANCE"/></xsl:if>
				</xsl:variable>
				<xsl:variable name="shapeW_"    select="(@MODS_W * $periMOD_W)"/>
				<xsl:variable name="shapeX_"    select="(ceiling($pstackW_ div 2) - ceiling($shapeW_ div 2))"/>
				<xsl:variable name="shapeY_">
					<xsl:call-template name="_calc_Proc_Shape_Y">
						<xsl:with-param name="procInst"  select="$procInst_"/>
						<xsl:with-param name="shapeIdx"  select="@PSTACK_MODS_Y"/>
						<xsl:with-param name="sbsGap"    select="$sbsGap_"/>
					</xsl:call-template>
				</xsl:variable>  
			
				<xsl:if test="(@MODCLASS = 'MEMORY_UNIT')">
				 	<use   x="{$shapeX_}"  y="{$shapeY_}"  xlink:href="#symbol_{$procInst_}_memory_{$shapeInst_}"/> 
				</xsl:if>
				
				<xsl:if test="not(@MODCLASS = 'MEMORY_UNIT') and not(@CSTACK_INDEX)">
				 	<use   x="{$shapeX_}"  y="{$shapeY_}"  xlink:href="#symbol_{$shapeInst_}"/> 
				</xsl:if>
				
				<xsl:if test="not(@MODCLASS = 'MEMORY_UNIT') and (@CSTACK_INDEX)">
					<xsl:for-each select="MODULE">
						<xsl:variable name="cstackInst_" select="@INSTANCE"/>
							
						<xsl:variable name="cstack_y_">	
							<xsl:call-template name="_calc_CStackShapesAbv_Height">
								<xsl:with-param name="cstackIndex"  select="../@CSTACK_INDEX"/>
								<xsl:with-param name="cstackModY"   select="@CSTACK_MODS_Y"/>
							</xsl:call-template>	
						</xsl:variable>
					
			 			<use   x="{$shapeX_}"  y="{$shapeY_ + $cstack_y_}"  xlink:href="#symbol_{$cstackInst_}"/> 
					</xsl:for-each>
				</xsl:if>
				
			</xsl:for-each>
			
			
			
			<!-- Then draw the slave buckets for the shared busses that this processor is master to -->	
<!--			
			<xsl:variable name="cstk_above_h_">
			<xsl:if test="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES[((@PROCESSOR = $procInst_) ))]">
			</xsl:if>
			</xsl:variable>
-->			
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@PROCESSOR = $procInst_)]">	
				<xsl:sort select="@PSTACK_MODS_Y" data-type="number"/>
			
				<xsl:variable name="bucketW_"   select="(($MOD_BKTLANE_W * 2) + (($periMOD_W * @MODS_W) + ($MOD_BUCKET_G * (@MODS_W - 1))))"/>
				<xsl:variable name="bucketX_"   select="(ceiling($pstackW_ div 2) - ceiling($bucketW_ div 2))"/>
				
				<xsl:variable name="bucketY_">
					<xsl:call-template name="_calc_Proc_Shape_Y">
						<xsl:with-param name="procInst"  select="$procInst_"/>
						<xsl:with-param name="shapeIdx"  select="@PSTACK_MODS_Y"/>
						<xsl:with-param name="sbsGap"    select="$sbsGap_"/>
					</xsl:call-template>
				</xsl:variable>  
				
				 <use  x="{$bucketX_}"  y="{$bucketY_}"  xlink:href="#sbsbucket_{@BUSNAME}"/> 
				 
				 <text class="ipclass"
					   x="{$bucketX_}" 
					   y="{$bucketY_ - 4}">SLAVES OF <xsl:value-of select="@BUSNAME"/></text>	
			</xsl:for-each>
			
			<!-- Then draw the the processor itself -->	
			<use  x="{$procX_}"  y="{$procY_}"  xlink:href="#symbol_{$procInst_}"/> 
			
			<xsl:if test = "not(@IS_LIKEPROC)">
				<text class="ipclass"
						x="{$procX_}" 
						y="{$procY_ - 4}">PROCESSOR</text>		
			</xsl:if>			
				  
			<xsl:if test = "@IS_LIKEPROC = 'TRUE'">
				<text class="ipclass"
						x="{$procX_}" 
						y="{$procY_ - 4}">USER MODULE</text>		
			</xsl:if>			
			
		</symbol>
		
		
		<!--    And now combine buslanes, bus lines etc into the entire group for the processor-->	
		<symbol id="pgroup_{$procInst_}">
<!--		
				<xsl:variable name="busConnsWestW_"  select="BUSCONNS[(@ORIENTED = 'EAST')]/@BUSLANE_W"/>	
				<xsl:variable name="busConnsEastW_"  select="BUSCONNS[(@ORIENTED = 'EAST')]/@BUSLANE_W"/>	
-->				
				<xsl:variable name="busConnsWestW_">
					<xsl:if test="BUSCONNS[(@ORIENTED = 'WEST')]">
				  		<xsl:value-of select="BUSCONNS[(@ORIENTED = 'WEST')]/@BUSLANE_W"/>	
					</xsl:if>
					<xsl:if test="not(BUSCONNS[(@ORIENTED = 'WEST')])">0</xsl:if>
				</xsl:variable>
				
				<xsl:variable name="busConnsEastW_">
					<xsl:if test="BUSCONNS[(@ORIENTED = 'EAST')]">
				  		<xsl:value-of select="BUSCONNS[(@ORIENTED = 'EAST')]/@BUSLANE_W"/>	
					</xsl:if>
					<xsl:if test="not(BUSCONNS[(@ORIENTED = 'EAST')])">0</xsl:if>
				</xsl:variable>
				
				<xsl:variable name="busConnsWestX_"  select="0"/>
				<xsl:variable name="pstackX_"        select="($busConnsWestW_ * $BUS_LANE_W)"/>
				<xsl:variable name="busConnsEastX_"  select="($pstackX_ + $pstackW_ + 1)"/>
					
				<!-- Draw the Bus lanes -->	
				
				<xsl:if test="BUSCONNS[(@ORIENTED = 'EAST')]">
					<use  x="{$busConnsEastX_}"  y="0"  xlink:href="#buslanes_{$procInst_}_EAST"/> 
				</xsl:if>		
				<xsl:if test="BUSCONNS[(@ORIENTED = 'WEST')]">
					<use  x="{$busConnsWestX_}"  y="0"  xlink:href="#buslanes_{$procInst_}_WEST"/> 
				</xsl:if>		
				
				<use  x="{$pstackX_}"            y="0"  xlink:href="#pstack_{$procInst_}"/> 
				
				<!-- Draw the Bus Lines on top of the lanes -->	
				<xsl:if test="BUSCONNS[(@ORIENTED = 'EAST')]">
					<use  x="{$busConnsEastX_ - ceiling($pstackW_ div 2)}"  y="0"  xlink:href="#buslines_{$procInst_}_EAST"/> 
				</xsl:if>		
				<xsl:if test="BUSCONNS[(@ORIENTED = 'WEST')]">
					<use  x="{$busConnsWestX_}"                             y="0"  xlink:href="#buslines_{$procInst_}_WEST"/> 
				</xsl:if>		
		</symbol>
	</xsl:for-each>	
</xsl:template>	

<xsl:template name="Define_CmplxStacks"> 
	
	<xsl:variable name="numSBSs_"     select="count(/EDKPROJECT/BLKDSHAPES/SBSSHAPES/MODULE)"/>	
	<xsl:for-each select="/EDKPROJECT//BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[(@CSTACK_INDEX) and (@IS_PROMOTED)]">	
	
		<xsl:variable name="cstackW_" select="$periMOD_W"/>	
		<xsl:variable name="cstackH_">	
			<xsl:call-template name="_calc_CStackShapesAbv_Height">
				<xsl:with-param name="cstackIndex"  select="@CSTACK_INDEX"/>
				<xsl:with-param name="cstackModY"   select="@MODS_H"/>
			</xsl:call-template>	
		</xsl:variable>
		
<!--		
		<xsl:message>Found stack of <xsl:value-of select="$cstackH_"/></xsl:message>
-->		

		<xsl:variable name="cstackIdx_" select="@CSTACK_INDEX"/>
		
		<!-- Define the stack's peripheral shapes -->	
		<xsl:for-each select="MODULE">
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE = $modInst_)]/@MODTYPE"/>
			<xsl:call-template name="Define_Peripheral"> 
				<xsl:with-param name="modInst" select="$modInst_"/>
				<xsl:with-param name="modType" select="$modType_"/>
			</xsl:call-template>		
		</xsl:for-each>	
		
<!--		
		<xsl:variable name="procH_"    select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * @BIFS_H) + ($MOD_LABEL_H + $BIF_GAP))"/>	
		<xsl:variable name="procY_"    select="($memUsH_ + $pAbvsH_)"/>
		<xsl:variable name="pstackH_"  select="($perisH_ + $memUsH_ + $procH_ + $PROC2SBS_GAP + $sbsH_ + $SbsBktsH_)"/>
		
		<xsl:variable name="procW_"    select="$periMOD_W"/>
		<xsl:variable name="procX_"    select="(ceiling($pstackW_ div 2) - ceiling($procW_ div 2))"/>
-->		

		<xsl:variable name="sbsH_"     select="($numSBSs_   * $SBS_H)"/>

		<!-- Define the processor's bus lanes and lines -->	
<!--		
		<xsl:variable name="periX_"    select="ceiling($procW_ div 2)"/>
		<xsl:variable name="sbsGap_"   select="($PROC2SBS_GAP + $sbsH_)"/>
-->		
		<xsl:for-each select="BUSCONNS">	
		
			<xsl:variable name="busConnId_">cstack_<xsl:value-of select="../@CSTACK_INDEX"/></xsl:variable>
			
		
<!--		
				<xsl:with-param name="procInst" select="_processor/>
				<xsl:with-param name="procH"    select="$procH_"/>
				<xsl:with-param name="procW"    select="$procW_"/>
				<xsl:with-param name="procY"    select="$procY_"/>
				<xsl:with-param name="memUH"    select="$memUsH_"/>
				<xsl:with-param name="sbsGap"   select="$sbsGap_"/>
				<xsl:with-param name="pstackH"  select="$pstackH_"/>
				<xsl:with-param name="pstackW"  select="$pstackW_"/>
			<xsl:message>Bus connn Id is <xsl:value-of select="$busConnId_"/></xsl:message>
-->			
			<xsl:call-template name="Define_BusConnLanes">		
				<xsl:with-param name="procInst" select="$busConnId_"/>
				<xsl:with-param name="procH"    select="0"/>
				<xsl:with-param name="procW"    select="$periMOD_W"/>
				<xsl:with-param name="procY"    select="0"/>
				<xsl:with-param name="memUH"    select="0"/>
				<xsl:with-param name="sbsGap"   select="$sbsH_"/>
				<xsl:with-param name="pstackH"  select="$cstackH_"/>
				<xsl:with-param name="pstackW"  select="$cstackW_"/>
			</xsl:call-template>		
			
			<xsl:call-template name="Define_BusConnLines">		
				<xsl:with-param name="procInst" select="$busConnId_"/>
				<xsl:with-param name="procH"    select="0"/>
				<xsl:with-param name="procW"    select="$periMOD_W"/>
				<xsl:with-param name="procY"    select="0"/>
				<xsl:with-param name="memUH"    select="0"/>
				<xsl:with-param name="sbsGap"   select="$sbsH_"/>
				<xsl:with-param name="pstackH"  select="$cstackH_"/>
				<xsl:with-param name="pstackW"  select="$cstackW_"/>
			</xsl:call-template>		
		</xsl:for-each>
		
		<!-- Now use all this stuff to draw the processor stack-->	
		
		<symbol id="cstack_{@CSTACK_INDEX}">
		
			<rect x="0"
				  y="0"
			      rx="6" 
			      ry="6" 
		          width = "{$cstackW_}"
		          height= "{$cstackH_}"
			      style="fill:{$COL_BG}; stroke:none;"/>
			
			<!--  Define the cstack -->	
			<!-- First draw the the processor's peripherals-->	
			<xsl:for-each select="MODULE">
				<xsl:variable name="cstackInst_" select="@INSTANCE"/>
							
				<xsl:variable name="cstack_y_">	
					<xsl:call-template name="_calc_CStackShapesAbv_Height">
						<xsl:with-param name="cstackIndex"  select="../@CSTACK_INDEX"/>
						<xsl:with-param name="cstackModY"   select="@CSTACK_MODS_Y"/>
					</xsl:call-template>	
				</xsl:variable>
					
	 			<use   x="0"  y="{$cstack_y_}"  xlink:href="#symbol_{$cstackInst_}"/> 
			</xsl:for-each>
		</symbol>
		
		
		
		<!--    And now combine buslanes, bus lines etc into the entire group for the processor-->	
		<symbol id="cgroup_{@CSTACK_INDEX}">
		
			<xsl:variable name="busConnsWestW_">
				<xsl:if test="BUSCONNS[(@ORIENTED = 'WEST')]">
			  		<xsl:value-of select="BUSCONNS[(@ORIENTED = 'WEST')]/@BUSLANE_W"/>	
				</xsl:if>
				<xsl:if test="not(BUSCONNS[(@ORIENTED = 'WEST')])">0</xsl:if>
			</xsl:variable>
				
			<xsl:variable name="busConnsEastW_">
				<xsl:if test="BUSCONNS[(@ORIENTED = 'EAST')]">
			  		<xsl:value-of select="BUSCONNS[(@ORIENTED = 'EAST')]/@BUSLANE_W"/>	
				</xsl:if>
				<xsl:if test="not(BUSCONNS[(@ORIENTED = 'EAST')])">0</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="busConnsWestX_"  select="0"/>
			<xsl:variable name="cstackX_"        select="($busConnsWestW_ * $BUS_LANE_W)"/>
			<xsl:variable name="busConnsEastX_"  select="($cstackX_ + $periMOD_W + 1)"/>
					
			<!-- Draw the Bus lanes -->	
			<xsl:if test="BUSCONNS[(@ORIENTED = 'EAST')]">
				<use  x="{$busConnsEastX_}"  y="0"  xlink:href="#buslanes_cstack_{@CSTACK_INDEX}_EAST"/> 
			</xsl:if>		
			<xsl:if test="BUSCONNS[(@ORIENTED = 'WEST')]">
				<use  x="{$busConnsWestX_}"  y="0"  xlink:href="#buslanes_cstack_{@CSTACK_INDEX}_WEST"/> 
			</xsl:if>		
			
			<use  x="{$cstackX_}"            y="{$sbsH_}"  xlink:href="#cstack_{@CSTACK_INDEX}"/> 
			
			<!-- Draw the Bus Lines on top of the lanes -->	
			<xsl:if test="BUSCONNS[(@ORIENTED = 'EAST')]">
				<use  x="{$busConnsEastX_ - ceiling($cstackW_ div 2)}"  y="0"  xlink:href="#buslines_cstack_{@CSTACK_INDEX}_EAST"/> 
			</xsl:if>		
			
			<xsl:if test="BUSCONNS[(@ORIENTED = 'WEST')]">
				<use  x="{$busConnsWestX_}"                             y="0"  xlink:href="#buslines_cstack_{@CSTACK_INDEX}_WEST"/> 
			</xsl:if>		

		</symbol>
	</xsl:for-each>		
	
</xsl:template>	



<xsl:template name="Define_MultiProcessorStack"> 
	<xsl:param name="stackBlkd_X" select="100"/>
	
<!--	
	<xsl:message>Drawing multiprocessor stack at <xsl:value-of select="$stackBlkd_X"/></xsl:message>
	<xsl:message>Number of memory units in stack are <xsl:value-of select="$numMemusInStack_"/></xsl:message>
	<xsl:message>Width of mpstack is <xsl:value-of select="$mpStack_W_"/></xsl:message>
-->	
	
	<xsl:variable name="numPerisInStack_"  select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = $stackBlkd_X) and (@MODCLASS = 'PERIPHERAL'))])"/>	
	<xsl:variable name="numMemusInStack_"  select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = $stackBlkd_X) and (@MODCLASS = 'MEMORY_UNIT'))])"/>	
	
	<xsl:variable name="mpstackW_">
		<xsl:if test="($numMemusInStack_ &gt; 0)">
			<xsl:value-of select="($periMOD_W * 2)"/>
		</xsl:if>
		<xsl:if test="not($numMemusInStack_ &gt; 0)">
			<xsl:value-of select="$periMOD_W"/>
		</xsl:if>
	</xsl:variable>
	
	<xsl:variable name="mpstackH_" select="(($numPerisInStack_  * ($periMOD_H + $BIF_H)) + ($numMemusInStack_  * (($periMOD_H * 2) + $BIF_H)))"/>
	
	<!-- Define the multistack's peripherals -->	
	<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = $stackBlkd_X) and (@MODCLASS='PERIPHERAL'))]">	
		<xsl:for-each select="MODULE">
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[(@INSTANCE=$modInst_)]/@MODTYPE"/>
			<xsl:call-template name="Define_Peripheral"> 
				<xsl:with-param name="modInst" select="$modInst_"/>
				<xsl:with-param name="modType" select="$modType_"/>
			</xsl:call-template>		
		</xsl:for-each>	
	</xsl:for-each>
		
	<!-- Define the multistack's memory blocks -->	
	<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = $stackBlkd_X) and (@MODCLASS='MEMORY_UNIT'))]">	
		<xsl:variable name="mpstackMemuInst_">mp_memu_<xsl:value-of select="$stackBlkd_X"/>_<xsl:value-of select="@MPSTACK_MEMUS_Y"/></xsl:variable>
		<xsl:call-template name="Define_ProcessorMemory"> 
			<xsl:with-param name="procInst"  select="$mpstackMemuInst_"/>
		</xsl:call-template>
	</xsl:for-each>
	
		<symbol id="mpstack_{$stackBlkd_X}">
			
<!--			
			<rect x="0"
				  y="0"
			      rx="6" 
			      ry="6" 
		          width = "{$mpstackW_}"
		          height= "{$mpstackH_}"
			      style="fill:{$COL_YELLOW}; stroke:none;"/>
-->	
				  
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = $stackBlkd_X) and (@MODCLASS='PERIPHERAL'))]">	
				<xsl:sort select="@MPSTACK_MODS_Y" data-type="number"/>
			
				<xsl:variable name="shapeInst_" select="(MODULE/@INSTANCE)"/>
				<xsl:variable name="shapeW_"    select="(@MODS_W * $periMOD_W)"/>
				<xsl:variable name="shapeH_"    select="(@MODS_H * $periMOD_H)"/>
					
				<xsl:variable name="memuY_"    select="(@MPSTACK_MEMUS_Y * (($periMOD_H * 2) + $BIF_H))"/>
				<xsl:variable name="periY_"    select="(@MPSTACK_MODS_Y  *  ($periMOD_H      + $BIF_H))"/>
					
				<xsl:variable name="shapeX_"    select="(ceiling($mpstackW_ div 2) - ceiling($shapeW_ div 2))"/>
				<xsl:variable name="shapeY_"    select="($memuY_ + $periY_)"/>
			
				 <use   x="{$shapeX_}"  y="{$shapeY_}"  xlink:href="#symbol_{$shapeInst_}"/> 
			</xsl:for-each>
			
			<!-- Then draw the memory above the processor -->	
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PSTACK_BLKD_X = $stackBlkd_X) and (@MODCLASS='MEMORY_UNIT'))]">	
				<xsl:sort select="@MPSTACK_MODS_Y" data-type="number"/>
				
				<xsl:variable name="mpstackMemuInst_">mp_memu_<xsl:value-of select="$stackBlkd_X"/>_<xsl:value-of select="@MPSTACK_MEMUS_Y"/></xsl:variable>
				
<!--				
				<xsl:message>Name of memory units is <xsl:value-of select="$mpstackMemuInst_"/></xsl:message>
-->				
				<xsl:variable name="shapeW_"  select="(@MODS_W * $periMOD_W)"/>
				<xsl:variable name="shapeH_"  select="(@MODS_H * $periMOD_H)"/>
				
				<xsl:variable name="memuY_"   select="(@MPSTACK_MEMUS_Y * (($periMOD_H * 2) + $BIF_H))"/>
				<xsl:variable name="periY_"   select="(@MPSTACK_MODS_Y  *  ($periMOD_H      + $BIF_H))"/>
				
				<xsl:variable name="shapeX_"  select="(ceiling($mpstackW_ div 2) - ceiling($shapeW_ div 2))"/>
				<xsl:variable name="shapeY_"  select="($memuY_ + $periY_)"/>
						
				<xsl:if test="not(@MPSTACK_MODS_Y)">
					<use   x="{$shapeX_}"  y="{$shapeY_}"  xlink:href="#symbol_{$mpstackMemuInst_}_memory"/> 
				</xsl:if>			
				<xsl:if test="(@MPSTACK_MODS_Y)">
					<use   x="{$shapeX_}"  y="{$shapeY_}"  xlink:href="#symbol_{$mpstackMemuInst_}_memory_{@MPSTACK_MODS_Y}"/> 
				</xsl:if>			
			</xsl:for-each>
				
		</symbol>		  
			

</xsl:template>	

<xsl:template name="Define_ProcessorMemory"> 
	<xsl:param name="procInst"    select="'_processor_'"/>
	
	<xsl:variable name="mods_h_"  select="@MODS_H"/>
	<xsl:variable name="mods_w_"  select="@MODS_W"/>
	
	<!-- first define its symbols as individual modules -->	
	<xsl:for-each select="MODULE[@MODCLASS='MEMORY']">
		<xsl:variable name="modInst_" select="@INSTANCE"/>
		<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst_]/@MODTYPE"/>
		
		<xsl:call-template name="Define_Peripheral"> 
			<xsl:with-param name="modVori"  select="'normal'"/>
			<xsl:with-param name="modInst"  select="$modInst_"/>
			<xsl:with-param name="modType"  select="$modType_"/>
		</xsl:call-template>		
	</xsl:for-each>	
	
	<xsl:for-each select="MODULE[@MODCLASS='MEMORY_CONTROLLER']">
		<xsl:variable name="modInst_" select="@INSTANCE"/>
		<xsl:variable name="modType_" select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$modInst_]/@MODTYPE"/>
		
		<xsl:call-template name="Define_Peripheral"> 
			<xsl:with-param name="modVori"  select="'rot180'"/>
			<xsl:with-param name="modInst"  select="$modInst_"/>
			<xsl:with-param name="modType"  select="$modType_"/>
		</xsl:call-template>		
	</xsl:for-each>	
	
	<xsl:variable name="memW_" select="($periMOD_W * $mods_w_)"/>
	<xsl:variable name="memH_" select="($periMOD_H * $mods_h_)"/>
	
	<xsl:variable name="mp_stack_name_">
		<xsl:if test="(@PSTACK_MODS_Y)">symbol_<xsl:value-of select="$procInst"/>_memory_<xsl:value-of select="@PSTACK_MODS_Y"/></xsl:if>
		<xsl:if test="(@MPSTACK_MODS_Y)">symbol_<xsl:value-of select="$procInst"/>_memory_<xsl:value-of select="@MPSTACK_MODS_Y"/></xsl:if>
	</xsl:variable>
	
<!--	
	<xsl:message>The mp stack name is <xsl:value-of select="$mp_stack_name_"/></xsl:message>
-->	
	
		
    <symbol id="{$mp_stack_name_}">

		<rect x="0"
		      y="0"
			  rx="6" 
			  ry="6" 
		      width = "{$memW_}"
		      height= "{$memH_}"
			  style="fill:{$COL_BG}; stroke:{$COL_WHITE}; stroke-width:2"/>		
			  
		<!-- Draw the memory block-->		  
		<xsl:for-each select="MODULE[@MODCLASS='MEMORY']">	
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			
			 <use  x="{ceiling($memW_ div 2) - ($periMOD_W div 2)}"  
				   y="0"  
				   xlink:href="#symbol_{$modInst_}"/> 
		</xsl:for-each>
		
		<xsl:for-each select="MODULE[(@MODCLASS='MEMORY_CONTROLLER') and (@ORIENTED = 'WEST')]">	
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			
			 <use  x="0"  
				   y="{$periMOD_H}"  
				   xlink:href="#symbol_{$modInst_}"/> 
		</xsl:for-each>
		
		<xsl:for-each select="MODULE[(@MODCLASS='MEMORY_CONTROLLER') and (@ORIENTED = 'EAST')]">	
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			
			 <use  x="{$periMOD_W}"  
				   y="{$periMOD_H}"  
				   xlink:href="#symbol_{$modInst_}"/> 
		</xsl:for-each>
		
		<xsl:for-each select="MODULE[(@MODCLASS='MEMORY_CONTROLLER') and (@ORIENTED = 'CENTER')]">	
			<xsl:variable name="modInst_" select="@INSTANCE"/>
			
			 <use  x="{ceiling($memW_ div 2) - ($periMOD_W div 2)}"  
				   y="{$periMOD_H}"  
				   xlink:href="#symbol_{$modInst_}"/> 
		</xsl:for-each>
		
	</symbol>			  
	
</xsl:template>	

<xsl:template name="Define_Processor">
	<xsl:param name="procInst"  select="@INSTANCE"/>
	<xsl:param name="modType"   select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$procInst]/@MODTYPE"/>
	<xsl:param name="procType"  select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$procInst]/@PROCTYPE"/>
	
	<xsl:variable name="label_y_">
		<xsl:value-of select="$MOD_LANE_H"/>	
	</xsl:variable>
	
<!--	
	<xsl:message>The proctype is <xsl:value-of select="$procType"/></xsl:message>	
-->
	
	<xsl:variable name="procH_" select="(($MOD_LANE_H * 2) + (($BIF_H + $BIF_GAP) * @BIFS_H) + ($MOD_LABEL_H + $BIF_GAP))"/>	
	<xsl:variable name="procW_" select="(($MOD_LANE_W * 2) + (($BIF_W             * @BIFS_W) + $BIF_GAP))"/>	
	
	<xsl:variable name="procColor">
		<xsl:choose>
			<xsl:when test="$procType = 'MICROBLAZE'"><xsl:value-of select="$COL_PROC_BG_MB"/></xsl:when>
			<xsl:when test="$procType = 'POWERPC'"><xsl:value-of select="$COL_PROC_BG_PP"/></xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$COL_PROC_BG_USR"/>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
<!--	
	<xsl:message>The proc color is <xsl:value-of select="$procColor"/></xsl:message>	
-->	
	
    <symbol id="symbol_{$procInst}">

		<rect x="0"
		      y="0"
			  rx="6" 
			  ry="6" 
		      width = "{$procW_}"
		      height= "{$procH_}"
			  style="fill:{$procColor}; stroke:{$COL_WHITE}; stroke-width:2"/>		
			  
			  
		<rect x="{ceiling($procW_ div 2) - ceiling($MOD_LABEL_W div 2)}"
		      y="{$MOD_LANE_H}"
			  rx="3" 
			  ry="3" 
		      width= "{$MOD_LABEL_W}"
		      height="{$MOD_LABEL_H}"
			  style="fill:{$COL_WHITE}; stroke:none;"/>		
			  
<!--			  
		<rect x="{ceiling($procW_ div 2) - ceiling($MOD_LABEL_W div 2)}"
		      y="{$MOD_LANE_H}"
			  rx="3" 
			  ry="3" 
		      width= "{$MOD_LABEL_W}"
		      height="{$BIF_H}"
			  style="fill:{$COL_IORING_LT}; stroke:none;"/>		
-->			  
			  
<!--			  
			  y="{$MOD_LANE_H + ceiling($MOD_LABEL_H div 2) - 4}"
			  y="{$MOD_LANE_H + ceiling($MOD_LABEL_H div 2) + 4}"
-->			  
		<text class="bciptype" 
			  x="{ceiling($procW_ div 2)}"
			  y="{$MOD_LANE_H + 8}">
				<xsl:value-of select="$modType"/>
		</text>
				
		<text class="bciplabel" 
			  x="{ceiling($procW_ div 2)}"
			  y="{$MOD_LANE_H + 16}">
				<xsl:value-of select="$procInst"/>
	   </text>
	   
	   
	  	<xsl:if test="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$procInst]/@GPORT_GROUP">
	  	
		<rect x="{ceiling($periMOD_W div 2) - ceiling($MOD_LABEL_W div 2)}"
		      y="{$MOD_LANE_H + $BIF_H + ceiling($BIF_H div 3) - 2}"
			  rx="3" 
			  ry="3" 
		      width= "{$MOD_LABEL_W}"
		      height="{$BIF_H}"
			  style="fill:{$COL_IORING_LT}; stroke:none;"/>		
			  
	
	   	   <text class="ioplblgrp" 
			  x="{ceiling($periMOD_W div 2)}"
		      y="{$MOD_LANE_H + $BIF_H + ceiling($BIF_H div 3) + 12}">
			   <xsl:value-of select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$procInst]/@GPORT_GROUP"/>
	   		</text>
	   
	  	</xsl:if> 
	   
	   
		<xsl:for-each select="/EDKPROJECT/MHSINFO/MODULES/MODULE[@INSTANCE=$procInst]/BUSINTERFACE[(@BIF_X and @BIF_Y)]">
<!--			
			<xsl:variable name="bif_dom_"   select="@BUSDOMAIN"/>
			<xsl:variable name="bif_name_"  select="@BIFNAME"/>
-->			
			
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
			
			<xsl:variable name="bif_x_"  select="(($BIF_W * @BIF_X) + ($BIF_GAP * @BIF_X) + ($MOD_LANE_W * 1))"/>
			<xsl:variable name="bif_y_"  select="((($BIF_H + $BIF_GAP) * @BIF_Y) + ($MOD_LANE_H + $MOD_LABEL_H + $BIF_GAP))"/>
			
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
			
			<xsl:call-template name="_draw_InterruptedProc">
				<xsl:with-param name="intr_col" select="$intr_col_"/>
				<xsl:with-param name="intr_x"   select="($periMOD_W - ceiling($INTR_W div 2))"/>
				<xsl:with-param name="intr_y"   select="3"/>
				<xsl:with-param name="intr_idx" select="@INTCINDEX"/>
			</xsl:call-template>	
		</xsl:if>
		
		
		
		
		
	</symbol>			  
</xsl:template>
<!-- ======================= END DEF BLOCK ============================ -->

<!-- ======================= UTILITY FUNCTIONS ============================ -->
<xsl:template name="_calc_Proc_Height">
	<xsl:param name="procInst"  select="_processor_"/>
	
	<xsl:variable name="tot_bifs_h_">
		<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[(@INSTANCE = $procInst)]/@BIFS_H)">0</xsl:if>
		
		<xsl:if test="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[(@INSTANCE = $procInst)]/@BIFS_H">
			<xsl:variable name="bifs_h_" select="(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[(@INSTANCE = $procInst)]/@BIFS_H)"/>
			<xsl:value-of select="(($BIF_H + $BIF_GAP) * $bifs_h_)"/>	
		</xsl:if>
	</xsl:variable>	
	
	<xsl:value-of select="(($MOD_LANE_H * 2) + $tot_bifs_h_ + ($MOD_LABEL_H + $BIF_GAP))"/>	
</xsl:template>

<xsl:template name="_calc_Proc_Max_Height">

	<!-- Store the heights in a variable -->	
	<xsl:variable name="proc_heights_">
	
		<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE)">
			<PROC HEIGHT="0"/>
		</xsl:if>
		
		<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE">
			<xsl:variable name="procInst_" select="@INSTANCE"/> 
			<xsl:variable name="proc_height_">
				<xsl:call-template name="_calc_Proc_Height">	
					<xsl:with-param name="procInst" select="$procInst_"/>
				</xsl:call-template>	
			</xsl:variable>
			
<!--			
			<xsl:message>Found Proc height as <xsl:value-of select="$proc_height_"/></xsl:message>
-->			
			<PROC HEIGHT="{$proc_height_}"/>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- Return the max of them -->	
<!--	
	<xsl:message>Found Proc Max as <xsl:value-of select="math:max(exsl:node-set($proc_heights_)/PROC/@HEIGHT)"/></xsl:message>
-->	

	<xsl:value-of select="math:max(exsl:node-set($proc_heights_)/PROC/@HEIGHT)"/>
</xsl:template>


<xsl:template name="_calc_Proc_MemoryUnits_Height">
	<xsl:param name="procInst"  select="_processor_"/>
	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and (@MODCLASS = 'MEMORY_UNIT'))])">0</xsl:if>
	
	<xsl:if test="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and (@MODCLASS='MEMORY_UNIT'))]">
	
		<!-- Store the all memory unit heights in a variable -->
		<xsl:variable name="memU_heights_">
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and (@MODCLASS='MEMORY_UNIT'))]">
		
				<xsl:variable name="unitId_" select="@PSTACK_MODS_Y"/>
			
				<xsl:variable name="unitHeight_">
					<xsl:call-template name="_calc_ProcMemoryUnit_Height">	
						<xsl:with-param name="unitId" select="$unitId_"/>
					</xsl:call-template>	
				</xsl:variable>
				<MEM_UNIT HEIGHT="{$unitHeight_}"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="sum(exsl:node-set($memU_heights_)/MEM_UNIT/@HEIGHT)"/>
	</xsl:if>
	
</xsl:template>

<xsl:template name="_calc_Proc_Peripherals_Height">
	<xsl:param name="procInst"  select="_processor_"/>
	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and not(@MODCLASS = 'MEMORY_UNIT'))])">0</xsl:if>
	
	<xsl:if test="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and not(@MODCLASS='MEMORY_UNIT'))]">
	
		<xsl:variable name="peri_gap_">
			<xsl:if test="@CSTACK_INDEX">
				<xsl:value-of select="$BIF_H"/>
			</xsl:if>
			<xsl:if test="not(@IS_CSTACK)">0</xsl:if>
		</xsl:variable>
	
		<!-- Store the all peripheral heights in a variable -->
		<xsl:variable name="peri_heights_">
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and not(@MODCLASS='MEMORY_UNIT'))]/MODULE">
		
				<xsl:variable name="peri_height_">
					<xsl:call-template name="_calc_PeriShape_Height">	
						<xsl:with-param name="shapeInst" select="@INSTANCE"/>
					</xsl:call-template>	
				</xsl:variable>
				<PERI HEIGHT="{$peri_height_ + $peri_gap_}"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="sum(exsl:node-set($peri_heights_)/PERI/@HEIGHT)"/>
	</xsl:if>
</xsl:template>


<xsl:template name="_calc_Proc_PerisAbvSbs_Height">
	<xsl:param name="procInst"  select="_processor_"/>
	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and not(@MODCLASS = 'MEMORY_UNIT') and not(@HAS_SBSBIF))])">0</xsl:if>
	
	<xsl:if test="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and not(@MODCLASS='MEMORY_UNIT') and not(@HAS_SBSBIF))]">
	
		<!-- Store the all peripheral heights in a variable -->
		<xsl:variable name="peri_heights_">
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and not(@MODCLASS='MEMORY_UNIT') and not(@HAS_SBSBIF))]">
		
				<xsl:variable name="peri_height_">
					<xsl:call-template name="_calc_PeriShape_Height">	
						<xsl:with-param name="shapeInst" select="MODULE/@INSTANCE"/>
					</xsl:call-template>	
				</xsl:variable>
				<PERI HEIGHT="{$peri_height_}"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="sum(exsl:node-set($peri_heights_)/PERI/@HEIGHT)"/>
	</xsl:if>
	
</xsl:template>

<xsl:template name="_calc_Proc_ShapesBlwSbs_Height">
	<xsl:param name="procInst"  select="_processor_"/>
	
	<xsl:variable name="numPeris_" select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and not(@MODCLASS = 'MEMORY_UNIT'))])"/>
	<xsl:variable name="numAbSbs_" select="count(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and not(@MODCLASS = 'MEMORY_UNIT') and not(@HAS_SBSBIF))])"/>
	
	<xsl:variable name="gapMul_">
		<xsl:choose>
			<xsl:when test="$numPeris_ &gt; $numAbSbs_"><xsl:value-of select="($numPeris_ - $numAbSbs_)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="($numAbSbs_ - $numPeris_)"/></xsl:otherwise>
		</xsl:choose>	
	</xsl:variable>
	
	<xsl:variable name="h_peris_gap_" select="($gapMul_ * $BIF_H)"/>
	
	<xsl:variable name="h_peris_">
		<xsl:call-template name="_calc_Proc_Peripherals_Height">	
			<xsl:with-param name="procInst" select="$procInst"/>
		</xsl:call-template>	
	</xsl:variable>
	
	<xsl:variable name="h_perisAbvSbs_">
		<xsl:call-template name="_calc_Proc_PerisAbvSbs_Height">	
			<xsl:with-param name="procInst" select="$procInst"/>
		</xsl:call-template>	
	</xsl:variable>
	
<!--	
	<xsl:variable name="h_memUnits_">
		<xsl:call-template name="_calc_Proc_MemoryUnits_Height">	
			<xsl:with-param name="procInst" select="$procInst"/>
		</xsl:call-template>	
	</xsl:variable>
-->	
	
	<xsl:variable name="h_sbsBuckets_">
		<xsl:call-template name="_calc_Proc_SbsBuckets_Height">	
			<xsl:with-param name="procInst" select="$procInst"/>
		</xsl:call-template>	
	</xsl:variable>
	
	
<!--	
	<xsl:message>Peris Gap <xsl:value-of select="$h_peris_gap_"/></xsl:message>
	<xsl:message>Num Peris <xsl:value-of select="$numPeris_"/></xsl:message>
	<xsl:message>Num Abv Peris <xsl:value-of select="$numAbSbs_"/></xsl:message>
	<xsl:message>Peripherals height <xsl:value-of select="$h_peris_"/></xsl:message>
	<xsl:message>Peripherals above sbs height <xsl:value-of select="$h_perisAbvSbs_"/></xsl:message>
	<xsl:message>Below height <xsl:value-of select="(($h_peris_ - $h_perisAbvSbs_) + $h_sbsBuckets_)"/></xsl:message>
	<xsl:message>==========================</xsl:message>	
	<xsl:message>Processor : <xsl:value-of select="$procInst"/></xsl:message>
	<xsl:message>Peripherals above sbs height <xsl:value-of select="$h_perisAbvSbs_"/></xsl:message>
	<xsl:message>Memory Units height <xsl:value-of select="$h_memUnits_"/></xsl:message>
	<xsl:message>Shared Buckets height <xsl:value-of select="$h_sbsBuckets_"/></xsl:message>
	<xsl:message>==========================</xsl:message>	
-->

	<xsl:value-of select="(($h_peris_ - $h_perisAbvSbs_) + $h_peris_gap_ + $h_sbsBuckets_)"/>
</xsl:template>


<xsl:template name="_calc_Proc_SbsBuckets_Height">
	<xsl:param name="procInst"  select="_processor_"/>
	
	<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@PROCESSOR = $procInst)])">0</xsl:if>
	
	<xsl:if test="/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@PROCESSOR = $procInst)]">
	
		<!-- Store the all buckets heights in a variable -->
		<xsl:variable name="bkt_heights_">
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[(@PROCESSOR = $procInst)]">
		
				<xsl:variable name="bkt_height_">
					<xsl:call-template name="_calc_SbsBucket_Height">	
						<xsl:with-param name="bucketId" select="@PSTACK_MODS_Y"/>
					</xsl:call-template>	
				</xsl:variable>
<!--				
				<xsl:message>Found shared buckets height as <xsl:value-of select="$bkt_height_"/></xsl:message>
-->				
				<BKT HEIGHT="{$bkt_height_}"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="sum(exsl:node-set($bkt_heights_)/BKT/@HEIGHT)"/>
	</xsl:if>
</xsl:template>


<xsl:template name="_calc_Proc_MaxBlwSbs_Height">

	<!-- Store the heights in a variable -->	
	<xsl:variable name="blwSbs_heights_">
		<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE)">
			<BLW HEIGHT="0"/>
		</xsl:if>
		<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE">
			<xsl:variable name="procInst_" select="@INSTANCE"/> 
			<xsl:variable name="blwSbs_">
				<xsl:call-template name="_calc_Proc_ShapesBlwSbs_Height">	
					<xsl:with-param name="procInst" select="$procInst_"/>
				</xsl:call-template>	
			</xsl:variable>
<!--			
			<xsl:message>Found Blw Sbs height as <xsl:value-of select="$blwSbs_"/></xsl:message>
-->			
			<BLW HEIGHT="{$blwSbs_}"/>
		</xsl:for-each>
	</xsl:variable>
	
<!--	
	<xsl:message>Found Blw Sbs max as <xsl:value-of select="math:max(exsl:node-set($blwSbs_heights_)/BLW/@HEIGHT)"/></xsl:message>
-->	
	<!-- Return the max of them -->	
	<xsl:value-of select="math:max(exsl:node-set($blwSbs_heights_)/BLW/@HEIGHT)"/>
</xsl:template>

<xsl:template name="_calc_Proc_MaxAbvSbs_Height">
	<xsl:param name="procInst"  select="_processor_"/>
	
	<!-- Store the heights in a variable -->	
	<xsl:variable name="abvSbs_heights_">
		<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE)">
			<ABV HEIGHT="0"/>
		</xsl:if>
		<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE">
			<xsl:variable name="procInst_" select="@INSTANCE"/> 
<!--			
			<xsl:message>Found Blw Sbs height as <xsl:value-of select="$blwSbs_"/></xsl:message>
			<ABV HEIGHT="{$pAbvSbs_}"/>
-->			
			
			<xsl:variable name="pAbvSbs_">
				<xsl:call-template name="_calc_Proc_PerisAbvSbs_Height">	
					<xsl:with-param name="procInst" select="$procInst_"/>
				</xsl:call-template>	
			</xsl:variable>
			
			<xsl:variable name="memUs_">
				<xsl:call-template name="_calc_Proc_MemoryUnits_Height">	
					<xsl:with-param name="procInst" select="$procInst_"/>
				</xsl:call-template>	
			</xsl:variable>
			
<!--			
			<xsl:message>Found Peris Above height as <xsl:value-of select="$pAbvSbs_"/></xsl:message>
			<xsl:message>Found MemUs Above height as <xsl:value-of select="$memUs_"/></xsl:message>
-->			
			<ABV HEIGHT="{$pAbvSbs_ + $memUs_}"/>
		</xsl:for-each>
		
	</xsl:variable>
<!--	
	<xsl:message>Found Abv Sbs max as <xsl:value-of select="math:max(exsl:node-set($abvSbs_heights_)/ABV/@HEIGHT)"/></xsl:message>
-->	

	<!-- Return the max of them -->	
	<xsl:value-of select="math:max(exsl:node-set($abvSbs_heights_)/ABV/@HEIGHT)"/>
</xsl:template>

<xsl:template name="_calc_MultiProcStack_Height">
	<xsl:param name="mpstack_blkd_x"  select="100"/>
	
		<xsl:variable name="mpStk_ShpHeights_">
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@HAS_MULTIPROCCONNS) and (@PSTACK_BLKD_X = $mpstack_blkd_x))])">
				<MPSHAPE HEIGHT="0"/>
			</xsl:if>
			
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@HAS_MULTIPROCCONNS) and (@PSTACK_BLKD_X = $mpstack_blkd_x))]">
				<xsl:variable name="shpClass_" select="@MODCLASS"/> 
				<xsl:variable name="shpHeight_">
					<xsl:choose>
						<xsl:when test="$shpClass_ = 'PERIPHERAL'">
							<xsl:call-template name="_calc_PeriShape_Height">	
								<xsl:with-param name="shapeInst" select="MODULE/@INSTANCE"/>
							</xsl:call-template>	
						</xsl:when>
						<xsl:when test="$shpClass_ = 'MEMORY_UNIT'">
							<xsl:variable name="memu_y" select="@MPSTACK_MEMUS_Y"/>
							<xsl:variable name="mods_y" select="@MPSTACK_MODS_Y"/>
							<xsl:call-template name="_calc_MProcMemoryUnit_Height">	
								<xsl:with-param name="blkd_x" select="$mpstack_blkd_x"/>
								<xsl:with-param name="memu_y" select="$memu_y"/>
								<xsl:with-param name="mods_y" select="$mods_y"/>
							</xsl:call-template>	
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
<!--				
				<xsl:message>Found <xsl:value-of select="$shpHeight_"/></xsl:message>
-->				
				
				<MPSHAPE HEIGHT="{$shpHeight_}"/>
			</xsl:for-each>
	</xsl:variable>
	
<!--	
	<xsl:message>Found stack of height <xsl:value-of select="sum(exsl:node-set($mpStk_ShpHeights_)/MPSHAPE/@HEIGHT)"/></xsl:message>
-->	
	
	<xsl:value-of select="sum(exsl:node-set($mpStk_ShpHeights_)/MPSHAPE/@HEIGHT)"/>
</xsl:template>

<xsl:template name="_calc_MaxMultiProcStack_Height">
	
	<!-- Store the heights in a variable -->	
	
	<xsl:variable name="mpStks_Heights_">
		<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE)">
			<MPSTK HEIGHT="0"/>
		</xsl:if>
		<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/PROCSHAPES/MODULE[(@PSTACK_BLKD_X)]">
			<xsl:variable name="mpstack_height_">
				<xsl:call-template name="_calc_MultiProcStack_Height">
					<xsl:with-param name="mpstack_blkd_x" select="(@PSTACK_BLKD_X + 1)"/>
				</xsl:call-template>
			</xsl:variable>
			
<!--			
			<xsl:message>Found <xsl:value-of select="$mpstack_height_"/></xsl:message>
-->			
			<MPSTK HEIGHT="{$mpstack_height_}"/>
		</xsl:for-each>
		
	</xsl:variable>

		<!-- Return the max of them -->	
	<xsl:value-of select="math:max(exsl:node-set($mpStks_Heights_)/MPSTK/@HEIGHT)"/>
	
</xsl:template>


<xsl:template name="_calc_Proc_Shape_Y">
	<xsl:param name="procInst" select="'_processor_'"/>
	<xsl:param name="shapeIdx" select="0"/>
	<xsl:param name="sbsGap"   select="0"/>
	
	<xsl:if test="(not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and (@PSTACK_MODS_Y = $shapeIdx))]) and  not(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[((@PROCESSOR = $procInst) and (@PSTACK_MODS_Y = $shapeIdx))]))">0</xsl:if>
	
	<xsl:if test="((/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and (@PSTACK_MODS_Y = $shapeIdx))]) or (/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[((@PROCESSOR = $procInst) and (@PSTACK_MODS_Y = $shapeIdx))]))">
	
		<!-- Store the spaces above this one in a variable -->
		<xsl:variable name="spaces_above_">
		
			<xsl:if test="not(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and (@PSTACK_MODS_Y &lt; $shapeIdx))])">
				<SPACE HEIGHT="0"/>
			</xsl:if>
			
			<!-- Store the height of all peripherals and memory units above this one-->
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst)  and (@PSTACK_MODS_Y &lt; $shapeIdx))]">
					
				<xsl:if test="not(@MODCLASS='MEMORY_UNIT')">	
					<xsl:variable name="peri_height_">
						<xsl:if test="not(@CSTACK_INDEX)">
							<xsl:call-template name="_calc_PeriShape_Height">	
								<xsl:with-param name="shapeInst" select="MODULE/@INSTANCE"/>
							</xsl:call-template>	
						</xsl:if>	
						<xsl:if test="(@CSTACK_INDEX)">
<!--						
							<xsl:message>Found height <xsl:value-of select="@MODS_H"/></xsl:message>
							<xsl:message>Found height <xsl:value-of select="@CSTACK_INDEX"/></xsl:message>
-->							
							<xsl:call-template name="_calc_CStackShapesAbv_Height">
								<xsl:with-param name="cstackModY"  select="@MODS_H"/>
								<xsl:with-param name="cstackIndex" select="@CSTACK_INDEX"/>
							</xsl:call-template>	
						</xsl:if>	
					</xsl:variable>
					
<!--					
					<xsl:message>Found height <xsl:value-of select="$peri_height_"/></xsl:message>
-->					
					<SPACE HEIGHT="{$peri_height_ + $BIF_H}"/>
				</xsl:if>
				
				<xsl:if test="(@MODCLASS='MEMORY_UNIT')">	
					<xsl:variable name="unitId_" select="@PSTACK_MODS_Y"/>
					<xsl:variable name="unit_height_">
						<xsl:call-template name="_calc_ProcMemoryUnit_Height">	
							<xsl:with-param name="unitId" select="$unitId_"/>
						</xsl:call-template>	
					</xsl:variable>
					<SPACE HEIGHT="{$unit_height_ + $BIF_H}"/>
				</xsl:if>
				
			</xsl:for-each>
			
			<!-- If its a peripheral that is below the shared busses, or its a shared bus bucket -->
			<!-- add the height of the shared busses and the processor.                           -->
			<xsl:if  test="(/EDKPROJECT/BLKDSHAPES/CMPLXSHAPES/CMPLXSHAPE[((@PROCESSOR = $procInst) and (@PSTACK_MODS_Y = $shapeIdx))]/@HAS_SBSBIF)">
				<SPACE HEIGHT="{$sbsGap}"/>
			</xsl:if>
			<xsl:if test="(/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[((@PROCESSOR = $procInst) and (@PSTACK_MODS_Y = $shapeIdx))])">
				<SPACE HEIGHT="{$sbsGap}"/>
			</xsl:if>
			
			<!-- Store the height of all shared bus buckets above this one-->
			<xsl:for-each select="/EDKPROJECT/BLKDSHAPES/SBSBUCKETS/SBSBUCKET[((@PROCESSOR = $procInst)  and (@PSTACK_MODS_Y &lt; $shapeIdx))]">
				<xsl:variable name="bkt_height_">
					<xsl:call-template name="_calc_SbsBucket_Height">
						<xsl:with-param name="bucketId" select="@PSTACK_MODS_Y"/>
					</xsl:call-template>	
				</xsl:variable>
				
				<SPACE HEIGHT="{$bkt_height_ + $BIF_H}"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="sum(exsl:node-set($spaces_above_)/SPACE/@HEIGHT)"/>
	</xsl:if>
	
</xsl:template>
			
<!-- ======================= END UTILITY FUNCTIONS  ======================= -->

</xsl:stylesheet>

