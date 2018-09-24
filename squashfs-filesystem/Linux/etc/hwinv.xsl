<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:output method="xml" indent="yes"/>
  <xsl:key name="vis_by_class" match="CIM/MESSAGE/SIMPLEREQ/VALUE.NAMEDINSTANCE" use="INSTANCENAME/@CLASSNAME" />
  <xsl:template match="/">
    <xsl:apply-templates select="CIM" />
  </xsl:template>
  <xsl:template match="CIM">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="MESSAGE" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="MESSAGE">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="SIMPLEREQ" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="SIMPLEREQ">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="vDigits" select="'0123456789 '"/>
      <xsl:variable name="vAlpha" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ '"/>
      <xsl:for-each select="VALUE.NAMEDINSTANCE[count(. | key('vis_by_class',INSTANCENAME/@CLASSNAME)[1]) = 1]">
        <xsl:sort select ="./INSTANCENAME/@CLASSNAME"/>


        <xsl:for-each select="key('vis_by_class',INSTANCENAME/@CLASSNAME)">
          <xsl:sort select="INSTANCENAME/KEYBINDING/FORMATTED.KEYVALUE" />
          
          
          <xsl:apply-templates select="."/>
          <!--<xsl:copy-of select="."/>-->
        </xsl:for-each>
      </xsl:for-each>
      
    </xsl:copy>
  </xsl:template>
  <xsl:template match="//FORMATTED.KEYVALUE">
    
  </xsl:template>
          
        
          
        

  <xsl:template match="VALUE.NAMEDINSTANCE">
    <VALUE.NAMEDINSTANCE>
      <xsl:apply-templates select="INSTANCENAME"/>
      <xsl:for-each select="INSTANCE">
        <INSTANCE>
          <xsl:attribute name="CLASSNAME">
            <xsl:value-of select="@CLASSNAME"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@CLASSNAME = 'DCIM_FanView'">
              <xsl:call-template name="Fan"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_PowerSupplyView'">
              <xsl:call-template name="PowerSupply"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_iDRACCardView'">
              <xsl:call-template name="iDRACCard"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_CPUView'">
              <xsl:call-template name="CPU"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_SystemView'">
              <xsl:call-template name="SystemInfo"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_MemoryView'">
              <xsl:call-template name="Memory"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_PCIDeviceView'">
              <xsl:call-template name="PCIDevice"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_VideoView'">
              <xsl:call-template name="Video"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_VirtualDiskView'">
              <xsl:call-template name="VirtualDisk"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_ControllerView'">
              <xsl:call-template name="Controller"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_EnclosureView'">
              <xsl:call-template name="Enclosure"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_PhysicalDiskView'">
              <xsl:call-template name="PhysicalDisk"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_NICView'">
              <xsl:call-template name="NIC"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_FCView'">
              <xsl:call-template name="FC"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_VFlashView'">
              <xsl:call-template name="VFlash"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_ControllerBatteryView'">
              <xsl:call-template name="ControllerBattery"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_EnclosureEMMView'">
              <xsl:call-template name="EnclosureEMM"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_EnclosurePSUView'">
              <xsl:call-template name="EnclosurePSU"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_USBDeviceView'">
              <xsl:call-template name="USBDevice"/>
            </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_HostNetworkInterfaceView'">
              <xsl:call-template name="HostNetworkInterface"/>
             </xsl:when>
             <xsl:when test="@CLASSNAME = 'DCIM_PCIeSSDView'">
             <xsl:call-template name="PCIeSSD"/>
             </xsl:when>
             <xsl:when test="@CLASSNAME = 'DCIM_PCIeSSDExtenderView'">
             <xsl:call-template name="PCIeSSDExtender"/>
             </xsl:when>
	     <xsl:when test="@CLASSNAME = 'DCIM_PCIeSSDBackPlaneView'">
             <xsl:call-template name="PCIeSSDBackPlane"/>
             </xsl:when>
            <xsl:when test="@CLASSNAME = 'DCIM_SystemQuickSyncView'">
              <xsl:call-template name="SystemQuickSync"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="*"/>
              <!--
              <xsl:for-each select="PROPERTY">
                <xsl:copy>
                  <xsl:apply-templates select="@*"/>
                  <xsl:apply-templates select="*"/>
                  <DisplayValue>
                    <xsl:value-of select="VALUE"/>
                  </DisplayValue>
                </xsl:copy>
              </xsl:for-each>
              -->
            </xsl:otherwise>
          </xsl:choose>
        </INSTANCE>
      </xsl:for-each>
    </VALUE.NAMEDINSTANCE>
  </xsl:template>

  <!-- Fan Provider -->
  <xsl:template name="Fan">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and @NAME != 'LastUpdateTime' and @NAME != 'RateUnits' and 
                                   @NAME != 'BaseUnits' and @NAME != 'CurrentReading' and @NAME != 'PrimaryStatus' and @NAME != 'RedundancyStatus' and @NAME != 'PWM']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RateUnits']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">None</xsl:when>
            <xsl:when test="VALUE = 1">Per MicroSecond</xsl:when>
            <xsl:when test="VALUE = 2">Per MilliSecond</xsl:when>
            <xsl:when test="VALUE = 3">Per Second</xsl:when>
            <xsl:when test="VALUE = 4">Per Minute</xsl:when>
            <xsl:when test="VALUE = 5">Per Hour</xsl:when>
            <xsl:when test="VALUE = 6">Per Day</xsl:when>
            <xsl:when test="VALUE = 7">Per Week</xsl:when>
            <xsl:when test="VALUE = 8">Per Month</xsl:when>
            <xsl:when test="VALUE = 9">Per Year</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'BaseUnits']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Other</xsl:when>
            <xsl:when test="VALUE = 2">Degrees C</xsl:when>
            <xsl:when test="VALUE = 3">Degrees F</xsl:when>
            <xsl:when test="VALUE = 4">Degrees K</xsl:when>
            <xsl:when test="VALUE = 5">Volts</xsl:when>
            <xsl:when test="VALUE = 6">Amps</xsl:when>
            <xsl:when test="VALUE = 7">Watts</xsl:when>
            <xsl:when test="VALUE = 8">Joules</xsl:when>
            <xsl:when test="VALUE = 9">Coulombs</xsl:when>
            <xsl:when test="VALUE = 10">VA</xsl:when>
            <xsl:when test="VALUE = 11">Nits</xsl:when>
            <xsl:when test="VALUE = 12">Lumens</xsl:when>
            <xsl:when test="VALUE = 13">Lux</xsl:when>
            <xsl:when test="VALUE = 14">Candelas</xsl:when>
            <xsl:when test="VALUE = 15">kPa</xsl:when>
            <xsl:when test="VALUE = 16">PSI</xsl:when>
            <xsl:when test="VALUE = 17">Newtons</xsl:when>
            <xsl:when test="VALUE = 18">CFM</xsl:when>
            <xsl:when test="VALUE = 19">RPM</xsl:when>
            <xsl:when test="VALUE = 20">Hertz</xsl:when>
            <xsl:when test="VALUE = 21">Seconds</xsl:when>
            <xsl:when test="VALUE = 22">Minutes</xsl:when>
            <xsl:when test="VALUE = 23">Hours</xsl:when>
            <xsl:when test="VALUE = 24">Days</xsl:when>
            <xsl:when test="VALUE = 25">Weeks</xsl:when>
            <xsl:when test="VALUE = 26">Mils</xsl:when>
            <xsl:when test="VALUE = 27">Inches</xsl:when>
            <xsl:when test="VALUE = 28">Feet</xsl:when>
            <xsl:when test="VALUE = 29">Cubic Inches</xsl:when>
            <xsl:when test="VALUE = 30">Cubic Feet</xsl:when>
            <xsl:when test="VALUE = 31">Meters</xsl:when>
            <xsl:when test="VALUE = 32">Cubic Centimeters</xsl:when>
            <xsl:when test="VALUE = 33">Cubic Meters</xsl:when>
            <xsl:when test="VALUE = 34">Liters</xsl:when>
            <xsl:when test="VALUE = 35">Fluid Ounces</xsl:when>
            <xsl:when test="VALUE = 36">Radians</xsl:when>
            <xsl:when test="VALUE = 37">Steradians</xsl:when>
            <xsl:when test="VALUE = 38">Revolutions</xsl:when>
            <xsl:when test="VALUE = 39">Cycles</xsl:when>
            <xsl:when test="VALUE = 40">Gravities</xsl:when>
            <xsl:when test="VALUE = 41">Ounces</xsl:when>
            <xsl:when test="VALUE = 42">Pounds</xsl:when>
            <xsl:when test="VALUE = 43">Foot-Pounds</xsl:when>
            <xsl:when test="VALUE = 44">Ounce-Inches</xsl:when>
            <xsl:when test="VALUE = 45">Gauss</xsl:when>
            <xsl:when test="VALUE = 46">Gilberts</xsl:when>
            <xsl:when test="VALUE = 47">Henries</xsl:when>
            <xsl:when test="VALUE = 48">Farads</xsl:when>
            <xsl:when test="VALUE = 49">Ohms</xsl:when>
            <xsl:when test="VALUE = 50">Siemens</xsl:when>
            <xsl:when test="VALUE = 51">Moles</xsl:when>
            <xsl:when test="VALUE = 52">Becquerels</xsl:when>
            <xsl:when test="VALUE = 53">PPM (parts/million)</xsl:when>
            <xsl:when test="VALUE = 54">Decibels</xsl:when>
            <xsl:when test="VALUE = 55">DbA</xsl:when>
            <xsl:when test="VALUE = 56">DbC</xsl:when>
            <xsl:when test="VALUE = 57">Grays</xsl:when>
            <xsl:when test="VALUE = 58">Sieverts</xsl:when>
            <xsl:when test="VALUE = 59">Color Temperature Degrees K</xsl:when>
            <xsl:when test="VALUE = 60">Bits</xsl:when>
            <xsl:when test="VALUE = 61">Bytes</xsl:when>
            <xsl:when test="VALUE = 62">Words (data)</xsl:when>
            <xsl:when test="VALUE = 63">DoubleWords</xsl:when>
            <xsl:when test="VALUE = 64">QuadWords</xsl:when>
            <xsl:when test="VALUE = 65">Percentage</xsl:when>
            <xsl:when test="VALUE = 66">Pascals</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'CurrentReading']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> RPM</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PWM']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text>%</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RedundancyStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RedundancyStatus"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- Power Supply Provider -->
  <xsl:template name="PowerSupply">
    <!-- start arrays -->
    <xsl:for-each select="PROPERTY.ARRAY">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <VALUE.ARRAY>
          <xsl:for-each select="VALUE.ARRAY/VALUE">
            <xsl:copy>
              <xsl:value-of select="."/>
            </xsl:copy>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="@NAME = 'RedTypeOfSet'">
              <xsl:for-each select="VALUE.ARRAY/VALUE">
                <DisplayValue>
                  <xsl:call-template name="PSViewRedTypeOfSet"/>
                </DisplayValue>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="VALUE.ARRAY/VALUE">
                <DisplayValue>
                  <xsl:value-of select="."/>
                </DisplayValue>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </VALUE.ARRAY>
      </xsl:copy>
    </xsl:for-each>
    <!-- end arrays-->
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and 
                  @NAME != 'LastUpdateTime' and 
                  @NAME != 'InputVoltage' and 
                  @NAME != 'TotalOutputPower' and 
                  @NAME != 'PrimaryStatus' and
                  @NAME != 'RedundancyStatus' and 
                  @NAME != 'Type' and
                  @NAME != 'RedTypeOfSet']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'InputVoltage']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> Volts</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'TotalOutputPower']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> Watts</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RedundancyStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RedundancyStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Type']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">AC</xsl:when>
            <xsl:when test="VALUE = 1">DC</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RedTypeOfSet']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Other</xsl:when>
            <xsl:when test="VALUE = 2">N+1</xsl:when>
            <xsl:when test="VALUE = 3">Load Balanced</xsl:when>
            <xsl:when test="VALUE = 4">Sparing</xsl:when>
            <xsl:when test="VALUE = 5">Limited Sparing</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>


  <!-- iDRAC Card Provider -->
  <xsl:template name="iDRACCard">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and @NAME != 'LastUpdateTime' and @NAME != 'LANEnabledState' and @NAME != 'SOLEnabledState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LANEnabledState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Disabled</xsl:when>
            <xsl:when test="VALUE = 1">Enabled</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SOLEnabledState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Disabled</xsl:when>
            <xsl:when test="VALUE = 1">Enabled</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- CPU Provider -->
  <xsl:template name="CPU">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and 
                                   @NAME != 'LastUpdateTime' and 
                                   @NAME != 'CPUFamily' and
                                   @NAME != 'CurrentClockSpeed' and 
                                   @NAME != 'MaxClockSpeed' and                  
                                   @NAME != 'ExternalBusClockSpeed' and 
                                   @NAME != 'Voltage' and
                                   @NAME != 'PrimaryStatus' and 
                                   @NAME != 'CPUStatus' and 
                                   @NAME != 'Characteristics' and 
                                   @NAME != 'Cache1Size' and 
                                   @NAME != 'Cache2Size' and 
                                   @NAME != 'Cache3Size' and 
                                   @NAME != 'Cache1PrimaryStatus' and 
                                   @NAME != 'Cache2PrimaryStatus' and 
                                   @NAME != 'Cache3PrimaryStatus' and 
                                   @NAME != 'Cache1Level' and 
                                   @NAME != 'Cache2Level' and 
                                   @NAME != 'Cache3Level' and 
                                   @NAME != 'Cache1WritePolicy' and 
                                   @NAME != 'Cache2WritePolicy' and 
                                   @NAME != 'Cache3WritePolicy' and 
                                   @NAME != 'Cache1SRAMType' and 
                                   @NAME != 'Cache2SRAMType' and 
                                   @NAME != 'Cache3SRAMType' and 
                                   @NAME != 'Cache1ErrorMethodology' and 
                                   @NAME != 'Cache2ErrorMethodology' and 
                                   @NAME != 'Cache3ErrorMethodology' and 
                                   @NAME != 'Cache1Type' and 
                                   @NAME != 'Cache2Type' and 
                                   @NAME != 'Cache3Type' and 
                                   @NAME != 'Cache1Associativity' and 
                                   @NAME != 'Cache2Associativity' and 
                                   @NAME != 'Cache3Associativity']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'CPUFamily']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="CPUFamily"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'CurrentClockSpeed' or
                  @NAME = 'MaxClockSpeed' or
                  @NAME = 'ExternalBusClockSpeed']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> MHz</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'CPUStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">CPU Enabled</xsl:when>
            <xsl:when test="VALUE = 2">CPU Disabled by User</xsl:when>
            <xsl:when test="VALUE = 3">CPU Disabled By BIOS (POST Error)</xsl:when>
            <xsl:when test="VALUE = 4">CPU Is Idle</xsl:when>
            <xsl:when test="VALUE = 7">Other</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Characteristics']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 2">Unknown</xsl:when>
            <xsl:when test="VALUE = 4">64-bit Capable</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Voltage']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text>V</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cache1Size' or
                  @NAME = 'Cache2Size' or
                  @NAME = 'Cache3Size']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> KB</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cache1PrimaryStatus' or 
                  @NAME = 'Cache2PrimaryStatus' or
                  @NAME = 'Cache3PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="CachePrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cache1Level' or 
                  @NAME = 'Cache2Level' or 
                  @NAME = 'Cache3Level']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="CacheLevel"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cache1WritePolicy' or 
                  @NAME = 'Cache2WritePolicy' or
                  @NAME = 'Cache3WritePolicy']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="CacheWritePolicy"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cache1SRAMType' or
                  @NAME = 'Cache2SRAMType' or 
                  @NAME = 'Cache3SRAMType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="CacheSRAMType"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cache1ErrorMethodology' or
                  @NAME = 'Cache2ErrorMethodology' or 
                  @NAME = 'Cache3ErrorMethodology']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="CacheErrorMethodology"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cache1Type' or 
                  @NAME = 'Cache2Type' or 
                  @NAME = 'Cache3Type']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="CacheType"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cache1Associativity' or 
                  @NAME = 'Cache2Associativity' or
                  @NAME = 'Cache3Associativity']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="CacheAssociativity"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- SystemInfo Provider -->
  <xsl:template name="SystemInfo">
    <xsl:for-each select="PROPERTY[
                   @NAME != 'LastSystemInventoryTime' and 
								   @NAME != 'LastUpdateTime' and 
								   @NAME != 'SysMemTotalSize' and 
								   @NAME != 'SysMemMaxCapacitySize' and 
								   @NAME != 'ChassisSystemHeight' and 
								   @NAME != 'SysMemLocation' and 
								   @NAME != 'SysMemErrorMethodology' and 
								   @NAME != 'SystemRevision' and 
								   @NAME != 'PowerState' and 
								   @NAME != 'BladeGeometry' and 
								   @NAME != 'PowerCapEnabledState' and
								   @NAME != 'PowerCap' and
								   @NAME != 'ServerAllocation' and
								   @NAME != 'PrimaryStatus' and 
								   @NAME != 'SysMemPrimaryStatus' and 
								   @NAME != 'CPURollupStatus' and 
								   @NAME != 'PSRollupStatus' and
								   @NAME != 'InstructionRollupStatus' and 								   
								   @NAME != 'TempRollupStatus' and
								   @NAME != 'VoltRollupStatus' and 
								   @NAME != 'FanRollupStatus' and 
								   @NAME != 'IntrusionRollupStatus' and
									@NAME != 'IDSDMRollupStatus' and
								   @NAME != 'BatteryRollupStatus' and 
								   @NAME != 'StorageRollupStatus' and 
								   @NAME != 'LicensingRollupStatus' and 
								   @NAME != 'EstimatedSystemAirflow' and 
								   @NAME != 'EstimatedExhaustTemperature' and
								   @NAME != 'RollupStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RollupStatus' or 
								   @NAME = 'PSRollupStatus' or
								   @NAME = 'InstructionRollupStatus' or
								   @NAME = 'TempRollupStatus' or
								   @NAME = 'VoltRollupStatus' or 
								   @NAME = 'FanRollupStatus' or 
								   @NAME = 'IntrusionRollupStatus' or
								   @NAME = 'IDSDMRollupStatus' or
								   @NAME = 'BatteryRollupStatus' or 
								   @NAME = 'StorageRollupStatus' or 
                   @NAME = 'LicensingRollupStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RollupStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus' or 
								   @NAME = 'SysMemPrimaryStatus' ]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PowerCapEnabledState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 2">Enabled</xsl:when>
            <xsl:when test="VALUE = 3">Disabled</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PowerCap']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> Watts</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'EstimatedSystemAirflow']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
      	<DisplayValue>
	  <xsl:choose>
      	    <xsl:when test="VALUE = 255">Not Applicable</xsl:when>
      	    <xsl:otherwise>
      	    <xsl:value-of select="VALUE"/>
      	    <xsl:text> CFM</xsl:text>
      	    </xsl:otherwise>
      	  </xsl:choose>
      	  </DisplayValue>
	</xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'EstimatedExhaustTemperature']">
        <xsl:copy>
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates select="*"/>
         <DisplayValue>
           <xsl:choose>
             <xsl:when test="VALUE = 255">Not Applicable</xsl:when>
             <xsl:otherwise>
             <xsl:value-of select="VALUE"/>
             <xsl:text> Degrees C</xsl:text>
             </xsl:otherwise>
           </xsl:choose>
           </DisplayValue>
        </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
        <xsl:for-each select="PROPERTY[@NAME = 'ServerAllocation']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:if  test="VALUE"> Watts</xsl:if>
	</DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SysMemMaxCapacitySize']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> MB</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SysMemTotalSize']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> MB</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
     <xsl:for-each select="PROPERTY[@NAME = 'ChassisSystemHeight']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text>U</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SysMemLocation']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 1">Other</xsl:when>
            <xsl:when test="VALUE = 2">Unknown</xsl:when>
            <xsl:when test="VALUE = 3">System board or motherboard</xsl:when>
            <xsl:when test="VALUE = 4">ISA add-on card</xsl:when>
            <xsl:when test="VALUE = 5">EISA add-on card</xsl:when>
            <xsl:when test="VALUE = 6">PCI add-on card</xsl:when>
            <xsl:when test="VALUE = 7">MCA add-on card</xsl:when>
            <xsl:when test="VALUE = 8">PCMCIA add-on card</xsl:when>
            <xsl:when test="VALUE = 9">Proprietary add-on card</xsl:when>
            <xsl:when test="VALUE = 10">NuBus</xsl:when>
            <xsl:when test="VALUE = 160">PC-98/C20 add-on card</xsl:when>
            <xsl:when test="VALUE = 161">PC-98/C24 add-on card</xsl:when>
            <xsl:when test="VALUE = 162">PC-98/E add-on card</xsl:when>
            <xsl:when test="VALUE = 163">PC-98/Local bus add-on card</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SysMemErrorMethodology']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 1">Other</xsl:when>
            <xsl:when test="VALUE = 2">Unknown</xsl:when>
            <xsl:when test="VALUE = 3">None</xsl:when>
            <xsl:when test="VALUE = 4">Parity</xsl:when>
            <xsl:when test="VALUE = 5">Single-bit ECC</xsl:when>
            <xsl:when test="VALUE = 6">Multi-bit ECC</xsl:when>
            <xsl:when test="VALUE = 7">CRC</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SystemRevision']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0"></xsl:when>
            <xsl:when test="VALUE = 1">II</xsl:when>
            <xsl:when test="VALUE = 2">III</xsl:when>
            <xsl:when test="VALUE = 3">IV</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PowerState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 2">On</xsl:when>
            <xsl:when test="VALUE = 8">Off - Soft</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'BladeGeometry']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Single width, half height</xsl:when>
            <xsl:when test="VALUE = 1">Dual width, half height</xsl:when>
            <xsl:when test="VALUE = 2">Single width, full height</xsl:when>
            <xsl:when test="VALUE = 3">Dual width, full height</xsl:when>
            <xsl:when test="VALUE = 4">Single width, quarter height</xsl:when>
            <xsl:when test="VALUE = 5">1U half width</xsl:when>
            <xsl:when test="VALUE = 6">1U quarter width</xsl:when>
            <xsl:when test="VALUE = 7">1U full width</xsl:when>
            <xsl:when test="VALUE = 8">Not Applicable</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- Memory Provider -->
  <xsl:template name="Memory">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and @NAME != 'LastUpdateTime' and @NAME != 'Speed' and 
                                   @NAME != 'CurrentOperatingSpeed' and @NAME != 'Size' and @NAME != 'Rank' and @NAME != 'PrimaryStatus' and @NAME != 'MemoryType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Speed']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> MHz</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'CurrentOperatingSpeed']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
          <DisplayValue>
            <xsl:value-of select="VALUE"/>
            <xsl:text> MHz</xsl:text>
          </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Size']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> MB</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Rank']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Single Rank</xsl:when>
            <xsl:when test="VALUE = 2">Double Rank</xsl:when>
            <xsl:when test="VALUE = 4">Quad Rank</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'MemoryType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 1">Other</xsl:when>
            <xsl:when test="VALUE = 2">Unknown</xsl:when>
            <xsl:when test="VALUE = 3">DRAM</xsl:when>
            <xsl:when test="VALUE = 4">EDRAM</xsl:when>
            <xsl:when test="VALUE = 5">VRAM</xsl:when>
            <xsl:when test="VALUE = 6">SRAM</xsl:when>
            <xsl:when test="VALUE = 7">RAM</xsl:when>
            <xsl:when test="VALUE = 8">ROM</xsl:when>
            <xsl:when test="VALUE = 9">Flash</xsl:when>
            <xsl:when test="VALUE = 10">EEPROM</xsl:when>
            <xsl:when test="VALUE = 11">FEPROM</xsl:when>
            <xsl:when test="VALUE = 12">EPROM</xsl:when>
            <xsl:when test="VALUE = 13">CDRAM</xsl:when>
            <xsl:when test="VALUE = 14">3DRAM</xsl:when>
            <xsl:when test="VALUE = 15">SDRAM</xsl:when>
            <xsl:when test="VALUE = 16">SGRAM</xsl:when>
            <xsl:when test="VALUE = 17">RDRAM</xsl:when>
            <xsl:when test="VALUE = 18">DDR</xsl:when>
            <xsl:when test="VALUE = 19">DDR-2</xsl:when>
            <xsl:when test="VALUE = 20">DDR-2-FB-DIMM</xsl:when>
            <xsl:when test="VALUE = 24">DDR-3</xsl:when>
            <xsl:when test="VALUE = 25">FBD2</xsl:when>
            <xsl:when test="VALUE = 26">DDR-4</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- PCI Device Provider -->
  <xsl:template name="PCIDevice">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and @NAME != 'LastUpdateTime' and 
                                   @NAME != 'DataBusWidth' and @NAME != 'SlotLength' and @NAME != 'SlotType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'DataBusWidth']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="DataBusWidth"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SlotLength']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="SlotLength"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SlotType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="SlotType"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- Video Provider -->
  <xsl:template name="Video">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and @NAME != 'LastUpdateTime' and 
                                   @NAME != 'DataBusWidth' and @NAME != 'SlotLength' and @NAME != 'SlotType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'DataBusWidth']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="DataBusWidth"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SlotLength']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="SlotLength"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SlotType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="SlotType"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- VirtualDisk Provider -->
  <xsl:template name="VirtualDisk">
    <!-- start arrays -->
    <xsl:for-each select="PROPERTY.ARRAY">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <VALUE.ARRAY>
          <xsl:for-each select="VALUE.ARRAY/VALUE">
            <xsl:copy>
              <xsl:value-of select="."/>
            </xsl:copy>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="@NAME = 'XXXXSAMPLEONLYXXXX'">
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="VALUE.ARRAY/VALUE">
                <DisplayValue>
                  <xsl:value-of select="."/>
                </DisplayValue>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </VALUE.ARRAY>
      </xsl:copy>
    </xsl:for-each>
