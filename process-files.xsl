<?xml version="1.0" encoding="iso-8859-1" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.daisy.org/ns/xprocspec"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:param name="xprocspec-tests" as="xs:string*" required="yes"/>
	<xsl:param name="xprocspec-reports" as="xs:string*" required="yes"/>
	<xsl:param name="result" as="xs:string" required="yes"/>
	
	<xsl:output method="xml" encoding="UTF-8" name="xml"/>
	
	<xsl:variable name="xprocspec-tests-doc" select="document($xprocspec-tests)"/>
	<xsl:variable name="xprocspec-reports-doc" select="document($xprocspec-reports)"/>
	
	<xsl:variable name="source-dir" select="resolve-uri('./', base-uri(/*))"/>
	
	<xsl:include href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xsl"/>
	
	<xsl:template match="/*">
		<xsl:result-document href="{$result}" format="xml">
			<xsl:apply-templates select="." mode="process-index"/>
		</xsl:result-document>
		<xsl:for-each select="$xprocspec-tests-doc">
			<xsl:result-document href="{x:rename-xprocspec-file(resolve-uri(substring-after(base-uri(/*), $source-dir), $result))}" format="xml">
				<xsl:apply-templates select="." mode="process-xprocspec-test"/>
			</xsl:result-document>
		</xsl:for-each>
		<xsl:for-each select="$xprocspec-reports-doc">
			<xsl:result-document href="{resolve-uri(replace(base-uri(/*), '^.*/([^/]*)$', 'xprocspec-reports/$1'), $result)}" format="xml">
				<xsl:apply-templates select="." mode="process-xprocspec-report"/>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="process-index process-xprocspec-test process-xprocspec-report">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:head" mode="process-index">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current"/>
			<link rel="stylesheet" type="text/css" href="style.css"/>
			<link rel="stylesheet" href="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.1/styles/github.min.css"/>
			<xsl:call-template name="javascripts"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:a[@class='xprocspec']" mode="process-index">
		<xsl:next-match/>
		<xsl:variable name="uri" select="resolve-uri(replace(@href, '^(.+)#(.+)$', '$1'), base-uri(/*))"/>
		<xsl:variable name="id" select="replace(@href, '^(.+)#(.+)$', '$2')"/>
		<xsl:if test="$xprocspec-tests=$uri">
			<xsl:variable name="label" select="document($uri)//*[@id=$id]/@label"/>
			<xsl:variable name="report" select="$xprocspec-reports-doc[.//html:body/html:p[1]/html:a[1][string()=$uri]]"/>
			<xsl:variable name="passed" as="xs:boolean"
			              select="contains(
			                        $report//html:th[string()=$label]/following-sibling::html:th,
			                        'pending:0 / failed:0 / errors:0')"/>
			<div class="test xprocspec {if ($passed) then 'test-passed' else 'test-failed'}">
				<xsl:value-of select="concat($id, '. ', $label)"/>
				<a class="test-src" href="{x:rename-xprocspec-file(@href)}">source</a>
				<xsl:if test="$report">
					<a class="test-report" href="{replace(base-uri($report/*),'^.*/([^/]*)$','xprocspec-reports/$1')}">report</a>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="x:description" mode="process-xprocspec-test">
		<xsl:variable name="filename" select="replace(base-uri(/*), '^.*/([^/]*)$', '$1')"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<link rel="stylesheet" type="text/css" href="../style.css"/>
			<link rel="stylesheet" href="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.1/styles/github.min.css"/>
			<xsl:call-template name="javascripts"/>
			<xsl:if test="not(child::x:documentation)">
				<x:documentation>
					<h1>
						<xsl:value-of select="$filename"/>
					</h1>
				</x:documentation>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="x:scenario" mode="process-xprocspec-test">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:if test="not(child::x:documentation) and x:call/@step='pxi:css-inline-and-louis-format'">
				<x:documentation>
					<xsl:variable name="ul">
						<wrap xml:base="{base-uri(.)}">
							<ul>
								<li>
									<xsl:call-template name="x:document-as-code">
										<xsl:with-param name="x:document" select="x:call/x:input[@port='source']/x:document"/>
										<xsl:with-param name="with-title">source</xsl:with-param>
									</xsl:call-template>
								</li>
								<li>
									<a class="code" href="{replace(x:call/x:option[@name='stylesheet']/@select, '^.(.*).$', '$1')}">stylesheet</a>
								</li>
								<li>
									<xsl:call-template name="x:document-as-code">
										<xsl:with-param name="x:document"
										                select="x:expect[preceding-sibling::x:context[1]/x:document[@port='result']
										                                 and @step='pxi:pef-compare']/x:document"/>
										<xsl:with-param name="with-title">result</xsl:with-param>
										<xsl:with-param name="with-class">pef</xsl:with-param>
									</xsl:call-template>
								</li>
							</ul>
						</wrap>
					</xsl:variable>
					<xsl:apply-templates select="$ul/*/html:ul" mode="#current"/>
				</x:documentation>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="#current"/>
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
	
	<xsl:template match="html:a[tokenize(@class, '\s+')='code']" mode="process-index process-xprocspec-test">
		<span>
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="#current"/>
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
					<xsl:apply-templates select="document(resolve-uri(@href, base-uri(/*)))/pef:pef" mode="#current"/>
					<a class="pef-xml" href="#">xml</a>
					<a class="pef-unicode" href="#">unicode</a>
					<a class="pef-ascii" href="#">ascii</a>
				</xsl:if>
			</div>
		</span>
	</xsl:template>
	
	<xsl:template match="*" mode="serialize">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:apply-templates select="@*" mode="#current"/>
		<xsl:choose>
			<xsl:when test="node()">
				<xsl:text>&gt;</xsl:text>
				<xsl:apply-templates mode="#current"/>
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>/&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*" mode="serialize">
		<xsl:text> </xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>="</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="text()" mode="serialize">
		<xsl:value-of select="."/>
	</xsl:template>
	
	<xsl:template name="javascripts">
		<script type="text/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery.min.js"/>
		<script type="text/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.1/highlight.min.js"/>
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
	</xsl:template>
	
	<xsl:template match="html:a" mode="process-xprocspec-report">
		<xsl:choose>
			<xsl:when test="starts-with(@href, $source-dir)">
				<xsl:copy>
					<xsl:variable name="new-href" select="concat('../', substring-after(@href, $source-dir))"/>
					<xsl:apply-templates select="@*[not(name(.)='href')]" mode="#current"/>
					<xsl:attribute name="href" select="x:rename-xprocspec-file($new-href)"/>
					<xsl:choose>
						<xsl:when test="string(.)=string(@href)">
							<xsl:value-of select="$new-href"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="node()" mode="#current"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="pef:page" mode="process-index process-xprocspec-test">
		<xsl:variable name="rows" select="xs:integer(number(ancestor::*[@rows][1]/@rows))"/>
		<xsl:variable name="cols" select="xs:integer(number(ancestor::*[@cols][1]/@cols))"/>
		<xsl:variable name="table" select="'org.daisy.braille.table.DefaultTableProvider.TableType.EN_US'"/>
		<xsl:copy>
			<xsl:sequence select="@*"/>
			<xsl:for-each select="pef:row">
				<xsl:variable name="row" select="string-join((string(.), for $x in string-length(string(.)) + 1 to $cols return '&#x2800;'), '')"/>
				<pef:row>
					<xsl:sequence select="$row"/>
				</pef:row>
				<pef:row class="ascii">
					<xsl:sequence select="pef:encode($table, $row)"/>
				</pef:row>
			</xsl:for-each>
			<xsl:for-each select="count(pef:row) + 1 to $rows">
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
	
	<xsl:function name="x:rename-xprocspec-file">
		<xsl:param name="uri"/>
		<xsl:sequence select="replace($uri, '(\.xprocspec)(#.+)?$', '$1.xhtml$2')"/>
	</xsl:function>
	
</xsl:stylesheet>
