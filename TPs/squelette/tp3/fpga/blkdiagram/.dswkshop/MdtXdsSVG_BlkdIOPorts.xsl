<?xml version="1.0" standalone="no"?>
<xsl:stylesheet version="1.0"
           xmlns:svg="http://www.w3.org/2000/svg"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:exsl="http://exslt.org/common"
           xmlns:xlink="http://www.w3.org/1999/xlink">
                
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
	       doctype-public="-//W3C//DTD SVG 1.0//EN"
		   doctype-system="http://www.w3.org/TR/SVG/DTD/svg10.dtd"/>
			
<xsl:param name="IOP_H"   select="16"/>				
<xsl:param name="IOP_W"   select="16"/>				
<xsl:param name="IOP_SPC" select="12"/>				

<xsl:param name="MOD_IO_GAP"   select="8"/>				

<!-- ======================= DEF BLOCK =============================== -->
<xsl:template name="Define_IOPorts">

	 <symbol id="G_IOPort">
		<rect  
			x="0"  
			y="0" 
			width= "{$IOP_W}" 
			height="{$IOP_H}" style="fill:{$COL_IORING_LT}; stroke:{$COL_IORING}; stroke-width:1"/> 
			
		<path class="ioport"
			  d="M   0,0
				 L   {$IOP_W},{ceiling($IOP_H div 2)}
				 L   0,{$IOP_H}
				 Z" style="stroke:none; fill:{$COL_SYSPRT}"/>	
	</symbol>

	 <symbol id="G_BIPort">
		<rect  
			x="0"  
			y="0" 
			width= "{$IOP_W}" 
			height="{$IOP_H}" style="fill:{$COL_IORING_LT}; stroke:{$COL_IORING}; stroke-width:1"/> 
			
		<path class="btop"
			  d="M 0,{ceiling($IOP_H div 2)}
				 {ceiling($IOP_W div 2)},0
				 {$IOP_W},{ceiling($IOP_H div 2)}
				 Z" style="stroke:none; fill:{$COL_SYSPRT}"/>	
				 
		<path class="bbot"
			  d="M 0,{ceiling($IOP_H div 2)}
				 {ceiling($IOP_W div 2)},{$IOP_H}
				 {$IOP_W},{ceiling($IOP_H div 2)}
				 Z" style="stroke:none; fill:{$COL_SYSPRT}"/>	
				 
	</symbol>

	 <symbol id="KEY_IOPort">
		<rect  
			x="0"  
			y="0" 
			width= "{$IOP_W}" 
			height="{$IOP_H}" style="fill:{$COL_KEY_LT}; stroke:none;"/> 
			
		<path class="ioport"
			  d="M   0,0
				 L   {$IOP_W},{ceiling($IOP_H div 2)}
				 L   0,{$IOP_H}
				 Z" style="stroke:none; fill:{$COL_KEY}"/>	
	</symbol>
	
	 <symbol id="KEY_BIPort">
		<rect  
			x="0"  
			y="0" 
			width= "{$IOP_W}" 
			height="{$IOP_H}" style="fill:{$COL_KEY_LT}; stroke:none;"/> 
			
		<path class="btop"
			  d="M 0,{ceiling($IOP_H div 2)}
				 {ceiling($IOP_W div 2)},0
				 {$IOP_W},{ceiling($IOP_H div 2)}
				 Z" style="stroke:none; fill:{$COL_KEY}"/>	
				 
		<path class="bbot"
			  d="M 0,{ceiling($IOP_H div 2)}
				 {ceiling($IOP_W div 2)},{$IOP_H}
				 {$IOP_W},{ceiling($IOP_H div 2)}
				 Z" style="stroke:none; fill:{$COL_KEY}"/>	
	</symbol>
	
	 <symbol id="KEY_INPort">
		<use   x="0"   y="0"   xlink:href="#KEY_IOPort"/>
		<rect  
			x="{$IOP_W}"  
			y="0" 
			width= "{ceiling($IOP_W div 2)}" 
			height="{$IOP_H}" style="fill:{$COL_SYSPRT}; stroke:none;"/> 
	</symbol>
	
	 <symbol id="KEY_OUTPort">
		<use   x="0"   y="0"   xlink:href="#KEY_IOPort" transform="scale(-1,1) translate({$IOP_W * -1},0)"/>
		<rect  
			x="{$IOP_W}"  
			y="0" 
			width= "{ceiling($IOP_W div 2)}" 
			height="{$IOP_H}" style="fill:{$COL_SYSPRT}; stroke:none;"/> 
	</symbol>

	 <symbol id="KEY_INOUTPort">
		<use   x="0"   y="0"   xlink:href="#KEY_BIPort"/>
		<rect  
			x="{$IOP_W}"  
			y="0" 
			width= "{ceiling($IOP_W div 2)}" 
			height="{$IOP_H}" style="fill:{$COL_SYSPRT}; stroke:none;"/> 
	</symbol>


