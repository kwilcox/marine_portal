<!--

pacioos-iso-html.xsl

Author: John Maurer (jmaurer@hawaii.edu)
Date: November 1, 2011

This Extensible Stylesheet Language for Transformations (XSLT) document takes
metadata in Extensible Markup Language (XML) for the ISO 19115
with Remote Sensing Extensions (RSE) and converts it into an HTML page. This 
format is used to show the full metadata record on PacIOOS's website.

For more information on XSLT see:

http://en.wikipedia.org/wiki/XSLT
http://www.w3.org/TR/xslt

-->

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gmi="http://www.isotc211.org/2005/gmi"
  xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:gsr="http://www.isotc211.org/2005/gsr"
  xmlns:gss="http://www.isotc211.org/2005/gss"
  xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gml="http://www.opengis.net/gml/3.2"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- Import another XSLT file for replacing newlines with HTML <br/>'s: -->

  <xsl:import href="xsl/utils/replace-newlines.xsl"/>

  <!-- Import another XSLT file for doing other string substitutions: -->

  <xsl:import href="xsl/utils/replace-string.xsl"/>

  <!-- Import another XSLT file for limiting the number of decimal places: -->

  <xsl:import href="xsl/utils/strip-digits.xsl"/>

  <!-- 

  This HTML output method conforms to the following DOCTYPE statement:

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
      "http://www.w3.org/TR/html4/loose.dtd">
  -->

  <xsl:output
    method="html"
    doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
    doctype-system="http://www.w3.org/TR/html4/loose.dtd"
    encoding="ISO-8859-1"
    indent="yes"/>

  <!-- VARIABLES: ***********************************************************-->

  <!-- The separator separates short names from long names. For example:
       DMSP > Defense Meteorological Satellite Program -->

  <xsl:variable name="separator">
     <xsl:text disable-output-escaping="yes"> &lt;img src="/images/right.gif" width="5" height="8"/&gt; </xsl:text>
  </xsl:variable>

  <!-- Define a variable for creating a newline: -->

  <xsl:variable name="newline">
<xsl:text>
</xsl:text>
  </xsl:variable>

  <!-- This variable is used to link to the other metadata views.
       NOTE: TDS FMRC ID's appear like "wrf_hi/WRF_Hawaii_Regional_Atmospheric_Model_best.ncd";
       to simplify the ID's, strip everything after "/":
  -->

  <xsl:variable name="datasetIdentifier">
    <xsl:variable name="datasetIdentifierOriginal" select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString"/>
    <xsl:choose>
      <xsl:when test="contains( $datasetIdentifierOriginal, '/' )">
        <xsl:value-of select="substring-before( $datasetIdentifierOriginal, '/' )"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$datasetIdentifierOriginal"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- Define a variable which creates a JavaScript array of the bounding box
       of the Spatial_Domain/Bounding element in the ISO for use in the Google
       Maps API, which is controlled by the loadGoogleMap function inside
       the google_maps.ssi include file. NOTE: This function expects the
       bounding box to be provided in a specific order: north, south, east,
       west: -->

  <xsl:variable name="bbox">    
    <xsl:if test="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal">
      <xsl:text> [ </xsl:text>
      <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"/><xsl:text>, </xsl:text>
      <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/><xsl:text>, </xsl:text>
      <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/><xsl:text>, </xsl:text>
      <xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/>
      <xsl:text> ] </xsl:text>
    </xsl:if>
  </xsl:variable>

  <!-- TOP-LEVEL: HTML ******************************************************-->

  <!-- The top-level template; Define various features for the entire page and then
       call the "gmi:MI_Metadata" template to fill in the remaining HTML: -->

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml"><xsl:value-of select="$newline"/>
    <head><xsl:value-of select="$newline"/>
    <title><xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></title><xsl:value-of select="$newline"/>
    <link href="xsl/iso.css" rel="stylesheet" type="text/css"/><xsl:value-of select="$newline"/>
    <link href="css/glos.css" rel="stylesheet" type="text/css"/><xsl:value-of select="$newline"/>
    <xsl:comment>
