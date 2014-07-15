<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:css-inline-and-louis-format"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:css="http://xmlcalabash.com/ns/extensions/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    name="main"
    version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    <p:option name="stylesheet" required="true"/>
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-formatter/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-calabash/library.xpl"/>
    
    <p:add-attribute match="/link" attribute-name="href" name="link">
        <p:input port="source">
            <p:inline>
                <link rel="stylesheet" media="embossed" type="text/css"/>
            </p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="resolve-uri($stylesheet)">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
    </p:add-attribute>
    
    <p:insert match="/*" position="first-child">
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe step="link" port="result"/>
        </p:input>
    </p:insert>
    
    <css:inline/>
    
    <louis:format>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </louis:format>
    
</p:declare-step>
