<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="/Files">
    <CIM CIMVERSION="2.0" DTDVERSION="2.0">
      <MESSAGE ID="4711" PROTOCOLVERSION="1.0">
        <SIMPLEREQ>
          <xsl:for-each select="FileDetails">
            <VALUE.NAMEDINSTANCE>
              <INSTANCENAME CLASSNAME="DCIM_RepoUpdateSWID">
                <PROPERTY NAME="Criticality" TYPE="string">
                  <VALUE>
                    <xsl:value-of select="@Criticality"/>
                  </VALUE>
                </PROPERTY>
                <PROPERTY NAME="DisplayName" TYPE="string">
                  <VALUE>
                    <xsl:value-of select="@displayName"/>
                  </VALUE>
                </PROPERTY>
                <PROPERTY NAME="BaseLocation" TYPE="string">
                  <VALUE>
                    <xsl:value-of select="@BaseLocation"/>
                  </VALUE>
                </PROPERTY>
                <PROPERTY NAME="PackagePath" TYPE="string">
                  <VALUE>
                    <xsl:value-of select="@path"/>
                  </VALUE>
                </PROPERTY>
                <PROPERTY NAME="PackageName" TYPE="string">
                  <VALUE>
                    <xsl:value-of select="@name"/>
                  </VALUE>
                </PROPERTY>
                <PROPERTY NAME="PackageVersion" TYPE="string">
                  <VALUE>
                    <xsl:value-of select="@packageVersion"/>
                  </VALUE>
                </PROPERTY>
                <PROPERTY NAME="RebootType" TYPE="string">
                  <VALUE>
                    <xsl:value-of select="@RebootType"/>
                  </VALUE>
                </PROPERTY>
                <PROPERTY NAME="JobID" TYPE="string">
                  <VALUE>
                    <xsl:value-of select="@JobID"/>
                  </VALUE>
                </PROPERTY>
                <xsl:apply-templates select="node()">
                </xsl:apply-templates>
              </INSTANCENAME>
            </VALUE.NAMEDINSTANCE>
          </xsl:for-each>
        </SIMPLEREQ>
      </MESSAGE>
    </CIM>
  </xsl:template>
  <xsl:template match="Device">
    <PROPERTY NAME="Target" TYPE="string">
      <VALUE>
        <xsl:value-of select="@target"/>
      </VALUE>
    </PROPERTY>
    <PROPERTY NAME="ComponentID" TYPE="string">
      <VALUE>
        <xsl:value-of select="@ComponentID"/>
      </VALUE>
    </PROPERTY>
    <PROPERTY NAME="ComponentType" TYPE="string">
      <VALUE>
        <xsl:value-of select="@ComponentType"/>
      </VALUE>
    </PROPERTY>
    <PROPERTY.ARRAY NAME="ComponentInfoValue" TYPE="string">
      <VALUE.ARRAY>
        <xsl:for-each select="Component">
          <xsl:choose>
            <xsl:when test="@vendorID and @deviceID and @subVendorID and @subDeviceID">
              <VALUE>
                <xsl:value-of select="@vendorID"/>:<xsl:value-of select="@deviceID"/>:<xsl:value-of select="@subVendorID"/>:<xsl:value-of select="@subDeviceID"/>
              </VALUE>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </VALUE.ARRAY>
    </PROPERTY.ARRAY>
    <PROPERTY.ARRAY NAME="ComponentInfoName" TYPE="string">
      <VALUE.ARRAY>
        <xsl:for-each select="Component">
          <xsl:choose>
            <xsl:when test="@vendorID and @deviceID and @subVendorID and @subDeviceID">
              <VALUE>VendorID:DeviceID:SubVendorID:SubDeviceID</VALUE>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </VALUE.ARRAY>
    </PROPERTY.ARRAY>

    <PROPERTY.ARRAY NAME="ComponentInfoTarget" TYPE="string">
      <VALUE.ARRAY>
        <xsl:for-each select="Component">
          <xsl:choose>
            <xsl:when test="@target">
              <VALUE>
                <xsl:value-of select="@target"/>
              </VALUE>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </VALUE.ARRAY>
    </PROPERTY.ARRAY>
    <PROPERTY.ARRAY NAME="ComponentInstalledVersion" TYPE="string">
      <VALUE.ARRAY>
        <xsl:for-each select="Component">
          <xsl:choose>
            <xsl:when test="@version">
              <VALUE>
                <xsl:value-of select="@version"/>
              </VALUE>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </VALUE.ARRAY>
    </PROPERTY.ARRAY>
  </xsl:template>
</xsl:stylesheet>