<!-- end arrays-->
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and 
                                   @NAME != 'LastUpdateTime' and  
                                   @NAME != 'PrimaryStatus' and 
                                   @NAME != 'RollupStatus' and 
                                   @NAME != 'RAIDTypes' and 
                                   @NAME != 'RAIDStatus' and 
                                   @NAME != 'ReadCachePolicy' and 
                                   @NAME != 'WriteCachePolicy' and  
                                   @NAME != 'DiskCachePolicy' and 
                                   @NAME != 'Cachecade' and 
                                   @NAME != 'ObjectStatus' and 
                                   @NAME != 'LockStatus' and
                                   @NAME != 'SizeInBytes' and 
                                   @NAME != 'BlockSizeInBytes' and 
                                   @NAME != 'T10PIStatus' and 
                                   @NAME != 'StripeSize' and
                                   @NAME != 'BusProtocol' and 
                                   @NAME != 'MediaType' and
                                   @NAME != 'OperationPercentComplete' ]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SizeInBytes' or
                                   @NAME = 'BlockSizeInBytes']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> Bytes</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'OperationPercentComplete']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text>%</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RollupStatus' ]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RollupStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RAIDTypes']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 1">No RAID</xsl:when>
            <xsl:when test="VALUE = 2">RAID0</xsl:when>
            <xsl:when test="VALUE = 4">RAID1</xsl:when>
            <xsl:when test="VALUE = 64">RAID5</xsl:when>
            <xsl:when test="VALUE = 128">RAID6</xsl:when>
            <xsl:when test="VALUE = 2048">RAID10</xsl:when>
            <xsl:when test="VALUE = 8192">RAID50</xsl:when>
            <xsl:when test="VALUE = 16384">RAID60</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RAIDStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Ready</xsl:when>
            <xsl:when test="VALUE = 2">Online</xsl:when>
            <xsl:when test="VALUE = 3">Foreign</xsl:when>
            <xsl:when test="VALUE = 4">Offline</xsl:when>
            <xsl:when test="VALUE = 5">Blocked</xsl:when>
            <xsl:when test="VALUE = 6">Failed</xsl:when>
            <xsl:when test="VALUE = 7">Degraded</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'ReadCachePolicy']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 16">No Read Ahead</xsl:when>
            <xsl:when test="VALUE = 32">Read Ahead</xsl:when>
            <xsl:when test="VALUE = 64">Adaptive</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'WriteCachePolicy']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 1">Write Through</xsl:when>
            <xsl:when test="VALUE = 2">Write Back</xsl:when>
            <xsl:when test="VALUE = 4">Write Back Force</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'StripeSize']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Default</xsl:when>
            <xsl:when test="VALUE = 1">512B</xsl:when>
            <xsl:when test="VALUE = 2">1KB</xsl:when>
            <xsl:when test="VALUE = 4">2KB</xsl:when>
            <xsl:when test="VALUE = 8">4KB</xsl:when>
            <xsl:when test="VALUE = 16">8KB</xsl:when>
            <xsl:when test="VALUE = 32">16KB</xsl:when>
            <xsl:when test="VALUE = 64">32KB</xsl:when>
            <xsl:when test="VALUE = 128">64KB</xsl:when>
            <xsl:when test="VALUE = 256">128KB</xsl:when>
            <xsl:when test="VALUE = 512">256KB</xsl:when>
            <xsl:when test="VALUE = 1024">512KB</xsl:when>
            <xsl:when test="VALUE = 2048">1MB</xsl:when>
            <xsl:when test="VALUE = 4096">2MB</xsl:when>
            <xsl:when test="VALUE = 8192">4MB</xsl:when>
            <xsl:when test="VALUE = 16384">8MB</xsl:when>
            <xsl:when test="VALUE = 32768">16MB</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'DiskCachePolicy']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 256">Default</xsl:when>
            <xsl:when test="VALUE = 512">Enabled</xsl:when>
            <xsl:when test="VALUE = 1024">Disabled</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'ObjectStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Current</xsl:when>
            <xsl:when test="VALUE = 2">Pending Create</xsl:when>
            <xsl:when test="VALUE = 3">Pending Delete</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Cachecade']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Not a Cachecade Virtual Disk</xsl:when>
            <xsl:when test="VALUE = 1">Cachecade Virtual Disk</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LockStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unlocked</xsl:when>
            <xsl:when test="VALUE = 1">Locked</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'BusProtocol']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
       
        <xsl:call-template name="BusProtocol"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'MediaType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 1">HDD</xsl:when>
            <xsl:when test="VALUE = 2">Solid State Drive</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'T10PIStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Disabled</xsl:when>
            <xsl:when test="VALUE = 1">Enabled</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- NIC Provider -->
  <xsl:template name="NIC">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and @NAME != 'LastUpdateTime' and 
                                   @NAME != 'NicMode' and @NAME != 'FCoEOffloadMode' and
                                   @NAME != 'iScsiOffloadMode' and @NAME != 'AutoNegotiation' and
                                   @NAME != 'TransmitFlowControl' and @NAME != 'TransmitFlowControl' and
                                   @NAME != 'LinkDuplex' and @NAME != 'LinkSpeed' and 
                                   @NAME != 'DataBusWidth' and @NAME != 'SlotLength' and @NAME != 'SlotType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'NicMode' or 
                                   @NAME = 'FCoEOffloadMode' or
                                   @NAME = 'iScsiOffloadMode' or 
                                   @NAME = 'AutoNegotiation' ]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 2">Enabled</xsl:when>
            <xsl:when test="VALUE = 3">Disabled</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'TransmitFlowControl' or @NAME = 'ReceiveFlowControl']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 2">On</xsl:when>
            <xsl:when test="VALUE = 3">Off</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LinkDuplex']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Full Duplex</xsl:when>
            <xsl:when test="VALUE = 2">Half Duplex</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LinkSpeed']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">10 Mbps</xsl:when>
            <xsl:when test="VALUE = 2">100 Mbps</xsl:when>
            <xsl:when test="VALUE = 3">1000 Mbps</xsl:when>
            <xsl:when test="VALUE = 4">2.5 Gbps</xsl:when>
            <xsl:when test="VALUE = 5">10 Gbps</xsl:when>
            <xsl:when test="VALUE = 6">20 Gbps</xsl:when>
            <xsl:when test="VALUE = 7">40 Gbps</xsl:when>
            <xsl:when test="VALUE = 8">100 Gbps</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'DataBusWidth']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="DataBusWidth"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SlotLength']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="SlotLength"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SlotType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="SlotType"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- FC Provider -->
  <xsl:template name="FC">
    <xsl:for-each select="PROPERTY[@NAME !='LinkStatus' and @NAME != 'PortSpeed' ]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
   </xsl:for-each>
   <xsl:for-each select="PROPERTY[@NAME = 'LinkStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LinkStatus"/>
      </xsl:copy>
   </xsl:for-each>   
   <xsl:for-each select="PROPERTY[@NAME = 'PortSpeed']">         
       <xsl:copy>
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates select="*"/>
         <xsl:call-template name="PortSpeed"/>
        </xsl:copy>
   </xsl:for-each> 
  </xsl:template>

  <!-- VFlash Provider -->
  <xsl:template name="VFlash">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and @NAME != 'LastUpdateTime' and @NAME != 'AvailableSize' and @NAME != 'Capacity']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'Capacity']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> MB</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'AvailableSize']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> MB</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- Controller Provider -->
  <xsl:template name="Controller">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and 
                                   @NAME != 'LastUpdateTime' and 
                                   @NAME != 'PrimaryStatus' and 
                                   @NAME != 'DeviceCardSlotLength' and 
                                   @NAME != 'RollupStatus' and 
                                   @NAME != 'SecurityStatus' and 
                                   @NAME != 'EncryptionCapability' and
                                   @NAME != 'EncryptionMode' and 
                                   @NAME != 'CachecadeCapability' and  
                                   @NAME != 'SlicedVDCapability' and  
                                   @NAME != 'PatrolReadState' and  
                                   @NAME != 'MaxAvailablePCILinkSpeed' and  
                                   @NAME != 'MaxPossiblePCILinkSpeed' and  
                                   @NAME != 'DriverVersion' and  
                                   @NAME != 'SASAddress' and  
                                   @NAME != 'SupportControllerBootMode' and  
                                   @NAME != 'SupportEnhancedAutoForeignImport' and  
                                   @NAME != 'SupportRAID10UnevenSpans' and  
                                   @NAME != 'T10PICapability' and  
                                   @NAME != 'CacheSizeInMB' ]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'T10PICapability']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Not supported</xsl:when>
            <xsl:when test="VALUE = 1">Supported</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SupportRAID10UnevenSpans']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Not supported</xsl:when>
            <xsl:when test="VALUE = 1">Supported</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SupportEnhancedAutoForeignImport']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Not supported</xsl:when>
            <xsl:when test="VALUE = 1">Supported</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'DeviceCardSlotLength']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
        <xsl:choose>
            <xsl:when test="VALUE = '1'">Other</xsl:when>
            <xsl:when test="VALUE = '2'">Unknown</xsl:when>
            <xsl:when test="VALUE = '3'">Short Length</xsl:when>
            <xsl:when test="VALUE = '4'">Long Length</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
        </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RollupStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RollupStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SecurityStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Encryption Capable</xsl:when>
            <xsl:when test="VALUE = 2">Security Key Assigned</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'EncryptionCapability']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">None</xsl:when>
            <xsl:when test="VALUE = 1">Local Key Management Capable</xsl:when>
            <xsl:when test="VALUE = 2">Dell Key Management Capable</xsl:when>
            <xsl:when test="VALUE = 3">Local Key Management and Dell Key Management Capable</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'EncryptionMode']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">None</xsl:when>
            <xsl:when test="VALUE = 1">Local Key Management</xsl:when>
            <xsl:when test="VALUE = 2">Dell Key Management</xsl:when>
            <xsl:when test="VALUE = 3">Pending Dell Key Management Capable</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'CachecadeCapability']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Cachecade Virtual Disk not supported</xsl:when>
            <xsl:when test="VALUE = 1">Cachecade Virtual Disk supported</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SlicedVDCapability']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Sliced Virtual Disk creation not supported</xsl:when>
            <xsl:when test="VALUE = 1">Sliced Virtual Disk creation supported</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PatrolReadState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Stopped</xsl:when>
            <xsl:when test="VALUE = 2">Running</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'CacheSizeInMB']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> MB</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'MaxAvailablePCILinkSpeed']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RAIDEmptyString"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'MaxPossiblePCILinkSpeed']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RAIDEmptyString"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'DriverVersion']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RAIDEmptyString"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SASAddress']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Not Applicable</xsl:when>
            <xsl:otherwise><xsl:value-of select="VALUE"/></xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- Enclosure Provider -->
  <xsl:template name="Enclosure">
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and 
                  @NAME != 'LastUpdateTime' and 
                  @NAME != 'PrimaryStatus' and 
                  @NAME != 'RollupStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RollupStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RollupStatus"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- PhysicalDisk Provider -->
  <xsl:template name="PhysicalDisk">
    <!-- start arrays -->
    <xsl:for-each select="PROPERTY.ARRAY">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <VALUE.ARRAY>
          <xsl:for-each select="VALUE.ARRAY/VALUE">
            <xsl:copy>
              <xsl:value-of select="."/>
            </xsl:copy>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="@NAME = 'XXXXSAMPLEONLYXXXX'">
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="VALUE.ARRAY/VALUE">
                <DisplayValue>
                  <xsl:value-of select="."/>
                </DisplayValue>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </VALUE.ARRAY>
      </xsl:copy>
    </xsl:for-each>
    <!-- end arrays-->
    <xsl:for-each select="PROPERTY[@NAME != 'LastSystemInventoryTime' and 
                  @NAME != 'LastUpdateTime' and 
                  @NAME != 'UsedSizeInBytes' and 
                  @NAME != 'FreeSizeInBytes' and 
                  @NAME != 'SizeInBytes' and
                  @NAME != 'BlockSizeInBytes' and
                  @NAME != 'PrimaryStatus' and 
                  @NAME != 'RollupStatus' and 
                  @NAME != 'RaidStatus' and 
                  @NAME != 'BusProtocol' and 
                  @NAME != 'HotSpareStatus' and 
                  @NAME != 'SecurityState' and 
                  @NAME != 'PredictiveFailureState' and 
                  @NAME != 'MediaType' and 
                  @NAME != 'MaxCapableSpeed' and 
                  @NAME != 'DriveFormFactor' and 
                  @NAME != 'RemainingRatedWriteEndurance' and 
                  @NAME != 'T10PICapability' and 
                  @NAME != 'OperationPercentComplete' ]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastSystemInventoryTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LastUpdateTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastUpdateTime"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'UsedSizeInBytes' or
                                   @NAME = 'FreeSizeInBytes' or
                                   @NAME = 'BlockSizeInBytes' or
                                   @NAME = 'SizeInBytes']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text> Bytes</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'OperationPercentComplete']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
          <xsl:text>%</xsl:text>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RollupStatus' ]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="RollupStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RaidStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Ready</xsl:when>
            <xsl:when test="VALUE = 2">Online</xsl:when>
            <xsl:when test="VALUE = 3">Foreign</xsl:when>
            <xsl:when test="VALUE = 4">Offline</xsl:when>
            <xsl:when test="VALUE = 5">Blocked</xsl:when>
            <xsl:when test="VALUE = 6">Failed</xsl:when>
            <xsl:when test="VALUE = 7">Degraded</xsl:when>
            <xsl:when test="VALUE = 8">Non-RAID</xsl:when>
            <xsl:when test="VALUE = 9">Missing</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'BusProtocol']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="BusProtocol"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'HotSpareStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">No</xsl:when>
            <xsl:when test="VALUE = 1">Dedicated</xsl:when>
            <xsl:when test="VALUE = 2">Global</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PredictiveFailureState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Smart Alert Absent</xsl:when>
            <xsl:when test="VALUE = 1">Smart Alert Present</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'SecurityState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Secured</xsl:when>
            <xsl:when test="VALUE = 2">Locked</xsl:when>
            <xsl:when test="VALUE = 3">Foreign</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'MediaType']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">HDD</xsl:when>
            <xsl:when test="VALUE = 1">Solid State Drive</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'MaxCapableSpeed']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">1.5Gbs</xsl:when>
            <xsl:when test="VALUE = 2">3Gbs</xsl:when>
            <xsl:when test="VALUE = 3">6Gbs</xsl:when>
            <xsl:when test="VALUE = 4">12Gbs</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'DriveFormFactor']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">1.8 inch</xsl:when>
            <xsl:when test="VALUE = 2">2.5 inch</xsl:when>
            <xsl:when test="VALUE = 3">3.5 inch</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RemainingRatedWriteEndurance']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 255">Unknown</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="VALUE"/> 
                <xsl:text>%</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'T10PICapability']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Not supported</xsl:when>
            <xsl:when test="VALUE = 1">Supported</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- ControllerBattery Provider -->
  <xsl:template name="ControllerBattery">
    <xsl:for-each select="PROPERTY[@NAME != 'PrimaryStatus' and 
                                   @NAME != 'PredictiveCapacity' and 
                                   @NAME != 'RAIDState' and 
                                   @NAME != 'LearnState' and 
                                   @NAME != 'NextLearnTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'RAIDState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Ready</xsl:when>
            <xsl:when test="VALUE = 6">Failed</xsl:when>
            <xsl:when test="VALUE = 7">Degraded</xsl:when>
            <xsl:when test="VALUE = 9">Missing</xsl:when>
            <xsl:when test="VALUE = 10">Charging</xsl:when>
            <xsl:when test="VALUE = 11">Battery Learn</xsl:when>
            <xsl:when test="VALUE = 12">Below Threshold</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'LearnState']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Active</xsl:when>
            <xsl:when test="VALUE = 2">Timeout</xsl:when>
            <xsl:when test="VALUE = 3">Requested</xsl:when>
            <xsl:when test="VALUE = 4">Idle</xsl:when>
            <xsl:when test="VALUE = 5">Due</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PredictiveCapacity']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:choose>
            <xsl:when test="VALUE = 0">Unknown</xsl:when>
            <xsl:when test="VALUE = 1">Ready</xsl:when>
            <xsl:when test="VALUE = 6">Failed</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
          </xsl:choose>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'NextLearnTime']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="LastSystemInventoryTime"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- EnclosureEMM Provider -->
  <xsl:template name="EnclosureEMM">
    <xsl:for-each select="PROPERTY[@NAME != 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- EnclosurePSU Provider -->
  <xsl:template name="EnclosurePSU">
    <xsl:for-each select="PROPERTY[@NAME != 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="PROPERTY[@NAME = 'PrimaryStatus']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="PrimaryStatus"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- USBDevice Provider -->
  <xsl:template name="USBDevice">
    <xsl:for-each select="PROPERTY">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

