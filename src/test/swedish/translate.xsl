<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:dotify="http://code.google.com/p/dotify/"
                version="2.0">
	
	<xsl:template name="main">
		<xsl:param name="query" as="xs:string"/>
		<xsl:param name="input" as="element()*"/>
		<xsl:apply-templates select="$input">
			<xsl:with-param name="query" select="$query"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="input">
		<xsl:param name="query" as="xs:string"/>
		<expect>
			<!--
			    workaround for the fact that DotifyTranslator does not inherit from
			    BrailleTranslator and thus not work with pf:text-transform
			-->
			<xsl:choose>
				<xsl:when test="matches($query,'(translator:dotify)')">
					<xsl:value-of select="dotify:translate($query, string(.))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="pf:text-transform($query, string(.))"/>
				</xsl:otherwise>
			</xsl:choose>
		</expect>
	</xsl:template>
	
</xsl:stylesheet>
