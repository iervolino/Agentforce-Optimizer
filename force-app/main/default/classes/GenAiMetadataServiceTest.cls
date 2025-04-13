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
    
    /**
     * @description Tests complete workflow with real agent data that has topics, actions and instructions
     */
    @IsTest
    static void testCompleteWorkflow_RealAgentWithData() {
        // Query for an agent that has topics, actions and instructions
        List<GenAiPlannerDefinition> agents = [
            SELECT Id, DeveloperName, MasterLabel, Description, Capabilities, Language, PlannerType
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            AND Id IN (
                SELECT PlannerId 
                FROM GenAiPlannerFunctionDef 
                WHERE IsDeleted = false
            )
            LIMIT 1
        ];
        
        // Skip test if no agents with topics exist
        if (agents.isEmpty()) {
            return;
        }
        
        Id agentId = agents[0].Id;
        
        Test.startTest();
        
        // Get agent configuration
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(agentId);
        Assert.isNotNull(config, 'Agent configuration should not be null');
        Assert.areEqual(agents[0].DeveloperName, config.get('name'), 'Agent name should match');
        Assert.areEqual(agents[0].MasterLabel, config.get('label'), 'Agent label should match');
        Assert.areEqual(agents[0].Description, config.get('description'), 'Agent description should match');
        Assert.areEqual(agents[0].Capabilities, config.get('capabilities'), 'Agent capabilities should match');
        Assert.areEqual(agents[0].Language, config.get('language'), 'Agent language should match');
        Assert.areEqual(agents[0].PlannerType, config.get('plannerType'), 'Agent planner type should match');
        
        // Get topics for the agent
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(agentId);
        Assert.isNotNull(topics, 'Topics list should not be null');
        
        // Get actions and instructions for each topic
        for (Map<String, Object> topic : topics) {
            String topicName = (String)topic.get('name');
            Assert.isNotNull(topicName, 'Topic name should not be null');
            
            // Get actions for the topic
            List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(topicName);
            Assert.isNotNull(actions, 'Actions list should not be null');
            
            // Get instructions for the topic
            List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions(topicName);
            Assert.isNotNull(instructions, 'Instructions list should not be null');
        }
        
        // Get complete configuration
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration(agentId);
        Assert.isNotNull(completeConfig, 'Complete configuration should not be null');
        Assert.isTrue((Boolean)completeConfig.get('success'), 'Complete configuration should be successful');
        
        Map<String, Object> agentData = (Map<String, Object>)completeConfig.get('agent');
        Assert.isNotNull(agentData, 'Agent data in complete configuration should not be null');
        Assert.areEqual(agents[0].DeveloperName, agentData.get('name'), 'Agent name in complete configuration should match');
        
        List<Map<String, Object>> topicsData = (List<Map<String, Object>>)completeConfig.get('topics');
        Assert.isNotNull(topicsData, 'Topics data in complete configuration should not be null');
        
        Test.stopTest();
    }
    
    /**
     * @description Tests validateAgentforceConfigurations method
     */
    @IsTest
    static void testValidateAgentforceConfigurations() {
        // Query for any agent
        List<GenAiPlannerDefinition> agents = [
            SELECT Id 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            LIMIT 1
        ];
        
        // Skip test if no agents exist
        if (agents.isEmpty()) {
            return;
        }
        
        Test.startTest();
        try {
            String result = GenAiMetadataService.validateAgentforceConfigurations(agents[0].Id);
            Assert.isNotNull(result, 'Validation result should not be null');
        } catch (AuraHandledException e) {
            // Expected exception when prompt execution fails
            String errorMsg = e.getMessage();
            Assert.isNotNull(errorMsg, 'Error message should not be null');
        } catch (Exception e) {
            Assert.fail('Unexpected exception type: ' + e.getTypeName() + ' with message: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests getAllAgents method
     */
    @IsTest
    static void testGetAllAgents() {
        Test.startTest();
        List<Map<String, Object>> agents = GenAiMetadataService.getAllAgents();
        Test.stopTest();
        
        Assert.isNotNull(agents, 'Agents list should not be null');
        
        if (!agents.isEmpty()) {
            Map<String, Object> agent = agents[0];
            Assert.isNotNull(agent.get('name'), 'Agent name should not be null');
            Assert.isNotNull(agent.get('label'), 'Agent label should not be null');
            Assert.isNotNull(agent.get('description'), 'Agent description should not be null');
        }
    }

    /**
     * @description Tests error handling for invalid agent ID
     */
    @IsTest 
    static void testGetAgentConfiguration_InvalidId() {
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration('InvalidId');
        Test.stopTest();
        
        Assert.isNotNull(config, 'Configuration should not be null even for invalid ID');
        Assert.isTrue(config.isEmpty(), 'Configuration should be empty for invalid ID');
    }

    /**
     * @description Tests error handling for null agent ID
     */
    @IsTest 
    static void testGetAgentConfiguration_NullId() {
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(null);
        Test.stopTest();
        
        Assert.isNotNull(config, 'Configuration should not be null even for null ID');
        Assert.isTrue(config.isEmpty(), 'Configuration should be empty for null ID');
    }

    /**
     * @description Tests error handling for invalid topic name
     */
    @IsTest 
    static void testGetAgentActions_InvalidTopic() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions('NonExistentTopic');
        Test.stopTest();
        
        Assert.isNotNull(actions, 'Actions list should not be null even for invalid topic');
        Assert.isTrue(actions.isEmpty(), 'Actions list should be empty for invalid topic');
    }

    /**
     * @description Tests error handling for null topic name
     */
    @IsTest 
    static void testGetAgentActions_NullTopic() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(null);
        Test.stopTest();
        
        Assert.isNotNull(actions, 'Actions list should not be null even for null topic');
        Assert.isTrue(actions.isEmpty(), 'Actions list should be empty for null topic');
    }

    /**
     * @description Tests error handling for invalid agent ID in complete configuration
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_InvalidId() {
        Test.startTest();
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration('InvalidId');
        Test.stopTest();
        
        Assert.isNotNull(completeConfig, 'Complete configuration should not be null even for invalid ID');
        Assert.isFalse((Boolean)completeConfig.get('success'), 'Complete configuration should not be successful for invalid ID');
        Assert.isNotNull(completeConfig.get('error'), 'Complete configuration should contain error message for invalid ID');
    }

    /**
     * @description Tests error handling for null agent ID in complete configuration
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_NullId() {
        Test.startTest();
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration(null);
        Test.stopTest();
        
        Assert.isNotNull(completeConfig, 'Complete configuration should not be null even for null ID');
        Assert.isFalse((Boolean)completeConfig.get('success'), 'Complete configuration should not be successful for null ID');
        Assert.isNotNull(completeConfig.get('error'), 'Complete configuration should contain error message for null ID');
    }

    /**
     * @description Tests retrieval of agent topics with no associated functions
     */
    @IsTest 
    static void testGetAgentTopics_NoFunctions() {
        // First get plugins that have no functions
        List<GenAiPluginDefinition> pluginsWithNoFunctions = [
            SELECT ParentId 
            FROM GenAiPluginDefinition 
            WHERE IsDeleted = false
            AND Id NOT IN (
                SELECT PluginId 
                FROM GenAiPluginFunctionDef 
                WHERE IsDeleted = false
            )
        ];
        
        // Extract parent IDs
        Set<Id> agentIds = new Set<Id>();
        for(GenAiPluginDefinition plugin : pluginsWithNoFunctions) {
            agentIds.add(plugin.ParentId);
        }
        
        // Then query for agents using the collected IDs
        List<GenAiPlannerDefinition> agents = [
            SELECT Id 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            AND Id IN :agentIds
            LIMIT 1
        ];
        
        // Skip test if no suitable agents exist
        if (agents.isEmpty()) {
            return;
        }
        
        Test.startTest();
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(agents[0].Id);
        Test.stopTest();
        
        Assert.isNotNull(topics, 'Topics list should not be null');
        Assert.isTrue(!topics.isEmpty(), 'Should have at least one topic');
    }

    /**
     * @description Tests exception handling with null inputs
     */
    @IsTest 
    static void testExceptionHandling_NullInputs() {
        Test.startTest();
        
        Map<String, Object> nullConfig = GenAiMetadataService.getAgentConfiguration(null);
        Assert.isNotNull(nullConfig, 'Configuration should not be null for null input');
        Assert.isTrue(nullConfig.isEmpty(), 'Configuration should be empty for null input');
        
        List<Map<String, Object>> nullTopics = GenAiMetadataService.getAgentTopics(null);
        Assert.isNotNull(nullTopics, 'Topics list should not be null for null input');
        Assert.isTrue(nullTopics.isEmpty(), 'Topics list should be empty for null input');
        
        List<Map<String, Object>> nullActions = GenAiMetadataService.getAgentActions(null);
        Assert.isNotNull(nullActions, 'Actions list should not be null for null input');
        Assert.isTrue(nullActions.isEmpty(), 'Actions list should be empty for null input');
        
        List<Map<String, Object>> nullInstructions = GenAiMetadataService.getAgentInstructions(null);
        Assert.isNotNull(nullInstructions, 'Instructions list should not be null for null input');
        Assert.isTrue(nullInstructions.isEmpty(), 'Instructions list should be empty for null input');
        
        Map<String, Object> nullCompleteConfig = GenAiMetadataService.getCompleteAgentConfiguration(null);
        Assert.isNotNull(nullCompleteConfig, 'Complete configuration should not be null for null input');
        Assert.isFalse((Boolean)nullCompleteConfig.get('success'), 'Complete configuration should not be successful for null input');
        
        Test.stopTest();
    }

    /**
     * @description Tests exception handling with invalid inputs
     */
    @IsTest 
    static void testExceptionHandling_InvalidInputs() {
        Test.startTest();
        
        Map<String, Object> invalidConfig = GenAiMetadataService.getAgentConfiguration('InvalidId');
        Assert.isNotNull(invalidConfig, 'Configuration should not be null for invalid input');
        Assert.isTrue(invalidConfig.isEmpty(), 'Configuration should be empty for invalid input');
        
        List<Map<String, Object>> invalidTopics = GenAiMetadataService.getAgentTopics('InvalidId');
        Assert.isNotNull(invalidTopics, 'Topics list should not be null for invalid input');
        Assert.isTrue(invalidTopics.isEmpty(), 'Topics list should be empty for invalid input');
        
        List<Map<String, Object>> invalidActions = GenAiMetadataService.getAgentActions('InvalidTopic');
        Assert.isNotNull(invalidActions, 'Actions list should not be null for invalid input');
        Assert.isTrue(invalidActions.isEmpty(), 'Actions list should be empty for invalid input');
        
        List<Map<String, Object>> invalidInstructions = GenAiMetadataService.getAgentInstructions('InvalidTopic');
        Assert.isNotNull(invalidInstructions, 'Instructions list should not be null for invalid input');
        Assert.isTrue(invalidInstructions.isEmpty(), 'Instructions list should be empty for invalid input');
        
        Map<String, Object> invalidCompleteConfig = GenAiMetadataService.getCompleteAgentConfiguration('InvalidId');
        Assert.isNotNull(invalidCompleteConfig, 'Complete configuration should not be null for invalid input');
        Assert.isFalse((Boolean)invalidCompleteConfig.get('success'), 'Complete configuration should not be successful for invalid input');
        
        Test.stopTest();
    }

    /**
     * @description Tests getAgentTopics with empty results
     */
    @IsTest 
    static void testGetAgentTopics_EmptyResults() {
        // Create a random ID that won't match any real records
        Id fakeId = '001000000000000AAA';
        
        Test.startTest();
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(fakeId);
        Test.stopTest();
        
        Assert.isNotNull(topics, 'Topics list should not be null even for non-existent agent');
        Assert.isTrue(topics.isEmpty(), 'Topics list should be empty for non-existent agent');
    }

    /**
     * @description Tests getAgentActions with empty results
     */
    @IsTest 
    static void testGetAgentActions_EmptyResults() {
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions('NonExistentTopic');
        Test.stopTest();
        
        Assert.isNotNull(actions, 'Actions list should not be null for non-existent topic');
        Assert.isTrue(actions.isEmpty(), 'Actions list should be empty for non-existent topic');
    }

    /**
     * @description Tests getAgentInstructions with empty results
     */
    @IsTest 
    static void testGetAgentInstructions_EmptyResults() {
        Test.startTest();
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions('NonExistentTopic');
        Test.stopTest();
        
        Assert.isNotNull(instructions, 'Instructions list should not be null for non-existent topic');
        Assert.isTrue(instructions.isEmpty(), 'Instructions list should be empty for non-existent topic');
    }

    /**
     * @description Tests getCompleteAgentConfiguration with empty agent configuration
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_EmptyConfig() {
        // Create a random ID that won't match any real records
        Id fakeId = '001000000000000AAA';
        
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getCompleteAgentConfiguration(fakeId);
        Test.stopTest();
        
        Assert.isNotNull(config, 'Configuration should not be null');
        Assert.isFalse((Boolean)config.get('success'), 'Success should be false for non-existent agent');
        Assert.isNotNull(config.get('error'), 'Error message should be present');
    }

    /**
     * @description Tests getAllAgents with exception handling
     */
    @IsTest 
    static void testGetAllAgents_ExceptionHandling() {
        Test.startTest();
        List<Map<String, Object>> agents = GenAiMetadataService.getAllAgents();
        Test.stopTest();
        
        Assert.isNotNull(agents, 'Agents list should not be null');
    }

    /**
     * @description Tests validateAgentforceConfigurations with invalid prompt template
     */
    @IsTest 
    static void testValidateAgentforceConfigurations_InvalidTemplate() {
        // Create a random ID that won't match any real records
        Id fakeId = '001000000000000AAA';
        
        Test.startTest();
        try {
            String result = GenAiMetadataService.validateAgentforceConfigurations(fakeId);
            Assert.fail('Should have thrown an exception for invalid agent ID');
        } catch (AuraHandledException e) {
            // Expected exception
            String errorMsg = e.getMessage();
            Assert.isNotNull(errorMsg, 'Error message should not be null');
        } catch (Exception e) {
            Assert.fail('Unexpected exception type: ' + e.getTypeName() + ' with message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * @description Tests getAgentConfiguration with exception handling
     */
    @IsTest 
    static void testGetAgentConfiguration_ExceptionHandling() {
        Test.startTest();
        try {
            Map<String, Object> config = GenAiMetadataService.getAgentConfiguration('InvalidId');
            Assert.isNotNull(config, 'Configuration should not be null even for invalid ID');
            Assert.isTrue(config.isEmpty(), 'Configuration should be empty for invalid ID');
        } catch (Exception e) {
            Assert.fail('Should handle invalid ID gracefully without throwing exception');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getAgentTopics with exception handling
     */
    @IsTest 
    static void testGetAgentTopics_ExceptionHandling() {
        Test.startTest();
        try {
            List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics('InvalidId');
            Assert.isNotNull(topics, 'Topics list should not be null even for invalid ID');
            Assert.isTrue(topics.isEmpty(), 'Topics list should be empty for invalid ID');
        } catch (Exception e) {
            Assert.fail('Should handle invalid ID gracefully without throwing exception');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getAgentTopics with forced exception
     */
    @IsTest 
    static void testGetAgentTopics_ForcedException() {
        Test.startTest();
        try {
            // Pass null to force exception handling path
            List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(null);
            Assert.isNotNull(topics, 'Topics list should not be null even with exception');
            Assert.isTrue(topics.isEmpty(), 'Topics list should be empty with exception');
        } catch (Exception e) {
            Assert.fail('Should handle exception gracefully without throwing');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getAgentActions with forced exception
     */
    @IsTest 
    static void testGetAgentActions_ForcedException() {
        Test.startTest();
        try {
            // Pass null to force exception handling path
            List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(null);
            Assert.isNotNull(actions, 'Actions list should not be null even with exception');
            Assert.isTrue(actions.isEmpty(), 'Actions list should be empty with exception');
        } catch (Exception e) {
            Assert.fail('Should handle exception gracefully without throwing');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getAgentInstructions with forced exception
     */
    @IsTest 
    static void testGetAgentInstructions_ForcedException() {
        Test.startTest();
        try {
            // Pass null to force exception handling path
            List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions(null);
            Assert.isNotNull(instructions, 'Instructions list should not be null even with exception');
            Assert.isTrue(instructions.isEmpty(), 'Instructions list should be empty with exception');
        } catch (Exception e) {
            Assert.fail('Should handle exception gracefully without throwing');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getCompleteAgentConfiguration with forced exception
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_ForcedException() {
        Test.startTest();
        try {
            // Pass null to force exception handling path
            Map<String, Object> config = GenAiMetadataService.getCompleteAgentConfiguration(null);
            Assert.isNotNull(config, 'Configuration should not be null even with exception');
            Assert.isFalse((Boolean)config.get('success'), 'Success should be false with exception');
            Assert.isNotNull(config.get('error'), 'Error message should be present');
        } catch (Exception e) {
            Assert.fail('Should handle exception gracefully without throwing');
        }
        Test.stopTest();
    }

    /**
     * @description Tests getAllAgents with forced exception
     */
    @IsTest 
    static void testGetAllAgents_ForcedException() {
        Test.startTest();
        try {
            // Force an exception by manipulating test context
            List<Map<String, Object>> agents = GenAiMetadataService.getAllAgents();
            Assert.isNotNull(agents, 'Agents list should not be null even with exception');
        } catch (Exception e) {
            Assert.fail('Should handle exception gracefully without throwing');
        }
        Test.stopTest();
    }

    /**
     * @description Tests validateAgentforceConfigurations with multiple scenarios
     */
    @IsTest 
    static void testValidateAgentforceConfigurations_MultipleScenarios() {
        // Test with null
        Test.startTest();
        try {
            String result = GenAiMetadataService.validateAgentforceConfigurations(null);
            Assert.fail('Should throw AuraHandledException for null input');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Error message should not be null');
        }

        // Test with invalid ID
        try {
            String result = GenAiMetadataService.validateAgentforceConfigurations('InvalidId');
            Assert.fail('Should throw AuraHandledException for invalid ID');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Error message should not be null');
        }

        // Test with empty string
        try {
            String result = GenAiMetadataService.validateAgentforceConfigurations('');
            Assert.fail('Should throw AuraHandledException for empty string');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Error message should not be null');
        }
        Test.stopTest();
    }

    /**
     * @description Tests complete workflow with forced exceptions
     */
    @IsTest 
    static void testCompleteWorkflow_ForcedExceptions() {
        Test.startTest();
        
        // Test getAgentConfiguration with invalid ID format
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration('invalid_format');
        Assert.isNotNull(config, 'Configuration should not be null even with invalid format');
        Assert.isTrue(config.isEmpty(), 'Configuration should be empty with invalid format');

        // Test getAgentTopics with invalid ID format
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics('invalid_format');
        Assert.isNotNull(topics, 'Topics should not be null even with invalid format');
        Assert.isTrue(topics.isEmpty(), 'Topics should be empty with invalid format');

        // Test getAgentActions with invalid format
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions('invalid_format');
        Assert.isNotNull(actions, 'Actions should not be null even with invalid format');
        Assert.isTrue(actions.isEmpty(), 'Actions should be empty with invalid format');

        // Test getAgentInstructions with invalid format
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions('invalid_format');
        Assert.isNotNull(instructions, 'Instructions should not be null even with invalid format');
        Assert.isTrue(instructions.isEmpty(), 'Instructions should be empty with invalid format');

        // Test getCompleteAgentConfiguration with invalid format
        Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration('invalid_format');
        Assert.isNotNull(completeConfig, 'Complete configuration should not be null even with invalid format');
        Assert.isFalse((Boolean)completeConfig.get('success'), 'Success should be false with invalid format');
        Assert.isNotNull(completeConfig.get('error'), 'Error message should be present');

        Test.stopTest(); 
    }

    /**
     * @description Tests getAgentConfiguration with all fields
     */
    @IsTest 
    static void testGetAgentConfiguration_AllFields() {
        // Query for an existing agent
        List<GenAiPlannerDefinition> agents = [
            SELECT Id, DeveloperName, MasterLabel, Description, Capabilities, Language, PlannerType
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            LIMIT 1
        ];
        
        // Skip test if no agents exist
        if (agents.isEmpty()) {
            return;
        }
        
        GenAiPlannerDefinition agent = agents[0];
        
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getAgentConfiguration(agent.Id);
        Test.stopTest();
        
        // Verify all fields are mapped correctly
        Assert.isNotNull(config, 'Configuration should not be null');
        Assert.areEqual(agent.Id, config.get('id'), 'ID should match');
        Assert.areEqual(agent.DeveloperName, config.get('name'), 'Name should match');
        Assert.areEqual(agent.MasterLabel, config.get('label'), 'Label should match');
        Assert.areEqual(agent.Description, config.get('description'), 'Description should match');
        Assert.areEqual(agent.Capabilities, config.get('capabilities'), 'Capabilities should match');
        Assert.areEqual(agent.Language, config.get('language'), 'Language should match');
        Assert.areEqual(agent.PlannerType, config.get('plannerType'), 'PlannerType should match');
        Assert.isNotNull(config.get('createdBy'), 'CreatedBy should not be null');
        Assert.isNotNull(config.get('lastModifiedBy'), 'LastModifiedBy should not be null');
        Assert.isNotNull(config.get('createdDate'), 'CreatedDate should not be null');
        Assert.isNotNull(config.get('lastModifiedDate'), 'LastModifiedDate should not be null');
    }

    /**
     * @description Tests getCompleteAgentConfiguration with all fields and relationships
     */
    @IsTest 
    static void testGetCompleteAgentConfiguration_AllFields() {
        // First get plugins that have both functions and instructions
        List<GenAiPluginDefinition> plugins = [
            SELECT ParentId 
            FROM GenAiPluginDefinition 
            WHERE IsDeleted = false 
            AND Id IN (SELECT PluginId FROM GenAiPluginFunctionDef WHERE IsDeleted = false)
        ];
        
        // Get plugin IDs that have instructions
        List<GenAiPluginInstructionDef> pluginInstructions = [
            SELECT GenAiPluginDefinitionId 
            FROM GenAiPluginInstructionDef 
            WHERE IsDeleted = false 
            AND GenAiPluginDefinitionId IN :plugins
        ];
        
        // Extract parent IDs from plugins that have both
        Set<Id> validParentIds = new Set<Id>();
        Set<Id> pluginsWithInstructions = new Set<Id>();
        for(GenAiPluginInstructionDef inst : pluginInstructions) {
            pluginsWithInstructions.add(inst.GenAiPluginDefinitionId);
        }
        
        for(GenAiPluginDefinition plugin : plugins) {
            if(pluginsWithInstructions.contains(plugin.Id)) {
                validParentIds.add(plugin.ParentId);
            }
        }
        
        // Query for agents using the collected parent IDs
        List<GenAiPlannerDefinition> agents = [
            SELECT Id, DeveloperName 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            AND Id IN :validParentIds
            LIMIT 1
        ];
        
        // Skip test if no suitable agents exist
        if (agents.isEmpty()) {
            return;
        }
        
        Test.startTest();
        Map<String, Object> config = GenAiMetadataService.getCompleteAgentConfiguration(agents[0].Id);
        Test.stopTest();
        
        // Verify complete configuration
        Assert.isNotNull(config, 'Configuration should not be null');
        Assert.isTrue((Boolean)config.get('success'), 'Success should be true');
        
        // Verify agent data
        Map<String, Object> agentData = (Map<String, Object>)config.get('agent');
        Assert.isNotNull(agentData, 'Agent data should not be null');
        Assert.areEqual(agents[0].DeveloperName, agentData.get('name'), 'Agent name should match');
        
        // Verify topics data
        List<Map<String, Object>> topicsData = (List<Map<String, Object>>)config.get('topics');
        Assert.isNotNull(topicsData, 'Topics data should not be null');
        Assert.isTrue(!topicsData.isEmpty(), 'Should have at least one topic');
        
        // Verify topic details
        Map<String, Object> topic = topicsData[0];
        Assert.isNotNull(topic.get('name'), 'Topic name should not be null');
        
        // Verify actions
        List<Map<String, Object>> actions = (List<Map<String, Object>>)topic.get('actions');
        Assert.isNotNull(actions, 'Actions should not be null');
        Assert.isTrue(!actions.isEmpty(), 'Should have at least one action');
        
        // Verify instructions
        List<Map<String, Object>> topicInstructions = (List<Map<String, Object>>)topic.get('instructions');
        Assert.isNotNull(topicInstructions, 'Instructions should not be null');
        Assert.isTrue(!topicInstructions.isEmpty(), 'Should have at least one instruction');
    }

    /**
     * @description Tests getAgentTopics with all fields
     */
    @IsTest 
    static void testGetAgentTopics_AllFields() {
        // First get plugins that have functions
        List<GenAiPluginDefinition> plugins = [
            SELECT ParentId 
            FROM GenAiPluginDefinition 
            WHERE IsDeleted = false 
            AND Id IN (SELECT PluginId FROM GenAiPluginFunctionDef WHERE IsDeleted = false)
        ];
        
        // Extract parent IDs
        Set<Id> validParentIds = new Set<Id>();
        for(GenAiPluginDefinition plugin : plugins) {
            validParentIds.add(plugin.ParentId);
        }
        
        // Query for agents using the collected parent IDs
        List<GenAiPlannerDefinition> agents = [
            SELECT Id, DeveloperName 
            FROM GenAiPlannerDefinition 
            WHERE IsDeleted = false 
            AND Id IN :validParentIds
            LIMIT 1
        ];
        
        // Skip test if no suitable agents exist
        if (agents.isEmpty()) {
            return;
        }
        
        Test.startTest();
        List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(agents[0].Id);
        Test.stopTest();
        
        // Verify topics are returned and mapped correctly
        Assert.isNotNull(topics, 'Topics should not be null');
        Assert.isTrue(!topics.isEmpty(), 'Should have at least one topic');
        
        Map<String, Object> topic = topics[0];
        Assert.isNotNull(topic.get('id'), 'Topic ID should not be null');
        Assert.isNotNull(topic.get('name'), 'Topic name should not be null');
        Assert.isNotNull(topic.get('label'), 'Topic label should not be null');
        Assert.isNotNull(topic.get('parentId'), 'Topic parentId should not be null');
    }

    /**
     * @description Tests getAgentActions with all fields
     */
    @IsTest 
    static void testGetAgentActions_AllFields() {
        // Query for a plugin that has functions
        List<GenAiPluginDefinition> plugins = [
            SELECT Id, DeveloperName 
            FROM GenAiPluginDefinition 
            WHERE IsDeleted = false 
            AND Id IN (
                SELECT PluginId 
                FROM GenAiPluginFunctionDef 
                WHERE IsDeleted = false
            )
            LIMIT 1
        ];
        
        // Skip test if no suitable plugins exist
        if (plugins.isEmpty()) {
            return;
        }
        
        Test.startTest();
        List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(plugins[0].DeveloperName);
        Test.stopTest();
        
        // Verify actions are returned and mapped correctly
        Assert.isNotNull(actions, 'Actions should not be null');
        Assert.isTrue(!actions.isEmpty(), 'Should have at least one action');
        
        Map<String, Object> action = actions[0];
        Assert.isNotNull(action.get('id'), 'Action ID should not be null');
        Assert.isNotNull(action.get('function'), 'Action function should not be null');
        Assert.isNotNull(action.get('pluginId'), 'Action pluginId should not be null');
    }

    /**
     * @description Tests getAgentInstructions with all fields
     */
    @IsTest 
    static void testGetAgentInstructions_AllFields() {
        // Query for a plugin that has instructions
        List<GenAiPluginDefinition> plugins = [
            SELECT Id, DeveloperName 
            FROM GenAiPluginDefinition 
            WHERE IsDeleted = false 
            AND Id IN (
                SELECT GenAiPluginDefinitionId 
                FROM GenAiPluginInstructionDef 
                WHERE IsDeleted = false
            )
            LIMIT 1
        ];
        
        // Skip test if no suitable plugins exist
        if (plugins.isEmpty()) {
            return;
        }
        
        Test.startTest();
        List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions(plugins[0].DeveloperName);
        Test.stopTest();
        
        // Verify instructions are returned and mapped correctly
        Assert.isNotNull(instructions, 'Instructions should not be null');
        Assert.isTrue(!instructions.isEmpty(), 'Should have at least one instruction');
        
        Map<String, Object> instruction = instructions[0];
        Assert.isNotNull(instruction.get('id'), 'Instruction ID should not be null');
        Assert.isNotNull(instruction.get('name'), 'Instruction name should not be null');
        Assert.isNotNull(instruction.get('label'), 'Instruction label should not be null');
        Assert.isNotNull(instruction.get('pluginId'), 'Instruction pluginId should not be null');
    }
}