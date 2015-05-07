<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:louis="http://liblouis.org/liblouis"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                version="2.0">
	
	<xsl:variable name="query" select="'(table:&quot;unicode.dis,no-no-g0.utb&quot;)'"/>
	
	<xsl:template match="input">
		<xsl:variable name="text" as="text()*" select=".//text()"/>
		<xsl:variable name="style" as="xs:string*">
			<xsl:apply-templates select="$text" mode="style"/>
		</xsl:variable>
		<expect>
			<xsl:apply-templates select="node()[1]" mode="treewalk">
				<xsl:with-param name="new-text-nodes" select="louis:translate($query,$text,$style)"/>
			</xsl:apply-templates>
		</expect>
	</xsl:template>
	
	<xsl:template match="text()" as="xs:string" mode="style">
		<xsl:variable name="text-transform" as="xs:string*">
			<xsl:if test="ancestor::html:strong">
				<xsl:sequence select="'louis-bold'"/>
			</xsl:if>
			<xsl:if test="ancestor::html:em">
				<xsl:sequence select="'louis-ital'"/>
			</xsl:if>
			<xsl:if test="ancestor::html:u">
				<xsl:sequence select="'louis-under'"/>
			</xsl:if>
		</xsl:variable>
		<xsl:sequence select="if (exists($text-transform))
		                      then concat('text-transform: ',string-join($text-transform,' '))
		                      else ''"/>
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
	
	<xsl:function name="css:normalize-space">
		<xsl:param name="x" as="element()"/>
		<xsl:apply-templates select="$x" mode="css:normalize-space"/>
	</xsl:function>
	
	<xsl:template match="*" mode="css:normalize-space">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="text()" mode="css:normalize-space">
		<xsl:value-of select="replace(
		                        normalize-space(
		                          translate(
		                            concat('|',string(.),'|'),
		                            '⠀',' ')),
		                        '^.|.$','')"/>
	</xsl:template>
	
	<xsl:function name="html:flatten">
		<xsl:param name="x" as="element()"/>
		<xsl:apply-templates select="$x" mode="html:flatten"/>
	</xsl:function>
	
	<xsl:template match="*" mode="html:flatten">
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:value-of select="string(.)"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
