<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:include href="../serialize.xsl"/>
	
	<xsl:template name="main">
		<html xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<link rel="stylesheet" type="text/css" href="../../style.css"/>
				<link rel="stylesheet" type="text/css" href="../../github.min.css"/>
				<script type="text/javascript" src="../../jquery.min.js"/>
				<script type="text/javascript" src="../../highlight.min.js"/>
				<script type="text/javascript">
					$(document).ready(function() {
					  $("code").each(function(i, block) {
					    hljs.highlightBlock(block);
					  });
					});
				</script>
			</head>
			<body>
				<div class="junit-test">
					<h2>
						testDutchHyphenation
					</h2>
					<table>
						<thead>
							<tr>
								<th>input</th>
								<th>expect</th>
							</tr>
						</thead>
						<tbody>
							<xsl:for-each select="document(resolve-uri('../../resources/hyphenation/data_dutch.xml'))//entry">
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
				</div>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="expect/text()" mode="serialize">
		<xsl:value-of select="translate(.,'&#x00AD;','=')"/>
	</xsl:template>
	
</xsl:stylesheet>
