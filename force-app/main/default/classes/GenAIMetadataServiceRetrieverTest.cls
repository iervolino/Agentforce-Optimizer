/**
 * @description Test class for GenAIMetadataServiceRetriever
 * This class contains test methods to verify the functionality of the GenAIMetadataServiceRetriever
 * including prompt generation and error handling scenarios
 * 
 * @author Francesco Iervolino
 * @date 2025-03-21
 */
@IsTest
private class GenAIMetadataServiceRetrieverTest {
    
    private static final String TEST_AGENT = 'TestAgent';
    private static final String TEST_TOPIC = 'TestTopic';
    private static final String TEST_INSTRUCTION = 'TestInstruction';
    private static final String TEST_FUNCTION = 'testFunction';
    
    /**
     * @description Sets up test data by creating necessary metadata records
     * This method creates test GenAiPlannerDefinition and GenAiPluginDefinition records
     * with predefined values for testing
     */
    @TestSetup
    static void setupTestData() {
        if (Test.isRunningTest()) {
            // Create test metadata records
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            
            // Create test planner (agent)
            Metadata.CustomMetadata plannerMetadata = new Metadata.CustomMetadata();
            plannerMetadata.fullName = 'GenAiPlannerDefinition.' + TEST_AGENT;
            plannerMetadata.label = 'Test Agent';
            
            Metadata.CustomMetadataValue descriptionField = new Metadata.CustomMetadataValue();
            descriptionField.field = 'Description';
            descriptionField.value = 'Test Agent Description';
            plannerMetadata.values.add(descriptionField);
            
            Metadata.CustomMetadataValue capabilitiesField = new Metadata.CustomMetadataValue();
            capabilitiesField.field = 'Capabilities';
            capabilitiesField.value = 'Test Capabilities';
            plannerMetadata.values.add(capabilitiesField);
            
            Metadata.CustomMetadataValue languageField = new Metadata.CustomMetadataValue();
            languageField.field = 'Language';
            languageField.value = 'en_US';
            plannerMetadata.values.add(languageField);
            
            Metadata.CustomMetadataValue plannerTypeField = new Metadata.CustomMetadataValue();
            plannerTypeField.field = 'PlannerType';
            plannerTypeField.value = 'Standard';
            plannerMetadata.values.add(plannerTypeField);
            
            mdContainer.addMetadata(plannerMetadata);
            
            // Create test plugin (topic)
            Metadata.CustomMetadata pluginMetadata = new Metadata.CustomMetadata();
            pluginMetadata.fullName = 'GenAiPluginDefinition.' + TEST_TOPIC;
            pluginMetadata.label = 'Test Topic';
            
            Metadata.CustomMetadataValue pluginDescField = new Metadata.CustomMetadataValue();
            pluginDescField.field = 'Description';
            pluginDescField.value = 'Test Topic Description';
            pluginMetadata.values.add(pluginDescField);
            
            Metadata.CustomMetadataValue pluginLangField = new Metadata.CustomMetadataValue();
            pluginLangField.field = 'Language';
            pluginLangField.value = 'en_US';
            pluginMetadata.values.add(pluginLangField);
            
            Metadata.CustomMetadataValue pluginTypeField = new Metadata.CustomMetadataValue();
            pluginTypeField.field = 'PluginType';
            pluginTypeField.value = 'Standard';
            pluginMetadata.values.add(pluginTypeField);
            
            Metadata.CustomMetadataValue scopeField = new Metadata.CustomMetadataValue();
            scopeField.field = 'Scope';
            scopeField.value = 'Global';
            pluginMetadata.values.add(scopeField);
            
            Metadata.CustomMetadataValue canEscalateField = new Metadata.CustomMetadataValue();
            canEscalateField.field = 'CanEscalate';
            canEscalateField.value = true;
            pluginMetadata.values.add(canEscalateField);
            
            mdContainer.addMetadata(pluginMetadata);
            
            // Deploy the test metadata
            Metadata.DeployCallback callback = new GenAiMetadataTestCallback();
            Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
    
    /**
     * @description Tests successful prompt generation
     * Verifies that the getPrompt method correctly generates a prompt containing
     * agent configuration and topics for a valid agent ID
     */
    @IsTest
    static void testGetPromptSuccess() {
        Test.startTest();
        
        // Create test request
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = TEST_AGENT;
        
        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>{request};
        
        // Call the invocable method
        List<GenAIMetadataServiceRetriever.Response> responses = GenAIMetadataServiceRetriever.getPrompt(requests);
        
        Test.stopTest();
        
        // Verify response
        Assert.isNotNull(responses, 'Response list should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        String prompt = responses[0].Prompt;
        Assert.isNotNull(prompt, 'Prompt should not be null');
        Assert.isTrue(prompt.contains('Agent Configuration:'), 'Prompt should contain agent configuration section');
        Assert.isTrue(prompt.contains('Topics:'), 'Prompt should contain topics section');
        Assert.isTrue(prompt.contains('Test Agent'), 'Prompt should contain agent label');
        Assert.isTrue(prompt.contains('Test Topic'), 'Prompt should contain topic label');
    }
    
    /**
     * @description Tests error handling for invalid agent ID
     * Verifies that the getPrompt method handles invalid agent IDs appropriately
     * and returns an error message in the response
     */
    @IsTest
    static void testGetPromptError() {
        Test.startTest();
        
        // Create test request with invalid agent ID
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = 'InvalidAgentId';
        
        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>{request};
        
        // Call the invocable method
        List<GenAIMetadataServiceRetriever.Response> responses = GenAIMetadataServiceRetriever.getPrompt(requests);
        
        Test.stopTest();
        
        // Verify error response
        Assert.isNotNull(responses, 'Response list should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        String prompt = responses[0].Prompt;
        Assert.isNotNull(prompt, 'Prompt should not be null');
        Assert.isTrue(prompt.contains('Error'), 'Prompt should contain error message');
    }
    
    /**
     * @description Tests handling of empty request list
     * Verifies that the getPrompt method handles empty request lists appropriately
     * and returns an error message in the response
     */
    @IsTest
    static void testGetPromptEmptyRequest() {
        Test.startTest();
        
        // Create empty request list
        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>();
        
        // Call the invocable method
        List<GenAIMetadataServiceRetriever.Response> responses = GenAIMetadataServiceRetriever.getPrompt(requests);
        
        Test.stopTest();
        
        // Verify response
        Assert.isNotNull(responses, 'Response list should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        String prompt = responses[0].Prompt;
        Assert.isNotNull(prompt, 'Prompt should not be null');
        Assert.isTrue(prompt.contains('Error'), 'Prompt should contain error message');
    }
    
    /**
     * @description Callback class for handling metadata deployment results
     * This class implements the Metadata.DeployCallback interface to handle
     * the results of test metadata deployment
     */
    private class GenAiMetadataTestCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            if (result.status == Metadata.DeployStatus.SUCCEEDED) {
                System.debug('Test metadata deployment succeeded');
            } else {
                System.debug('Test metadata deployment failed: ' + result.errorMessage);
            }
        }
    }
} 