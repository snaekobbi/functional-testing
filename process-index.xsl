<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:param name="xprocspec-reports" as="xs:anyURI*" required="yes"/>
	<xsl:param name="xspec-reports" as="xs:anyURI*" required="yes"/>
	<xsl:param name="result-base" as="xs:anyURI" required="yes"/>
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
	
	<xsl:variable name="xprocspec-reports-doc" select="document($xprocspec-reports)"/>
	<xsl:variable name="xspec-reports-doc" select="document($xspec-reports)"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:a[@class='test-src']">
		<xsl:next-match/>
		<xsl:variable name="uri" select="replace(@href, '^(.+)#(.+)$', '$1')"/>
		<xsl:variable name="abs-uri" select="resolve-uri($uri, base-uri(/*))"/>
		<xsl:variable name="id" select="replace(@href, '^(.+)#(.+)$', '$2')"/>
		<xsl:variable name="label" select="document($abs-uri)//*[@id=$id]/@label"/>
		<xsl:variable name="report" as="node()?">
			<xsl:choose>
				<xsl:when test="ends-with($uri,'.xprocspec')">
					<xsl:sequence select="$xprocspec-reports-doc[.//html:body/html:p[1][string(html:a[1])=$abs-uri]]"/>
				</xsl:when>
				<xsl:when test="ends-with($uri,'.xspec')">
					<xsl:sequence select="$xspec-reports-doc[.//html:body/html:table[1]/html:tbody/html:tr[normalize-space(string(html:th[1]))=$label]]"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="passed" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="ends-with($uri,'.xprocspec')">
					<xsl:sequence select="contains(
					                        $report//html:th[string()=$label]/following-sibling::html:th,
					                        'pending:0 / failed:0 / errors:0')"/>
				</xsl:when>
				<xsl:when test="ends-with($uri,'.xspec')">
					<xsl:sequence select="boolean($report//html:body/html:table[1]/html:tbody/html:tr[not(@class='failed')][normalize-space(string(html:th[1]))=$label])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="false()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="test {if ($passed) then 'test-passed' else 'test-failed'}">
			<xsl:value-of select="concat($id, '. ', $label)"/>
			<a class="test-src" href="{concat($uri,'.xhtml#',$id)}">source</a>
			<xsl:if test="$report">
				<a class="test-report" href="{pf:relativize-uri(base-uri($report/*), $result-base)}">report</a>
			</xsl:if>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
