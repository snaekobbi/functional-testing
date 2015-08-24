<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:louis="http://liblouis.org/liblouis"
                version="2.0">
	
	<xsl:variable name="query" select="concat('(table:&quot;',resolve-uri('../../resources/43.1/translate.cti'),',',resolve-uri('../../resources/43.1/hyphenate.dic'),'&quot;)')"/>
	
	<xsl:template match="input">
		<xsl:variable name="text" as="text()*" select=".//text()"/>
		<xsl:variable name="style" as="xs:string*" select="for $t in $text return concat('hyphens:',
		                                                   if ($t/ancestor::a) then 'none' else 'auto')"/>
		<expect>
			<xsl:apply-templates select="node()[1]" mode="treewalk">
				<xsl:with-param name="new-text-nodes" select="for $t in louis:translate($query,$text,$style)
				                                              return translate($t,'&#xAD;','|')"/>
			</xsl:apply-templates>
		</expect>
	</xsl:template>
	
	<xsl:template match="*" mode="treewalk">
		<xsl:param name="new-text-nodes" as="xs:string*" required="yes"/>
		<xsl:variable name="text-node-count" select="count(.//text())"/>
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:apply-templates select="child::node()[1]" mode="#current">
				<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&lt;=$text-node-count]"/>
			</xsl:apply-templates>
		</xsl:copy>
		<xsl:apply-templates select="following-sibling::node()[1]" mode="#current">
			<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&gt;$text-node-count]"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="text()" mode="treewalk">
		<xsl:param name="new-text-nodes" as="xs:string*" required="yes"/>
		<xsl:value-of select="$new-text-nodes[1]"/>
		<xsl:apply-templates select="following-sibling::node()[1]" mode="#current">
			<xsl:with-param name="new-text-nodes" select="$new-text-nodes[position()&gt;1]"/>
		</xsl:apply-templates>
	</xsl:template>
	
</xsl:stylesheet>
