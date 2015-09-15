<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.daisy.org/ns/xprocspec"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:dp2="http://www.daisy.org/ns/pipeline"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:include href="serialize.xsl"/>
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xsl"/>
	<xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="x:description">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<link rel="stylesheet" type="text/css" href="{pf:relativize-uri(resolve-uri('../style.css'),base-uri(/*))}"/>
			<link rel="stylesheet" type="text/css" href="{pf:relativize-uri(resolve-uri('../github.min.css'),base-uri(/*))}"/>
			<style type="text/css">
				@namespace x url(http://www.daisy.org/ns/xprocspec);
				x|scenario x|documentation ul li {
				  margin-top: 10px;
				  margin-bottom: 10px;
				}
				code.xpath {
				  display: inline;
				}
			</style>
			<script type="text/javascript" src="{pf:relativize-uri(resolve-uri('../jquery.min.js'),base-uri(/*))}"/>
			<script type="text/javascript" src="{pf:relativize-uri(resolve-uri('../highlight.min.js'),base-uri(/*))}"/>
			<script type="text/javascript">
				$(document).ready(function() {
				  $("code").each(function(i, block) {
				    hljs.highlightBlock(block);
				  });
				  $(".document.pef").each(function(i, div) {
				    var x = ["pef-xml", "pef-ascii", "pef-unicode"];
				    x.forEach(function(clazz) {
				      $(div).children("a." + clazz).click((function(clazz) {
				        return function(e) {
				          e.preventDefault();
				          $(div).removeClass("pef-xml pef-ascii pef-unicode");
				          $(div).addClass(clazz);
				        }
				      })(clazz));
				    });
				  });
				});
			</script>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="x:scenario">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="not(child::x:documentation)">
				<x:documentation>
					<xsl:variable name="ul">
						<wrap xml:base="{base-uri(.)}">
							<ul>
								<xsl:apply-templates select="x:call/x:input" mode="html"/>
								<xsl:apply-templates select="x:call/x:option" mode="html"/>
								<xsl:apply-templates select="x:expect" mode="html"/>
							</ul>
						</wrap>
					</xsl:variable>
					<xsl:apply-templates select="$ul/*/html:ul"/>
				</x:documentation>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="x:call/x:input" mode="html">
		<xsl:if test="x:document">
			<li>
				<xsl:call-template name="x:document-as-code">
					<xsl:with-param name="x:document" select="x:document"/>
					<xsl:with-param name="with-title">
						<xsl:value-of select="@port"/>
					</xsl:with-param>
				</xsl:call-template>
			</li>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="x:call/x:option" mode="html">
		<li>
			<xsl:value-of select="concat(@name,': ')"/>
			<code class="xpath">
				<xsl:value-of select="@select"/>
			</code>
		</li>
	</xsl:template>
	
	<xsl:template match="x:expect" mode="html"/>
	
	<xsl:template name="x:document-as-code">
		<xsl:param name="x:document"/>
		<xsl:param name="with-title"/>
		<xsl:param name="with-class"/>
		<xsl:choose>
			<xsl:when test="$x:document/@type='file'">
				<a href="{$x:document/@href}" class="{string-join(('code', $with-class), ' ')}">
					<xsl:sequence select="$with-title"/>
				</a>
			</xsl:when>
			<xsl:when test="$x:document/@type='inline'">
				<span>
					<xsl:sequence select="$with-title"/>
					<div class="{string-join(('document', $with-class), ' ')}">
						<code>
							<xsl:if test="$with-class">
								<xsl:attribute name="class" select="$with-class"/>
							</xsl:if>
							<xsl:apply-templates select="$x:document/*" mode="serialize"/>
						</code>
						<xsl:if test="tokenize($with-class, '\s+')='pef'">
							<xsl:sequence select="$x:document/pef:pef"/>
							<a class="pef-xml" href="#">xml</a>
							<a class="pef-unicode" href="#">unicode</a>
							<a class="pef-ascii" href="#">ascii</a>
						</xsl:if>
					</div>
				</span>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:a[tokenize(@class, '\s+')='code']">
		<span>
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
			<xsl:variable name="class" select="string-join(tokenize(@class, '\s+')[not('code'=.)], ' ')"/>
			<div class="{string-join(('document', $class), ' ')}">
				<code>
					<xsl:if test="$class!=''">
						<xsl:attribute name="class" select="$class"/>
					</xsl:if>
					<xsl:value-of select="unparsed-text(resolve-uri(@href, base-uri(/*)))"/>
				</code>
				<xsl:if test="tokenize($class, '\s+')='pef'">
					<xsl:apply-templates select="document(resolve-uri(@href, base-uri(/*)))/pef:pef"/>
					<a class="pef-xml" href="#">xml</a>
					<a class="pef-unicode" href="#">unicode</a>
					<a class="pef-ascii" href="#">ascii</a>
				</xsl:if>
			</div>
		</span>
	</xsl:template>
	
	<xsl:template match="pef:pef[pef:head/pef:meta/dp2:ascii-table]">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()">
				<xsl:with-param name="ascii-table" tunnel="yes" select="string(pef:head/pef:meta/dp2:ascii-table)"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="pef:page">
		<xsl:param name="ascii-table" as="xs:string" tunnel="yes"
		           select="'(id:&quot;org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US&quot;)'"/>
		<xsl:variable name="rows" select="xs:integer(number(ancestor::*[@rows][1]/@rows))"/>
		<xsl:variable name="cols" select="xs:integer(number(ancestor::*[@cols][1]/@cols))"/>
		<xsl:variable name="rowgap" select="xs:integer(number(ancestor-or-self::*[@rowgap][1]/@rowgap))"/>
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:for-each select="pef:row">
				<xsl:variable name="row" select="string-join((string(.), for $x in string-length(string(.)) + 1 to $cols return '&#x2800;'), '')"/>
				<xsl:variable name="rowgap" select="xs:integer(number(ancestor-or-self::*[@rowgap][1]/@rowgap))"/>
				<pef:row rowgap="{format-number($rowgap,'0')}">
					<xsl:sequence select="$row"/>
				</pef:row>
				<pef:row class="ascii" rowgap="{format-number($rowgap,'0')}">
					<xsl:sequence select="pef:encode($ascii-table, $row)"/>
				</pef:row>
			</xsl:for-each>
			<xsl:for-each select="1 to (($rows * 4
			                             - sum(for $row in pef:row
			                                   return 4 + xs:integer(number($row/ancestor-or-self::*[@rowgap][1]/@rowgap))))
			                             idiv 4)">
				<xsl:variable name="row" select="string-join(for $x in 1 to $cols return '&#x2800;', '')"/>
				<pef:row>
					<xsl:sequence select="$row"/>
				</pef:row>
				<pef:row class="ascii">
					<xsl:sequence select="pef:encode($ascii-table, $row)"/>
				</pef:row>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
