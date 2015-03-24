<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
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
						testNorwegianHyphenation
					</h2>
					<table>
						<xsl:for-each select="tokenize(unparsed-text(resolve-uri('../../resources/hyphenation/data_no.txt')),'\n')[normalize-space()]">
							<tr>
								<td>
									<code class="xml">
										<xsl:value-of select="translate(normalize-space(.),'&#x00AD;','=')"/>
									</code>
								</td>
							</tr>
						</xsl:for-each>
					</table>
				</div>
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>
