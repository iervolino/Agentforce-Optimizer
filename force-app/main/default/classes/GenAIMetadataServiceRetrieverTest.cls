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
    
    /**
     * @description Tests successful prompt generation using real agent data.
     */
    @IsTest
    static void testSuccessfulPromptGeneration() {
        // First get functions
        List<GenAiPlannerFunctionDef> functions = [
            SELECT PlannerId 
            FROM GenAiPlannerFunctionDef 
            WHERE IsDeleted = false
        ];
        
        // Extract planner IDs
        Set<Id> plannerIds = new Set<Id>();
        for(GenAiPlannerFunctionDef func : functions) {
            plannerIds.add(func.PlannerId);
        }
        
        // Then query for agents using the collected IDs
        List<GenAiPlannerDefinition> agents = [
            SELECT Id, DeveloperName 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            AND Id IN :plannerIds
            LIMIT 1
        ];
        
        // Skip test if no agents with topics exist
        if (agents.isEmpty()) {
            return;
        }
        
        // Create test request using real agent
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = agents[0].Id;
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();
        
        // Verify response
        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        GenAIMetadataServiceRetriever.Response response = responses[0];
        Assert.isNotNull(response.Prompt, 'Prompt should not be null');
        
        // Verify prompt content
        String prompt = response.Prompt;
        Assert.isTrue(prompt.contains('Agent Configuration:'), 'Prompt missing Agent Configuration section');
        Assert.isTrue(prompt.contains('Name: ' + agents[0].DeveloperName), 'Prompt missing agent name');
    }
    
    /**
     * @description Tests prompt generation for an agent with no topics
     */
    @IsTest
    static void testPromptGeneration_NoTopics() {
        // First get all plugins
        List<GenAiPluginDefinition> plugins = [
            SELECT ParentId 
            FROM GenAiPluginDefinition 
            WHERE IsDeleted = false
        ];
        
        // Extract parent IDs
        Set<Id> agentsWithTopics = new Set<Id>();
        for(GenAiPluginDefinition plugin : plugins) {
            agentsWithTopics.add(plugin.ParentId);
        }
        
        // Then query for agents that don't have topics
        List<GenAiPlannerDefinition> agents = [
            SELECT Id, DeveloperName 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            AND Id NOT IN :agentsWithTopics
            LIMIT 1
        ];
        
        // Skip test if no agents without topics exist
        if (agents.isEmpty()) {
            return;
        }
        
        // Create test request
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = agents[0].Id;
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();
        
        // Verify response
        Assert.isNotNull(responses, 'Response should not be null');
        GenAIMetadataServiceRetriever.Response response = responses[0];
        String prompt = response.Prompt;
        Assert.isTrue(prompt.contains('Agent Configuration:'), 'Prompt missing Agent Configuration section');
        Assert.isFalse(prompt.contains('Topics:'), 'Prompt should not contain Topics section');
    }
    
    /**
     * @description Tests prompt generation for a topic with no actions or instructions
     */
    @IsTest
    static void testPromptGeneration_TopicNoActionsOrInstructions() {
        // First get plugins that have no functions or instructions
        List<GenAiPluginDefinition> plugins = [
            SELECT ParentId 
            FROM GenAiPluginDefinition 
            WHERE IsDeleted = false
        ];
        
        // Get all plugins that have functions
        List<GenAiPluginFunctionDef> functions = [
            SELECT PluginId 
            FROM GenAiPluginFunctionDef 
            WHERE IsDeleted = false
        ];
        
        // Get all plugins that have instructions
        List<GenAiPluginInstructionDef> instructions = [
            SELECT GenAiPluginDefinitionId 
            FROM GenAiPluginInstructionDef 
            WHERE IsDeleted = false
        ];
        
        // Create sets for plugins with functions or instructions
        Set<Id> pluginsWithFunctions = new Set<Id>();
        for(GenAiPluginFunctionDef func : functions) {
            pluginsWithFunctions.add(func.PluginId);
        }
        
        Set<Id> pluginsWithInstructions = new Set<Id>();
        for(GenAiPluginInstructionDef inst : instructions) {
            pluginsWithInstructions.add(inst.GenAiPluginDefinitionId);
        }
        
        // Find plugins with no functions or instructions
        Set<Id> agentIds = new Set<Id>();
        for(GenAiPluginDefinition plugin : plugins) {
            if(!pluginsWithFunctions.contains(plugin.Id) && 
               !pluginsWithInstructions.contains(plugin.Id)) {
                agentIds.add(plugin.ParentId);
            }
        }
        
        // Query for agents that have such plugins
        List<GenAiPlannerDefinition> agents = [
            SELECT Id, DeveloperName 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            AND Id IN :agentIds
            LIMIT 1
        ];
        
        // Skip test if no suitable agents exist
        if (agents.isEmpty()) {
            return;
        }
        
        // Create test request
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = agents[0].Id;
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();
        
        // Verify response
        Assert.isNotNull(responses, 'Response should not be null');
        GenAIMetadataServiceRetriever.Response response = responses[0];
        String prompt = response.Prompt;
        Assert.isTrue(prompt.contains('Topics:'), 'Prompt missing Topics section');
        Assert.isFalse(prompt.contains('Actions:'), 'Prompt should not contain Actions section');
        Assert.isFalse(prompt.contains('Instructions:'), 'Prompt should not contain Instructions section');
    }
    
    /**
     * @description Tests error handling when the underlying service fails to find the agent.
     */
    @IsTest
    static void testErrorHandling_AgentNotFound() {
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = 'NonExistentAgent';
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();
        
        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        GenAIMetadataServiceRetriever.Response response = responses[0];
        Assert.isNotNull(response.Prompt, 'Prompt should not be null');
        Assert.isTrue(response.Prompt.contains('No configuration found for agent ID:') || 
                      response.Prompt.contains('Error generating prompt template'), 
                      'Prompt should contain agent not found error message');
    }

    /**
     * @description Tests the scenario where the input request list is empty.
     */
    @IsTest
    static void testEmptyRequestList() {
        Exception thrownException = null;
        Test.startTest();
        try {
            List<GenAIMetadataServiceRetriever.Response> responses = 
                GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>());
        } catch (Exception e) {
            thrownException = e;
        }
        Test.stopTest();

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
        request.AgentId = null;

        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();

        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        
        GenAIMetadataServiceRetriever.Response response = responses[0];
        Assert.isNotNull(response.Prompt, 'Prompt should not be null');
        Assert.isTrue(response.Prompt.contains('No configuration found') || response.Prompt.contains('Error'), 
                      'Prompt should contain an error or not found message for null agent ID');
    }
    
    /**
     * @description Tests exception handling in generatePromptTemplate
     */
    @IsTest
    static void testGeneratePromptTemplate_ExceptionHandling() {
        // Create an invalid ID that will cause an exception
        String invalidId = 'InvalidId';
        
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = invalidId;
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
        Test.stopTest();
        
        Assert.isNotNull(responses, 'Response should not be null');
        GenAIMetadataServiceRetriever.Response response = responses[0];
        Assert.isTrue(response.Prompt.contains('Error generating prompt template') || 
                     response.Prompt.contains('No configuration found'), 
                     'Should handle exception gracefully');
    }

    /**
     * @description Tests prompt generation with null request
     */
    @IsTest
    static void testPromptGeneration_NullRequest() {
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{null});
        Test.stopTest();

        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        Assert.isTrue(responses[0].Prompt.contains('Error'), 'Should contain error message for null request');
    }

    /**
     * @description Tests prompt generation with multiple requests
     */
    @IsTest
    static void testPromptGeneration_MultipleRequests() {
        // Create two requests with the same valid agent ID
        List<GenAiPlannerFunctionDef> functions = [
            SELECT PlannerId 
            FROM GenAiPlannerFunctionDef 
            WHERE IsDeleted = false
            LIMIT 1
        ];
        
        // Skip test if no agents exist
        if (functions.isEmpty()) {
            return;
        }

        Id validAgentId = functions[0].PlannerId;
        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>();
        
        // Add two requests with the same valid agent ID
        for(Integer i = 0; i < 2; i++) {
            GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
            request.AgentId = validAgentId;
            requests.add(request);
        }

        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(requests);
        Test.stopTest();

        // Debug information
        System.debug('Number of requests: ' + requests.size());
        System.debug('Number of responses: ' + responses.size());
        
        Assert.isNotNull(responses, 'Responses should not be null');
        Assert.isTrue(responses.size() > 0, 'Should have at least one response');
        
        // Verify the response content
        GenAIMetadataServiceRetriever.Response response = responses[0];
        Assert.isNotNull(response.Prompt, 'Prompt should not be null');
        Assert.isTrue(response.Prompt.contains('Agent Configuration:'), 
            'Prompt should contain Agent Configuration section');
    }

    /**
     * @description Tests prompt generation with various error scenarios
     */
    @IsTest
    static void testPromptGeneration_ErrorScenarios() {
        Test.startTest();
        
        // Test with invalid agent ID format
        GenAIMetadataServiceRetriever.Request invalidRequest = new GenAIMetadataServiceRetriever.Request();
        invalidRequest.AgentId = 'INVALID_FORMAT';
        List<GenAIMetadataServiceRetriever.Response> invalidResponses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{invalidRequest});
        Assert.isNotNull(invalidResponses, 'Response should not be null for invalid format');
        Assert.isTrue(invalidResponses[0].Prompt.contains('Error') || 
                     invalidResponses[0].Prompt.contains('No configuration found'), 
                     'Should handle invalid format appropriately');

        // Test with malformed ID to force SOQL exception
        GenAIMetadataServiceRetriever.Request malformedRequest = new GenAIMetadataServiceRetriever.Request();
        malformedRequest.AgentId = '123'; // Invalid ID format
        List<GenAIMetadataServiceRetriever.Response> malformedResponses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{malformedRequest});
        Assert.isTrue(malformedResponses[0].Prompt.contains('Error') || 
                     malformedResponses[0].Prompt.contains('No configuration found'), 
                     'Should handle malformed ID appropriately');

        // Test with very long agent ID
        GenAIMetadataServiceRetriever.Request longRequest = new GenAIMetadataServiceRetriever.Request();
        longRequest.AgentId = 'a'.repeat(255); // Max length string
        List<GenAIMetadataServiceRetriever.Response> longResponses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{longRequest});
        Assert.isTrue(longResponses[0].Prompt.contains('Error') || 
                     longResponses[0].Prompt.contains('No configuration found'), 
                     'Should handle long ID appropriately');

        Test.stopTest();
    }

    /**
     * @description Tests prompt generation with mixed valid and invalid requests
     */
    @IsTest
    static void testPromptGeneration_MixedRequests() {
        // Get a valid agent ID
        List<GenAiPlannerFunctionDef> functions = [
            SELECT PlannerId 
            FROM GenAiPlannerFunctionDef 
            WHERE IsDeleted = false
            LIMIT 1
        ];
        
        // Skip test if no valid agents exist
        if (functions.isEmpty()) {
            return;
        }

        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>();
        
        // Add valid request
        GenAIMetadataServiceRetriever.Request validRequest = new GenAIMetadataServiceRetriever.Request();
        validRequest.AgentId = functions[0].PlannerId;
        requests.add(validRequest);

        // Add invalid request
        GenAIMetadataServiceRetriever.Request invalidRequest = new GenAIMetadataServiceRetriever.Request();
        invalidRequest.AgentId = 'INVALID_ID';
        requests.add(invalidRequest);

        Test.startTest();
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(requests);
        Test.stopTest();

        Assert.isNotNull(responses, 'Responses should not be null');
        Assert.isTrue(responses.size() > 0, 'Should have at least one response');
        
        // At least one response should be valid
        Boolean hasValidResponse = false;
        Boolean hasErrorResponse = false;
        
        for(GenAIMetadataServiceRetriever.Response response : responses) {
            if(response.Prompt.contains('Agent Configuration:')) {
                hasValidResponse = true;
            }
            if(response.Prompt.contains('Error') || response.Prompt.contains('No configuration found')) {
                hasErrorResponse = true;
            }
        }
        
        Assert.isTrue(hasValidResponse, 'Should have at least one valid response');
    }

    /**
     * @description Tests prompt generation with null values in request
     */
    @IsTest
    static void testPromptGeneration_NullValues() {
        Test.startTest();
        
        // Test with null request
        List<GenAIMetadataServiceRetriever.Response> nullRequestResponse = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{null});
        Assert.isNotNull(nullRequestResponse, 'Response should not be null for null request');
        Assert.isTrue(nullRequestResponse[0].Prompt.contains('Error'), 'Should handle null request appropriately');

        // Test with request containing null agent ID
        GenAIMetadataServiceRetriever.Request nullIdRequest = new GenAIMetadataServiceRetriever.Request();
        nullIdRequest.AgentId = null;
        List<GenAIMetadataServiceRetriever.Response> nullIdResponse = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{nullIdRequest});
        Assert.isTrue(nullIdResponse[0].Prompt.contains('Error') || 
                     nullIdResponse[0].Prompt.contains('No configuration found'), 
                     'Should handle null agent ID appropriately');

        Test.stopTest();
    }

    /**
     * @description Tests prompt generation with empty string values
     */
    @IsTest
    static void testPromptGeneration_EmptyValues() {
        Test.startTest();
        
        // Test with empty agent ID
        GenAIMetadataServiceRetriever.Request emptyRequest = new GenAIMetadataServiceRetriever.Request();
        emptyRequest.AgentId = '';
        List<GenAIMetadataServiceRetriever.Response> emptyResponses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{emptyRequest});
        Assert.isTrue(emptyResponses[0].Prompt.contains('Error') || 
                     emptyResponses[0].Prompt.contains('No configuration found'), 
                     'Should handle empty agent ID appropriately');

        // Test with whitespace agent ID
        GenAIMetadataServiceRetriever.Request whitespaceRequest = new GenAIMetadataServiceRetriever.Request();
        whitespaceRequest.AgentId = '   ';
        List<GenAIMetadataServiceRetriever.Response> whitespaceResponses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{whitespaceRequest});
        Assert.isTrue(whitespaceResponses[0].Prompt.contains('Error') || 
                     whitespaceResponses[0].Prompt.contains('No configuration found'), 
                     'Should handle whitespace agent ID appropriately');

        Test.stopTest();
    }

    /**
     * @description Tests prompt generation with special characters
     */
    @IsTest
    static void testPromptGeneration_SpecialCharacters() {
        Test.startTest();
        
        // Test with special characters in agent ID
        GenAIMetadataServiceRetriever.Request specialRequest = new GenAIMetadataServiceRetriever.Request();
        specialRequest.AgentId = '!@#$%^&*()';
        List<GenAIMetadataServiceRetriever.Response> specialResponses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{specialRequest});
        Assert.isTrue(specialResponses[0].Prompt.contains('Error') || 
                     specialResponses[0].Prompt.contains('No configuration found'), 
                     'Should handle special characters appropriately');

        // Test with SQL injection attempt
        GenAIMetadataServiceRetriever.Request sqlRequest = new GenAIMetadataServiceRetriever.Request();
        sqlRequest.AgentId = '1\' OR \'1\'=\'1';
        List<GenAIMetadataServiceRetriever.Response> sqlResponses = 
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{sqlRequest});
        Assert.isTrue(sqlResponses[0].Prompt.contains('Error') || 
                     sqlResponses[0].Prompt.contains('No configuration found'), 
                     'Should handle SQL injection attempt appropriately');

        Test.stopTest();
    }

    /**
     * @description Tests prompt generation with maximum request list size
     */
    @IsTest
    static void testPromptGeneration_MaxRequests() {
        Test.startTest();
        
        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>();
        for(Integer i = 0; i < 100; i++) {
            GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
            request.AgentId = 'TestId' + i;
            requests.add(request);
        }
        
        List<GenAIMetadataServiceRetriever.Response> responses = 
            GenAIMetadataServiceRetriever.getPrompt(requests);
        
        Assert.isNotNull(responses, 'Response should not be null for max requests');

        Test.stopTest();
    }

    /**
     * @description Tests request and response object creation and validation
     */
    @IsTest
    static void testObjectCreation_Validation() {
        Test.startTest();
        
        // Test Request object with valid ID
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = '001000000000000AAA';
        Assert.areEqual('001000000000000AAA', request.AgentId, 'Request AgentId should be set correctly');
        
        // Test Response object with valid prompt
        GenAIMetadataServiceRetriever.Response response = new GenAIMetadataServiceRetriever.Response();
        response.Prompt = 'Test Prompt';
        Assert.areEqual('Test Prompt', response.Prompt, 'Response Prompt should be set correctly');

        // Test empty request list handling
        Exception emptyListException = null;
        try {
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>());
        } catch (Exception e) {
            emptyListException = e;
        }
        Assert.isNotNull(emptyListException, 'Should throw exception for empty list');

        Test.stopTest();
    }

    /**
     * @description Tests prompt generation with empty topics list
     */
    @IsTest
    static void testPromptGeneration_EmptyTopics() {
        // Query for an agent that has no topics
        List<GenAiPlannerDefinition> agents = [
            SELECT Id 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            AND Id NOT IN (SELECT ParentId FROM GenAiPluginDefinition WHERE IsDeleted = false)
            LIMIT 1
        ];
        
        // Skip test if no such agents exist
        if (agents.isEmpty()) {
            return;
        }
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>();
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = agents[0].Id;
        requests.add(request);
        
        List<GenAIMetadataServiceRetriever.Response> responses = GenAIMetadataServiceRetriever.getPrompt(requests);
        Test.stopTest();
        
        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        Assert.isTrue(responses[0].Prompt.contains('Agent Configuration:'), 'Should contain agent configuration');
        Assert.isFalse(responses[0].Prompt.contains('Topics:'), 'Should not contain topics section');
    }

    /**
     * @description Tests prompt generation with topics that have no actions or instructions
     */
    @IsTest
    static void testPromptGeneration_TopicsWithoutActionsOrInstructions() {
        // Query for plugins that have no functions or instructions
        List<GenAiPluginDefinition> plugins = [
            SELECT ParentId 
            FROM GenAiPluginDefinition 
            WHERE IsDeleted = false 
            AND Id NOT IN (SELECT PluginId FROM GenAiPluginFunctionDef WHERE IsDeleted = false)
            AND Id NOT IN (SELECT GenAiPluginDefinitionId FROM GenAiPluginInstructionDef WHERE IsDeleted = false)
            LIMIT 1
        ];
        
        // Skip test if no such plugins exist
        if (plugins.isEmpty()) {
            return;
        }
        
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>();
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        request.AgentId = plugins[0].ParentId;
        requests.add(request);
        
        List<GenAIMetadataServiceRetriever.Response> responses = GenAIMetadataServiceRetriever.getPrompt(requests);
        Test.stopTest();
        
        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        String prompt = responses[0].Prompt;
        Assert.isTrue(prompt.contains('Topics:'), 'Should contain topics section');
        Assert.isFalse(prompt.contains('Actions:'), 'Should not contain actions section');
        Assert.isFalse(prompt.contains('Instructions:'), 'Should not contain instructions section');
    }

    /**
     * @description Tests prompt generation with null agent configuration
     */
    @IsTest
    static void testPromptGeneration_NullAgentConfig() {
        Test.startTest();
        List<GenAIMetadataServiceRetriever.Request> requests = new List<GenAIMetadataServiceRetriever.Request>();
        GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
        // Use a valid format ID that doesn't exist
        request.AgentId = '0Hn000000000001AAA';
        requests.add(request);
        
        List<GenAIMetadataServiceRetriever.Response> responses = GenAIMetadataServiceRetriever.getPrompt(requests);
        Test.stopTest();
        
        Assert.isNotNull(responses, 'Response should not be null');
        Assert.areEqual(1, responses.size(), 'Should have one response');
        Assert.isTrue(responses[0].Prompt.contains('No configuration found for agent ID:'), 
            'Should indicate no configuration found');
    }

    /**
     * @description Tests prompt generation with empty request list
     */
    @IsTest
    static void testPromptGeneration_EmptyRequestList() {
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>());
        } catch (Exception e) {
            exceptionThrown = true;
            Assert.isTrue(e instanceof System.ListException, 'Should throw ListException');
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Should throw exception for empty request list');
    }

    /**
     * @description Tests prompt generation with null request list
     */
    @IsTest
    static void testPromptGeneration_NullRequestList() {
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            GenAIMetadataServiceRetriever.getPrompt(null);
        } catch (Exception e) {
            exceptionThrown = true;
            Assert.isTrue(e instanceof System.NullPointerException, 'Should throw NullPointerException');
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Should throw exception for null request list');
    }

    /**
     * @description Tests prompt generation for all available agents in the org
     */
    @IsTest
    static void testPromptGeneration_AllAgents() {
        // Query all available agents
        List<GenAiPlannerDefinition> agents = [
            SELECT Id, DeveloperName 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false
        ];
        
        // Skip test if no agents exist
        if (agents.isEmpty()) {
            return;
        }
        
        Test.startTest();
        
        // Test each agent
        for(GenAiPlannerDefinition agent : agents) {
            // Create request for current agent
            GenAIMetadataServiceRetriever.Request request = new GenAIMetadataServiceRetriever.Request();
            request.AgentId = agent.Id;
            
            // Get prompt for current agent
            List<GenAIMetadataServiceRetriever.Response> responses = 
                GenAIMetadataServiceRetriever.getPrompt(new List<GenAIMetadataServiceRetriever.Request>{request});
            
            // Verify response
            Assert.isNotNull(responses, 'Response should not be null for agent: ' + agent.DeveloperName);
            Assert.areEqual(1, responses.size(), 'Should have one response for agent: ' + agent.DeveloperName);
            
            GenAIMetadataServiceRetriever.Response response = responses[0];
            Assert.isNotNull(response.Prompt, 'Prompt should not be null for agent: ' + agent.DeveloperName);
            
            // Verify prompt content
            String prompt = response.Prompt;
            Assert.isTrue(prompt.contains('Agent Configuration:'), 
                'Prompt missing Agent Configuration section for agent: ' + agent.DeveloperName);
            Assert.isTrue(prompt.contains('Name:'), 
                'Prompt missing Name field for agent: ' + agent.DeveloperName);
        }
        
        Test.stopTest();
    }
}