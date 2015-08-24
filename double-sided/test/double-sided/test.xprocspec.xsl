<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.daisy.org/ns/xprocspec"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:include href="../common/serialize.xsl"/>
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xsl"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="x:description">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<link rel="stylesheet" type="text/css" href="../../style.css"/>
			<link rel="stylesheet" href="../../github.min.css"/>
			<script type="text/javascript" src="../../jquery.min.js"/>
			<script type="text/javascript" src="../../highlight.min.js"/>
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
								<xsl:variable name="source" select="x:call/x:input[@port='source']/x:document"/>
								<xsl:if test="$source">
									<li>
										<xsl:call-template name="x:document-as-code">
											<xsl:with-param name="x:document" select="$source"/>
											<xsl:with-param name="with-title">source</xsl:with-param>
										</xsl:call-template>
									</li>
								</xsl:if>
								<xsl:if test="x:call/x:option[@name='stylesheet']">
									<li>
										<a class="code" href="{replace(x:call/x:option[@name='stylesheet']/@select, '^.(.*).$', '$1')}">stylesheet</a>
									</li>
								</xsl:if>
								<xsl:variable name="result" select="x:expect[preceding-sibling::x:context[1]/x:document[@port='result']]/x:document"/>
								<xsl:if test="$result">
									<li>
										<xsl:call-template name="x:document-as-code">
											<xsl:with-param name="x:document" select="$result"/>
											<xsl:with-param name="with-title">result</xsl:with-param>
											<xsl:with-param name="with-class" select="if ($result/parent::*/@step='x:pef-compare') then 'pef' else ''"/>
										</xsl:call-template>
									</li>
								</xsl:if>
							</ul>
						</wrap>
					</xsl:variable>
					<xsl:apply-templates select="$ul/*/html:ul"/>
				</x:documentation>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
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
	
	<xsl:template match="pef:section">
		<xsl:variable name="duplex" select="ancestor-or-self::*[@duplex][1]/@duplex='true'"/>
		<xsl:choose>
			<xsl:when test="$duplex
			                and (count(child::pef:page) mod 2 = 1)
			                and (following::pef:page intersect ancestor::pef:pef/descendant::pef:page)">
				<xsl:variable name="section" as="element()">
					<pef:section rows="{ancestor-or-self::*[@rows][1]/@rows}"
					             cols="{ancestor-or-self::*[@cols][1]/@cols}"
					             rowgap="{ancestor-or-self::*[@rowgap][1]/@rowgap}">
						<pef:page/>
					</pef:section>
				</xsl:variable>
				<xsl:copy>
					<xsl:sequence select="@*"/>
					<xsl:apply-templates select="*"/>
					<xsl:apply-templates select="$section/pef:page"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="pef:page">
		<xsl:variable name="rows" select="xs:integer(number(ancestor::*[@rows][1]/@rows))"/>
		<xsl:variable name="cols" select="xs:integer(number(ancestor::*[@cols][1]/@cols))"/>
		<xsl:variable name="rowgap" select="xs:integer(number(ancestor-or-self::*[@rowgap][1]/@rowgap))"/>
		<!--
		    TODO: which encoding is used in Sweden?
		-->
		<xsl:variable name="table" select="'(id:&quot;org.daisy.braille.table.DefaultTableProvider.TableType.EN_US&quot;)'"/>
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:for-each select="pef:row">
				<xsl:variable name="row" select="string-join((string(.), for $x in string-length(string(.)) + 1 to $cols return '&#x2800;'), '')"/>
				<xsl:variable name="rowgap" select="xs:integer(number(ancestor-or-self::*[@rowgap][1]/@rowgap))"/>
				<pef:row rowgap="{format-number($rowgap,'0')}">
					<xsl:sequence select="$row"/>
				</pef:row>
				<pef:row class="ascii" rowgap="{format-number($rowgap,'0')}">
					<xsl:sequence select="pef:encode($table, $row)"/>
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
					<xsl:sequence select="pef:encode($table, $row)"/>
				</pef:row>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
