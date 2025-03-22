/**
 * @description Test class for AgentforceHomepageController
 * This class contains test methods to verify the functionality of the AgentforceHomepageController
 * 
 * @author Francesco Iervolino
 * @date 2025-03-21
 */
@isTest
public class AgentforceHomepageControllerTest {
    
    /**
     * @description Tests the banner URL retrieval functionality
     * This test method verifies that the getAgentforceBannerUrl method can be called
     * with different index values without throwing exceptions
     */
    @isTest
    static void testController() {
        // Test with index 1
        AgentforceHomepageController.getAgentforceBannerUrl(1);
        // Test with index 0 (default banner)
        AgentforceHomepageController.getAgentforceBannerUrl(0);
    }
}