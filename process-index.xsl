<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:xspec="http://www.jenitennison.com/xslt/xspec"
                xmlns:xprocspec="http://www.daisy.org/ns/xprocspec"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:param name="junit-reports" as="xs:anyURI*" required="yes"/>
	<xsl:param name="xprocspec-reports" as="xs:anyURI*" required="yes"/>
	<xsl:param name="xspec-reports" as="xs:anyURI*" required="yes"/>
	<xsl:param name="result-base" as="xs:anyURI" required="yes"/>
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
	
	<xsl:variable name="junit-reports-doc" select="document($junit-reports)"/>
	<xsl:variable name="xprocspec-reports-doc" select="document($xprocspec-reports)"/>
	<xsl:variable name="xspec-reports-doc" select="document($xspec-reports)"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:a[@class='test-src']">
		<xsl:variable name="uri" select="replace(@href, '^(.+)#(.+)$', '$1')"/>
		<xsl:variable name="abs-uri" select="resolve-uri($uri, base-uri(/*))"/>
		<xsl:variable name="id" select="replace(@href, '^(.+)#(.+)$', '$2')"/>
		<xsl:variable name="label" select="if (ends-with($uri, '.java')) then $id
		                                   else document($abs-uri)//*[@id=$id]/@label"/>
		<xsl:variable name="report" as="node()?">
			<xsl:choose>
				<xsl:when test="ends-with($uri,'.java')">
					<xsl:sequence select="$junit-reports-doc[/testFile[@href=$abs-uri]]"/>
				</xsl:when>
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
				<xsl:when test="ends-with($uri,'.java')">
					<xsl:sequence select="not($report//testCase[@name=$id and @result='failed'])"/>
				</xsl:when>
				<xsl:when test="ends-with($uri,'.xprocspec')">
					<xsl:sequence select="contains(
					                        $report//html:th[string()=$label]/following-sibling::html:th,
					                        'pending:0 / failed:0 / errors:0')"/>
				</xsl:when>
				<xsl:when test="ends-with($uri,'.xspec')">
					<xsl:sequence select="boolean($report//html:body/html:table[1]/html:tbody/html:tr[not(@class='failed')][normalize-space(string(html:th[1]))=$label])"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<div class="test {if ($passed) then 'test-passed' else 'test-failed'}">
			<xsl:value-of select="if (ends-with($uri, '.java')) then $id
			                      else string-join(document($abs-uri)//*[@id=$id]
			                                       /(ancestor-or-self::xspec:scenario|ancestor-or-self::xprocspec:scenario)/@label,
			                                       ' -- ')"/>
			<a class="test-src" href="{concat($uri,'.xhtml#',$id)}">source</a>
			<xsl:if test="$report">
				<a class="test-report" href="{pf:relativize-uri(base-uri($report/*), $result-base)}">report</a>
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template match="html:a[@class='test-src' and matches(@href, '^https?://')]">
		<div class="test external-test">
			<a href="{@href}">
				<xsl:value-of select="@href"/>
			</a>
			<a class="test-src" href="{@href}">source</a>
		</div>
	</xsl:template>
	
	<xsl:template match="html:span[@id='date']">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:value-of select="format-date(current-date(), '[M01]/[D01]/[Y0001]')"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