</xsl:template>

<!-- ======================= DRAW BLOCK =============================== -->

<xsl:template name="Draw_IOPorts"> 
	<xsl:param name="drawarea_w" select="500"/>
	<xsl:param name="drawarea_h" select="500"/>
	
	
	<xsl:variable name="ports_count_"    select="count(MHSINFO/GLOBALPORTS/GPORT)"/>
	
	<xsl:if test="($ports_count_ &gt; 30)">
		<xsl:call-template name="Draw_IOPorts_4Sides"> 
			<xsl:with-param name="drawarea_w" select="$drawarea_w"/>
			<xsl:with-param name="drawarea_h" select="$drawarea_h"/>
		</xsl:call-template>	
	</xsl:if>
	
	<xsl:if test="($ports_count_ &lt;= 30)">
		<xsl:call-template name="Draw_IOPorts_2Sides"> 
			<xsl:with-param name="drawarea_w" select="$drawarea_w"/>
			<xsl:with-param name="drawarea_h" select="$drawarea_h"/>
		</xsl:call-template>	
	</xsl:if>
</xsl:template>


<xsl:template name="Draw_IOPorts_2Sides"> 
	
	<xsl:param name="drawarea_h"  select="500"/>
	<xsl:param name="drawarea_w"  select="500"/>
	
	<xsl:variable name="ports_count_"    select="count(MHSINFO/GLOBALPORTS/GPORT)"/>
	<xsl:variable name="ports_per_side_" select="ceiling($ports_count_ div 2)"/>
	
	<xsl:variable name="h_ofs_">
		<xsl:value-of select="$BLKD_PRTCHAN_W + ceiling(($drawarea_w  - (($ports_per_side_ * $IOP_W) + (($ports_per_side_ - 1) * $IOP_SPC))) div 2)"/>
	</xsl:variable>
	
	<xsl:variable name="v_ofs_">
		<xsl:value-of select="$BLKD_PRTCHAN_H + ceiling(($drawarea_h  - (($ports_per_side_ * $IOP_H) + (($ports_per_side_ - 1) * $IOP_SPC))) div 2)"/>
	</xsl:variable>
	

	<xsl:for-each select="MHSINFO/GLOBALPORTS/GPORT">
		<xsl:sort data-type="number" select="@PRTNUMBER" order="ascending"/>
		
		<xsl:variable name="poffset_" select="0"/>
		<xsl:variable name="pcount_"  select="$poffset_ + (position() -1)"/>
		
		<xsl:variable name="pdir_">
			<xsl:choose>
				<xsl:when test="(@DIR='I'  or @DIR='IN'  or @DIR='INPUT')">I</xsl:when>
				<xsl:when test="(@DIR='O'  or @DIR='OUT' or @DIR='OUTPUT')">O</xsl:when>
				<xsl:when test="(@DIR='IO' or @DIR='INOUT')">B</xsl:when>
				<xsl:otherwise>I</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="pside_">
			<xsl:choose>
				<xsl:when test="($pcount_ &gt;= ($ports_per_side_ * 0) and ($pcount_ &lt; ($ports_per_side_ * 1)))">W</xsl:when>
				<xsl:when test="($pcount_ &gt;= ($ports_per_side_ * 1) and ($pcount_ &lt; ($ports_per_side_ * 2)))">E</xsl:when>
				<xsl:otherwise>D</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="pdec_">
			<xsl:choose>
				<xsl:when test="($pside_ = 'W')"><xsl:value-of select="($ports_per_side_ * 0)"/></xsl:when>
				<xsl:when test="($pside_ = 'E')"><xsl:value-of select="($ports_per_side_ * 1)"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="px_">
			<xsl:choose>
				<xsl:when test="($pside_ = 'W')"><xsl:value-of select="($BLKD_PRTCHAN_W - $IOP_W)"/></xsl:when>
				<xsl:when test="($pside_ = 'S')"><xsl:value-of select="($h_ofs_ + (((position() - 1) - $pdec_) * ($IOP_SPC + $IOP_W)) - 2)"/></xsl:when>
				<xsl:when test="($pside_ = 'E')"><xsl:value-of select="($BLKD_PRTCHAN_W + ($BLKD_IORCHAN_W * 2) + $drawarea_w)"/></xsl:when>
				<xsl:when test="($pside_ = 'N')"><xsl:value-of select="($h_ofs_ + (((position() - 1) - $pdec_) * ($IOP_SPC + $IOP_W)))"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="py_">
			<xsl:choose>
				<xsl:when test="($pside_ = 'W')"><xsl:value-of select="($v_ofs_ + (((position() - 1) - $pdec_) * ($IOP_SPC + $IOP_H)))"/></xsl:when>
				<xsl:when test="($pside_ = 'S')"><xsl:value-of select="($BLKD_PRTCHAN_H + ($BLKD_IORCHAN_H * 2) + $drawarea_h)"/></xsl:when>
				<xsl:when test="($pside_ = 'E')"><xsl:value-of select="($v_ofs_ + (((position() - 1) - $pdec_) * ($IOP_SPC + $IOP_H)))"/></xsl:when>
				<xsl:when test="($pside_ = 'N')"><xsl:value-of select="($BLKD_PRTCHAN_H - $IOP_H)"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
	
		<xsl:variable name="prot_">
			<xsl:choose>
				<xsl:when test="(($pside_ = 'W') and ($pdir_ = 'I'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'S') and ($pdir_ = 'I'))">-90</xsl:when>
				<xsl:when test="(($pside_ = 'E') and ($pdir_ = 'I'))">180</xsl:when>
				<xsl:when test="(($pside_ = 'N') and ($pdir_ = 'I'))">90</xsl:when>
				
				<xsl:when test="(($pside_ = 'W') and ($pdir_ = 'O'))">180</xsl:when>
				<xsl:when test="(($pside_ = 'S') and ($pdir_ = 'O'))">90</xsl:when>
				<xsl:when test="(($pside_ = 'E') and ($pdir_ = 'O'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'N') and ($pdir_ = 'O'))">-90</xsl:when>
				
				<xsl:when test="(($pside_ = 'W') and ($pdir_ = 'B'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'S') and ($pdir_ = 'B'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'E') and ($pdir_ = 'B'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'N') and ($pdir_ = 'B'))">0</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		
		<xsl:variable name="txo_">
			<xsl:choose>
				<xsl:when test="($pside_  = 'W')">-10</xsl:when>
				<xsl:when test="($pside_  = 'S')">6</xsl:when>
				 <xsl:when test="($pside_ = 'E')"><xsl:value-of select="(($IOP_W * 2) - 4)"/></xsl:when>
				<xsl:when test="($pside_  = 'N')">6</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="tyo_">
			<xsl:choose>
				<xsl:when test="($pside_ = 'W')"><xsl:value-of select="ceiling($IOP_H div 2) + 6"/></xsl:when>
				<xsl:when test="($pside_ = 'S')"><xsl:value-of select="($IOP_H * 2) + 4"/></xsl:when>
				<xsl:when test="($pside_ = 'E')"><xsl:value-of select="ceiling($IOP_H div 2) + 6"/></xsl:when>
				<xsl:when test="($pside_ = 'N')">-2</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>

		<xsl:if test="$pdir_ = 'B'">	   
			<use   x="{$px_}"  
			       y="{$py_}"  
			       xlink:href="#G_BIPort" 
			       transform="rotate({$prot_},{$px_ + ceiling($IOP_W div 2)},{$py_ + ceiling($IOP_H div 2)})"/>
		</xsl:if>
		
		<xsl:if test="(($pside_ = 'S') and not($pdir_ = 'B'))">	   
			<rect  
				x="{$px_}"  
				y="{$py_}" 
				width= "{$IOP_W}" 
				height="{$IOP_H}" style="stroke:{$COL_IORING}; stroke-width:1"/> 
		</xsl:if>
		
		<xsl:if test="not($pdir_ = 'B')">	   
			<use   x="{$px_}"  
			       y="{$py_}"  
			       xlink:href="#G_IOPort" 
			       transform="rotate({$prot_},{$px_ + ceiling($IOP_W div 2)},{$py_ + ceiling($IOP_H div 2)})"/>
		</xsl:if>
		
		<text class="iopnumb"
	  		x="{$px_ + $txo_}" 
	  		y="{$py_ + $tyo_}">
			<xsl:value-of select="@PRTNUMBER"/><tspan class="iopgrp"><xsl:value-of select="@GPORT_GROUP"/></tspan>
		</text>

		
