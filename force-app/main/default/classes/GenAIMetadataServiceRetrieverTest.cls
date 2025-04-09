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
    
    // Using the same mock constants as GenAiMetadataService
    private static final String TEST_AGENT = 'TestAgent'; 
    private static final String TEST_TOPIC = 'TestTopic';
    
    /**
     * @description Tests successful prompt generation using mock data from GenAiMetadataService.
     * Verifies that the getPrompt method correctly generates a prompt containing
     * agent configuration and topics for a valid test agent ID.
     */
    @IsTest
    static void testSuccessfulPromptGeneration() {
        // Create test request using the mock agent name
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = TEST_AGENT;
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();
        
        // Verify response
        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        GenAIMetadataServiceRetriever.Response response = responses[0];
        Assert.isNotNull(response.Prompt, 'Prompt should not be null');
        
        // Verify prompt content based on mock data structure
        Assert.isTrue(response.Prompt.contains('Agent Configuration:'), 'Prompt missing Agent Configuration section');
        Assert.isTrue(response.Prompt.contains('Name: ' + TEST_AGENT), 'Prompt missing mock agent name');
        Assert.isTrue(response.Prompt.contains('Label: Test Agent'), 'Prompt missing mock agent label');
        Assert.isTrue(response.Prompt.contains('Topics:'), 'Prompt missing Topics section');
        Assert.isTrue(response.Prompt.contains('Topic: Test Topic'), 'Prompt missing mock topic label');
        Assert.isTrue(response.Prompt.contains('Description: Test Topic Description'), 'Prompt missing mock topic description');
        // Actions and Instructions are empty in the mock data path for getAgentActions/Instructions
        Assert.isFalse(response.Prompt.contains('Actions:'), 'Prompt should not contain Actions section for mock topic');
        Assert.isFalse(response.Prompt.contains('Instructions:'), 'Prompt should not contain Instructions section for mock topic');
    }
    
    /**
     * @description Tests error handling when the underlying service fails to find the agent.
     * Verifies that the getPrompt method returns an error message.
     */
    @IsTest
    static void testErrorHandling_AgentNotFound() {
        // Create test request with an agent ID that GenAiMetadataService will return empty map for (in test context)
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = 'NonExistentAgent';
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();
        
        // Verify error response
        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        GenAIMetadataServiceRetriever.Response response = responses[0];
        Assert.isNotNull(response.Prompt, 'Prompt should not be null');
        // Check for the specific error message generated when agentConfig is empty
        Assert.isTrue(response.Prompt.contains('No configuration found for agent ID:') || 
                      response.Prompt.contains('Error generating prompt template'), 
                      'Prompt should contain agent not found error message');
    }

    /**
     * @description Tests the scenario where the input request list is empty.
     * Verifies that the getPrompt method handles this gracefully (though it currently throws an error).
     */
    @IsTest
    static void testEmptyRequestList() {
        Exception thrownException = null;
        Test.startTest();
        try {
            // Call with an empty list
            List<GenAIMetadataServiceRetriever.Response> responses = 
                GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>());
        } catch (Exception e) {
            thrownException = e;
        }
        Test.stopTest();

        // The current implementation will throw a ListException: List index out of bounds: 0
        Assert.isNotNull(thrownException, 'An exception should be thrown for empty request list');
        Assert.isInstanceOfType(thrownException, System.ListException.class, 
            'Expected ListException for empty request list, but got: ' + thrownException.getTypeName());
    }

    /**
     * @description Tests the scenario where the Request object has a null AgentId.
     */
    @IsTest
    static void testNullAgentId() {
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = null; // Explicitly set to null
        Exception thrownException = null;

        Test.startTest();
         List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();

        // Verify error response because getAgentConfiguration will likely fail or return empty
        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        GenAIMetadataServiceRetriever.Response response = responses[0];
        Assert.isNotNull(response.Prompt, 'Prompt should not be null');
        Assert.isTrue(response.Prompt.contains('No configuration found') || response.Prompt.contains('Error'), 
                      'Prompt should contain an error or not found message for null agent ID');
    }
}