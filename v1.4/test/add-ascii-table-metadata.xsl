<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:dp2="http://www.daisy.org/ns/pipeline"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pef="http://www.daisy.org/ns/2008/pef">
	
	<xsl:param name="ascii-table"/>
	
	<xsl:template match="pef:meta">
		<xsl:copy>
			<xsl:sequence select="@*|node()"/>
			<dp2:ascii-table>
				<xsl:value-of select="$ascii-table"/>
			</dp2:ascii-table>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