<!--
		<xsl:if test="not(@GPORT_GROUP = '0')">	
			<text class="iopnumb"
		  		x="{$px_ + $txo_}" 
		  		y="{$py_ + $tyo_}">
					<xsl:value-of select="@PRTNUMBER"/>
					<tspan class="iopgrp"><xsl:value-of select="@GPORT_GROUP"/></tspan>
			</text>
		</xsl:if>
		
		<xsl:if test="@GPORT_GROUP = '0'">	
			<text class="iopnumb"
		  		x="{$px_ + $txo_}" 
		  		y="{$py_ + $tyo_}">
					<xsl:value-of select="@PRTNUMBER"/>
					<tspan class="iopgrp">G</tspan>
			</text>
		</xsl:if>
-->
		
		
	</xsl:for-each>
	
</xsl:template>


<xsl:template name="Draw_IOPorts_4Sides"> 
	
	<xsl:param name="drawarea_h"  select="500"/>
	<xsl:param name="drawarea_w"  select="500"/>
	
	<xsl:variable name="ports_count_"    select="count(MHSINFO/GLOBALPORTS/GPORT)"/>
	<xsl:variable name="ports_per_side_" select="ceiling($ports_count_ div 4)"/>
	
	<xsl:variable name="h_ofs_">
		<xsl:value-of select="$BLKD_PRTCHAN_W + ceiling(($drawarea_w  - (($ports_per_side_ * $IOP_W) + (($ports_per_side_ - 1) * $IOP_SPC))) div 2)"/>
	</xsl:variable>
	
	<xsl:variable name="v_ofs_">
		<xsl:value-of select="$BLKD_PRTCHAN_H + ceiling(($drawarea_h  - (($ports_per_side_ * $IOP_H) + (($ports_per_side_ - 1) * $IOP_SPC))) div 2)"/>
	</xsl:variable>
	

	<xsl:for-each select="MHSINFO/GLOBALPORTS/GPORT">
		<xsl:sort data-type="number" select="@PRTNUMBER" order="ascending"/>
		
		<xsl:variable name="poffset_" select="0"/>
		<xsl:variable name="pcount_"  select="$poffset_ + (position() -1)"/>
		
		<xsl:variable name="pdir_">
			<xsl:choose>
				<xsl:when test="(@DIR='I'  or @DIR='IN'  or @DIR='INPUT')">I</xsl:when>
				<xsl:when test="(@DIR='O'  or @DIR='OUT' or @DIR='OUTPUT')">O</xsl:when>
				<xsl:when test="(@DIR='IO' or @DIR='INOUT')">B</xsl:when>
				<xsl:otherwise>I</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="pside_">
			<xsl:choose>
				<xsl:when test="($pcount_ &gt;= ($ports_per_side_ * 0) and ($pcount_ &lt; ($ports_per_side_ * 1)))">W</xsl:when>
				<xsl:when test="($pcount_ &gt;= ($ports_per_side_ * 1) and ($pcount_ &lt; ($ports_per_side_ * 2)))">S</xsl:when>
				<xsl:when test="($pcount_ &gt;= ($ports_per_side_ * 2) and ($pcount_ &lt; ($ports_per_side_ * 3)))">E</xsl:when>
				<xsl:when test="($pcount_ &gt;= ($ports_per_side_ * 3) and ($pcount_ &lt; ($ports_per_side_ * 4)))">N</xsl:when>
				<xsl:otherwise>D</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="pdec_">
			<xsl:choose>
				<xsl:when test="($pside_ = 'W')"><xsl:value-of select="($ports_per_side_ * 0)"/></xsl:when>
				<xsl:when test="($pside_ = 'S')"><xsl:value-of select="($ports_per_side_ * 1)"/></xsl:when>
				<xsl:when test="($pside_ = 'E')"><xsl:value-of select="($ports_per_side_ * 2)"/></xsl:when>
				<xsl:when test="($pside_ = 'N')"><xsl:value-of select="($ports_per_side_ * 3)"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="px_">
			<xsl:choose>
				<xsl:when test="($pside_ = 'W')"><xsl:value-of select="($BLKD_PRTCHAN_W - $IOP_W)"/></xsl:when>
				<xsl:when test="($pside_ = 'S')"><xsl:value-of select="($h_ofs_ + (((position() - 1) - $pdec_) * ($IOP_SPC + $IOP_W)) - 2)"/></xsl:when>
				<xsl:when test="($pside_ = 'E')"><xsl:value-of select="($BLKD_PRTCHAN_W + ($BLKD_IORCHAN_W * 2) + $drawarea_w)"/></xsl:when>
				<xsl:when test="($pside_ = 'N')"><xsl:value-of select="($h_ofs_ + (((position() - 1) - $pdec_) * ($IOP_SPC + $IOP_W)))"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="py_">
			<xsl:choose>
				<xsl:when test="($pside_ = 'W')"><xsl:value-of select="($v_ofs_ + (((position() - 1) - $pdec_) * ($IOP_SPC + $IOP_H)))"/></xsl:when>
				<xsl:when test="($pside_ = 'S')"><xsl:value-of select="($BLKD_PRTCHAN_H + ($BLKD_IORCHAN_H * 2) + $drawarea_h)"/></xsl:when>
				<xsl:when test="($pside_ = 'E')"><xsl:value-of select="($v_ofs_ + (((position() - 1) - $pdec_) * ($IOP_SPC + $IOP_H)))"/></xsl:when>
				<xsl:when test="($pside_ = 'N')"><xsl:value-of select="($BLKD_PRTCHAN_H - $IOP_H)"/></xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
	
		<xsl:variable name="prot_">
			<xsl:choose>
				<xsl:when test="(($pside_ = 'W') and ($pdir_ = 'I'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'S') and ($pdir_ = 'I'))">-90</xsl:when>
				<xsl:when test="(($pside_ = 'E') and ($pdir_ = 'I'))">180</xsl:when>
				<xsl:when test="(($pside_ = 'N') and ($pdir_ = 'I'))">90</xsl:when>
				
				<xsl:when test="(($pside_ = 'W') and ($pdir_ = 'O'))">180</xsl:when>
				<xsl:when test="(($pside_ = 'S') and ($pdir_ = 'O'))">90</xsl:when>
				<xsl:when test="(($pside_ = 'E') and ($pdir_ = 'O'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'N') and ($pdir_ = 'O'))">-90</xsl:when>
				
				<xsl:when test="(($pside_ = 'W') and ($pdir_ = 'B'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'S') and ($pdir_ = 'B'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'E') and ($pdir_ = 'B'))">0</xsl:when>
				<xsl:when test="(($pside_ = 'N') and ($pdir_ = 'B'))">0</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		
		<xsl:variable name="txo_">
			<xsl:choose>
				<xsl:when test="($pside_  = 'W')">-14</xsl:when>
				<xsl:when test="($pside_  = 'S')">8</xsl:when>
				 <xsl:when test="($pside_ = 'E')"><xsl:value-of select="(($IOP_W * 2) - 4)"/></xsl:when>
				<xsl:when test="($pside_  = 'N')">8</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="tyo_">
			<xsl:choose>
				<xsl:when test="($pside_ = 'W')"><xsl:value-of select="ceiling($IOP_H div 2) + 6"/></xsl:when>
				<xsl:when test="($pside_ = 'S')"><xsl:value-of select="($IOP_H * 2) + 4"/></xsl:when>
				<xsl:when test="($pside_ = 'E')"><xsl:value-of select="ceiling($IOP_H div 2) + 6"/></xsl:when>
				<xsl:when test="($pside_ = 'N')">-2</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>	
		</xsl:variable>

		<xsl:if test="$pdir_ = 'B'">	   
			<use   x="{$px_}"  
			       y="{$py_}"  
			       xlink:href="#G_BIPort" 
			       transform="rotate({$prot_},{$px_ + ceiling($IOP_W div 2)},{$py_ + ceiling($IOP_H div 2)})"/>
		</xsl:if>
		
		<xsl:if test="(($pside_ = 'S') and not($pdir_ = 'B'))">	   
			<rect  
				x="{$px_}"  
				y="{$py_}" 
				width= "{$IOP_W}" 
				height="{$IOP_H}" style="stroke:{$COL_IORING}; stroke-width:1"/> 
		</xsl:if>
		
		<xsl:if test="not($pdir_ = 'B')">	   
			<use   x="{$px_}"  
			       y="{$py_}"  
			       xlink:href="#G_IOPort" 
			       transform="rotate({$prot_},{$px_ + ceiling($IOP_W div 2)},{$py_ + ceiling($IOP_H div 2)})"/>
		</xsl:if>
		
		<text class="iopnumb"
	  		x="{$px_ + $txo_}" 
	  		y="{$py_ + $tyo_}"><xsl:value-of select="@PRTNUMBER"/><tspan class="iopgrp"><xsl:value-of select="@GPORT_GROUP"/></tspan>
		</text>


<!--		
		<text class="iopnumb"
		  x="{$px_ + $txo_}" 
		  y="{$py_ + $tyo_}">
			<xsl:value-of select="@PRTNUMBER"/>
		</text>
-->		

<!--

		<xsl:if test="not(@GPORT_GROUP = '0')">	
			<text class="iopnumb"
		  		x="{$px_ + $txo_}" 
		  		y="{$py_ + $tyo_}">
					<xsl:value-of select="@PRTNUMBER"/>
					<tspan class="iopgrp"><xsl:value-of select="@GPORT_GROUP"/></tspan>
			</text>
		</xsl:if>
		
		<xsl:if test="@GPORT_GROUP = '0'">	
			<text class="iopnumb"
		  		x="{$px_ + $txo_}" 
		  		y="{$py_ + $tyo_}">
					<xsl:value-of select="@PRTNUMBER"/>
					<tspan class="iopgrp">G</tspan>
			</text>
		</xsl:if>
-->
		
		
	</xsl:for-each>
	
</xsl:template>




<!-- ======================= END MAIN BLOCK =========================== -->

</xsl:stylesheet>
