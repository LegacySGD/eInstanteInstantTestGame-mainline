import static org.junit.Assert.assertEquals;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.xml.xpath.XPathExpressionException;

import org.apache.log4j.Logger;
import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.igt.gle.gds.proxy.TestGDSProxy;
import com.igt.gle.manager.EngineManager;
import com.igt.gle.random.proxy.TestRandomNumberProxy;
import com.igt.gle.tools.outcome.OutcomeSigner;
import com.igt.gle.util.InputUtil;
import com.igt.gle.util.InputUtil.PlayerInputBuilder;
import com.igt.gle.util.InputUtil.Wager;
import com.igt.gle.util.OutcomeUtil;
import com.igt.util.xml.JXPathUtil;
import com.igt.util.xml.XMLUtil;

public class eInstantTestGameCOMEngineManagerTest
{
	private Logger logger;
	private EngineManager manager = new EngineManager();
	private Element gameParams;
	private Element previousOutcome;
	private JsonParser jsonParser;
	
	private String buyAction = "BUY";
	private String tryAction = "TRY";
	
	private long[] noWinForce = {
			1000000,						// division 9
			0, 0, 0, 0, 0, 0, 0, 0, 0	// scenario per division
	};
	private long[] division1Force = {
			0,							// division 1
			0, 0, 0, 0, 0, 0, 0, 0, 0	// scenario per division
	};
	/**
	 * @throws java.lang.Exception
	 */
	@Before
	public void setUp() throws Exception
	{
		logger = Logger.getLogger(eInstantTestGameCOMEngineManagerTest.class);
		gameParams = XMLUtil.parseResource("paymodel/eInstantTestGameIW/GameParams.xml").getDocumentElement();
		previousOutcome = XMLUtil.parseResource("paymodel/eInstantTestGameIW/InitOutcome.xml").getDocumentElement();
		previousOutcome = XMLUtil.getElement(OutcomeSigner.sign(previousOutcome));
		jsonParser = new JsonParser();
	}

	@After
	public void cleanUp() 
		throws Exception
	{
		TestRandomNumberProxy.reset();
	}

	@Ignore
	@Test
	public void test_buy_NoWin_RevealOneTime()
			throws Exception
	{
		Element playerInput;
		int pricePoint = 200;
		
		// Wager
		playerInput = new PlayerInputBuilder()
				.appendActionInput(buyAction)
				.appendWagerInput(new Wager("Wager1", pricePoint))
				.appendJSONInput("{'testData':0}").build();
		Node outcome = manager.play(InputUtil.buildInput(gameParams, previousOutcome, playerInput));
		logger.debug(outcome);
		
		assertEquals("Scenario", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, 0, pricePoint, 0);
		
		// Scenario
		TestRandomNumberProxy.setTestRngData(noWinForce);
		TestGDSProxy.setTestGdsData(getTestGdsData("test-scenario-data"));
		playerInput = new PlayerInputBuilder().appendActionInput("play").build();
		outcome = OutcomeUtil.getSignedData(outcome, "Outcome");
		outcome = manager.play(InputUtil.buildInput(gameParams, XMLUtil.getElement(outcome), playerInput));
		logger.debug(outcome);
		
		assertEquals("Reveal", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, 0, pricePoint, 0);
		
		// Reveal 1
		playerInput = new PlayerInputBuilder()
				.appendActionInput("play")
				.appendJSONInput("{'revealStatus':0,'revealData':'test message'}").build();
		outcome = OutcomeUtil.getSignedData(outcome, "Outcome");
		outcome = manager.play(InputUtil.buildInput(gameParams, XMLUtil.getElement(outcome), playerInput));
		logger.debug(outcome);
		
		String revealDataString = JXPathUtil.getString(outcome, "//JSONOutcome[@name='ODERevealData']/text()");
		JsonObject revealData = jsonParser.parse(revealDataString).getAsJsonObject();
		assertEquals("test message", revealData.get("revealData").getAsString());
		assertEquals("Wager", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, pricePoint, 0, 0);
	}
	
