<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:include href="../common/serialize.xsl"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="x:description">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<link rel="stylesheet" type="text/css" href="../../style.css"/>
			<link rel="stylesheet" href="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.1/styles/github.min.css"/>
			<script type="text/javascript" src="../../jquery.min.js"/>
			<script type="text/javascript" src="../../highlight.min.js"/>
			<script type="text/javascript">
				$(document).ready(function() {
				  $("code").each(function(i, block) {
				    hljs.highlightBlock(block);
				  });
				});
			</script>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="x:scenario">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<table>
				<thead>
					<tr>
						<th>input</th>
						<th>expect</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="document(resolve-uri(x:context/@href))//entry">
						<tr>
							<td>
								<code class="xml">
									<xsl:apply-templates select="input/node()" mode="serialize"/>
								</code>
							</td>
							<td>
								<code class="xml">
									<xsl:apply-templates select="expect/node()" mode="serialize"/>
								</code>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
