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
    
    private static final String TEST_AGENT_NAME = 'RealTestAgent';
    private static final String TEST_TOPIC_NAME = 'RealTestTopic';
    private static final String TEST_FUNCTION_NAME = 'RealTestAction';
    private static final String TEST_INSTRUCTION_NAME = 'RealTestInstruction';
    
    private static final String MOCK_AGENT = 'TestAgent';
    private static final String MOCK_TOPIC = 'TestTopic';
    private static final String MOCK_FUNCTION = 'testFunction';
    private static final String MOCK_INSTRUCTION = 'TestInstruction';
    
    private static final Id MOCK_AGENT_ID = '0Ml000000000001AAA';
    private static final Id MOCK_TOPIC_ID = '0Ml000000000002AAA';
    
    /**
     * @description Sets up test data by configuring metadata mocks
     */
    @TestSetup
    static void setupTestData() {
        // No DML operations needed - we'll use Test.isRunningTest() paths instead
    }
    
    /**
     * @description Tests the retrieval of agent configuration using mock data.
     */
    @IsTest
    static void testGetAgentConfiguration_Mock() {
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(MOCK_AGENT);
        Test.stopTest();
        
        Assert.isNotNull(config, 'Agent configuration should not be null');
        Assert.isFalse(config.isEmpty(), 'Config map should not be empty for mock agent');
        Assert.areEqual(MOCK_AGENT, config.get('name'), 'Agent name should match mock');
        Assert.areEqual('Test Agent', config.get('label'), 'Agent label should match mock');
        Assert.areEqual('Test Agent Description', config.get('description'), 'Description should match mock');
        Assert.areEqual('Test Capabilities', config.get('capabilities'), 'Capabilities should match mock');
        Assert.areEqual('en_US', config.get('language'), 'Language should match mock');
        Assert.areEqual('Standard', config.get('plannerType'), 'PlannerType should match mock');
    }
    
    /**
     * @description Tests the retrieval of agent topics using mock data.
     */
    @IsTest
    static void testGetAgentTopics_Mock() {
        Test.startTest();
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(MOCK_AGENT);
        Test.stopTest();
        
        Assert.isNotNull(topics, 'Topics list should not be null');
        Assert.areEqual(1, topics.size(), 'Should have one mock topic');
        Map<String, Object> topic = topics[0];
        Assert.areEqual(MOCK_TOPIC, topic.get('name'), 'Topic name should match mock');
        Assert.areEqual('Test Topic', topic.get('label'), 'Topic label should match mock');
        Assert.areEqual('Test Topic Description', topic.get('description'), 'Description should match mock');
        Assert.areEqual(true, topic.get('isLocal'), 'IsLocal should be true');
        Assert.areEqual('en_US', topic.get('language'), 'Language should match mock');
    }

    /**
     * @description Tests the retrieval of agent actions using mock data.
     */
    @IsTest
    static void testGetAgentActions_Mock() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(MOCK_TOPIC);
        Test.stopTest();
        
        Assert.isNotNull(actions, 'Actions list should not be null');
        // Note: Currently returns empty list as mock data path is not implemented
        Assert.areEqual(0, actions.size(), 'Should have no actions for mock topic');
    }

    /**
     * @description Tests the retrieval of agent instructions using mock data.
     */
    @IsTest
    static void testGetAgentInstructions_Mock() {
        Test.startTest();
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions(MOCK_TOPIC);
        Test.stopTest();
        
        Assert.isNotNull(instructions, 'Instructions list should not be null');
        // Note: Currently returns empty list as mock data path is not implemented
        Assert.areEqual(0, instructions.size(), 'Should have no instructions for mock topic');
    }

    /**
     * @description Tests the retrieval of complete agent configuration using mock data.
     */
    @IsTest
    static void testGetCompleteAgentConfiguration_Mock() {
        Test.startTest();
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration(MOCK_AGENT);
        Test.stopTest();
        
        Assert.isNotNull(completeConfig, 'Complete configuration should not be null');
        Assert.isFalse(completeConfig.isEmpty(), 'Complete config map should not be empty for mock agent');
        Assert.isTrue((Boolean)completeConfig.get('success'), 'Success should be true');
        
        Map<String, Object> agent = (Map<String, Object>)completeConfig.get('agent');
        Assert.isNotNull(agent, 'Agent section should not be null');
        Assert.areEqual(MOCK_AGENT, agent.get('name'), 'Agent name should match mock');
        
        List<Map<String, Object>> topics = (List<Map<String, Object>>)completeConfig.get('topics');
        Assert.isNotNull(topics, 'Topics section should not be null');
        Assert.areEqual(1, topics.size(), 'Should have one mock topic');
        
        Map<String, Object> topic = topics[0];
        Assert.areEqual(MOCK_TOPIC, topic.get('name'), 'Topic name should match mock');
        Assert.isNotNull(topic.get('actions'), 'Actions list should not be null');
        Assert.isNotNull(topic.get('instructions'), 'Instructions list should not be null');
    }

    /**
     * @description Tests retrieval of all agents using mock data.
     */
    @IsTest
    static void testGetAllAgents_Mock() {
        Test.startTest();
        List<Map<String, Object>> agents = GenAiMetadataService.getAllAgents();
        Test.stopTest();
        
        Assert.isNotNull(agents, 'Agents list should not be null');
        // Note: getAllAgents doesn't have a mock data path, so it will return empty list
        //Assert.areEqual(0, agents.size(), 'Should have no agents in test context');
    }

    /**
     * @description Tests retrieval of agent configuration using real-like data.
     */
    @IsTest 
    static void testGetAgentConfiguration_RealData() {
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(MOCK_AGENT_ID);
        Test.stopTest();

        Assert.isNotNull(config, 'Config should not be null for real agent');
    }

    /**
     * @description Tests retrieval of agent topics using real-like data.
     */
    @IsTest 
    static void testGetAgentTopics_RealData() {
        Test.startTest();
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(MOCK_AGENT_ID);
        Test.stopTest();

        Assert.isNotNull(topics, 'Topics list should not be null');
    }

    /**
     * @description Tests retrieval of agent actions using real-like data.
     */
    @IsTest 
    static void testGetAgentActions_RealData() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(TEST_TOPIC_NAME);
        Test.stopTest();

        Assert.isNotNull(actions, 'Actions list should not be null');
    }

    /**
     * @description Tests retrieval of agent instructions using real-like data.
     */
    @IsTest 
    static void testGetAgentInstructions_RealData() {
        Test.startTest();
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions(TEST_TOPIC_NAME);
        Test.stopTest();

        Assert.isNotNull(instructions, 'Instructions list should not be null');
    }

    /**
     * @description Tests retrieval of complete configuration using real-like data.
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_RealData() {
        Test.startTest();
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration(MOCK_AGENT_ID);
        Test.stopTest();

        Assert.isNotNull(completeConfig, 'Complete config should not be null');
    }

    /**
     * @description Tests retrieval of all agents.
     */
    @IsTest 
    static void testGetAllAgents() {
        Test.startTest();
        List<Map<String, Object>> allAgents = GenAiMetadataService.getAllAgents();
        Test.stopTest();

        Assert.isNotNull(allAgents, 'All agents list should not be null');
    }

    /**
     * @description Tests validateAgentforceConfigurations expecting an exception.
     */
    @IsTest 
    static void testValidateAgentforceConfigurations_Exception() {
        String result = null;
        Exception thrownException = null;

        Test.startTest();
        try {
            result = GenAiMetadataService.validateAgentforceConfigurations(MOCK_AGENT_ID);
        } catch (Exception e) {
            thrownException = e;
        }
        Test.stopTest();

        Assert.isNull(result, 'Result should be null when exception occurs');
        Assert.isNotNull(thrownException, 'An exception should have been thrown');
        Assert.isInstanceOfType(thrownException, System.AuraHandledException.class, 
            'Expected AuraHandledException, but got: ' + thrownException.getTypeName());
    }
    
    /**
     * @description Tests negative scenarios and error handling using mock data paths.
     */
    @IsTest
    static void testNegativeCases_Mock() {
        Test.startTest();
        
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration('NonExistentAgent');
        Assert.isTrue(config.isEmpty(), 'Should return empty map for non-existent agent (mock)');
        
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics('NonExistentAgent');
        Assert.areEqual(0, topics.size(), 'Should return empty list for non-existent agent topics (mock)');
        
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration('NonExistentAgent');
        Assert.isTrue(completeConfig.isEmpty(), 'Should return empty map for non-existent agent complete configuration (mock)');
        
        Test.stopTest();
    }

    /**
     * @description Tests negative scenarios using real-like data paths.
     */
    @IsTest 
    static void testNegativeCases_RealData() {
        Test.startTest();

        Id fakeAgentId = '0Ml000000000099AAA'; 
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(fakeAgentId);
        Assert.isTrue(config.isEmpty(), 'Should return empty map for non-existent agent ID');

        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(fakeAgentId);
        Assert.areEqual(0, topics.size(), 'Should return empty list for non-existent agent ID topics');

        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration(fakeAgentId);
        Assert.isNotNull(completeConfig, 'Complete config should not be null for non-existent agent');
        Assert.isTrue(completeConfig.isEmpty() || completeConfig.get('success') == false, 
            'Config should be empty or success should be false for non-existent agent');

        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions('NonExistentTopicName');
        Assert.areEqual(0, actions.size(), 'Should return empty list for non-existent topic actions');
        
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions('NonExistentTopicName');
        Assert.areEqual(0, instructions.size(), 'Should return empty list for non-existent topic instructions');

        Test.stopTest();
    }

    /**
     * @description Tests error handling for invalid agent ID
     */
    @IsTest 
    static void testGetAgentConfiguration_InvalidId() {
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration('InvalidId');
        Test.stopTest();

        Assert.isNotNull(config, 'Config should not be null for invalid agent');
        Assert.isTrue(config.isEmpty(), 'Config map should be empty for invalid agent');
    }

    /**
     * @description Tests error handling for null agent ID
     */
    @IsTest 
    static void testGetAgentConfiguration_NullId() {
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(null);
        Test.stopTest();

        Assert.isNotNull(config, 'Config should not be null for null agent ID');
        Assert.isTrue(config.isEmpty(), 'Config map should be empty for null agent ID');
    }

    /**
     * @description Tests error handling for invalid topic name
     */
    @IsTest 
    static void testGetAgentActions_InvalidTopic() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions('NonExistentTopic');
        Test.stopTest();

        Assert.isNotNull(actions, 'Actions list should not be null for invalid topic');
        Assert.areEqual(0, actions.size(), 'Actions list should be empty for invalid topic');
    }

    /**
     * @description Tests error handling for null topic name
     */
    @IsTest 
    static void testGetAgentActions_NullTopic() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(null);
        Test.stopTest();

        Assert.isNotNull(actions, 'Actions list should not be null for null topic');
        Assert.areEqual(0, actions.size(), 'Actions list should be empty for null topic');
    }

    /**
     * @description Tests error handling for invalid agent ID in complete configuration
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_InvalidId() {
        Test.startTest();
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration('InvalidId');
        Test.stopTest();

        Assert.isNotNull(completeConfig, 'Complete config should not be null for invalid agent');
        Assert.isTrue(completeConfig.isEmpty() || completeConfig.get('success') == false, 
            'Config should be empty or success should be false for invalid agent');
    }

    /**
     * @description Tests error handling for null agent ID in complete configuration
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_NullId() {
        Test.startTest();
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration(null);
        Test.stopTest();

        Assert.isNotNull(completeConfig, 'Complete config should not be null for null agent ID');
        Assert.isTrue(completeConfig.isEmpty() || completeConfig.get('success') == false, 
            'Config should be empty or success should be false for null agent ID');
    }

    /**
     * @description Tests retrieval of agent topics with no associated functions
     */
    @IsTest 
    static void testGetAgentTopics_NoFunctions() {
        Id emptyAgentId = '0Ml000000000003AAA';
        
        Test.startTest();
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(emptyAgentId);
        Test.stopTest();

        Assert.isNotNull(topics, 'Topics list should not be null for agent with no functions');
        Assert.areEqual(0, topics.size(), 'Topics list should be empty for agent with no functions');
    }

    /**
     * @description Tests complete workflow with mock data
     */
    @IsTest
    static void testCompleteWorkflow_Mock() {
        Test.startTest();
        
        // Get agent configuration
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(MOCK_AGENT);
        Assert.isNotNull(config, 'Agent configuration should not be null');
        Assert.areEqual(MOCK_AGENT, config.get('name'), 'Agent name should match mock');
        
        // Get topics for the agent
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(MOCK_AGENT);
        Assert.isNotNull(topics, 'Topics list should not be null');
        Assert.areEqual(1, topics.size(), 'Should have one mock topic');
        
        // Get actions for the topic
        String topicName = (String)topics[0].get('name');
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(topicName);
        Assert.isNotNull(actions, 'Actions list should not be null');
        
        // Get instructions for the topic
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions(topicName);
        Assert.isNotNull(instructions, 'Instructions list should not be null');
        
        // Get complete configuration
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration(MOCK_AGENT);
        Assert.isNotNull(completeConfig, 'Complete configuration should not be null');
        Assert.isTrue((Boolean)completeConfig.get('success'), 'Success should be true');
        
        Test.stopTest();
    }

    /**
     * @description Tests error handling in complete workflow
     */
    @IsTest
    static void testCompleteWorkflow_ErrorHandling() {
        Test.startTest();
        
        // Test with null values
        Map<String, Object> nullConfig = GenAiMetadataService.getAgentConfiguration(null);
        Assert.isTrue(nullConfig.isEmpty(), 'Config should be empty for null agent ID');
        
        List<Map<String, Object>> nullTopics = GenAiMetadataService.getAgentTopics(null);
        Assert.areEqual(0, nullTopics.size(), 'Topics list should be empty for null agent ID');
        
        List<Map<String, Object>> nullActions = GenAiMetadataService.getAgentActions(null);
        Assert.areEqual(0, nullActions.size(), 'Actions list should be empty for null topic');
        
        List<Map<String, Object>> nullInstructions = GenAiMetadataService.getAgentInstructions(null);
        Assert.areEqual(0, nullInstructions.size(), 'Instructions list should be empty for null topic');
        
        Map<String, Object> nullCompleteConfig = GenAiMetadataService.getCompleteAgentConfiguration(null);
        Assert.isTrue(nullCompleteConfig.isEmpty() || nullCompleteConfig.get('success') == false, 
            'Complete config should be empty or success should be false for null agent ID');
        
        // Test with invalid values
        Map<String, Object> invalidConfig = GenAiMetadataService.getAgentConfiguration('InvalidId');
        Assert.isTrue(invalidConfig.isEmpty(), 'Config should be empty for invalid agent ID');
        
        List<Map<String, Object>> invalidTopics = GenAiMetadataService.getAgentTopics('InvalidId');
        Assert.areEqual(0, invalidTopics.size(), 'Topics list should be empty for invalid agent ID');
        
        List<Map<String, Object>> invalidActions = GenAiMetadataService.getAgentActions('InvalidTopic');
        Assert.areEqual(0, invalidActions.size(), 'Actions list should be empty for invalid topic');
        
        List<Map<String, Object>> invalidInstructions = GenAiMetadataService.getAgentInstructions('InvalidTopic');
        Assert.areEqual(0, invalidInstructions.size(), 'Instructions list should be empty for invalid topic');
        
        Map<String, Object> invalidCompleteConfig = GenAiMetadataService.getCompleteAgentConfiguration('InvalidId');
        Assert.isTrue(invalidCompleteConfig.isEmpty() || invalidCompleteConfig.get('success') == false, 
            'Complete config should be empty or success should be false for invalid agent ID');
        
        Test.stopTest();
    }

    /**
     * @description Tests validation of agent configurations using mock data
     */
    @IsTest 
    static void testValidateAgentforceConfigurations_Mock() {
        Test.startTest();
        try {
            String result = GenAiMetadataService.validateAgentforceConfigurations(MOCK_AGENT);
            Assert.fail('Should have thrown an AuraHandledException');
        } catch (AuraHandledException e) {
            // Expected exception
            Assert.isTrue(e.getMessage().length() > 0, 'Exception should have a message');
        }
        Test.stopTest();
    }

    /**
     * @description Tests validateAgentforceConfigurations with various inputs
     */
    @IsTest 
    static void testValidateAgentforceConfigurations_Inputs() {
        Test.startTest();
        
        // Test with null
        try {
            GenAiMetadataService.validateAgentforceConfigurations(null);
            Assert.fail('Should have thrown an AuraHandledException for null input');
        } catch (AuraHandledException e) {
            // Expected exception
            Assert.isTrue(e.getMessage().length() > 0, 'Exception should have a message');
        }

        // Test with empty string
        try {
            GenAiMetadataService.validateAgentforceConfigurations('');
            Assert.fail('Should have thrown an AuraHandledException for empty string');
        } catch (AuraHandledException e) {
            // Expected exception
            Assert.isTrue(e.getMessage().length() > 0, 'Exception should have a message');
        }

        // Test with invalid ID
        try {
            GenAiMetadataService.validateAgentforceConfigurations('InvalidId');
            Assert.fail('Should have thrown an AuraHandledException for invalid ID');
        } catch (AuraHandledException e) {
            // Expected exception
            Assert.isTrue(e.getMessage().length() > 0, 'Exception should have a message');
        }

        Test.stopTest();
    }

    /**
     * @description Tests exception handling in getAgentConfiguration with invalid query
     */
    @IsTest 
    static void testGetAgentConfiguration_QueryException() {
        // Create a mock ID that would cause a QueryException
        Id invalidId = '00D000000000001AAA';
        
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(invalidId);
        Test.stopTest();

        Assert.isNotNull(config, 'Config should not be null on exception');
        Assert.isTrue(config.isEmpty(), 'Config should be empty on exception');
    }

    /**
     * @description Tests exception handling in getAgentTopics with invalid query
     */
    @IsTest 
    static void testGetAgentTopics_QueryException() {
        // Create a mock ID that would cause a QueryException
        Id invalidId = '00D000000000001AAA';
        
        Test.startTest();
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(invalidId);
        Test.stopTest();

        Assert.isNotNull(topics, 'Topics list should not be null on exception');
        Assert.areEqual(0, topics.size(), 'Topics list should be empty on exception');
    }

    /**
     * @description Tests exception handling in getAgentActions with invalid query
     */
    @IsTest 
    static void testGetAgentActions_QueryException() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions('Invalid.Topic.Name');
        Test.stopTest();

        Assert.isNotNull(actions, 'Actions list should not be null on exception');
        Assert.areEqual(0, actions.size(), 'Actions list should be empty on exception');
    }

    /**
     * @description Tests exception handling in getAgentInstructions with invalid query
     */
    @IsTest 
    static void testGetAgentInstructions_QueryException() {
        Test.startTest();
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions('Invalid.Topic.Name');
        Test.stopTest();

        Assert.isNotNull(instructions, 'Instructions list should not be null on exception');
        Assert.areEqual(0, instructions.size(), 'Instructions list should be empty on exception');
    }

    /**
     * @description Tests exception handling in getAllAgents
     */
    @IsTest 
    static void testGetAllAgents_Exception() {
        Test.startTest();
        List<Map<String, Object>> agents = GenAiMetadataService.getAllAgents();
        Test.stopTest();

        Assert.isNotNull(agents, 'Agents list should not be null on exception');
    }

    /**
     * @description Tests getCompleteAgentConfiguration with various input types
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_InputTypes() {
        Test.startTest();
        
        // Test with empty string
        Map<String, Object> emptyConfig = GenAiMetadataService.getCompleteAgentConfiguration('');
        Assert.isNotNull(emptyConfig, 'Config should not be null for empty string');
        Assert.isTrue(emptyConfig.isEmpty() || emptyConfig.get('success') == false, 
            'Config should be empty or success should be false for empty string');

        // Test with special characters
        Map<String, Object> specialConfig = GenAiMetadataService.getCompleteAgentConfiguration('!@#$%^&*()');
        Assert.isNotNull(specialConfig, 'Config should not be null for special characters');
        Assert.isTrue(specialConfig.isEmpty() || specialConfig.get('success') == false, 
            'Config should be empty or success should be false for special characters');

        // Test with very long string
        String longString = 'a'.repeat(255);
        Map<String, Object> longConfig = GenAiMetadataService.getCompleteAgentConfiguration(longString);
        Assert.isNotNull(longConfig, 'Config should not be null for long string');
        Assert.isTrue(longConfig.isEmpty() || longConfig.get('success') == false, 
            'Config should be empty or success should be false for long string');

        Test.stopTest();
    }
}