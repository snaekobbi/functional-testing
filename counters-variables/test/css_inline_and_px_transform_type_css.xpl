<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:css-inline-and-px-transform-type-css"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                version="1.0">
  
  <p:input port="source"/>
  <p:output port="result"/>
  
  <p:option name="stylesheet" required="true"/>
  <p:option name="transform" required="true"/>
  <p:option name="temp-dir" required="true"/>
  
  <p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
  
  <css:inline>
    <p:with-option name="default-stylesheet" select="$stylesheet"/>
  </css:inline>
  
  <px:transform type="css">
    <p:with-option name="query" select="$transform"/>
    <p:with-option name="temp-dir" select="$temp-dir"/>
  </px:transform>
  
</p:declare-step>
