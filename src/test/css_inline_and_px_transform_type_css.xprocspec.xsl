<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:x="http://www.daisy.org/ns/xprocspec"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:include href="xprocspec.xsl"/>
	
	<xsl:template match="x:call/x:option[@name='stylesheet']" mode="html">
		<li>
			<xsl:variable name="regex"> *resolve-uri\( *['"](.*)['"] *\) *</xsl:variable>
			<a class="code" href="{replace(@select,$regex,'$1')}">
				stylesheet:
				<code class="xpath">
					<xsl:value-of select="@select"/>
				</code>
			</a>
		</li>
	</xsl:template>
	
	<xsl:template match="x:call/x:option[@name='temp-dir']" mode="html"/>
	
	<xsl:template match="x:expect[@type='custom' and @step='x:pef-compare' and preceding-sibling::x:context[1]/x:document[@port='result']]" mode="html">
		<li>
			<xsl:call-template name="x:document-as-code">
				<xsl:with-param name="x:document" select="x:document"/>
				<xsl:with-param name="with-title">result</xsl:with-param>
				<xsl:with-param name="with-class" select="'pef'"/>
			</xsl:call-template>
		</li>
	</xsl:template>
	
</xsl:stylesheet>
