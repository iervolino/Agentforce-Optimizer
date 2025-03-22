/**
 * @description Test class for GenAiMetadataService
 * This class contains test methods to verify the functionality of the GenAiMetadataService
 * including agent configuration, topics, actions, and instructions retrieval
 * 
 * @author Francesco Iervolino
 * @date 2025-03-21
 */
@IsTest
private class GenAiMetadataServiceTest {
    
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
     * @description Tests the retrieval of agent configuration
     * Verifies that the getAgentConfiguration method returns the correct configuration
     * for a test agent
     */
    @IsTest
    static void testGetAgentConfiguration() {
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(TEST_AGENT);
        Test.stopTest();
        
        // Verify agent configuration
        Assert.isNotNull(config, 'Agent configuration should not be null');
        Assert.areEqual(TEST_AGENT, config.get('name'), 'Agent name should match');
        Assert.areEqual('Test Agent', config.get('label'), 'Agent label should match');
        Assert.areEqual('Test Agent Description', config.get('description'), 'Agent description should match');
        Assert.areEqual('Test Capabilities', config.get('capabilities'), 'Agent capabilities should match');
        Assert.areEqual('en_US', config.get('language'), 'Agent language should match');
        Assert.areEqual('Standard', config.get('plannerType'), 'Agent planner type should match');
    }
    
    /**
     * @description Tests the retrieval of agent topics
     * Verifies that the getAgentTopics method returns the correct topics
     * associated with a test agent
     */
    @IsTest
    static void testGetAgentTopics() {
        Test.startTest();
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(TEST_AGENT);
        Test.stopTest();
        
        // Verify topics
        Assert.isNotNull(topics, 'Topics list should not be null');
        Assert.areEqual(1, topics.size(), 'Should have one topic');
        
        Map<String, Object> topic = topics[0];
        Assert.areEqual(TEST_TOPIC, topic.get('name'), 'Topic name should match');
        Assert.areEqual('Test Topic', topic.get('label'), 'Topic label should match');
        Assert.areEqual('Test Topic Description', topic.get('description'), 'Topic description should match');
        Assert.areEqual('en_US', topic.get('language'), 'Topic language should match');
        Assert.areEqual('Standard', topic.get('pluginType'), 'Topic plugin type should match');
        Assert.areEqual('Global', topic.get('scope'), 'Topic scope should match');
        Assert.areEqual(true, topic.get('canEscalate'), 'Topic canEscalate should match');
    }
    
    /**
     * @description Tests the retrieval of agent actions
     * Verifies that the getAgentActions method returns the correct actions
     * associated with a test topic
     */
    @IsTest
    static void testGetAgentActions() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(TEST_TOPIC);
        Test.stopTest();
        
        // Verify actions
        Assert.isNotNull(actions, 'Actions list should not be null');
        Assert.areEqual(0, actions.size(), 'Should have no actions in test context');
    }
    
    /**
     * @description Tests the retrieval of agent instructions
     * Verifies that the getAgentInstructions method returns the correct instructions
     * associated with a test topic
     */
    @IsTest
    static void testGetAgentInstructions() {
        Test.startTest();
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions(TEST_TOPIC);
        Test.stopTest();
        
        // Verify instructions
        Assert.isNotNull(instructions, 'Instructions list should not be null');
        Assert.areEqual(0, instructions.size(), 'Should have no instructions in test context');
    }
    
    /**
     * @description Tests the retrieval of complete agent configuration
     * Verifies that the getCompleteAgentConfiguration method returns the complete
     * configuration including agent details and associated topics
     */
    @IsTest
    static void testGetCompleteAgentConfiguration() {
        Test.startTest();
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration(TEST_AGENT);
        Test.stopTest();
        
        // Verify complete configuration
        Assert.isNotNull(completeConfig, 'Complete configuration should not be null');
        
        // Verify agent section
        Map<String, Object> agent = (Map<String, Object>)completeConfig.get('agent');
        Assert.isNotNull(agent, 'Agent section should not be null');
        Assert.areEqual(TEST_AGENT, agent.get('name'), 'Agent name should match');
        
        // Verify topics section
        List<Map<String, Object>> topics = (List<Map<String, Object>>)completeConfig.get('topics');
        Assert.isNotNull(topics, 'Topics section should not be null');
        Assert.areEqual(1, topics.size(), 'Should have one topic');
        
        Map<String, Object> topic = topics[0];
        Assert.areEqual(TEST_TOPIC, topic.get('name'), 'Topic name should match');
    }
    
    /**
     * @description Tests negative scenarios and error handling
     * Verifies that the service handles non-existent agents and topics appropriately
     */
    @IsTest
    static void testNegativeCases() {
        Test.startTest();
        
        // Test with non-existent agent
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration('NonExistentAgent');
        Assert.areEqual(true, config.isEmpty(), 'Should return empty map for non-existent agent');
        
        // Test with non-existent topic
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics('NonExistentAgent');
        Assert.areEqual(0, topics.size(), 'Should return empty list for non-existent agent topics');
        
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions('NonExistentTopic');
        Assert.areEqual(0, actions.size(), 'Should return empty list for non-existent topic actions');
        
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions('NonExistentTopic');
        Assert.areEqual(0, instructions.size(), 'Should return empty list for non-existent topic instructions');
        
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration('NonExistentAgent');
        Assert.areEqual(true, completeConfig.isEmpty(), 'Should return empty map for non-existent agent complete configuration');
        
        Test.stopTest();
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