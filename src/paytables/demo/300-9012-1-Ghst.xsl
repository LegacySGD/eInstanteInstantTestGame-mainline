<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="java" extension-element-prefixes="my-ext" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my-ext="ext1">
<xsl:import href="HTML-CCFR.xsl"/>
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="*"/>
<xsl:apply-templates select="/output/root[position()=last()]" mode="last"/>
<br/>
</xsl:template>
<lxslt:component prefix="my-ext" functions="formatJson">
<lxslt:script lang="javascript">
					
					var debugFeed = [];
					var debugFlag = false;					
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param bingoColumns String of Bingo Symbols.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNames)
					{
						var scenario = getScenario(jsonContext);
						var drawnNumbers = (scenario.split("|")[0]).split(",");
						var bingoCardData = (scenario.split("|")[1]).split(",");
						var bingoPatterns = (prizeNames.substring(1)).split(',');
						var patternWins = (prizeValues.substring(1)).split('|');
						
						// Define Bingo Constants, which may vary per game
						var bingoSymbols = ['B','I','N','G','O'];
						var prizePatterns = ["XXXXX,XXXXX,XXXXX,XXXXX,XXXXX,XXXXX","XXXXX,---X-,--X--,-X---,XXXXX","X---X,-X-X-,--X--,-X-X-,X---X","X---X,-----,-----,-----,X---X","-X---,-X---,-X---,-X---,-X---"];

						var index = 1;
						registerDebugText("Translation Table");
						while(index &lt; translations.item(0).getChildNodes().getLength())
						{
							var childNode = translations.item(0).getChildNodes().item(index);
							registerDebugText(childNode.getAttribute("key") + ": " +  childNode.getAttribute("value"));
							index += 2;
						}
						registerDebugText("Prize Table");
						for(var i = 0; i &lt; bingoPatterns.length; ++i)
						{
							 registerDebugText("[" + i + "] -- Name: " + bingoPatterns[i] + ", Value: " + patternWins[i]);
						}
						
						var r = [];
						
						// Output Bingo Patterns
						/////////////////////////////
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;display:inline-block"&gt;');
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable" style="table-layout:fixed;display:inline-block"&gt;');
							r.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + bingoSymbols.length + '"&gt;');
							r.push(getTranslationByName("prizePatterns", translations));
							r.push('&lt;/td&gt;');
							r.push('&lt;/tr&gt;');
							
							for(var row = 0; row &lt; bingoSymbols.length; ++row)
							{
								r.push('&lt;tr class="tablebody" height="20"&gt;');
							}
							
							r.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + bingoSymbols.length + '"&gt;');
							r.push(getTranslationByName("winsPerPattern", translations));
							r.push('&lt;/td&gt;');
							r.push('&lt;/tr&gt;');
							
							r.push('&lt;/table&gt;');
						
							for(var pattern = 0; pattern &lt; prizePatterns.length; ++pattern)
							{
								r.push('&lt;table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable" style="table-layout:fixed;display:inline-block"&gt;');
								
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablehead" colspan="' + bingoSymbols.length + '"&gt;');
								r.push(getTranslationByName(bingoPatterns[pattern], translations));
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
								
								for(var row = 0; row &lt; bingoSymbols.length; ++row)
								{
									var rowSpots = prizePatterns[pattern].split(",")[row];
									r.push('&lt;tr height="20"&gt;');
									for(var spot = 0; spot &lt; bingoSymbols.length; ++spot)
									{
										r.push('&lt;td class="tablebody" width="20"&gt;');
										r.push(rowSpots[spot]);
										r.push('&lt;/td&gt;');
									}
									r.push('&lt;/tr&gt;');
								}
								
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablehead bold" colspan="' + bingoSymbols.length + '"&gt;');
								r.push(patternWins[pattern]);
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
								
								r.push('&lt;/table&gt;');
							}
						
						r.push('&lt;/table&gt;');

						// Output Bingo Card Data
						////////////////////////////
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
						r.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + bingoSymbols.length + '"&gt;');
						r.push(getTranslationByName("bingoCardNumbers", translations));
						r.push('&lt;/td&gt;');
						r.push('&lt;/tr&gt;');
						
						r.push('&lt;tr&gt;');
						for(var i = 0; i &lt; bingoSymbols.length; ++i)
						{
							r.push('&lt;td class="tablehead"&gt;');
							r.push(bingoSymbols[i]);
							r.push('&lt;/td&gt;');
						}
						r.push('&lt;/tr&gt;');
						
						for(var x = 0; x &lt; bingoSymbols.length; ++x)
						{	
							r.push('&lt;tr&gt;');
							for(var y = 0; y &lt; bingoSymbols.length; ++y)
							{
								var data = bingoCardData[y * bingoSymbols.length + x];
								if(data == "FREE")
								{
									r.push('&lt;td class="tablebody bold"&gt;');
									r.push(getTranslationByName("freeSpace", translations));
								}
								else if(checkMatch(drawnNumbers, data))
								{
									r.push('&lt;td class="tablebody bold"&gt;');
									r.push(getTranslationByName("youMatched", translations) + ": " + data);
								}
								else
								{
									r.push('&lt;td class="tablebody"&gt;');
									r.push(data);
								}
								r.push('&lt;/td&gt;');								
							}
							r.push('&lt;/tr&gt;');
						}
						r.push('&lt;/table&gt;');
						
						// Output Drawn Numbers
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
						r.push('&lt;tr&gt;&lt;td class="tablehead" width="100%"&gt;');
						r.push(getTranslationByName("drawnNumbers", translations));
						r.push('&lt;/td&gt;');
						r.push('&lt;/tr&gt;');
						
						for(var num = 0; num &lt; drawnNumbers.length; ++num)
						{
							r.push('&lt;tr&gt;');	
							r.push('&lt;td class="tablebody" width="100%"&gt;');
							r.push(drawnNumbers[num]);
							r.push('&lt;/td&gt;');
							r.push('&lt;/tr&gt;');	
						}
						r.push('&lt;/table&gt;');
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
							for(var idx = 0; idx &lt; debugFeed.length; ++idx)
							{
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablebody"&gt;');
								r.push(debugFeed[idx]);
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
							}
							r.push('&lt;/table&gt;');
						}

						return r.join('');
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i &lt; winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum)
							{
								return true;
							}
						}
						
						return false;
					}
	
					
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index &lt; translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);

							if(childNode.name == "phrase" &amp;&amp; childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}
					
						
					
					
				</lxslt:script>
</lxslt:component>
<xsl:template match="root" mode="last">
<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWager']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWins']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:template>
<xsl:template match="//Outcome">
<xsl:if test="OutcomeDetail/Stage = 'Scenario'">
<xsl:call-template name="Scenario.Detail"/>
</xsl:if>
</xsl:template>
<xsl:template name="Scenario.Detail">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='transactionId']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="OutcomeDetail/RngTxnId"/>
</td>
</tr>
</table>
<xsl:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())"/>
<xsl:variable name="translations" select="lxslt:nodeset(//translation)"/>
<xsl:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)"/>
<xsl:variable name="prizeTable" select="lxslt:nodeset(//lottery)"/>
<xsl:variable name="convertedPrizeValues">
<xsl:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
</xsl:variable>
<xsl:variable name="prizeNames">
<xsl:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
</xsl:variable>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template match="prize" mode="PrizeValue">
<xsl:text>|</xsl:text>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="text()"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</xsl:template>
<xsl:template match="description" mode="PrizeDescriptions">
<xsl:text>,</xsl:text>
<xsl:value-of select="text()"/>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>
