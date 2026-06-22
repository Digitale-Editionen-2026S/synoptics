<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">
    
    <xsl:import href="./partials/shared.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <!-- <xsl:import href="./partials/blockquote.xsl"/> -->
    <xsl:import href="./partials/zotero.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:variable name="prev" select="replace(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml', '.html')"/>
        <xsl:variable name="next" select="replace(tokenize(data(tei:TEI/@next), '/')[last()], '.xml', '.html')"/>
        <xsl:variable name="teiSource">
            <xsl:choose>
                <xsl:when test="normalize-space(data(tei:TEI/@xml:id)) and matches(data(tei:TEI/@xml:id), '\\.xml$')">
                    <xsl:value-of select="data(tei:TEI/@xml:id)"/>
                </xsl:when>
                <xsl:when test="normalize-space(data(tei:TEI/@xml:id))">
                    <xsl:value-of select="concat(data(tei:TEI/@xml:id), '.xml')"/>
                </xsl:when>
                <xsl:otherwise>source.xml</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="link" select="replace($teiSource, '\\.xml$', '.html')"/>
        <xsl:variable name="doc_title" select=".//tei:titleStmt/tei:title[1]/text()"/>

        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <!-- Zusätzliche Styles für das OSD-Zweispaltenlayout der Editionsseite. -->
                <link rel="stylesheet" href="css/editions-osd.css?v=20260622" type="text/css"/>
                <xsl:call-template name="zoterMetaTags">
                    <xsl:with-param name="pageId" select="$link"></xsl:with-param>
                    <xsl:with-param name="zoteroTitle" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <!-- Provide the names of the authors/editors of the current unit, ideally fetched from the data via xslt or hard coded as below -->
                <meta name="citation_author" content="Foo, Bar"/>
                <meta name="citation_author" content="Bar, Foo"/> 
            </head>
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main class="flex-shrink-0 flex-grow-1">
                    <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" class="ps-5 p-3">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="index.html">
                                    <xsl:value-of select="$project_short_title"/>
                                </a>
                            </li>
                            <li class="breadcrumb-item">
                                <a href="toc.html">
                                    <xsl:value-of select="'Inhaltsverzeichnis'"/>
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">
                                <xsl:value-of select="$doc_title"/>
                            </li>
                        </ol>
                    </nav>
                    <div class="container">
                        <div class="row">
                            <div class="col-md-2 col-lg-2 col-sm-12 text-start">
                                <xsl:if test="ends-with($prev,'.html')">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$prev"/>
                                        </xsl:attribute>
                                        <i class="fs-2 bi bi-chevron-left" title="Zurück zum vorigen Dokument" visually-hidden="true">
                                            <span class="visually-hidden">Zurück zum vorigen Dokument</span>
                                        </i>
                                    </a>
                                </xsl:if>
                            </div>
                            <div class="col-md-8 col-lg-8 col-sm-12 text-center">
                                <h1>
                                    <xsl:value-of select="$doc_title"/>
                                </h1>
                                <div>
                                    <a href="{$teiSource}">
                                        <i class="bi bi-download fs-2" title="Zum TEI/XML Dokument" visually-hidden="true">
                                            <span class="visually-hidden">Zum TEI/XML Dokument</span>
                                        </i>
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-2 col-lg-2 col-sm-12 text-end">
                                <xsl:if test="ends-with($next, '.html')">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$next"/>
                                        </xsl:attribute>
                                        <i class="fs-2 bi bi-chevron-right" title="Weiter zum nächsten Dokument" visually-hidden="true">
                                            <span class="visually-hidden">Weiter zum nächsten Dokument</span>
                                        </i>
                                    </a>
                                </xsl:if>
                            </div>
                        </div>
                        <!-- OSD-Layout: links Viewer, rechts Text; bleibt auch bei schmaleren Viewports nebeneinander. -->
                        <div class="row g-4 editions-layout flex-nowrap">
                            <!-- Linke Spalte: fixer OpenSeadragon-Container für das Faksimile. -->
                            <div class="col-5 editions-viewer-col">
                                <aside class="osd-column">
                                    <div id="osd-viewer" class="osd-viewer" aria-label="Faksimileansicht"></div>
                                </aside>
                            </div>
                            <!-- Rechte Spalte: transformierter TEI-Text mit PB-Markern als Scroll-Anker. -->
                            <div class="col-7 editions-text-col">
                                <div class="editions-text-column">
                                    <xsl:apply-templates select=".//tei:body"></xsl:apply-templates>
                                    <p style="text-align:center;">
                                        <xsl:for-each select=".//tei:note[not(./tei:p)]">
                                            <div class="footnotes">
                                                <xsl:element name="a">
                                                    <xsl:attribute name="name">
                                                        <xsl:text>fn</xsl:text>
                                                        <xsl:number level="any" format="1" count="tei:note"/>
                                                    </xsl:attribute>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:text>#fna_</xsl:text>
                                                            <xsl:number level="any" format="1" count="tei:note"/>
                                                        </xsl:attribute>
                                                        <span style="font-size:7pt;vertical-align:super; margin-right: 0.4em">
                                                            <xsl:number level="any" format="1" count="tei:note"/>
                                                        </span>
                                                    </a>
                                                </xsl:element>
                                                <xsl:apply-templates/>
                                            </div>
                                        </xsl:for-each>
                                    </p>

                                    <!-- <div class="text-center p-4">
                                        <xsl:call-template name="blockquote">
                                            <xsl:with-param name="pageId" select="$link"/>
                                        </xsl:call-template>
                                    </div> -->

                                    <xsl:for-each select="//tei:back">
                                        <div class="tei-back">
                                            <xsl:apply-templates/>
                                        </div>
                                    </xsl:for-each>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
                <!-- OpenSeadragon-Bibliothek und lokale Scroll-Synchronisierung laden. -->
                <script src="https://cdn.jsdelivr.net/npm/openseadragon@5.0/build/openseadragon/openseadragon.min.js"></script>
                <script src="js/editions-osd.js?v=20260622"></script>
            </body>
        </html>
    </xsl:template>

    <!-- Pro TEI-PB genau ein HTML-Marker; darüber steuert JS den Bildwechsel im OSD. -->
    <xsl:template match="tei:pb">
        <!-- PB-Referenz auf die facsimile-Graphic (xml:id) normalisieren. -->
        <xsl:variable name="gid" select="replace(@facs, '^#', '')"/>
        <!-- Bild-URL zur PB-Referenz auflösen: bevorzugt über surface/@xml:id, optional über graphic/@xml:id. -->
        <xsl:variable name="image_url" select="string((/tei:TEI/tei:facsimile/tei:surface[@xml:id = $gid]/tei:graphic/@url, /tei:TEI/tei:facsimile/tei:graphic[@xml:id = $gid]/@url)[1])"/>
        <xsl:choose>
            <xsl:when test="normalize-space($image_url)">
                <!-- Marker mit OSD-Datenattributen für IntersectionObserver + Bildwechsel. -->
                <span class="pb osd-marker" source="{$gid}" data-osd-facs="{$gid}" data-osd-image="{$image_url}">
                    <xsl:value-of select="./@n"/>
                </span>
                <!-- Sichtbarer Zeilenumbruch am Seitenwechsel im Lesetext. -->
                <br class="pb-break"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Fallback ohne OSD-Daten, falls kein Bild zur PB gefunden wurde. -->
                <span class="pb" source="{$gid}"><xsl:value-of select="./@n"/></span>
                <br class="pb-break"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
