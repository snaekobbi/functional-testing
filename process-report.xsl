<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:param name="src-dir_" as="xs:anyURI" required="yes"/>
	<xsl:param name="dest-dir_" as="xs:anyURI" required="yes"/>
	<xsl:param name="result-base" as="xs:anyURI" required="yes"/>
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
	
	<xsl:variable name="src-dir" as="xs:string" select="pf:normalize-uri(concat($src-dir_,'/'))"/>
	<xsl:variable name="dest-dir" as="xs:string" select="pf:normalize-uri(concat($dest-dir_,'/'))"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:a">
		<xsl:choose>
			<xsl:when test="starts-with(@href, $src-dir)">
				<xsl:copy>
					<xsl:variable name="new-href" select="pf:relativize-uri(resolve-uri(pf:relativize-uri(@href, $src-dir), $dest-dir), $result-base)"/>
					<xsl:apply-templates select="@* except @href"/>
					<xsl:attribute name="href" select="replace($new-href, '\.xprocspec$', '$0.xhtml')"/>
					<xsl:choose>
						<xsl:when test="string(@href)=(string(.),concat('file:/',string(.)))">
							<xsl:value-of select="$new-href"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="node()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