If you want to show polylines on a Google Map (like the rectangle used to
outline the data set geographic coverage), you need to include the VML
namespace in the html tag and the following CSS code in an XHTML compliant
doctype to make everything work properly in IE:
</xsl:comment><xsl:value-of select="$newline"/>
    <style type="text/css">

  v\:* {
    behavior:url(#default#VML);
  }

  .callouthead {
    font-size: 85%;
    font-weight: bold;
    color: #003366;
    padding: 4px 4px 0 4px;
    margin: 0;
  }

  .callouttext {
    font-size: .88em;
    font-weight: normal;
    padding: 2px 4px 0 5px;
    margin: 0;
  }

  .wrapline {
    /* http://perishablepress.com/press/2010/06/01/wrapping-content/ */
    white-space: pre;           /* CSS 2.0 */
    white-space: pre-wrap;      /* CSS 2.1 */
    white-space: pre-line;      /* CSS 3.0 */
    white-space: -pre-wrap;     /* Opera 4-6 */
    white-space: -o-pre-wrap;   /* Opera 7 */
    white-space: -moz-pre-wrap; /* Mozilla */
    white-space: -hp-pre-wrap;  /* HP Printers */
    word-wrap: break-word;
    width: 550px; 
  }

</style><xsl:value-of select="$newline"/>
    <xsl:comment>#include virtual="/pacioos/ssi/google_maps_bboxes.ssi"</xsl:comment><xsl:value-of select="$newline"/>
    </head><xsl:value-of select="$newline"/>
<!--
    <body onLoad="loadGoogleMap( [ {$bbox} ] )" onUnload="GUnload()"><xsl:value-of select="$newline"/>
    <xsl:comment>#include virtual="/pacioos/ssi/pacioos_header.ssi"</xsl:comment><xsl:value-of select="$newline"/>
    <xsl:comment>#include virtual="/pacioos/navigation/index.php"</xsl:comment><xsl:value-of select="$newline"/>
    <xsl:comment>#include virtual="/pacioos/ssi/pacioos_header_b.ssi"</xsl:comment><xsl:value-of select="$newline"/>
    <ul id="nav-breadcrumb">
      <li><a style="margin-top:-12px;" href="/pacioos">Home</a></li>
      <li><a href="/pacioos/data_access/">Data Access</a></li>
      <li class="last"><a href="/pacioos/metadata/">Metadata</a></li>
    </ul>
-->
    <body><xsl:value-of select="$newline"/>
    <div id="headwrapper"><div id="head"><a href="http://glos.us/"><img src="img/blank.png" width="168" height="75" alt="GLOS" /></a><a href="http://explorer.glos.us/"><img src="img/blank.png" width="632" height="75" alt="GLOS Observations Explorer" /></a> </div></div>
    <table width="99%" border="0" cellspacing="2" cellpadding="0">
      <tr>
        <td valign="top">
          <table width="98%" border="0" align="center" cellpadding="2" cellspacing="8" style="margin-top: -20px;">
            <tr>
              <td valign="top" >
                <!--<p style="color: darkred; background-color: lightyellow; border: 1px dashed lightgray; padding: 2px;"><b>NOTE: ISO metadata output is under construction. Please check back later...</b></p>-->
                <h2 style="margin-right: 185px; text-transform: none;"><xsl:value-of select="gmi:MI_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></h2>
                <ul>
                  <li><a href="#Identification_Information">Identification Information</a></li>
                  <xsl:if test="string-length( gmi:MI_Metadata/gmd:dataQualityInfo )">
                    <li><a href="#Data_Quality_Information">Data Quality Information</a></li>
                  </xsl:if>
                  <xsl:if test="string-length( gmi:MI_Metadata/gmd:spatialRepresentationInfo )">
                    <li><a href="#Spatial_Representation_Information">Spatial Representation Information</a></li>
                  </xsl:if>
                  <xsl:if test="string-length( gmi:MI_Metadata/gmd:contentInfo )">
                    <li><a href="#Content_Information">Content Information</a></li>
                  </xsl:if>
                  <xsl:if test="string-length( gmi:MI_Metadata/gmd:distributionInfo )">
                    <li><a href="#Distribution_Information">Distribution Information</a></li>                  
                  </xsl:if>
                  <xsl:if test="string-length( gmi:MI_Metadata/gmd:acquisitionInformation )">
				            <li><a href="#Acquisition_Information">Acquisition Information</a></li>
                  </xsl:if>
                  <li><a href="#Metadata_Reference_Information">Metadata Reference Information</a></li>
                </ul>
                <xsl:apply-templates select="gmi:MI_Metadata"/>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
<!--
    <table width="185" cellspacing="0" cellpadding="0" style="position: absolute; top: 10px; right: 10px; z-index: 2; background-color: #fff; padding-left: 10px;">
      <tr>
        <td style="font-size: 105%; font-weight: bold; color: #006699; padding: 6px 4px 4px 4px; margin: 17px 0 4px 0; border-left-width: 1px; border-left-style: solid; border-left-color: #006699;">Metadata Views</td>
      </tr>
      <tr>
        <td>
          <p class="callouthead"><a href="http://pacioos.org/metadata/{$datasetIdentifier}.txt">ISO Text-Only</a></p>
          <p class="callouttext">International Organization for Standardization (ISO) in plain text</p>
          <p class="callouthead"><a href="http://pacioos.org/metadata/{$datasetIdentifier}.xml">ISO XML</a></p>
          <p class="callouttext">International Organization for Standardization (ISO) in Extensible Markup Language (XML)</p>
          <p class="callouthead"><a href="http://pacioos.org/metadata/{$datasetIdentifier}.html?format=fgdc">FGDC HTML</a></p>
          <p class="callouttext">U.S. Federal Geographic Data Committee (FGDC) Content Standard for Digital Geospatial Metadata (CSDGM)</p>
        </td>
      </tr>
    </table>
-->
    <xsl:comment> END MAIN CONTENT </xsl:comment><xsl:value-of select="$newline"/>
    <xsl:comment> footer include </xsl:comment><xsl:value-of select="$newline"/>
    <xsl:comment>#include virtual="/pacioos/ssi/pacioos_footer.ssi"</xsl:comment><xsl:value-of select="$newline"/>
    <xsl:comment> end footer include </xsl:comment><xsl:value-of select="$newline"/>
    </body><xsl:value-of select="$newline"/>
    </html>
  </xsl:template>

  <!-- The second-level template: match all the main elements of the ISO and
       process them separately. The order of these elements is maintained in
       the resulting document: -->

  <!-- ROOT: ****************************************************************-->

  <xsl:template match="gmi:MI_Metadata">
    <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification"/>
    <xsl:if test="string-length( gmd:identificationInfo/srv:SV_ServiceIdentification )">
      <h4>Services:</h4>
    </xsl:if>
    <xsl:apply-templates select="gmd:identificationInfo/srv:SV_ServiceIdentification"/>
    <p><a href="javascript:void(0)" onClick="window.scrollTo( 0, 0 ); this.blur(); return false;">Back to Top</a></p>
    <xsl:apply-templates select="gmd:dataQualityInfo/gmd:DQ_DataQuality"/>
    <xsl:apply-templates select="gmd:spatialRepresentationInfo/gmd:MD_GridSpatialRepresentation"/>
    <xsl:apply-templates select="gmd:contentInfo"/>
    <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution"/>
    <xsl:apply-templates select="gmd:acquisitionInformation/gmi:MI_AcquisitionInformation"/>
    <xsl:call-template name="metadataReferenceInfo"/>
  </xsl:template>

  <!-- METADATA_REFERENCE_INFORMATION: *****************************************

  NOTE: I have combined the following sections under this heading:

      1. METADATA_ENTITY_SET_INFORMATION (miscellaneous stuff under root doc)
      2. METADATA_MAINTENANCE_INFORMATION (I stuck this within the above)
      3. METADATA_EXTENSION_INFORMATION (ditto)
  --> 

  <xsl:template name="metadataReferenceInfo">
    <hr/>
    <h3><a name="Metadata_Reference_Information"></a>Metadata Reference Information:</h3>
    <xsl:call-template name="metadataEntitySetInfo"/>
    <p><a href="javascript:void(0)" onClick="window.scrollTo( 0, 0 ); this.blur(); return false;">Back to Top</a></p>
  </xsl:template>
 
  <!-- METADATA_ENTITY_SET_INFORMATION: ************************************--> 

  <xsl:template name="metadataEntitySetInfo">
    <xsl:apply-templates select="gmd:fileIdentifier"/>
    <xsl:apply-templates select="gmd:language"/>
    <xsl:apply-templates select="gmd:characterSet"/>
    <xsl:apply-templates select="gmd:parentIdentifier"/>
    <xsl:apply-templates select="gmd:hierarchyLevel"/>
    <xsl:apply-templates select="gmd:hierarchyLevelName"/>
    <xsl:apply-templates select="gmd:contact"/>
    <xsl:apply-templates select="gmd:dateStamp"/>
    <xsl:apply-templates select="gmd:metadataMaintenance/gmd:MD_MaintenanceInformation"/>
    <xsl:apply-templates select="gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation"/>
    <xsl:apply-templates select="gmd:metadataStandardName"/>
    <xsl:apply-templates select="gmd:metadataStandardVersion"/>
    <xsl:apply-templates select="gmd:dataSetURI"/>
  </xsl:template>

  <xsl:template match="gmd:fileIdentifier">
    <h4 style="display: inline">File Identifier:</h4>
    <xsl:variable name="fileURL">
      <xsl:choose>
        <xsl:when test="contains( ., 'http:')">
          <xsl:value-of select="gco:CharacterString"/><xsl:text>.xml</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>http://pacioos.org/metadata/iso/</xsl:text><xsl:value-of select="$datasetIdentifier"/><xsl:text>.xml</xsl:text> 
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <p style="display: inline"><a href="{$fileURL}"><xsl:value-of select="$fileURL"/></a></p>
    <p></p>
  </xsl:template>

  <xsl:template match="gmd:language">
    <h4 style="display: inline">Language:</h4>
    <p style="display: inline"><xsl:value-of select="."/></p>
    <p></p>
  </xsl:template>

  <xsl:template match="gmd:parentIdentifier">
    <h4 style="display: inline">Parent Identifier:</h4>
    <p style="display: inline"><xsl:value-of select="."/></p>
    <p></p>
  </xsl:template>

  <xsl:template match="gmd:characterSet">
    <h4 style="display: inline">Character Set:</h4>
    <p style="display: inline"><xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_CharacterSetCode" target="_blank">MD_CharacterSetCode</a>)</p>
    <p></p>
  </xsl:template>

  <xsl:template match="gmd:hierarchyLevel">
    <h4 style="display: inline">Hierarchy Level:</h4>
    <p style="display: inline"><xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_ScopeCode" target="_blank">MD_ScopeCode</a>)</p>
    <p></p>
  </xsl:template>

  <xsl:template match="gmd:hierarchyLevelName">
    <h4 style="display: inline">Hierarchy Level Name:</h4>
    <p style="display: inline"><xsl:value-of select="."/></p>
    <p></p>
  </xsl:template>
  
  <xsl:template match="gmd:contact">
    <h4>Contact:</h4>
    <xsl:call-template name="CI_ResponsibleParty">
      <xsl:with-param name="element" select="gmd:CI_ResponsibleParty"/>
      <xsl:with-param name="italicize-heading" select="true()"/>      
    </xsl:call-template>        
  </xsl:template>
  
  <xsl:template match="gmd:dateStamp">
    <h4 style="display: inline">Date Stamp:</h4>
    <p style="display: inline">
      <xsl:call-template name="date">
        <xsl:with-param name="element" select="./gco:Date"/>
      </xsl:call-template>
    </p>
    <p></p>
  </xsl:template>

  <xsl:template match="gmd:metadataStandardName">
    <h4>Metadata Standard Name:</h4>
    <p><xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="gmd:metadataStandardVersion">
    <h4>Metadata Standard Version:</h4>
    <p><xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="gmd:dataSetURI">
    <h4>Dataset URI:</h4>
    <p><a href="{.}"><xsl:value-of select="."/></a></p>
  </xsl:template>

  <!-- METADATA_MAINTENANCE_INFORMATION: ************************************-->

  <xsl:template match="gmd:metadataMaintenance/gmd:MD_MaintenanceInformation">
    <h4>Metadata Maintenance Information:</h4>
    <xsl:apply-templates select="gmd:maintenanceAndUpdateFrequency"/>
    <xsl:apply-templates select="gmd:maintenanceNote"/>
    <!--
    Duplicates gmd:contact above so ignore here...
    <xsl:apply-templates select="gmd:contact"/>
    -->
  </xsl:template>

  <xsl:template match="gmd:maintenanceAndUpdateFrequency">
    <p>
      <b><i>Maintenance And Update Frequency: </i></b>
      <xsl:choose>
        <xsl:when test="string-length( . )">
          <xsl:value-of select="."/> 
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@gco:nilReason"/>
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>

  <xsl:template match="gmd:maintenanceNote">
    <xsl:if test="string-length( . )">
      <p><b><i>Maintenance Note:</i></b></p>
      <p><xsl:value-of select="."/></p>
    </xsl:if>
  </xsl:template>

  <!-- METADATA_EXTENSION_INFORMATION: **************************************-->

  <xsl:template match="gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation">
    <h4>Metadata Extension Information:</h4>
    <xsl:for-each select="gmd:extendedElementInformation/gmd:MD_ExtendedElementInformation">
      <p><b><i>Extended Element Information:</i></b></p>
      <font color="#6e6e6e">
      <blockquote>
        <xsl:for-each select="gmd:name">
          <xsl:if test="string-length( . )">
            <b>Name: </b> <xsl:value-of select="."/><br/>
          </xsl:if>
        </xsl:for-each> 
        <xsl:for-each select="gmd:shortName">
          <xsl:if test="string-length( . )">
            <b>Short Name: </b> <xsl:value-of select="."/><br/>
          </xsl:if>
        </xsl:for-each> 
        <xsl:for-each select="gmd:obligation">
          <xsl:if test="string-length( gmd:MD_ObligationCode )">
            <b>Obligation: </b><xsl:value-of select="gmd:MD_ObligationCode"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_ObligationCode">MD_ObligationCode</a>)<br/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:dataType">
          <xsl:if test="string-length( gmd:MD_DatatypeCode )">
            <b>Data Type: </b><xsl:value-of select="gmd:MD_DatatypeCode"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_DatatypeCode">MD_DatatypeCode</a>)<br/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:maximumOccurrence">
          <xsl:if test="string-length( . )">
            <b>Maximum Occurrence: </b> <xsl:value-of select="."/><br/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:parentEntity">
          <xsl:if test="string-length( . )">
            <b>Parent Entity: </b> <xsl:value-of select="."/><br/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:rule">
          <xsl:if test="string-length( . )">
            <b>Rule: </b><br/>
            <p><xsl:value-of select="."/></p>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:definition">
          <xsl:if test="string-length( . )">
            <p><b>Definition:</b></p>
            <p><xsl:value-of select="."/></p>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:rationale">
          <xsl:if test="string-length( . )">
            <p><b>Rationale:</b></p>
            <p><xsl:value-of select="."/></p>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:source">
          <xsl:if test="string-length( . )">
            <p><b>Source:</b></p>
            <blockquote>
              <xsl:call-template name="CI_ResponsibleParty">
                <xsl:with-param name="element" select="gmd:CI_ResponsibleParty"/>
              </xsl:call-template>
            </blockquote>
          </xsl:if>
        </xsl:for-each>
      </blockquote>
      </font>
    </xsl:for-each>
  </xsl:template>
 
  <!-- IDENTIFICATION_INFORMATION: ******************************************-->
 
  <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification">
    <hr/>
    <h3><a name="Identification_Information"></a> Identification Information:</h3>
    <xsl:apply-templates select="gmd:citation"/>
    <xsl:apply-templates select="gmd:abstract"/>
    <xsl:apply-templates select="gmd:purpose"/>
    <xsl:apply-templates select="gmd:credit"/>
    <xsl:apply-templates select="gmd:status"/>
    <xsl:apply-templates select="gmd:pointOfContact"/>
    <xsl:apply-templates select="gmd:resourceMaintenance"/>
    <xsl:apply-templates select="gmd:graphicOverview"/>
    <xsl:if test="gmd:descriptiveKeywords">
      <h4>Descriptive Keywords:</h4>
      <xsl:apply-templates select="gmd:descriptiveKeywords"/>
    </xsl:if>
    <xsl:apply-templates select="gmd:taxonomy"/>
    <xsl:apply-templates select="gmd:aggregationInfo"/>
    <xsl:apply-templates select="gmd:resourceConstraints"/>
    <xsl:apply-templates select="gmd:language"/>
    <xsl:apply-templates select="gmd:characterSet"/>
    <xsl:if test="gmd:topicCategory">
      <h4>Topic Categories (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_TopicCategoryCode">MD_TopicCategoryCode</a>):</h4>
      <blockquote>
        <font color="#6e6e6e">
        <xsl:for-each select="gmd:topicCategory">
          <xsl:sort select="."/>
          <b>Topic Category: </b><xsl:value-of select="."/><br/>
        </xsl:for-each>
        </font>
      </blockquote>
    </xsl:if>
    <xsl:apply-templates select="gmd:extent"/>
    <xsl:apply-templates select="gmd:supplementalInformation"/>
  </xsl:template>

  <xsl:template match="gmd:citation">
    <h4>Citation:</h4>
    <font color="#6e6e6e">
    <xsl:call-template name="CI_Citation">
      <xsl:with-param name="element" select="gmd:CI_Citation"/>
      <xsl:with-param name="italicize-heading" select="true()"/>
      <xsl:with-param name="wrap-text" select="true()"/>
    </xsl:call-template>
    </font>
  </xsl:template>

  <xsl:template match="gmd:abstract">
    <h4>Abstract:</h4>
    <p><xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="gmd:purpose">
    <h4>Purpose:</h4>
    <p><xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="gmd:credit">
    <h4>Credit:</h4>
    <p><xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="gmd:status">
    <h4 style="display: inline">Status:</h4>
    <p style="display: inline"><xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_ProgressCode" target="_blank">MD_ProgressCode</a>)</p>
    <p></p>
  </xsl:template>

  <xsl:template match="gmd:pointOfContact">
    <h4>Point of Contact:</h4>
    <xsl:for-each select="gmd:CI_ResponsibleParty">        
      <xsl:call-template name="CI_ResponsibleParty">
        <xsl:with-param name="element" select="."/>
        <xsl:with-param name="italicize-heading" select="true()"/>
      </xsl:call-template>        
    </xsl:for-each>      
  </xsl:template>

  <xsl:template match="gmd:resourceMaintenance">
    <h4>Maintenance Information:</h4>
    <xsl:for-each select="gmd:MD_MaintenanceInformation">
      <xsl:for-each select="gmd:maintenanceAndUpdateFrequency">
        <p><b><i>Maintenance and Update Frequency: </i></b> <xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_MaintenanceFrequencyCode">MD_MaintenanceFrequencyCode</a>)</p>
      </xsl:for-each>
      <xsl:for-each select="gmd:updateScope">
        <p><b><i>Update Scope:</i></b> <xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_ScopeCode">MD_ScopeCode</a>)</p>
      </xsl:for-each>
      <xsl:for-each select="gmd:contact">
        <p><b><i>Contact:</i></b></p>
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="element" select="gmd:CI_ResponsibleParty"/>
          <xsl:with-param name="italicize-heading" select="false()"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="gmd:graphicOverview">
    <h4>Browse Graphic:</h4>    
    <xsl:for-each select="gmd:MD_BrowseGraphic">
      <xsl:for-each select="gmd:fileName">
        <p>
          <a href="{.}" target="_blank"><img src="{.}" height="260" border="0"/></a><br/>
          <a href="{.}" target="_blank">View full image</a>
        </p>
        <p><b><i>Image File: </i></b><a href="{.}"><xsl:value-of select="."/></a></p>
      </xsl:for-each>
      <xsl:for-each select="gmd:fileDescription">
        <p><b><i>File Description:</i></b></p>
        <p><xsl:value-of select="."/></p>
      </xsl:for-each>
      <xsl:for-each select="gmd:fileType">
        <p><b><i>File Type: </i></b><xsl:value-of select="."/></p>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!--Create keywords indices (keys) so that we can do a unique sort below: -->

  <xsl:key name="values_by_id" match="gmd:keyword" use="gco:CharacterString"/>

  <xsl:template match="gmd:descriptiveKeywords">
    <font color="#6e6e6e">
    <xsl:for-each select="gmd:MD_Keywords">        
      <p><b><i>Keywords:</i></b></p>
      <blockquote>
        <xsl:for-each select="gmd:type">
          <p><b>Keyword Type: </b><xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_KeywordTypeCode">MD_KeywordTypeCode</a>)</p>
        </xsl:for-each>
        <!--
        Do unique sort method below instead to remove duplicates...
        <xsl:for-each select="gmd:keyword">
          <xsl:sort select="."/>
          <b>Keyword: </b><xsl:value-of select="."/><br/>
        </xsl:for-each>
        -->
        <xsl:for-each select="gmd:keyword[ count( . | key( 'values_by_id', translate( normalize-space( gco:CharacterString ), ',', '' ) )[ 1 ]) = 1 ]">
          <xsl:sort select="gco:CharacterString"/>
          <xsl:if test="gco:CharacterString != '&gt;'">
            <xsl:variable name="keyword">
              <xsl:call-template name="replace-string">
                <xsl:with-param name="element" select="gco:CharacterString"/>
                <xsl:with-param name="old-string">&gt;</xsl:with-param>
                <xsl:with-param name="new-string"><xsl:value-of select="$separator"/></xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <b>Keyword: </b><xsl:value-of select="$keyword" disable-output-escaping="yes"/><br/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:thesaurusName">
          <xsl:choose>
            <xsl:when test="string-length( . )">
              <p><b>Keyword Thesaurus:</b></p>
              <blockquote>
              <xsl:for-each select="gmd:CI_Citation">
                <xsl:call-template name="CI_Citation">
                  <xsl:with-param name="element" select="."/>
                  <xsl:with-param name="italicize-heading" select="false()"/>
                </xsl:call-template>
              </xsl:for-each>
              </blockquote>
            </xsl:when>
            <xsl:otherwise>
              <p><b>Keyword Thesaurus: </b><xsl:value-of select="@gco:nilReason"/></p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </blockquote>
    </xsl:for-each>    
    </font>
  </xsl:template>

  <xsl:template match="gmd:taxonomy">
    <h4>Taxonomy:</h4>
    <font color="#6e6e6e">
    <xsl:for-each select="gmd:MD_TaxonSys">
      <p><b><i>Taxonomic System:</i></b></p>
      <blockquote>
        <xsl:for-each select="gmd:classSys">
          <xsl:call-template name="CI_Citation">
            <xsl:with-param name="element" select="gmd:CI_Citation"/>
          </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="gmd:idref">
          <xsl:for-each select="gmd:RS_Identifier">
            <p><b>Identification Reference:</b></p>
            <xsl:for-each select="gmd:authority">
              <blockquote>
                <xsl:call-template name="CI_Citation">
                  <xsl:with-param name="element" select="gmd:CI_Citation"/>
                </xsl:call-template>
              </blockquote>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="gmd:obs">
          <p><b>Observer:</b></p>
          <blockquote>
            <xsl:call-template name="CI_ResponsibleParty">
              <xsl:with-param name="element" select="gmd:CI_ResponsibleParty"/>
            </xsl:call-template> 
          </blockquote>
        </xsl:for-each>
        <xsl:for-each select="gmd:taxonpro">
          <p><b>Taxonomic Procedures:</b></p>
          <p><xsl:value-of select="."/></p> 
        </xsl:for-each>
        <xsl:for-each select="gmd:taxoncom">
          <p><b>Taxonomic Completeness:</b></p>
          <p><xsl:value-of select="."/></p>
        </xsl:for-each>
        <xsl:for-each select="gmd:taxonCl">
          <p><b>Taxonomic Classification:</b></p>
          <xsl:apply-templates select="./gmd:MD_TaxonCl" />
        </xsl:for-each>
      </blockquote>
    </xsl:for-each>
    </font>
  </xsl:template>

  <xsl:template match="gmd:aggregationInfo">
    <h4>Aggregation Information:</h4>
    <xsl:for-each select="gmd:MD_AggregateInformation/gmd:aggregateDataSetName">
      <p><b><i>Aggregate Dataset Name:</i></b></p>
      <font color="#6e6e6e">
      <blockquote>
        <xsl:call-template name="CI_Citation">
          <xsl:with-param name="element" select="gmd:CI_Citation"/>
        </xsl:call-template>
      </blockquote>
      </font>
    </xsl:for-each>
    <xsl:for-each select="gmd:MD_AggregateInformation/gmd:aggregateDataSetIdentifier">
      <p><b><i>Aggregate Dataset Identifier:</i></b></p>
      <font color="#6e6e6e">
      <blockquote>
        <xsl:if test="gmd:MD_Identifier/gmd:code">
          <b>Code: </b><xsl:value-of select="gmd:MD_Identifier/gmd:code"/><br/>
        </xsl:if>
        <xsl:if test="gmd:MD_Identifier/gmd:authority">
          <b>Authority: </b><xsl:value-of select="gmd:MD_Identifier/gmd:authority/gmd:CI_Citation/gmd:title"/><br/>
        </xsl:if>
      </blockquote>
      </font>
    </xsl:for-each>
    <xsl:for-each select="gmd:MD_AggregateInformation/gmd:associationType">
      <p><b><i>Association Type: </i></b> <xsl:value-of select="gmd:DS_AssociationTypeCode"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#DS_AssociationTypeCode">DS_AssociationTypeCode</a>)</p>
    </xsl:for-each>
    <xsl:for-each select="gmd:MD_AggregateInformation/gmd:initiativeType">
      <p><b><i>Initiative Type: </i></b> <xsl:value-of select="gmd:DS_InitiativeTypeCode"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#DS_InitiativeTypeCode">DS_InitiativeTypeCode</a>)</p> 
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="gmd:resourceConstraints">
    <h4>Resource Constraints:</h4>
    <xsl:for-each select="gmd:MD_LegalConstraints">
      <p><b><i>Legal Constraints:</i></b></p>
      <blockquote>
        <xsl:for-each select="gmd:accessConstraints">
          <p><b>Access Constraints: </b><xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_RestrictionCode">MD_RestrictionCode</a>)</p>
        </xsl:for-each>
        <xsl:for-each select="gmd:useConstraints">
          <p><b>Use Constraints: </b><xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_RestrictionCode">MD_RestrictionCode</a>)</p>
        </xsl:for-each>
        <xsl:for-each select="gmd:otherConstraints">
          <p><b>Other Constraints:</b></p>
          <p><xsl:value-of select="."/></p>
        </xsl:for-each>
        <xsl:for-each select="gmd:useLimitation">
          <p><b>Use Limitation:</b></p>
          <p><xsl:value-of select="."/></p> 
        </xsl:for-each>
      </blockquote>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="gmd:extent">
    <h4>Extent Information:</h4>
    <font color="#6e6e6e">
    <xsl:for-each select="gmd:EX_Extent">
      <p><b><i>Spatial Temporal Extent:</i></b></p>
      <blockquote>
      <xsl:for-each select="gmd:geographicElement">
        <p><b>Geographic Element:</b></p>
        <blockquote>          
          <p><b>Bounding Coordinates:</b></p>
          <blockquote>
<!--
            <xsl:comment> Add Google Map here: </xsl:comment>
            <div id="map" style="width: 260px; height: 260px"></div>
-->
            <xsl:comment> Area to display current cursor lat/lon location: </xsl:comment>
            <div id="message" class="SmallTextGray">&#160;</div>
            <b>Westbound Longitude: </b>
            <xsl:call-template name="strip-digits">
              <xsl:with-param name="element" select="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/>
              <xsl:with-param name="num-digits" select="5"/>
            </xsl:call-template>&#176;<br/>
            <b>Eastbound Longitude: </b>
            <xsl:call-template name="strip-digits">
              <xsl:with-param name="element" select="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/>
              <xsl:with-param name="num-digits" select="5"/>
            </xsl:call-template>&#176;<br/>
            <b>Southbound Latitude: </b>
            <xsl:call-template name="strip-digits">
              <xsl:with-param name="element" select="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/>
              <xsl:with-param name="num-digits" select="5"/>
            </xsl:call-template>&#176;<br/>
            <b>Northbound Latitude: </b>
            <xsl:call-template name="strip-digits">
              <xsl:with-param name="element" select="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"/>
              <xsl:with-param name="num-digits" select="5"/>
            </xsl:call-template>&#176;<br/>
          </blockquote>        
        </blockquote>
      </xsl:for-each>
      <xsl:for-each select="gmd:temporalElement">
        <p><b>Temporal Element:</b></p>
        <blockquote>
          <p><b>Time Period:</b></p>
          <blockquote>
            <xsl:for-each select="gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:description">
              <b>Description: </b><xsl:value-of select="."/><br/>
            </xsl:for-each>
            <xsl:for-each select="gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition">
              <b>Begin Position: </b>
              <xsl:call-template name="date">
                <xsl:with-param name="element" select="."/>
              </xsl:call-template>
              <br/>
            </xsl:for-each>
            <xsl:for-each select="gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition">
              <b>End Position: </b>
              <xsl:call-template name="date">
                <xsl:with-param name="element" select="."/>
              </xsl:call-template>
              <br/>
            </xsl:for-each>
          </blockquote>
        </blockquote>    
      </xsl:for-each>
      <xsl:for-each select="gmd:verticalElement">
        <xsl:if test="gmd:EX_VerticalExtent/gmd:minimumValue != 0 or gmd:EX_VerticalExtent/gmd:maximumValue != 0">
          <p><b>Vertical Element:</b></p>
          <blockquote>
            <b>Minimum Value: </b>
            <xsl:call-template name="strip-digits">
              <xsl:with-param name="element" select="gmd:EX_VerticalExtent/gmd:minimumValue"/>
              <xsl:with-param name="num-digits" select="5"/>
            </xsl:call-template><br/>
            <b>Maximum Value: </b>
            <xsl:call-template name="strip-digits">
              <xsl:with-param name="element" select="gmd:EX_VerticalExtent/gmd:maximumValue"/>
              <xsl:with-param name="num-digits" select="5"/>
            </xsl:call-template><br/>
            <xsl:choose>
              <xsl:when test="string-length( gmd:EX_VerticalExtent/gmd:verticalCRS )">
                <b>Coordinate Reference System (CRS): </b><xsl:value-of select="gmd:EX_VerticalExtent/gmd:verticalCRS"/><br/>
              </xsl:when>
              <xsl:otherwise>
                <b>Coordinate Reference System (CRS): </b><xsl:value-of select="gmd:EX_VerticalExtent/gmd:verticalCRS/@gco:nilReason"/><br/>
              </xsl:otherwise>
            </xsl:choose>
          </blockquote>
        </xsl:if>
      </xsl:for-each>
      </blockquote>    
    </xsl:for-each>
    </font>
  </xsl:template>

  <xsl:template match="gmd:supplementalInformation">
    <h4>Supplemental Information:</h4>
    <p><xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="gmd:identificationInfo/srv:SV_ServiceIdentification">
    <p><b><i>Service Identification:</i></b></p>
    <font color="#6e6e6e">
    <blockquote>
      <p><b>Identifier: </b><xsl:value-of select="@id"/></p>
      <p><b>Service Type: </b><xsl:value-of select="srv:serviceType"/></p>
      <!--<p><b>Coupling Type: </b><xsl:value-of select="srv:couplingType/srv:SV_CouplingType"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#SV_CouplingType">SV_CouplingType</a>)</p>-->
      <xsl:for-each select="srv:containsOperations/srv:SV_OperationMetadata">
        <p><b>Contains Operation:</b></p>
        <blockquote>
          <p><b>Operation Name: </b><xsl:value-of select="srv:operationName"/></p>
          <xsl:call-template name="CI_OnlineResource">
            <xsl:with-param name="element" select="srv:connectPoint/gmd:CI_OnlineResource"/>
          </xsl:call-template>
        </blockquote>
      </xsl:for-each> 
    </blockquote>
    </font>
  </xsl:template>

  <!-- DATA_QUALITY_INFORMATION: ********************************************-->

  <xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality">
    <hr/>
    <h3><a name="Data_Quality_Information"></a>Data Quality Information:</h3>
    <xsl:apply-templates select="gmd:scope"/>
    <xsl:if test="string-length( gmd:report )">
      <h4>Reports:</h4>
      <xsl:apply-templates select="gmd:report"/>
    </xsl:if>
    <xsl:apply-templates select="gmd:lineage"/>
    <p><a href="javascript:void(0)" onClick="window.scrollTo( 0, 0 ); this.blur(); return false;">Back to Top</a></p>
  </xsl:template>

  <xsl:template match="gmd:scope">
    <xsl:if test="string-length( . )">
      <h4>Scope:</h4>
      <p><xsl:value-of select="."/></p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:report">
    <xsl:for-each select="gmd:DQ_CompletenessCommission">
      <p><b><i>Completeness Commission:</i></b></p>
      <blockquote>
        <p><b>Evaluation Method Description:</b></p>
        <p><xsl:value-of select="gmd:evaluationMethodDescription"/></p>
        <xsl:if test="string-length( gmd:result )">
          <p><b>Result:</b></p>
          <p><xsl:value-of select="gmd:result"/></p>
        </xsl:if>
      </blockquote>
    </xsl:for-each>
    <xsl:for-each select="gmd:DQ_CompletenessOmission">
      <p><b><i>Completeness Omission:</i></b></p>
      <blockquote>
        <p><b>Evaluation Method Description:</b></p>
        <p><xsl:value-of select="gmd:evaluationMethodDescription"/></p>
        <xsl:if test="string-length( gmd:result )">
          <p><b>Result:</b></p>
          <p><xsl:value-of select="gmd:result"/></p>
        </xsl:if>
      </blockquote>
    </xsl:for-each>
    <xsl:for-each select="gmd:DQ_ConceptualConsistency">
      <p><b><i>Conceptual Consistency:</i></b></p>
      <blockquote>
        <p><b>Measure Description:</b></p>
        <p><xsl:value-of select="gmd:measureDescription"/></p>
        <xsl:if test="string-length( gmd:result )">
          <p><b>Result:</b></p>
          <p><xsl:value-of select="gmd:result"/></p>
        </xsl:if>
      </blockquote>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="gmd:lineage">
    <xsl:for-each select="gmd:LI_Lineage">
      <h4>Lineage:</h4>
      <xsl:for-each select="gmd:processStep/gmd:LI_ProcessStep">
        <p><b><i>Process Step:</i></b></p>
        <p><xsl:value-of select="gmd:description"/></p>
        <blockquote>
          <xsl:for-each select="gmd:dateTime">
            <xsl:if test="string-length( . )">
              <p><b>Date And Time: </b><xsl:value-of select="."/></p>   
            </xsl:if>
          </xsl:for-each>
          <xsl:for-each select="gmd:rationale">
            <xsl:if test="string-length( . )">
              <p><b>Rationale:</b></p>
              <p><xsl:value-of select="."/></p>
            </xsl:if>
          </xsl:for-each>
        </blockquote>
      </xsl:for-each>
      <xsl:for-each select="gmd:statement">
        <p><b><i>Statement:</i></b></p>
        <p><xsl:value-of select="."/></p>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- SPATIAL_REPRESENTATION_INFORMATION: **********************************-->

  <xsl:template match="gmd:spatialRepresentationInfo/gmd:MD_GridSpatialRepresentation">
    <hr/>
    <h3><a name="Spatial_Representation_Information"></a>Spatial Representation Information:</h3>
    <xsl:apply-templates select="gmd:numberOfDimensions"/>
    <xsl:if test="string-length( gmd:axisDimensionProperties )">
      <h4>Axis Dimension Properties:</h4>
      <xsl:apply-templates select="gmd:axisDimensionProperties"/>
    </xsl:if>
    <xsl:apply-templates select="gmd:cellGeometry"/>
    <!-- Fill these in later when I have actual examples:
    <xsl:apply-templates select="gmd:transformationParameterAvailability"/>
    -->
    <p><a href="javascript:void(0)" onClick="window.scrollTo( 0, 0 ); this.blur(); return false;">Back to Top</a></p>
  </xsl:template>

  <xsl:template match="gmd:numberOfDimensions">
    <h4 style="display: inline">Number Of Dimensions:</h4>
    <p style="display: inline"><xsl:value-of select="."/></p>
    <p></p>
  </xsl:template>

  <xsl:template match="gmd:axisDimensionProperties">
    <xsl:for-each select="gmd:MD_Dimension">
      <p><b><i>Dimension:</i></b></p>
      <font color="#6e6e6e">
      <blockquote>
        <xsl:for-each select="gmd:dimensionName">
          <xsl:if test="string-length( . )">
            <b>Dimension Name: </b><xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_DimensionNameTypeCode">MD_DimensionNameTypeCode</a>)<br/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:dimensionSize">
          <xsl:if test="string-length( . )">
            <b>Dimension Size: </b><xsl:value-of select="."/><br/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:resolution">
          <xsl:if test="string-length( gco:Scale )">
            <b>Resolution: </b>
            <xsl:call-template name="strip-digits">
              <xsl:with-param name="element" select="gco:Scale"/>
              <xsl:with-param name="num-digits" select="5"/>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="gco:Scale/@uom = 'decimalDegrees'">
                <xsl:text>&#176;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> </xsl:text><xsl:value-of select="gco:Scale/@uom"/>
              </xsl:otherwise>
            </xsl:choose>
            <br/> 
          </xsl:if>
          <xsl:if test="string-length( gco:Measure )">
            <xsl:variable name="measure">
              <xsl:call-template name="strip-digits">
                <xsl:with-param name="element" select="gco:Measure"/>
                <xsl:with-param name="num-digits" select="5"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="gco:Measure/@uom = '1'">
                <b>Resolution: </b><xsl:value-of select="$measure"/>
              </xsl:when>
              <xsl:otherwise>
                <b>Resolution: </b><xsl:value-of select="$measure"/><xsl:text> </xsl:text><xsl:value-of select="gco:Measure/@uom"/><br/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>          
        </xsl:for-each>
      </blockquote>
      </font>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="gmd:cellGeometry">
    <h4 style="display: inline">Cell Geometry:</h4>
    <p style="display: inline"><xsl:value-of select="gmd:MD_CellGeometryCode"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_CellGeometryCode">MD_CellGeometryCode</a>)</p>
    <p></p> 
  </xsl:template>

  <xsl:template match="gmd:transformationParameterAvailability">
    <h4>Transformation Parameter Availability:</h4>
  </xsl:template>

  <!-- CONTENT_INFORMATION: *************************************************-->

  <xsl:template match="gmd:contentInfo">
    <hr/>
    <h3><a name="Content_Information"></a>Content Information:</h3>
    <xsl:apply-templates select="gmi:MI_CoverageDescription"/>
    <xsl:apply-templates select="gmd:MD_FeatureCatalogueDescription"/>
    <p><a href="javascript:void(0)" onClick="window.scrollTo( 0, 0 ); this.blur(); return false;">Back to Top</a></p>
  </xsl:template>

  <xsl:template match="gmi:MI_CoverageDescription">
    <h4>Coverage Description:</h4>
    <xsl:apply-templates select="gmd:attributeDescription"/>
    <xsl:apply-templates select="gmd:contentType"/>
    <xsl:if test="string-length( gmd:dimension )">
      <p><b><i>Dimensions:</i></b></p>
      <ul>
        <xsl:for-each select="gmd:dimension">
          <xsl:sort select="gmd:MD_Band/gmd:sequenceIdentifier/gco:MemberName/gco:aName"/>
          <li><a href="#{gmd:MD_Band/gmd:sequenceIdentifier/gco:MemberName/gco:aName/gco:CharacterString}"><xsl:value-of select="gmd:MD_Band/gmd:sequenceIdentifier/gco:MemberName/gco:aName"/></a></li>
        </xsl:for-each>
      </ul>
    </xsl:if>
    <xsl:apply-templates select="gmd:dimension"/>
    <xsl:apply-templates select="gmi:rangeElementDescription"/>
  </xsl:template>

  <xsl:template match="gmd:attributeDescription">
    <xsl:if test="string-length( . )">
      <p><b><i>Attribute Description:</i></b></p>
      <p><xsl:value-of select="."/></p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:contentType">
    <xsl:if test="string-length( . )">
      <p><b><i>Content Type: </i></b><xsl:value-of select="gmd:MD_CoverageContentTypeCode"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_CoverageContentTypeCode">MD_CoverageContentTypeCode</a>)</p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:dimension">
    <xsl:if test="string-length( . )">
      <p><a name="{gmd:MD_Band/gmd:sequenceIdentifier/gco:MemberName/gco:aName/gco:CharacterString}"></a><b><i>Dimension: </i></b></p>
      <blockquote>
        <font color="#6e6e6e">
        <xsl:apply-templates select="gmd:MD_Band"/> 
        </font>
      </blockquote>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:MD_Band">
    <xsl:if test="string-length( . )">
      <xsl:apply-templates select="gmd:sequenceIdentifier"/>
      <xsl:apply-templates select="gmd:units"/>
      <xsl:if test="string-length( gmd:descriptor )">
        <b>Descriptor:</b><br/>
        <p><xsl:value-of select="gmd:descriptor"/></p>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:sequenceIdentifier">
    <xsl:apply-templates select="gco:MemberName"/>
  </xsl:template>

  <xsl:template match="gco:MemberName">
    <xsl:if test="string-length( gco:aName )">
      <b>Attribute Name: </b><xsl:value-of select="gco:aName"/><br/>
    </xsl:if>
    <xsl:apply-templates select="gco:attributeType"/>
  </xsl:template>

  <xsl:template match="gco:attributeType">
    <xsl:if test="string-length( gco:TypeName/gco:aName )">
      <b>Attribute Type: </b><xsl:value-of select="gco:TypeName/gco:aName"/><br/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:units">
    <xsl:choose>
      <xsl:when test="string-length( . )">
        <b>Units: </b><xsl:value-of select="."/><br/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="unitsUrl">
          <xsl:choose>
            <xsl:when test="contains( @xlink:href, 'someUnitsDictionary')">
              <xsl:value-of select="substring-after( @xlink:href, '#' )"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@xlink:href"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains( $unitsUrl, 'http' )">
            <b>Units: </b><a href="{$unitsUrl}"><xsl:value-of select="$unitsUrl"/></a><br/>
          </xsl:when>
          <xsl:otherwise>
            <b>Units: </b><xsl:value-of select="$unitsUrl"/><br/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gmi:rangeElementDescription">
    <xsl:if test="string-length( . )">
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:MD_FeatureCatalogueDescription">
    <h4>Feature Catalogue Description:</h4>
    <xsl:for-each select="gmd:includedWithDataset">
      <p>
        <b><i>Included With Dataset?: </i></b>
        <xsl:choose>
          <xsl:when test=".">
            <xsl:text>Yes</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>No</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </p> 
    </xsl:for-each>
    <xsl:for-each select="gmd:featureTypes">
      <p><b><i>Feature Types: </i></b><xsl:value-of select="gco:LocalName/@codeSpace"/></p>
    </xsl:for-each>
    <xsl:for-each select="gmd:featureCatalogueCitation">
      <p>
        <b><i>Feature Catalogue Citation: </i></b>
        <xsl:choose>
          <xsl:when test="string-length( gmd:CI_Citation )">
            <xsl:call-template name="CI_Citation">
              <xsl:with-param name="element" select="gmd:CI_Citation"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@gco:nilReason"/>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </xsl:for-each>
  </xsl:template>

  <!-- DISTRIBUTION_INFORMATION: ********************************************-->
 
  <xsl:template match="gmd:distributionInfo/gmd:MD_Distribution">
    <hr/>
    <h3><a name="Distribution_Information"></a>Distribution Information:</h3>
    <xsl:apply-templates select="gmd:distributor"/>
    <xsl:apply-templates select="gmd:distributionFormat"/>
    <xsl:apply-templates select="gmd:transferOptions"/>
    <p><a href="javascript:void(0)" onClick="window.scrollTo( 0, 0 ); this.blur(); return false;">Back to Top</a></p>
  </xsl:template>

  <xsl:template match="gmd:distributor">
    <h4>Distributor:</h4>
    <font color="#6e6e6e">
    <xsl:for-each select="gmd:MD_Distributor/gmd:distributorContact">
      <p><b><i>Distributor Contact:</i></b></p>
      <blockquote>
      <xsl:call-template name="CI_ResponsibleParty">
        <xsl:with-param name="element" select="gmd:CI_ResponsibleParty"/>          
        <xsl:with-param name="italicize-heading" select="false()"/>  
      </xsl:call-template> 
      </blockquote>
    </xsl:for-each>
    <xsl:for-each select="gmd:MD_Distributor/gmd:distributionOrderProcess">
      <p><b><i>Distribution Order Process:</i></b></p>
      <blockquote>
        <xsl:for-each select="gmd:MD_StandardOrderProcess">
          <p><b>Standard Order Process:</b></p>
          <blockquote>
            <xsl:for-each select="gmd:fees">
              <p><b>Fees: </b><xsl:value-of select="."/></p>
            </xsl:for-each>
          </blockquote> 
        </xsl:for-each>
      </blockquote>
    </xsl:for-each>
    <xsl:if test="string-length( gmd:MD_Distributor/gmd:distributorFormat )">
      <p><b><i>Distributor Formats:</i></b></p>
      <blockquote>
        <xsl:apply-templates select="gmd:MD_Distributor/gmd:distributorFormat"/>
      </blockquote>
    </xsl:if>
    <xsl:if test="string-length( gmd:MD_Distributor/gmd:distributorTransferOptions )">
      <p><b><i>Distributor Transfer Options:</i></b></p>
      <xsl:apply-templates select="gmd:MD_Distributor/gmd:distributorTransferOptions"/>
    </xsl:if>
    </font>
  </xsl:template>

  <xsl:template match="gmd:distributorFormat">
    <b>Name: </b><xsl:value-of select="gmd:MD_Format/gmd:name"/><br/>
    <xsl:choose>
      <xsl:when test="string-length( gmd:MD_Format/gmd:version )">
        <b>Version: </b><xsl:value-of select="gmd:MD_Format/gmd:version"/><br/>
      </xsl:when>
      <xsl:otherwise>
        <b>Version: </b><xsl:value-of select="gmd:MD_Format/gmd:version/@gco:nilReason"/><br/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gmd:distributorTransferOptions">
    <xsl:call-template name="CI_OnlineResource">
      <xsl:with-param name="element" select="gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="gmd:distributionFormat">
    <h4>Distribution Format:</h4>
    <font color="#6e6e6e">
    <xsl:for-each select="gmd:MD_Format">        
      <p><b><i>Data File Format:</i></b></p>
      <blockquote>            
        <xsl:if test="string-length( gmd:name )">
          <b>Name: </b><xsl:value-of select="gmd:name"/><br/>
        </xsl:if>
        <xsl:if test="string-length( gmd:version )">
          <b>Version: </b><xsl:value-of select="gmd:version"/><br/>
        </xsl:if>
        <xsl:if test="string-length( gmd:specification )">
          <b>Specification: </b><xsl:value-of select="gmd:specification"/><br/>
        </xsl:if>
      </blockquote>
    </xsl:for-each>
    </font>
  </xsl:template>
  
  <xsl:template match="gmd:transferOptions">
    <h4>Digital Transfer Options:</h4>                  
    <xsl:for-each select="gmd:MD_DigitalTransferOptions">
      <xsl:for-each select="gmd:transferSize">
        <p><b><i>Transfer Size:</i></b> <xsl:value-of select="."/> MB</p>
      </xsl:for-each>
      <xsl:if test="gmd:onLine">
        <p><b><i>Online Transfer Options:</i></b></p>
      </xsl:if>
      <xsl:for-each select="gmd:onLine">
        <blockquote>
          <p><b>Online Resource:</b></p>
          <blockquote>
            <xsl:for-each select="gmd:CI_OnlineResource">
              <xsl:call-template name="CI_OnlineResource">
                <xsl:with-param name="element" select="."/>
              </xsl:call-template> 
            </xsl:for-each>
          </blockquote>
        </blockquote>
      </xsl:for-each>
      <xsl:if test="gmd:offLine">
        <p><b><i>Offline Transfer Options:</i></b></p>
      </xsl:if>
      <xsl:for-each select="gmd:offLine">
        <blockquote>
          <p><b>Offline Resource:</b></p>
          <blockquote>
            <xsl:for-each select="gmd:MD_Medium">        
              <p>
                <xsl:if test="string-length( gmd:name )">
                  <b>Name: </b><xsl:value-of select="gmd:name"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_MediumNameCode">MD_MediumNameCode</a>)<br/>
                </xsl:if>
                <xsl:apply-templates select="name"/>          
                <xsl:if test="string-length( gmd:density )">
                  <b>Density: </b><xsl:value-of select="gmd:density"/><br/>
                </xsl:if>
                <xsl:if test="string-length( gmd:densityUnits )">
                  <b>Density Units: </b><xsl:value-of select="gmd:densityUnits"/><br/>
                </xsl:if>
                <xsl:if test="string-length( gmd:mediumName )">
                  <b>Medium Name: </b><xsl:value-of select="gmd:mediumName"/><br/>
                </xsl:if>          
                <xsl:if test="string-length( gmd:mediumFormat )">
                  <b>Medium Format: </b><xsl:value-of select="gmd:mediumFormat"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#MD_MediumFormatCode">MD_MediumFormatCode</a>)<br/>
                </xsl:if>
              </p>
            </xsl:for-each>
          </blockquote>
        </blockquote>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- ACQUISITION_INFORMATION: *********************************************-->

  <xsl:template match="gmd:acquisitionInformation/gmi:MI_AcquisitionInformation">
    <hr/> 
    <h3><a name="Acquisition_Information"></a>Acquisition Information:</h3>
    <xsl:apply-templates select="gmd:instrument"/>
    <xsl:apply-templates select="gmd:platform"/>
    <p><a href="javascript:void(0)" onClick="window.scrollTo( 0, 0 ); this.blur(); return false;">Back to Top</a></p>
  </xsl:template>

  <xsl:template match="gmd:instrument">
    <h4>Instrument Information:</h4>    
    <font color="#6e6e6e">
    <xsl:for-each select="gmd:MI_Instrument">
      <p><b><i>Instrument:</i></b></p>
      <blockquote>
        <xsl:for-each select="gmd:identifier">
          <b>Identifier: </b><xsl:value-of select="."/><br/>
        </xsl:for-each>
        <xsl:for-each select="gmd:type">
          <b>Type: </b><xsl:value-of select="."/><br/>
        </xsl:for-each>
      </blockquote>
    </xsl:for-each>
    </font>
  </xsl:template>
   
  <xsl:template match="gmd:platform"> 
    <h4>Platform Information:</h4>
    <font color="#6e6e6e">
    <xsl:for-each select="gmd:MI_Platform">
      <p><b><i>Platform:</i></b></p>
      <blockquote>
        <xsl:for-each select="gmd:identifier">
          <b>Identifier: </b><xsl:value-of select="."/><br/>
        </xsl:for-each>
        <xsl:for-each select="gmd:description">
          <b>Description: </b><xsl:value-of select="."/><br/>
        </xsl:for-each>
        <xsl:for-each select="gmd:instrument">
          <b>Instrument: </b><xsl:value-of select="."/><br/>
        </xsl:for-each>
      </blockquote>
    </xsl:for-each>    
    </font>
  </xsl:template>

  <!-- NAMED TEMPLATES: *****************************************************-->

  <!-- template: CI_Citation ************************************************-->

  <xsl:template name="CI_Citation">
    <xsl:param name="element"/>
    <xsl:param name="italicize-heading"/>    
    <xsl:param name="wrap-text"/>
    <xsl:choose>
      <xsl:when test="$italicize-heading">
        <p><b><i>Citation Information:</i></b></p>
      </xsl:when>
      <xsl:otherwise>
        <p><b>Citation Information:</b></p>
      </xsl:otherwise>
    </xsl:choose>
    <blockquote>    
      <xsl:for-each select="$element/gmd:title">
        <xsl:choose>
          <xsl:when test="$wrap-text">
            <div style="margin-right: 185px;"><b>Title: </b><xsl:value-of select="."/></div>
          </xsl:when>
          <xsl:otherwise>
            <b>Title: </b><xsl:value-of select="."/><br/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:alternateTitle">
        <b>Alternate Title: </b><xsl:value-of select="."/><br/>
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:date">
        <xsl:call-template name="CI_Date">
          <xsl:with-param name="element" select="./gmd:CI_Date"/>          
        </xsl:call-template>        
      </xsl:for-each>      
      <xsl:for-each select="$element/gmd:edition">
        <b>Edition: </b><xsl:value-of select="."/><br/>        
      </xsl:for-each>      
      <xsl:for-each select="$element/gmd:editionDate">
        <b>Edition Date: </b>
        <xsl:call-template name="date">
          <xsl:with-param name="element" select="."/>
        </xsl:call-template>
        <br/>
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:identifier">
        <b>Identifier:</b><br/>
        <blockquote>
          <xsl:if test="gmd:MD_Identifier/gmd:code">
            <b>Code: </b><xsl:value-of select="gmd:MD_Identifier/gmd:code"/><br/>
          </xsl:if>
          <xsl:if test="gmd:MD_Identifier/gmd:authority">
            <b>Authority: </b><xsl:value-of select="gmd:MD_Identifier/gmd:authority"/><br/>
          </xsl:if>
        </blockquote>
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty">
        <xsl:call-template name="CI_ResponsibleParty">
          <xsl:with-param name="element" select="."/>
          <xsl:with-param name="italicize-heading" select="false()"/>          
        </xsl:call-template>        
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:presentationForm">        
        <b>Presentation Form: </b> <xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#CI_PresentationFormCode" target="_blank">CI_PresentationFormCode</a>)<br/>
      </xsl:for-each>      
      <xsl:for-each select="$element/gmd:series">        
        <b>Series: </b><xsl:value-of select="."/><br/> 
      </xsl:for-each>      
      <xsl:for-each select="$element/gmd:otherCitationDetails">
        <b>Other Citation Details: </b><xsl:value-of select="."/><br/>        
      </xsl:for-each>
    </blockquote>
  </xsl:template>

  <!-- template: CI_Date ****************************************************-->

  <xsl:template name="CI_Date">
    <xsl:param name="element"/>
    <xsl:if test="string-length( $element/gmd:date ) and $element/gmd:dateType/gmd:CI_DateTypeCode != 'issued' and $element/gmd:dateType/gmd:CI_DateTypeCode != 'revision'">
      <p><b>Date:</b></p>
      <blockquote>
        <b>Date: </b>
        <xsl:call-template name="date">
          <xsl:with-param name="element" select="$element/gmd:date/gco:Date"/>
        </xsl:call-template>
        <br/>
        <xsl:if test="string-length( $element/gmd:dateType/gmd:CI_DateTypeCode )">
          <b>Date Type: </b><xsl:value-of select="$element/gmd:dateType"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#CI_DateTypeCode">CI_DateTypeCode</a>)<br/>
        </xsl:if>
      </blockquote>
    </xsl:if>
  </xsl:template>

  <!-- template: CI_ResponsibleParty ****************************************-->

  <xsl:template name="CI_ResponsibleParty">
    <xsl:param name="element"/>
    <xsl:param name="italicize-heading"/>        
    <xsl:choose>
      <xsl:when test="$italicize-heading">
        <p><b><i>Responsible Party:</i></b></p>
      </xsl:when>
      <xsl:otherwise>
        <p><b>Responsible Party:</b></p>
      </xsl:otherwise>
    </xsl:choose>
    <blockquote>
      <div style="color: #6e6e6e">
      <xsl:for-each select="$element/gmd:individualName">
        <b>Individual Name: </b><xsl:value-of select="."/><br/>
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:organisationName">
        <xsl:if test="string-length( . )">
          <b>Organization Name: </b><xsl:value-of select="$element/gmd:organisationName"/><br/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:positionName">
        <xsl:if test=". != 'none'">
          <b>Position Name: </b><xsl:value-of select="."/><br/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:contactInfo/gmd:CI_Contact">
        <xsl:if test="string-length( . )">
          <xsl:call-template name="CI_Contact">
            <xsl:with-param name="element" select="."/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$element/gmd:role">
        <xsl:if test="string-length( ./gmd:CI_RoleCode )">
          <b>Contact Role: </b><xsl:value-of select="."/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#CI_RoleCode" target="_blank">CI_RoleCode</a>)<br/>
        </xsl:if>
      </xsl:for-each>
      </div>
    </blockquote>
  </xsl:template>

  <!-- template: CI_Contact *************************************************-->

  <xsl:template name="CI_Contact">
    <xsl:param name="element"/> 
    <b>Contact: </b>
    <xsl:for-each select="$element/gmd:phone/gmd:CI_Telephone">
      <xsl:call-template name="CI_Telephone">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="$element/gmd:address/gmd:CI_Address">
      <xsl:call-template name="CI_Address">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="$element/gmd:onlineResource/gmd:CI_OnlineResource">
      <xsl:call-template name="CI_OnlineResource">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- template: CI_Telephone ***********************************************-->

  <xsl:template name="CI_Telephone">
    <xsl:param name="element"/>
    <blockquote>
      <p><b>Contact Phone: </b></p>
      <blockquote>
        <xsl:for-each select="$element/gmd:voice">
          <xsl:if test="string-length( . )">
            <b>Contact Voice Telephone: </b><xsl:value-of select="."/><br/>
          </xsl:if>        
        </xsl:for-each>        
        <xsl:for-each select="$element/gmd:facsimile">
          <xsl:if test="string-length( . )">
            <b>Contact Facsimile Telephone: </b><xsl:value-of select="."/><br/>
          </xsl:if>        
        </xsl:for-each>       
      </blockquote>    
    </blockquote>
  </xsl:template>

  <!-- template: CI_Address *************************************************-->

  <xsl:template name="CI_Address">
    <xsl:param name="element"/>
    <blockquote>
      <p><b>Contact Address: </b></p>
      <blockquote>
        <xsl:if test="string-length( $element/gmd:deliveryPoint )">
          <b>Delivery Point: </b><xsl:value-of select="$element/gmd:deliveryPoint"/><br/>
        </xsl:if>
        <xsl:if test="string-length( $element/gmd:city )">
          <b>City: </b><xsl:value-of select="$element/gmd:city"/><br/>
        </xsl:if>
        <xsl:if test="string-length( $element/gmd:administrativeArea )">
          <b>Administrative Area: </b><xsl:value-of select="$element/gmd:administrativeArea"/><br/>
        </xsl:if>
        <xsl:if test="string-length( $element/gmd:postalCode )">
          <b>Postal Code: </b><xsl:value-of select="$element/gmd:postalCode"/><br/>
        </xsl:if>
        <xsl:if test="string-length( $element/gmd:country )">
          <b>Country: </b><xsl:value-of select="$element/gmd:country"/><br/>
        </xsl:if>
        <xsl:if test="string-length( $element/gmd:electronicMailAddress )">
          <b>Email: </b><a href="mailto:{$element/gmd:electronicMailAddress/gco:CharacterString}"><xsl:value-of select="$element/gmd:electronicMailAddress"/></a><br/>        
        </xsl:if>
      </blockquote>
    </blockquote>    
  </xsl:template>

  <!-- template: CI_OnlineResource ******************************************-->

  <xsl:template name="CI_OnlineResource">
    <xsl:param name="element"/>
    <xsl:if test="string-length( $element/gmd:linkage )">
      <blockquote>
        <p><b>Online Resource:</b></p>
        <blockquote>
          <xsl:choose>
            <xsl:when test="$element/gmd:linkage != 'Unknown'">
              <xsl:variable name="url">
                <!-- Replace PacIOOS internal URL with external proxy: -->
                <xsl:call-template name="replace-string">
                  <xsl:with-param name="element" select="$element/gmd:linkage/gmd:URL"/>
                  <xsl:with-param name="old-string">lawelawe.soest.hawaii.edu:8080</xsl:with-param>
                  <xsl:with-param name="new-string">oos.soest.hawaii.edu</xsl:with-param>
                </xsl:call-template>
              </xsl:variable>
              <span style="float: left; margin-right: 4px;"><b>Linkage: </b></span><a href="{$url}"><div class="wrapline"><xsl:value-of select="$url"/></div></a>
            </xsl:when>
            <xsl:otherwise>
              <b>Linkage: </b><xsl:value-of select="$element/gmd:linkage"/><br/>
            </xsl:otherwise>        
          </xsl:choose>     
          <xsl:if test="string-length( $element/gmd:description/gco:CharacterString )">
            <b>Description: </b><xsl:value-of select="$element/gmd:description"/><br/>
          </xsl:if>
          <xsl:if test="string-length( $element/gmd:function )">
            <xsl:variable name="codeList" select="substring-after( $element/gmd:function/gmd:CI_OnLineFunctionCode/@codeList, '#' )"/>
            <xsl:variable name="codeListShortName">
              <xsl:choose>
                <xsl:when test="contains( $codeList, ':' )">
                  <xsl:value-of select="substring-after( $codeList, ':' )"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$codeList"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <b>Function: </b><xsl:value-of select="$element/gmd:function"/> (<a href="http://pacioos.org/metadata/gmxCodelists.html#{$codeListShortName}"><xsl:value-of select="$codeListShortName"/></a>)<br/>
          </xsl:if> 
        </blockquote>
      </blockquote>    
    </xsl:if>
  </xsl:template>

  <!-- template: MD_TaxonCl (recursive) *************************************-->

  <xsl:template match="gmd:taxonCl/gmd:MD_TaxonCl">
    <div style="margin-left: 15px;">
      <xsl:choose>
        <xsl:when test="string-length( gmd:taxonrv )"> 
          <b><xsl:value-of select="gmd:taxonrn/gco:CharacterString"/>: </b><xsl:value-of select="gmd:taxonrv"/>
        </xsl:when>
        <xsl:otherwise>
          <b><xsl:value-of select="gmd:taxonrn/gco:CharacterString"/>: </b><xsl:value-of select="gmd:taxonrv/@gco:nilReason"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="gmd:common">
        <div style="margin-left: 15px;"><b>Common Name: </b><xsl:value-of select="." /></div>
      </xsl:for-each>
      <xsl:apply-templates select="gmd:taxonCl/gmd:MD_TaxonCl" />
    </div>  
  </xsl:template>

  <!-- template: date *******************************************************-->

  <xsl:template name="date">
    <xsl:param name="element"/>
    <xsl:choose>
      <xsl:when test="contains( $element, 'known' )">
        <xsl:value-of select="$element"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="year" select="substring($element, 1, 4)"/>
        <xsl:variable name="month" select="substring($element, 6, 2)"/>
        <xsl:variable name="day" select="substring($element, 9, 2)"/>
        <xsl:if test="$month = '01'">
          <xsl:text>January </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '02'">
          <xsl:text>February </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '03'">
          <xsl:text>March </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '04'">
          <xsl:text>April </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '05'">
          <xsl:text>May </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '06'">
          <xsl:text>June </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '07'">
          <xsl:text>July </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '08'">
          <xsl:text>August </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '09'">
          <xsl:text>September </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '10'">
          <xsl:text>October </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '11'">
          <xsl:text>November </xsl:text>
        </xsl:if>
        <xsl:if test="$month = '12'">
          <xsl:text>December </xsl:text>
        </xsl:if>
        <xsl:if test="string-length( $day )">
          <xsl:choose>
            <xsl:when test="$day = '01'">
              <xsl:variable name="daydisplay" select="'1'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="$day = '02'">
              <xsl:variable name="daydisplay" select="'2'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="$day = '03'">
              <xsl:variable name="daydisplay" select="'3'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="$day = '04'">
              <xsl:variable name="daydisplay" select="'4'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="$day = '05'">
              <xsl:variable name="daydisplay" select="'5'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="$day = '06'">
              <xsl:variable name="daydisplay" select="'6'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="$day = '07'">
              <xsl:variable name="daydisplay" select="'7'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="$day = '08'">
              <xsl:variable name="daydisplay" select="'8'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="$day = '09'">
              <xsl:variable name="daydisplay" select="'9'"/>
              <xsl:value-of select="$daydisplay"/><xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$day"/><xsl:text>, </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:value-of select="$year"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
