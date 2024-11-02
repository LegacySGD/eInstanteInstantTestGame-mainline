<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>
			
			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson">
				<lxslt:script lang="javascript">
					<![CDATA[
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
						while(index < translations.item(0).getChildNodes().getLength())
						{
							var childNode = translations.item(0).getChildNodes().item(index);
							registerDebugText(childNode.getAttribute("key") + ": " +  childNode.getAttribute("value"));
							index += 2;
						}
						registerDebugText("Prize Table");
						for(var i = 0; i < bingoPatterns.length; ++i)
						{
							 registerDebugText("[" + i + "] -- Name: " + bingoPatterns[i] + ", Value: " + patternWins[i]);
						}
						
						var r = [];
						
						// Output Bingo Patterns
						/////////////////////////////
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;display:inline-block">');
						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable" style="table-layout:fixed;display:inline-block">');
							r.push('<tr><td class="tablehead" colspan="' + bingoSymbols.length + '">');
							r.push(getTranslationByName("prizePatterns", translations));
							r.push('</td>');
							r.push('</tr>');
							
							for(var row = 0; row < bingoSymbols.length; ++row)
							{
								r.push('<tr class="tablebody" height="20">');
							}
							
							r.push('<tr><td class="tablehead" colspan="' + bingoSymbols.length + '">');
							r.push(getTranslationByName("winsPerPattern", translations));
							r.push('</td>');
							r.push('</tr>');
							
							r.push('</table>');
						
							for(var pattern = 0; pattern < prizePatterns.length; ++pattern)
							{
								r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable" style="table-layout:fixed;display:inline-block">');
								
								r.push('<tr>');
								r.push('<td class="tablehead" colspan="' + bingoSymbols.length + '">');
								r.push(getTranslationByName(bingoPatterns[pattern], translations));
								r.push('</td>');
								r.push('</tr>');
								
								for(var row = 0; row < bingoSymbols.length; ++row)
								{
									var rowSpots = prizePatterns[pattern].split(",")[row];
									r.push('<tr height="20">');
									for(var spot = 0; spot < bingoSymbols.length; ++spot)
									{
										r.push('<td class="tablebody" width="20">');
										r.push(rowSpots[spot]);
										r.push('</td>');
									}
									r.push('</tr>');
								}
								
								r.push('<tr>');
								r.push('<td class="tablehead bold" colspan="' + bingoSymbols.length + '">');
								r.push(patternWins[pattern]);
								r.push('</td>');
								r.push('</tr>');
								
								r.push('</table>');
							}
						
						r.push('</table>');

						// Output Bingo Card Data
						////////////////////////////
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						r.push('<tr><td class="tablehead" colspan="' + bingoSymbols.length + '">');
						r.push(getTranslationByName("bingoCardNumbers", translations));
						r.push('</td>');
						r.push('</tr>');
						
						r.push('<tr>');
						for(var i = 0; i < bingoSymbols.length; ++i)
						{
							r.push('<td class="tablehead">');
							r.push(bingoSymbols[i]);
							r.push('</td>');
						}
						r.push('</tr>');
						
						for(var x = 0; x < bingoSymbols.length; ++x)
						{	
							r.push('<tr>');
							for(var y = 0; y < bingoSymbols.length; ++y)
							{
								var data = bingoCardData[y * bingoSymbols.length + x];
								if(data == "FREE")
								{
									r.push('<td class="tablebody bold">');
									r.push(getTranslationByName("freeSpace", translations));
								}
								else if(checkMatch(drawnNumbers, data))
								{
									r.push('<td class="tablebody bold">');
									r.push(getTranslationByName("youMatched", translations) + ": " + data);
								}
								else
								{
									r.push('<td class="tablebody">');
									r.push(data);
								}
								r.push('</td>');								
							}
							r.push('</tr>');
						}
						r.push('</table>');
						
						// Output Drawn Numbers
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						r.push('<tr><td class="tablehead" width="100%">');
						r.push(getTranslationByName("drawnNumbers", translations));
						r.push('</td>');
						r.push('</tr>');
						
						for(var num = 0; num < drawnNumbers.length; ++num)
						{
							r.push('<tr>');	
							r.push('<td class="tablebody" width="100%">');
							r.push(drawnNumbers[num]);
							r.push('</td>');
							r.push('</tr>');	
						}
						r.push('</table>');
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
							{
								r.push('<tr>');
								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
								r.push('</td>');
								r.push('</tr>');
							}
							r.push('</table>');
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
						for(var i = 0; i < winningNums.length; ++i)
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
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}
					
						
					
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />
				
				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>
				
				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>
				
				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>
			
			<x:template match="prize" mode="PrizeValue">
				<x:text>|</x:text>
				<x:call-template name="Utils.ApplyConversionByLocale">
					<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
					<x:with-param name="code" select="/output/denom/currencycode" />
					<x:with-param name="locale" select="//translation/@language" />
				</x:call-template>
			</x:template>
			
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
