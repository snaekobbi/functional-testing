<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:template match="*" mode="serialize">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:apply-templates select="@*" mode="#current"/>
		<xsl:choose>
			<xsl:when test="node()">
				<xsl:text>&gt;</xsl:text>
				<xsl:apply-templates mode="#current"/>
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>/&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*" mode="serialize">
		<xsl:text> </xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>="</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="text()" mode="serialize">
		<xsl:value-of select="."/>
	</xsl:template>
	
</xsl:stylesheet>
