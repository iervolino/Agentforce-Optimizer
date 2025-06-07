/**
 * @description Service class for retrieving GenAI prompt template metadata from Salesforce
 * This class provides methods to fetch metadata for prompt templates associated with agents
 * 
 * @author Francesco Iervolino
 * @date 2025-03-21
 */
public with sharing class GenAIMetadataServiceRetriever {
    
    /**
     * @description Main invocable method to retrieve prompt template configuration
     * @param requests List of Request objects containing the agent ID
     * @return List<Response> List containing the prompt template configuration
     */
    @InvocableMethod
    public static List<Response> getPrompt(List<Request> requests) {
        Request input = requests[0];
        List<Response> responses = new List<Response>();
        Response output = new Response();
        responses.add(output); 
        
        try {
            // Generate the prompt template configuration
            String promptTemplate = generatePromptTemplate(input.AgentId);
            output.Prompt = promptTemplate;
        } catch (Exception e) {
            System.debug('Error in getPrompt: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            output.Prompt = 'Error generating prompt template: ' + e.getMessage();
        }
        
        return responses;
    }
    
    /**
     * @description Generates the prompt template configuration for a specific agent
     * @param agentId The ID of the agent
     * @return String The prompt template configuration as a formatted string
     */
    private static String generatePromptTemplate(String agentId) {
        System.debug('Starting generatePromptTemplate() method for agent ID: ' + agentId);
        String promptTemplate = ''; 
        
        try {
            // Get base agent configuration
            Map<String, Object> agentConfig = GenAiMetadataService.getAgentConfiguration(agentId);
            if (agentConfig == null || agentConfig.isEmpty()) {
                return 'No configuration found for agent ID: ' + agentId;
            }
            
            // Add agent configuration to prompt template
            promptTemplate += 'Agent Configuration:\n';
            promptTemplate += 'Name: ' + agentConfig.get('name') + '\n';
            promptTemplate += 'Label: ' + agentConfig.get('label') + '\n';
            promptTemplate += 'Description: ' + agentConfig.get('description') + '\n';
            promptTemplate += 'Capabilities: ' + agentConfig.get('capabilities') + '\n';
            promptTemplate += 'Language: ' + agentConfig.get('language') + '\n';
            promptTemplate += 'Planner Type: ' + agentConfig.get('plannerType') + '\n\n';
            
            // Get agent topics
            List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics(agentId);
            
            if (!topics.isEmpty()) {
                promptTemplate += 'Topics:\n';
                
                // For each topic, get its actions and instructions
                for (Map<String, Object> topic : topics) {
                    String topicName = (String)topic.get('name');
                    String topicId = (String)topic.get('id');
                    
                    promptTemplate += '\nTopic: ' + topic.get('label') + '\n';
                    promptTemplate += 'Description: ' + topic.get('description') + '\n';
                    
                    // Get actions for this topic
                    List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions(topicId);
                    if (!actions.isEmpty()) {
                        promptTemplate += '\nActions:\n';
                        for (Map<String, Object> action : actions) {
                            promptTemplate += '- Action: ' + action.get('masterLabel') + '\n';
                            promptTemplate += '  Developer Name: ' + action.get('developerName') + '\n';
                            promptTemplate += '  Description: ' + action.get('description') + '\n';
                            promptTemplate += '  Invocation Target: ' + action.get('invocationTarget') + '\n';
                            promptTemplate += '  Invocation Type: ' + action.get('invocationTargetType') + '\n';
                            promptTemplate += '  Is Local: ' + action.get('isLocal') + '\n\n';
                        }
                    }
                    
                    // Get instructions for this topic
                    List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions(topicName);
                    if (!instructions.isEmpty()) {
                        promptTemplate += '\nInstructions:\n';
                        for (Map<String, Object> instruction : instructions) {
                            promptTemplate += '- ' + instruction.get('description') + '\n';
                        }
                    }
                    
                    promptTemplate += '\n';
                }
            }
            
            System.debug('Successfully generated prompt template for agent ID: ' + agentId);
            return promptTemplate;
            
        } catch (Exception e) {
            System.debug('Error in generatePromptTemplate: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return 'Error generating prompt template: ' + e.getMessage();
        }
    }
    
    /**
     * @description Request class for the invocable method
     */
    public class Request {
        @InvocableVariable(required=true)
        public String AgentId;
    }
    
    /**
     * @description Response class for the invocable method
     */
    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}