<!-- HostNetworkInterface Provider -->
  <xsl:template name="HostNetworkInterface">
    <xsl:for-each select="PROPERTY">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

 <!-- PCIeSSD Provider -->
   <xsl:template name="PCIeSSD">
     <xsl:for-each select="PROPERTY">
      <xsl:copy>
  	<xsl:apply-templates select="@*"/>
  	<xsl:apply-templates select="*"/>
  	<DisplayValue>
  	  <xsl:value-of select="VALUE"/>
  	</DisplayValue>
      </xsl:copy>
     </xsl:for-each>
   </xsl:template>

<!-- PCIeSSDExtender Provider -->
  <xsl:template name="PCIeSSDExtender">
    <xsl:for-each select="PROPERTY">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

<!-- PCIeSSDBackPlane Provider -->
  <xsl:template name="PCIeSSDBackPlane">
    <xsl:for-each select="PROPERTY">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
          <DisplayValue>
           <xsl:value-of select="VALUE"/>
          </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- SystemQuickSync Provider -->
  <xsl:template name="SystemQuickSync">
    <xsl:for-each select="PROPERTY">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*"/>
        <DisplayValue>
          <xsl:value-of select="VALUE"/>
        </DisplayValue>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>
 
 
  <!-- FC Provider -->
   <xsl:template name="LinkStatus">
      <DisplayValue>
        <xsl:choose>
       	    <xsl:when test="VALUE = '0'">Down</xsl:when>
       	    <xsl:when test="VALUE = '1'">Up</xsl:when>
       	    <xsl:when test="VALUE = '2'">Unknown</xsl:when>
        </xsl:choose>
      </DisplayValue>
   </xsl:template>
 
  <!--FC Provider -->
   <xsl:template name="PortSpeed">
      <DisplayValue>
         <xsl:choose>
            <xsl:when test="VALUE = '0'">No Link</xsl:when>
            <xsl:when test="VALUE = '1'">2 Gbps</xsl:when>
            <xsl:when test="VALUE = '2'">4 Gbps</xsl:when>
            <xsl:when test="VALUE = '3'">8 Gbps</xsl:when>
            <xsl:when test="VALUE = '4'">16 Gbps</xsl:when>
            <xsl:when test="VALUE = '5'">32 Gbps</xsl:when>
            <xsl:when test="VALUE = '6'">Unknown</xsl:when>
         </xsl:choose>
      </DisplayValue>
   </xsl:template>

  <!-- Common Properties -->
  <xsl:template name="PrimaryStatus">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 0">Unknown</xsl:when>
        <xsl:when test="VALUE = 1">OK</xsl:when>
        <xsl:when test="VALUE = 2">Degraded</xsl:when>
        <xsl:when test="VALUE = 3">Error</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="RedundancyStatus">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 0">Unknown</xsl:when>
        <xsl:when test="VALUE = 1">DMTF Reserved</xsl:when>
        <xsl:when test="VALUE = 2">Fully Redundant</xsl:when>
        <xsl:when test="VALUE = 3">Degraded Redundancy</xsl:when>
        <xsl:when test="VALUE = 4">Redundancy Lost</xsl:when>
        <xsl:when test="VALUE = 5">Overall Failure</xsl:when>
        <xsl:when test="VALUE = 6">Not Applicable</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="CacheErrorMethodology">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 1">Other</xsl:when>
        <xsl:when test="VALUE = 2">Unknown</xsl:when>
        <xsl:when test="VALUE = 3">None</xsl:when>
        <xsl:when test="VALUE = 4">Parity</xsl:when>
        <xsl:when test="VALUE = 5">Single-bit ECC</xsl:when>
        <xsl:when test="VALUE = 6">Multi-bit ECC</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="CacheType">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 1">Other</xsl:when>
        <xsl:when test="VALUE = 2">Unknown</xsl:when>
        <xsl:when test="VALUE = 3">Instruction</xsl:when>
        <xsl:when test="VALUE = 4">Data</xsl:when>
        <xsl:when test="VALUE = 5">Unified</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="CacheAssociativity">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 1">Other</xsl:when>
        <xsl:when test="VALUE = 2">Unknown</xsl:when>
        <xsl:when test="VALUE = 3">Direct Mapped</xsl:when>
        <xsl:when test="VALUE = 4">2-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 5">4-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 6">Fully Associative</xsl:when>
        <xsl:when test="VALUE = 7">8-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 8">16-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 9">12-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 10">24-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 11">32-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 12">48-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 13">64-way Set-Associative</xsl:when>
        <xsl:when test="VALUE = 14">20-way Set-Associative</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="CacheSRAMType">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 1">Other</xsl:when>
        <xsl:when test="VALUE = 2">Unknown</xsl:when>
        <xsl:when test="VALUE = 4">Non-Burst</xsl:when>
        <xsl:when test="VALUE = 8">Burst</xsl:when>
        <xsl:when test="VALUE = 16">Pipeline Burst</xsl:when>
        <xsl:when test="VALUE = 32">Synchronous</xsl:when>
        <xsl:when test="VALUE = 64">Asynchronous</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="CacheWritePolicy">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 0">Write Through</xsl:when>
        <xsl:when test="VALUE = 1">Write Back</xsl:when>
        <xsl:when test="VALUE = 2">Varies with Address</xsl:when>
        <xsl:when test="VALUE = 3">Unknown</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="CacheLevel">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 0">L1</xsl:when>
        <xsl:when test="VALUE = 1">L2</xsl:when>
        <xsl:when test="VALUE = 2">L3</xsl:when>
        <xsl:when test="VALUE = 3">L4</xsl:when>
        <xsl:when test="VALUE = 4">L5</xsl:when>
        <xsl:when test="VALUE = 5">L6</xsl:when>
        <xsl:when test="VALUE = 6">L7</xsl:when>
        <xsl:when test="VALUE = 7">L8</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="CachePrimaryStatus">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 0">Unknown</xsl:when>
        <xsl:when test="VALUE = 1">OK</xsl:when>
        <xsl:when test="VALUE = 2">Degraded</xsl:when>
        <xsl:when test="VALUE = 3">Error</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="RollupStatus">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 0">Unknown</xsl:when>
        <xsl:when test="VALUE = 1">OK</xsl:when>
        <xsl:when test="VALUE = 2">Degraded</xsl:when>
        <xsl:when test="VALUE = 3">Error</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="DataBusWidth">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = '0001'">Other</xsl:when>
        <xsl:when test="VALUE = '0002'">Unknown</xsl:when>
        <xsl:when test="VALUE = '0003'">8 bit</xsl:when>
        <xsl:when test="VALUE = '0004'">16 bit</xsl:when>
        <xsl:when test="VALUE = '0005'">32 bit</xsl:when>
        <xsl:when test="VALUE = '0006'">64 bit</xsl:when>
        <xsl:when test="VALUE = '0007'">128 bit</xsl:when>
        <xsl:when test="VALUE = '0008'">1x or x1</xsl:when>
        <xsl:when test="VALUE = '0009'">2x or x2</xsl:when>
        <xsl:when test="VALUE = '000A'">4x or x4</xsl:when>
        <xsl:when test="VALUE = '000B'">8x or x8</xsl:when>
        <xsl:when test="VALUE = '000C'">12x or x12</xsl:when>
        <xsl:when test="VALUE = '000D'">16x or x16</xsl:when>
        <xsl:when test="VALUE = '000E'">32x or x32</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="SlotLength">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = '0001'">Other</xsl:when>
        <xsl:when test="VALUE = '0002'">Unknown</xsl:when>
        <xsl:when test="VALUE = '0003'">Short Length</xsl:when>
        <xsl:when test="VALUE = '0004'">Long Length</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="SlotType">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = '0001'">Other</xsl:when>
        <xsl:when test="VALUE = '0002'">Unknown</xsl:when>
        <xsl:when test="VALUE = '0003'">ISA</xsl:when>
        <xsl:when test="VALUE = '0004'">MCA</xsl:when>
        <xsl:when test="VALUE = '0005'">EISA</xsl:when>
        <xsl:when test="VALUE = '0006'">PCI</xsl:when>
        <xsl:when test="VALUE = '0007'">PC Card (PCMCIA)</xsl:when>
        <xsl:when test="VALUE = '0008'">VL-VESA</xsl:when>
        <xsl:when test="VALUE = '0009'">Proprietary</xsl:when>
        <xsl:when test="VALUE = '000A'">Processor Card Slot</xsl:when>
        <xsl:when test="VALUE = '000B'">Proprietary Memory Card Slot</xsl:when>
        <xsl:when test="VALUE = '000C'">I/O Riser Card Slot</xsl:when>
        <xsl:when test="VALUE = '000D'">NuBus</xsl:when>
        <xsl:when test="VALUE = '000E'">PCI - 66MHz Capable</xsl:when>
        <xsl:when test="VALUE = '000F'">AGP</xsl:when>
        <xsl:when test="VALUE = '0010'">AGP 2X</xsl:when>
        <xsl:when test="VALUE = '0011'">AGP 4X</xsl:when>
        <xsl:when test="VALUE = '0012'">PCI-X</xsl:when>
        <xsl:when test="VALUE = '0013'">AGP 8X</xsl:when>
        <xsl:when test="VALUE = '00A0'">PC-98/C20</xsl:when>
        <xsl:when test="VALUE = '00A1'">PC-98/C24</xsl:when>
        <xsl:when test="VALUE = '00A2'">PC-98/E</xsl:when>
        <xsl:when test="VALUE = '00A3'">PC-98/Local Bus</xsl:when>
        <xsl:when test="VALUE = '00A4'">PC-98/Card</xsl:when>
        <xsl:when test="VALUE = '00A5'">PCI Express</xsl:when>
        <xsl:when test="VALUE = '00A6'">PCI Express x1</xsl:when>
        <xsl:when test="VALUE = '00A7'">PCI Express x2</xsl:when>
        <xsl:when test="VALUE = '00A8'">PCI Express x4</xsl:when>
        <xsl:when test="VALUE = '00A9'">PCI Express x8</xsl:when>
        <xsl:when test="VALUE = '00AA'">PCI Express x16</xsl:when>
        <xsl:when test="VALUE = '00AB'">PCI Express Gen 2</xsl:when>
        <xsl:when test="VALUE = '00AC'">PCI Express Gen 2 x1</xsl:when>
        <xsl:when test="VALUE = '00AD'">PCI Express Gen 2 x2</xsl:when>
        <xsl:when test="VALUE = '00AE'">PCI Express Gen 2 x4</xsl:when>
        <xsl:when test="VALUE = '00AF'">PCI Express Gen 2 x8</xsl:when>
        <xsl:when test="VALUE = '00B0'">PCI Express Gen 2 x16</xsl:when>
        <xsl:when test="VALUE = '00B1'">PCI Express Gen 3</xsl:when>
        <xsl:when test="VALUE = '00B2'">PCI Express Gen 3 x1</xsl:when>
        <xsl:when test="VALUE = '00B3'">PCI Express Gen 3 x2</xsl:when>
        <xsl:when test="VALUE = '00B4'">PCI Express Gen 3 x4</xsl:when>
        <xsl:when test="VALUE = '00B5'">PCI Express Gen 3 x8</xsl:when>
        <xsl:when test="VALUE = '00B6'">PCI Express Gen 3 x16</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="VALUE"/>
        </xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="BusProtocol">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 0">Unknown</xsl:when>
        <xsl:when test="VALUE = 1">SCSI</xsl:when>
        <xsl:when test="VALUE = 2">PATA</xsl:when>
        <xsl:when test="VALUE = 3">FIBRE</xsl:when>
        <xsl:when test="VALUE = 4">USB</xsl:when>
        <xsl:when test="VALUE = 5">SATA</xsl:when>
        <xsl:when test="VALUE = 6">SAS</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="CPUFamily">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = '1'">Other</xsl:when>
        <xsl:when test="VALUE = '2'">Unknown</xsl:when>
        <xsl:when test="VALUE = '3'">8086</xsl:when>
        <xsl:when test="VALUE = '4'">80286</xsl:when>
        <xsl:when test="VALUE = '5'">80386</xsl:when>
        <xsl:when test="VALUE = '6'">80486</xsl:when>
        <xsl:when test="VALUE = '7'">8087</xsl:when>
        <xsl:when test="VALUE = '8'">80287</xsl:when>
        <xsl:when test="VALUE = '9'">80387</xsl:when>
        <xsl:when test="VALUE = 'A'">80487</xsl:when>
        <xsl:when test="VALUE = 'B'">Pentium(R) brand</xsl:when>
        <xsl:when test="VALUE = 'C'">Pentium(R) Pro</xsl:when>
        <xsl:when test="VALUE = 'D'">Pentium(R) II</xsl:when>
        <xsl:when test="VALUE = 'E'">Pentium(R) processor with MMX(TM) technology</xsl:when>
        <xsl:when test="VALUE = 'F'">Celeron(TM)</xsl:when>
        <xsl:when test="VALUE = '10'">Pentium(R) II Xeon(TM)</xsl:when>
        <xsl:when test="VALUE = '11'">Pentium(R) III</xsl:when>
        <xsl:when test="VALUE = '12'">M1 Family</xsl:when>
        <xsl:when test="VALUE = '13'">M2 Family</xsl:when>
        <xsl:when test="VALUE = '14'">Intel(R) Celeron(R) M processor</xsl:when>
        <xsl:when test="VALUE = '15'">Intel(R) Pentium(R) 4 HT processor</xsl:when>
        <xsl:when test="VALUE = '18'">K5 Family</xsl:when>
        <xsl:when test="VALUE = '19'">K6 Family</xsl:when>
        <xsl:when test="VALUE = '1A'">K6-2</xsl:when>
        <xsl:when test="VALUE = '1B'">K6-3</xsl:when>
        <xsl:when test="VALUE = '1C'">AMD Athlon(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = '1D'">AMD(R) Duron(TM) Processor</xsl:when>
        <xsl:when test="VALUE = '1E'">AMD29000 Family</xsl:when>
        <xsl:when test="VALUE = '1F'">K6-2+</xsl:when>
        <xsl:when test="VALUE = '20'">Power PC Family</xsl:when>
        <xsl:when test="VALUE = '21'">Power PC 601</xsl:when>
        <xsl:when test="VALUE = '22'">Power PC 603</xsl:when>
        <xsl:when test="VALUE = '23'">Power PC 603+</xsl:when>
        <xsl:when test="VALUE = '24'">Power PC 604</xsl:when>
        <xsl:when test="VALUE = '25'">Power PC 620</xsl:when>
        <xsl:when test="VALUE = '26'">Power PC X704</xsl:when>
        <xsl:when test="VALUE = '27'">Power PC 750</xsl:when>
        <xsl:when test="VALUE = '28'">Intel(R) Core(TM) Duo processor</xsl:when>
        <xsl:when test="VALUE = '29'">Intel(R) Core(TM) Duo mobile processor</xsl:when>
        <xsl:when test="VALUE = '2A'">Intel(R) Core(TM) Solo mobile processor</xsl:when>
        <xsl:when test="VALUE = '2B'">Intel(R) Atom(TM) processor</xsl:when>
        <xsl:when test="VALUE = '30'">Alpha Family</xsl:when>
        <xsl:when test="VALUE = '31'">Alpha 21064</xsl:when>
        <xsl:when test="VALUE = '32'">Alpha 21066</xsl:when>
        <xsl:when test="VALUE = '33'">Alpha 21164</xsl:when>
        <xsl:when test="VALUE = '34'">Alpha 21164PC</xsl:when>
        <xsl:when test="VALUE = '35'">Alpha 21164a</xsl:when>
        <xsl:when test="VALUE = '36'">Alpha 21264</xsl:when>
        <xsl:when test="VALUE = '37'">Alpha 21364</xsl:when>
        <xsl:when test="VALUE = '38'">AMD Turion(TM) II Ultra Dual-Core Mobile M Processor Family</xsl:when>
        <xsl:when test="VALUE = '39'">AMD Turion(TM) II Dual-Core Mobile M Processor Family</xsl:when>
        <xsl:when test="VALUE = '3A'">AMD Athlon(TM) II Dual-Core Mobile M Processor Family</xsl:when>
        <xsl:when test="VALUE = '3B'">AMD Opteron(TM) 6100 Series Processor</xsl:when>
        <xsl:when test="VALUE = '3C'">AMD Opteron(TM) 4100 Series Processor</xsl:when>
        <xsl:when test="VALUE = '3D'">AMD Opteron(TM) 6200 Series Processor</xsl:when>
        <xsl:when test="VALUE = '3E'">AMD Opteron(TM) 4200 Series Processor</xsl:when>
        <xsl:when test="VALUE = '40'">MIPS Family</xsl:when>
        <xsl:when test="VALUE = '41'">MIPS R4000</xsl:when>
        <xsl:when test="VALUE = '42'">MIPS R4200</xsl:when>
        <xsl:when test="VALUE = '43'">MIPS R4400</xsl:when>
        <xsl:when test="VALUE = '44'">MIPS R4600</xsl:when>
        <xsl:when test="VALUE = '45'">MIPS R10000</xsl:when>
        <xsl:when test="VALUE = '46'">AMD C-Series Processor</xsl:when>
        <xsl:when test="VALUE = '47'">AMD E-Series Processor</xsl:when>
        <xsl:when test="VALUE = '48'">AMD S-Series Processor</xsl:when>
        <xsl:when test="VALUE = '49'">AMD G-Series Processor</xsl:when>
        <xsl:when test="VALUE = '50'">SPARC Family</xsl:when>
        <xsl:when test="VALUE = '51'">SuperSPARC</xsl:when>
        <xsl:when test="VALUE = '52'">microSPARC II</xsl:when>
        <xsl:when test="VALUE = '53'">microSPARC IIep</xsl:when>
        <xsl:when test="VALUE = '54'">UltraSPARC</xsl:when>
        <xsl:when test="VALUE = '55'">UltraSPARC II</xsl:when>
        <xsl:when test="VALUE = '56'">UltraSPARC IIi</xsl:when>
        <xsl:when test="VALUE = '57'">UltraSPARC III</xsl:when>
        <xsl:when test="VALUE = '58'">UltraSPARC IIIi</xsl:when>
        <xsl:when test="VALUE = '60'">68040</xsl:when>
        <xsl:when test="VALUE = '61'">68xxx Family</xsl:when>
        <xsl:when test="VALUE = '62'">68000</xsl:when>
        <xsl:when test="VALUE = '63'">68010</xsl:when>
        <xsl:when test="VALUE = '64'">68020</xsl:when>
        <xsl:when test="VALUE = '65'">68030</xsl:when>
        <xsl:when test="VALUE = '70'">Hobbit Family</xsl:when>
        <xsl:when test="VALUE = '78'">Crusoe(TM) TM5000 Family</xsl:when>
        <xsl:when test="VALUE = '79'">Crusoe(TM) TM3000 Family</xsl:when>
        <xsl:when test="VALUE = '7A'">Efficeon(TM) TM8000 Family</xsl:when>
        <xsl:when test="VALUE = '80'">Weitek</xsl:when>
        <xsl:when test="VALUE = '82'">Itanium(TM) Processor</xsl:when>
        <xsl:when test="VALUE = '83'">AMD Athlon(TM) 64 Processor Family</xsl:when>
        <xsl:when test="VALUE = '84'">AMD Opteron(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = '85'">AMD Sempron(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = '86'">AMD Turion(TM) 64 Mobile Technology</xsl:when>
        <xsl:when test="VALUE = '87'">Dual-Core AMD Opteron(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = '88'">AMD Athlon(TM) 64 X2 Dual-Core Processor Family</xsl:when>
        <xsl:when test="VALUE = '89'">AMD Turion(TM) 64 X2 Mobile Technology</xsl:when>
        <xsl:when test="VALUE = '8A'">Quad-Core AMD Opteron(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = '8B'">Third-Generation AMD Opteron(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = '8C'">AMD Phenom(TM) FX Quad-Core Processor Family</xsl:when>
        <xsl:when test="VALUE = '8D'">AMD Phenom(TM) X4 Quad-Core Processor Family</xsl:when>
        <xsl:when test="VALUE = '8E'">AMD Phenom(TM) X2 Dual-Core Processor Family</xsl:when>
        <xsl:when test="VALUE = '8F'">AMD Athlon(TM) X2 Dual-Core Processor Family</xsl:when>
        <xsl:when test="VALUE = '90'">PA-RISC Family</xsl:when>
        <xsl:when test="VALUE = '91'">PA-RISC 8500</xsl:when>
        <xsl:when test="VALUE = '92'">PA-RISC 8000</xsl:when>
        <xsl:when test="VALUE = '93'">PA-RISC 7300LC</xsl:when>
        <xsl:when test="VALUE = '94'">PA-RISC 7200</xsl:when>
        <xsl:when test="VALUE = '95'">PA-RISC 7100LC</xsl:when>
        <xsl:when test="VALUE = '96'">PA-RISC 7100</xsl:when>
        <xsl:when test="VALUE = 'A0'">V30 Family</xsl:when>
        <xsl:when test="VALUE = 'A1'">Quad-Core Intel(R) Xeon(R) processor 3200 Series</xsl:when>
        <xsl:when test="VALUE = 'A2'">Dual-Core Intel(R) Xeon(R) processor 3000 Series</xsl:when>
        <xsl:when test="VALUE = 'A3'">Quad-Core Intel(R) Xeon(R) processor 5300 Series</xsl:when>
        <xsl:when test="VALUE = 'A4'">Dual-Core Intel(R) Xeon(R) processor 5100 Series</xsl:when>
        <xsl:when test="VALUE = 'A5'">Dual-Core Intel(R) Xeon(R) processor 5000 Series</xsl:when>
        <xsl:when test="VALUE = 'A6'">Dual-Core Intel(R) Xeon(R) processor LV</xsl:when>
        <xsl:when test="VALUE = 'A7'">Dual-Core Intel(R) Xeon(R) processor ULV</xsl:when>
        <xsl:when test="VALUE = 'A8'">Dual-Core Intel(R) Xeon(R) processor 7100 Series</xsl:when>
        <xsl:when test="VALUE = 'A9'">Quad-Core Intel(R) Xeon(R) processor 5400 Series</xsl:when>
        <xsl:when test="VALUE = 'AA'">Quad-Core Intel(R) Xeon(R) processor</xsl:when>
        <xsl:when test="VALUE = 'AB'">Dual-Core Intel(R) Xeon(R) processor 5200 Series</xsl:when>
        <xsl:when test="VALUE = 'AC'">Dual-Core Intel(R) Xeon(R) processor 7200 Series</xsl:when>
        <xsl:when test="VALUE = 'AD'">Quad-Core Intel(R) Xeon(R) processor 7300 Series</xsl:when>
        <xsl:when test="VALUE = 'AE'">Quad-Core Intel(R) Xeon(R) processor 7400 Series</xsl:when>
        <xsl:when test="VALUE = 'AF'">Multi-Core Intel(R) Xeon(R) processor 7400 Series</xsl:when>
        <xsl:when test="VALUE = 'B0'">Pentium(R) III Xeon(TM)</xsl:when>
        <xsl:when test="VALUE = 'B1'">Pentium(R) III Processor with Intel(R) SpeedStep(TM) Technology</xsl:when>
        <xsl:when test="VALUE = 'B2'">Pentium(R) 4</xsl:when>
        <xsl:when test="VALUE = 'B3'">Intel(R) Xeon(TM)</xsl:when>
        <xsl:when test="VALUE = 'B4'">AS400 Family</xsl:when>
        <xsl:when test="VALUE = 'B5'">Intel(R) Xeon(TM) processor MP</xsl:when>
        <xsl:when test="VALUE = 'B6'">AMD Athlon(TM) XP Family</xsl:when>
        <xsl:when test="VALUE = 'B7'">AMD Athlon(TM) MP Family</xsl:when>
        <xsl:when test="VALUE = 'B8'">Intel(R) Itanium(R) 2</xsl:when>
        <xsl:when test="VALUE = 'B9'">Intel(R) Pentium(R) M processor</xsl:when>
        <xsl:when test="VALUE = 'BA'">Intel(R) Celeron(R) D processor</xsl:when>
        <xsl:when test="VALUE = 'BB'">Intel(R) Pentium(R) D processor</xsl:when>
        <xsl:when test="VALUE = 'BC'">Intel(R) Pentium(R) Processor Extreme Edition</xsl:when>
        <xsl:when test="VALUE = 'BD'">Intel(R) Core(TM) Solo Processor</xsl:when>
        <xsl:when test="VALUE = 'BE'">K7</xsl:when>
        <xsl:when test="VALUE = 'BF'">Intel(R) Core(TM)2 Duo Processor</xsl:when>
        <xsl:when test="VALUE = 'C0'">Intel(R) Core(TM)2 Solo processor</xsl:when>
        <xsl:when test="VALUE = 'C1'">Intel(R) Core(TM)2 Extreme processor</xsl:when>
        <xsl:when test="VALUE = 'C2'">Intel(R) Core(TM)2 Quad processor</xsl:when>
        <xsl:when test="VALUE = 'C3'">Intel(R) Core(TM)2 Extreme mobile processor</xsl:when>
        <xsl:when test="VALUE = 'C4'">Intel(R) Core(TM)2 Duo mobile processor</xsl:when>
        <xsl:when test="VALUE = 'C5'">Intel(R) Core(TM)2 Solo mobile processor</xsl:when>
        <xsl:when test="VALUE = 'C6'">Intel(R) Core(TM) i7 processor</xsl:when>
        <xsl:when test="VALUE = 'C7'">Dual-Core Intel(R) Celeron(R) Processor</xsl:when>
        <xsl:when test="VALUE = 'C8'">S/390 and zSeries Family</xsl:when>
        <xsl:when test="VALUE = 'C9'">ESA/390 G4</xsl:when>
        <xsl:when test="VALUE = 'CA'">ESA/390 G5</xsl:when>
        <xsl:when test="VALUE = 'CB'">ESA/390 G6</xsl:when>
        <xsl:when test="VALUE = 'CC'">z/Architectur base</xsl:when>
        <xsl:when test="VALUE = 'CD'">Intel(R) Core(TM) i5 processor</xsl:when>
        <xsl:when test="VALUE = 'CE'">Intel(R) Core(TM) i3 processor</xsl:when>
        <xsl:when test="VALUE = 'D2'">VIA C7(TM)-M Processor Family</xsl:when>
        <xsl:when test="VALUE = 'D3'">VIA C7(TM)-D Processor Family</xsl:when>
        <xsl:when test="VALUE = 'D4'">VIA C7(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = 'D5'">VIA Eden(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = 'D6'">Multi-Core Intel(R) Xeon(R) processor</xsl:when>
        <xsl:when test="VALUE = 'D7'">Dual-Core Intel(R) Xeon(R) processor 3xxx Series</xsl:when>
        <xsl:when test="VALUE = 'D8'">Quad-Core Intel(R) Xeon(R) processor 3xxx Series</xsl:when>
        <xsl:when test="VALUE = 'D9'">VIA Nano(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = 'DA'">Dual-Core Intel(R) Xeon(R) processor 5xxx Series</xsl:when>
        <xsl:when test="VALUE = 'DB'">Quad-Core Intel(R) Xeon(R) processor 5xxx Series</xsl:when>
        <xsl:when test="VALUE = 'DD'">Dual-Core Intel(R) Xeon(R) processor 7xxx Series</xsl:when>
        <xsl:when test="VALUE = 'DE'">Quad-Core Intel(R) Xeon(R) processor 7xxx Series</xsl:when>
        <xsl:when test="VALUE = 'DF'">Multi-Core Intel(R) Xeon(R) processor 7xxx Series</xsl:when>
        <xsl:when test="VALUE = 'E0'">Multi-Core Intel(R) Xeon(R) processor 3400 Series</xsl:when>
        <xsl:when test="VALUE = 'E6'">Embedded AMD Opteron(TM) Quad-Core Processor Family</xsl:when>
        <xsl:when test="VALUE = 'E7'">AMD Phenom(TM) Triple-Core Processor Family</xsl:when>
        <xsl:when test="VALUE = 'E8'">AMD Turion(TM) Ultra Dual-Core Mobile Processor Family</xsl:when>
        <xsl:when test="VALUE = 'E9'">AMD Turion(TM) Dual-Core Mobile Processor Family</xsl:when>
        <xsl:when test="VALUE = 'EA'">AMD Athlon(TM) Dual-Core Processor Family</xsl:when>
        <xsl:when test="VALUE = 'EB'">AMD Sempron(TM) SI Processor Family</xsl:when>
        <xsl:when test="VALUE = 'EC'">AMD Phenom(TM) II Processor Family</xsl:when>
        <xsl:when test="VALUE = 'ED'">AMD Athlon(TM) II Processor Family</xsl:when>
        <xsl:when test="VALUE = 'EE'">Six-Core AMD Opteron(TM) Processor Family</xsl:when>
        <xsl:when test="VALUE = 'EF'">AMD Sempron(TM) M Processor Family</xsl:when>
        <xsl:when test="VALUE = 'FA'">i860</xsl:when>
        <xsl:when test="VALUE = 'FB'">i960</xsl:when>
        <xsl:when test="VALUE = 'FE'">Reserved (SMBIOS Extension)</xsl:when>
        <xsl:when test="VALUE = 'FF'">Reserved (Un-initialized Flash Content - Lo)</xsl:when>
        <xsl:when test="VALUE = '104'">SH-3</xsl:when>
        <xsl:when test="VALUE = '105'">SH-4</xsl:when>
        <xsl:when test="VALUE = '118'">ARM</xsl:when>
        <xsl:when test="VALUE = '119'">StrongARM</xsl:when>
        <xsl:when test="VALUE = '12C'">6x86</xsl:when>
        <xsl:when test="VALUE = '12D'">MediaGX</xsl:when>
        <xsl:when test="VALUE = '12E'">MII</xsl:when>
        <xsl:when test="VALUE = '140'">WinChip</xsl:when>
        <xsl:when test="VALUE = '15E'">DSP</xsl:when>
        <xsl:when test="VALUE = '1F4'">Video Processor</xsl:when>
        <xsl:when test="VALUE = 'FFFE'">Reserved (For Future Special Purpose Assignment)</xsl:when>
        <xsl:when test="VALUE = 'FFFF'">Reserved (Un-initialized Flash Content - Hi)</xsl:when>
        <xsl:otherwise>Unknown</xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="LastUpdateTime">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 'Unknown'">Unknown</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring(VALUE,1,4)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">-</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,5,2)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">-</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,7,2)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">T</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,9,2)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">:</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,11,2)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">:</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,13,2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="LastSystemInventoryTime">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="VALUE = 'Unknown'">Unknown</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring(VALUE,1,4)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">-</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,5,2)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">-</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,7,2)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">T</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,9,2)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">:</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,11,2)"/>
          <xsl:choose>
            <xsl:when test="VALUE = VALUE">:</xsl:when>
          </xsl:choose>
          <xsl:value-of select="substring(VALUE,13,2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>

  <xsl:template name="PSViewRedTypeOfSet">
    <xsl:choose>
      <xsl:when test=". = 1">Other</xsl:when>
      <xsl:when test=". = 2">N+1</xsl:when>
      <xsl:when test=". = 3">Load Balanced</xsl:when>
      <xsl:when test=". = 4">Sparing</xsl:when>
      <xsl:when test=". = 5">Limited Sparing</xsl:when>
      <xsl:otherwise>Unknown</xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="INSTANCENAME">
    <xsl:apply-templates select="../node()"/>
  </xsl:template>

  <xsl:template name="property">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="RAIDEmptyString">
    <DisplayValue>
      <xsl:choose>
        <xsl:when test="string-length(VALUE)=0">Not Applicable</xsl:when>
        <xsl:otherwise><xsl:value-of select="VALUE"/></xsl:otherwise>
      </xsl:choose>
    </DisplayValue>
  </xsl:template>
  
</xsl:stylesheet>
