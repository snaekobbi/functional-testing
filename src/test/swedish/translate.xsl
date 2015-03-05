<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dotify="http://code.google.com/p/dotify/"
                version="2.0">
	
	<xsl:variable name="query" select="'(locale:sv-SE)'"/>
	
	<xsl:template match="input">
		<expect>
			<xsl:value-of select="dotify:translate($query, string(.))"/>
		</expect>
	</xsl:template>
	
</xsl:stylesheet>