	@Ignore
	@Test
	public void test_buy_200x_2500000CreditsWin_RevealThreeTimes()
		throws Exception
	{
		Element playerInput;
		int pricePoint = 200;
		
		// Wager
		playerInput = new PlayerInputBuilder()
				.appendActionInput(buyAction)
				.appendWagerInput(new Wager("Wager1", pricePoint))
				.appendJSONInput("{'testData':0}").build();
		Node outcome = manager.play(InputUtil.buildInput(gameParams, previousOutcome, playerInput));
		logger.debug(outcome);
		
		assertEquals("Scenario", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, 0, pricePoint, 0);
		
		// Scenario
		TestRandomNumberProxy.setTestRngData(division1Force);
		TestGDSProxy.setTestGdsData(getTestGdsData("test-scenario-data"));
		playerInput = new PlayerInputBuilder().appendActionInput("play").build();
		outcome = OutcomeUtil.getSignedData(outcome, "Outcome");
		outcome = manager.play(InputUtil.buildInput(gameParams, XMLUtil.getElement(outcome), playerInput));
		logger.debug(outcome);
		
		assertEquals("Reveal", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, 0, pricePoint, 0);
		
		// Reveal 1 - with reveal data
		playerInput = new PlayerInputBuilder()
				.appendActionInput("play")
				.appendJSONInput("{'revealStatus':1,'revealData':'msg1'}").build();
		outcome = OutcomeUtil.getSignedData(outcome, "Outcome");
		outcome = manager.play(InputUtil.buildInput(gameParams, XMLUtil.getElement(outcome), playerInput));
		logger.debug(outcome);
		
		assertEquals("Reveal", JXPathUtil.getString(outcome, "//NextStage/text()"));
		String revealDataString = JXPathUtil.getString(outcome, "//JSONOutcome[@name='ODERevealData']/text()");
		JsonObject revealData = jsonParser.parse(revealDataString).getAsJsonObject();
		assertEquals("msg1", revealData.get("revealData").getAsString());
		assertSettledPendingPayout(outcome, 0, pricePoint, 0);
		
		// Reveal 2 - without reveal data
		playerInput = new PlayerInputBuilder()
				.appendActionInput("play")
				.appendJSONInput("{'revealStatus':1,'revealData':null}").build();
		outcome = OutcomeUtil.getSignedData(outcome, "Outcome");
		outcome = manager.play(InputUtil.buildInput(gameParams, XMLUtil.getElement(outcome), playerInput));
		logger.debug(outcome);
		
		revealDataString = JXPathUtil.getString(outcome, "//JSONOutcome[@name='ODERevealData']/text()");
		revealData = jsonParser.parse(revealDataString).getAsJsonObject();
		assertEquals("msg1", revealData.get("revealData").getAsString());
		assertEquals("Reveal", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, 0, pricePoint, 0);
		
		// Reveal 3 (complete) - with reveal data
		playerInput = new PlayerInputBuilder()
				.appendActionInput("play")
				.appendJSONInput("{'revealStatus':0,'revealData':'msg2'}").build();
		outcome = OutcomeUtil.getSignedData(outcome, "Outcome");
		outcome = manager.play(InputUtil.buildInput(gameParams, XMLUtil.getElement(outcome), playerInput));
		logger.debug(outcome);
		
		revealDataString = JXPathUtil.getString(outcome, "//JSONOutcome[@name='ODERevealData']/text()");
		revealData = jsonParser.parse(revealDataString).getAsJsonObject();
		assertEquals("msg2", revealData.get("revealData").getAsString());
		assertEquals("Wager", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, pricePoint, 0, 2500000);
	}
	
	@Ignore
	@Test
	public void test_try_NoWin()
			throws Exception
	{
		Element playerInput;
		int pricePoint = 200;
		
		// Wager
		TestRandomNumberProxy.setTestRngData(noWinForce);
		TestGDSProxy.setTestGdsData(getTestGdsData("test-scenario-data"));
		playerInput = new PlayerInputBuilder()
				.appendActionInput(tryAction)
				.appendWagerInput(new Wager("Wager1", pricePoint))
				.appendJSONInput("{'testData':0}").build();
		Node outcome = manager.play(InputUtil.buildInput(gameParams, previousOutcome, playerInput));
		logger.debug(outcome);
		
		assertEquals("Wager", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, pricePoint, 0, 0);
	}
	
	@Ignore
	@Test
	public void test_try_200x_2500000CreditsWin()
			throws Exception
	{
		Element playerInput;
		int pricePoint = 200;
		
		// Wager
		TestRandomNumberProxy.setTestRngData(division1Force);
		TestGDSProxy.setTestGdsData(getTestGdsData("test-scenario-data"));
		playerInput = new PlayerInputBuilder()
				.appendActionInput(tryAction)
				.appendWagerInput(new Wager("Wager1", pricePoint))
				.appendJSONInput("{'testData':0}").build();
		Node outcome = manager.play(InputUtil.buildInput(gameParams, previousOutcome, playerInput));
		logger.debug(outcome);
		
		assertEquals("Wager", JXPathUtil.getString(outcome, "//NextStage/text()"));
		assertSettledPendingPayout(outcome, pricePoint, 0, 2500000);
	}
	private List<Map<String, Object>> getTestGdsData(String scenario)
	{
		List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("scenario", scenario);
		result.add(map);
		return result;
	}
	
	private void assertSettledPendingPayout(Node outcome, int settled, int pending, int payout)
			throws XPathExpressionException
	{
		assertEquals(settled, JXPathUtil.getDouble(outcome, "//OutcomeDetail/Settled/text()"), 0d);
		assertEquals(pending, JXPathUtil.getDouble(outcome, "//OutcomeDetail/Pending/text()"), 0d);
		assertEquals(payout, JXPathUtil.getDouble(outcome, "//OutcomeDetail/Payout/text()"), 0d);
	}
}
