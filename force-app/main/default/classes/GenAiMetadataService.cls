/**
 * @description Service class for retrieving GenAI-related metadata from Salesforce
 * This class provides methods to fetch metadata for various GenAI components including
 * planners, plugins, functions, and prompt templates.
 * 
 * @author Francesco Iervolino
 * @date 2025-03-21
 */
public class GenAiMetadataService {

    /**
     * @description Retrieves configuration metadata for a specific agent 
     * This method retrieves the configuration metadata associated with an agent,
     * including its settings, capabilities, and other configuration details.
     * 
     * @param agentId The ID of the agent
     * @return Map<String, Object> A map containing the agent's configuration details,
     *         or null if the agent is not found or if there's an error
     * 
     * @example
     * Map<String, Object> agentConfig = GenAiMetadataService.getAgentConfiguration('a0x1234567890');
     */
    public static Map<String, Object> getAgentConfiguration(String agentId) {
        System.debug('Starting getAgentConfiguration() method for agent ID: ' + agentId);
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Query the GenAiPlannerDefinition record for the agent
            List<GenAiPlannerDefinition> planners = [
                SELECT 
                    Id, 
                    DeveloperName, 
                    MasterLabel,
                    Description, 
                    Capabilities,
                    Language,
                    PlannerType,
                    NamespacePrefix,
                    CreatedById,
                    LastModifiedById,
                    CreatedDate,
                    LastModifiedDate
                FROM GenAiPlannerDefinition 
                WHERE Id = :agentId 
                AND IsDeleted = false
                LIMIT 1
            ];
            
            if (!planners.isEmpty()) {
                GenAiPlannerDefinition planner = planners[0];
                result.put('id', planner.Id);
                result.put('name', planner.DeveloperName);
                result.put('label', planner.MasterLabel);
                result.put('description', planner.Description);
                result.put('capabilities', planner.Capabilities);
                result.put('language', planner.Language);
                result.put('plannerType', planner.PlannerType);
                result.put('namespacePrefix', planner.NamespacePrefix);
                result.put('createdBy', planner.CreatedById);
                result.put('lastModifiedBy', planner.LastModifiedById);
                result.put('createdDate', planner.CreatedDate);
                result.put('lastModifiedDate', planner.LastModifiedDate);
                
                System.debug('Successfully retrieved configuration for agent ID: ' + agentId);
            } else {
                System.debug('No configuration found for agent ID: ' + agentId);
            }
        } catch (Exception e) {
            System.debug('Error retrieving agent configuration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }

    /**
     * @description Retrieves topics associated with a specific agent
     * This method retrieves the topics (GenAiPlugins) associated with the agent.
     * 
     * @param agentId The ID of the agent
     * @return List<Map<String, Object>> A list of maps containing topic details,
     *         or an empty list if no topics are found
     * 
     * @example
     * List<Map<String, Object>> topics = GenAiMetadataService.getAgentTopics('a0x1234567890');
     */
    public static List<Map<String, Object>> getAgentTopics(String agentId) {
        System.debug('Starting getAgentTopics() method for agent ID: ' + agentId);
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        try {
            // First query: Get all Plugin DeveloperNames from GenAiPlannerFunctionDef
            List<GenAiPlannerFunctionDef> plannerFunctions = [
                SELECT Id, Plugin
                FROM GenAiPlannerFunctionDef 
                WHERE PlannerId = :agentId 
                AND IsDeleted = false
            ];
            
            // Build set of Plugin DeveloperNames
            Set<String> pluginNames = new Set<String>();
            for (GenAiPlannerFunctionDef pf : plannerFunctions) {
                pluginNames.add(pf.Plugin);
                pluginNames.add(pf.Id);
            }
            
            if (pluginNames.isEmpty()) {
                System.debug('No topics found for agent ID: ' + agentId);
                return result;
            }
            
            // Second query: Get Plugin details using the DeveloperNames
            List<GenAiPluginDefinition> plugins = [
                SELECT 
                    Id, 
                    DeveloperName,
                    MasterLabel,
                    Description,
                    IsLocal,
                    Language,
                    PluginType,
                    Scope,
                    CanEscalate,
                    ParentId,
                    NamespacePrefix,
                    CreatedById,
                    LastModifiedById,
                    CreatedDate,
                    LastModifiedDate
                FROM GenAiPluginDefinition
                WHERE (ParentId IN :pluginNames OR Id IN :pluginNames)
                AND IsDeleted = false
            ];
            
            for (GenAiPluginDefinition plugin : plugins) {
                Map<String, Object> topicMap = new Map<String, Object>{
                    'id' => plugin.Id,
                    'name' => plugin.DeveloperName,
                    'label' => plugin.MasterLabel,
                    'description' => plugin.Description,
                    'isLocal' => plugin.IsLocal,
                    'language' => plugin.Language,
                    'pluginType' => plugin.PluginType,
                    'scope' => plugin.Scope,
                    'canEscalate' => plugin.CanEscalate,
                    'parentId' => plugin.ParentId,
                    'namespacePrefix' => plugin.NamespacePrefix,
                    'createdBy' => plugin.CreatedById,
                    'lastModifiedBy' => plugin.LastModifiedById,
                    'createdDate' => plugin.CreatedDate,
                    'lastModifiedDate' => plugin.LastModifiedDate
                };
                
                result.add(topicMap);
            }
            
            System.debug('Successfully retrieved ' + result.size() + ' topics for agent ID: ' + agentId);
        } catch (Exception e) {
            System.debug('Error retrieving agent topics: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }

    /**
     * @description Retrieves actions associated with a specific topic
     * This method retrieves the actions (GenAiFunctions) associated with the topic.
     * 
     * @param topicName The name of the topic (DeveloperName)
     * @return List<Map<String, Object>> A list of maps containing action details,
     *         or an empty list if no actions are found
     * 
     * @example
     * List<Map<String, Object>> actions = GenAiMetadataService.getAgentActions('MyTopic');
     */
    public static List<Map<String, Object>> getAgentActions(String topicName) {
        System.debug('Starting getAgentActions() method for topic: ' + topicName);
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        try {
            // Query the GenAiPluginFunctionDef records associated with the topic
            List<GenAiPluginFunctionDef> functions = [
                SELECT 
                    Id,
                    Function,
                    PluginId,
                    CreatedById,
                    LastModifiedById,
                    CreatedDate,
                    LastModifiedDate
                FROM GenAiPluginFunctionDef
                WHERE PluginId IN (
                    SELECT Id 
                    FROM GenAiPluginDefinition 
                    WHERE DeveloperName = :topicName
                    AND IsDeleted = false
                )
                AND IsDeleted = false
            ];
            
            // Get all function IDs
            Set<String> functionIds = new Set<String>();
            for (GenAiPluginFunctionDef func : functions) {
                functionIds.add(func.Function);
            }
            
            // Query the GenAiFunctionDefinition records
            List<GenAiFunctionDefinition> functionDefs = [
                SELECT 
                    CreatedById,
                    CreatedDate,
                    Description,
                    DeveloperName,
                    Id,
                    InvocationTarget,
                    InvocationTargetType,
                    IsConfirmationRequired,
                    IsDeleted,
                    IsIncludeInProgressIndicator,
                    IsLocal,
                    Language,
                    LastModifiedById,
                    LastModifiedDate,
                    MasterLabel,
                    NamespacePrefix,
                    ParentId,
                    ProgressIndicatorMessage,
                    SystemModstamp
                FROM GenAiFunctionDefinition
                WHERE Id IN :functionIds
                AND IsDeleted = false
            ];
            
            // Create a map of function definitions by ID for easy lookup
            Map<String, GenAiFunctionDefinition> functionDefMap = new Map<String, GenAiFunctionDefinition>();
            for (GenAiFunctionDefinition funcDef : functionDefs) {
                functionDefMap.put(funcDef.Id, funcDef);
            }
            
            // Create the result maps
            for (GenAiPluginFunctionDef func : functions) {
                GenAiFunctionDefinition funcDef = functionDefMap.get(func.Function);
                if (funcDef != null) {
                    Map<String, Object> actionMap = new Map<String, Object>{
                        'id' => func.Id,
                        'functionId' => func.Function,
                        'pluginId' => func.PluginId,
                        'createdBy' => func.CreatedById,
                        'lastModifiedBy' => func.LastModifiedById,
                        'createdDate' => func.CreatedDate,
                        'lastModifiedDate' => func.LastModifiedDate,
                        'description' => funcDef.Description,
                        'developerName' => funcDef.DeveloperName,
                        'invocationTarget' => funcDef.InvocationTarget,
                        'invocationTargetType' => funcDef.InvocationTargetType,
                        'isConfirmationRequired' => funcDef.IsConfirmationRequired,
                        'isLocal' => funcDef.IsLocal,
                        'language' => funcDef.Language,
                        'masterLabel' => funcDef.MasterLabel,
                        'namespacePrefix' => funcDef.NamespacePrefix,
                        'parentId' => funcDef.ParentId,
                        'progressIndicatorMessage' => funcDef.ProgressIndicatorMessage,
                        'systemModstamp' => funcDef.SystemModstamp
                    };
                    
                    result.add(actionMap);
                }
            }
            
            System.debug('Successfully retrieved ' + result.size() + ' actions for topic: ' + topicName);
        } catch (Exception e) {
            System.debug('Error retrieving topic actions: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }

    /**
     * @description Retrieves instructions associated with a specific topic
     * This method retrieves the instructions (GenAiPluginInstructionDef) associated with the topic.
     * 
     * @param topicName The name of the topic (DeveloperName)
     * @return List<Map<String, Object>> A list of maps containing instruction details,
     *         or an empty list if no instructions are found
     * 
     * @example
     * List<Map<String, Object>> instructions = GenAiMetadataService.getAgentInstructions('MyTopic');
     */
    public static List<Map<String, Object>> getAgentInstructions(String topicName) {
        System.debug('Starting getAgentInstructions() method for topic: ' + topicName);
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        try {

            // Query the GenAiPluginInstructionDef records associated with the topic
            List<GenAiPluginInstructionDef> instructions = [
                SELECT 
                    Id,
                    DeveloperName,
                    MasterLabel,
                    Description,
                    Language,
                    GenAiPluginDefinitionId,
                    CreatedById,
                    LastModifiedById,
                    CreatedDate,
                    LastModifiedDate
                FROM GenAiPluginInstructionDef
                WHERE GenAiPluginDefinitionId IN (
                    SELECT Id 
                    FROM GenAiPluginDefinition 
                    WHERE DeveloperName = :topicName
                    AND IsDeleted = false
                )
                AND IsDeleted = false
            ];
            
            for (GenAiPluginInstructionDef instruction : instructions) {
                Map<String, Object> instructionMap = new Map<String, Object>{
                    'id' => instruction.Id,
                    'name' => instruction.DeveloperName,
                    'label' => instruction.MasterLabel,
                    'description' => instruction.Description,
                    'language' => instruction.Language,
                    'pluginId' => instruction.GenAiPluginDefinitionId,
                    'createdBy' => instruction.CreatedById,
                    'lastModifiedBy' => instruction.LastModifiedById,
                    'createdDate' => instruction.CreatedDate,
                    'lastModifiedDate' => instruction.LastModifiedDate
                };
                
                result.add(instructionMap);
            }
            
            System.debug('Successfully retrieved ' + result.size() + ' instructions for topic: ' + topicName);
        } catch (Exception e) {
            System.debug('Error retrieving topic instructions: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }

    /**
     * @description Retrieves complete configuration for an agent including all related metadata
     * This method retrieves the agent configuration along with all its topics, instructions,
     * and actions in a single nested structure.
     * 
     * @param agentId The ID of the agent
     * @return Map<String, Object> A map containing all agent-related configurations,
     *         including topics, instructions, and actions
     * 
     * @example
     * Map<String, Object> completeConfig = GenAiMetadataService.getCompleteAgentConfiguration('a0x1234567890');
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCompleteAgentConfiguration(String agentId) {
        System.debug('Starting getCompleteAgentConfiguration() method for agent ID: ' + agentId);
        Map<String, Object> configuration = new Map<String, Object>();
        
        try {
            // Get base agent configuration
            Map<String, Object> agentConfig = getAgentConfiguration(agentId);
            if (agentConfig == null || agentConfig.isEmpty()) {
                System.debug('No configuration found for agent ID: ' + agentId);
                configuration.put('error', 'Agent configuration not found for ID: ' + agentId);
                configuration.put('success', false);
                return configuration;
            }
            
            configuration.put('agent', agentConfig);
            configuration.put('success', true);
            
            // Get agent topics
            List<Map<String, Object>> topics = getAgentTopics(agentId);
            List<Map<String, Object>> enrichedTopics = new List<Map<String, Object>>();
            
            // For each topic, get its actions and instructions
            for (Map<String, Object> topic : topics) {
                String topicName = (String)topic.get('name');
                
                // Get actions for this topic
                List<Map<String, Object>> actions = getAgentActions(topicName);
                topic.put('actions', actions);
                
                // Get instructions for this topic
                List<Map<String, Object>> instructions = getAgentInstructions(topicName);
                topic.put('instructions', instructions);
                
                enrichedTopics.add(topic);
            }
            
            configuration.put('topics', enrichedTopics);
            
            System.debug('Successfully retrieved complete configuration for agent ID: ' + agentId);
            return configuration;
            
        } catch (Exception e) {
            System.debug('Error in getCompleteAgentConfiguration: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            configuration.put('error', 'Error retrieving complete agent configuration: ' + e.getMessage());
            configuration.put('success', false);
            return configuration;
        }
    }

    /**
     * @description Retrieves all available agents in the system
     * This method retrieves a list of all GenAiPlannerDefinition records that are not deleted.
     * 
     * @return List<Map<String, Object>> A list of maps containing agent details,
     *         or an empty list if no agents are found
     * 
     * @example
     * List<Map<String, Object>> agents = GenAiMetadataService.getAllAgents();
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllAgents() {
        System.debug('Starting getAllAgents() method');
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        try {

            List<GenAiPlannerDefinition> planners = [
                SELECT 
                    Id, 
                    DeveloperName, 
                    MasterLabel,
                    Description
                FROM GenAiPlannerDefinition 
                WHERE IsDeleted = false
                ORDER BY MasterLabel ASC
            ];
            
            for (GenAiPlannerDefinition planner : planners) {
                Map<String, Object> agentMap = new Map<String, Object>{
                    'id' => planner.Id,
                    'name' => planner.DeveloperName,
                    'label' => planner.MasterLabel,
                    'description' => planner.Description
                };
                result.add(agentMap);
            }
            
            System.debug('Successfully retrieved ' + result.size() + ' agents');
        } catch (Exception e) {
            System.debug('Error retrieving agents: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }

    /**
     * @description Executes a prompt to validate Agentforce configurations
     * This method executes a prompt template to validate the configurations of an agent.
     * Note: This method is not cacheable as it performs DML operations.
     * 
     * @param agentId The ID of the agent to validate
     * @return String The result of the prompt execution
     * 
     * @example
     * String result = GenAiMetadataService.validateAgentforceConfigurations('a0x1234567890');
     */
    @AuraEnabled
    public static String validateAgentforceConfigurations(String agentId) {
        System.debug('Starting validateAgentforceConfigurations() method for agent ID: ' + agentId);
        
        try {
            // Create input parameters for the prompt
            ConnectApi.WrappedValue agentIdWV = new ConnectApi.WrappedValue();
            agentIdWV.value = agentId;
            
            Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>{
                'Input:AgentId' => agentIdWV
            };
            
            // Execute the prompt using PromptUtil
            String result = PromptUtil.runPrompt('Validate_Agentforce_Configurations', inputParams);
            
            System.debug('Successfully executed validation prompt for agent ID: ' + agentId);
            return result;
            
        } catch (AuraHandledException e) {
            System.debug('Error executing validation prompt: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw e; // Re-throw AuraHandledException to be handled by the Lightning component
        } catch (Exception e) {
            System.debug('Error executing validation prompt: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error executing validation prompt: ' + e.getMessage());
        }
    }

    /**
     * @description Gets user and organization information
     * @return Map<String, String> Map containing user and org information
     */
    private static Map<String, String> getUserAndOrgInfo() {
        Map<String, String> info = new Map<String, String>();
        
        // Get current user info
        User currentUser = [SELECT Username, CompanyName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        info.put('username', currentUser.Username);
        info.put('companyName', currentUser.CompanyName);
        
        // Get org info
        Organization org = [SELECT OrganizationType FROM Organization LIMIT 1];
        info.put('orgType', org.OrganizationType);
        
        return info;
    }

    /**
     * @description Sends diagnostic email with agent configuration information
     * @param agentId The ID of the agent
     * @param diagnosticContent The diagnostic content to include in the email
     * @return Boolean True if email was sent successfully
     */
    @AuraEnabled
    public static Boolean sendDiagnosticEmail(Id agentId, String diagnosticContent) {
        try {
            if (agentId == null) {
                throw new AuraHandledException('Agent ID is required');
            }
            
            if (String.isBlank(diagnosticContent)) {
                throw new AuraHandledException('Diagnostic content is required');
            }

            // Get agent configuration for subject
            Map<String, Object> agentConfig = getAgentConfiguration(agentId);
            if (agentConfig == null || agentConfig.isEmpty()) {
                throw new AuraHandledException('Invalid agent ID: ' + agentId);
            }

            // Get user and org info
            Map<String, String> userOrgInfo = getUserAndOrgInfo();

            // Create email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ 'agentoptimizer@salesforce.com' });
            email.setSubject('Agent Diagnostic Information - ' + agentConfig.get('name'));

            // Format email body with user and org info
            String emailBody = '<html><body>';
            emailBody += '<h2>User Information</h2>';
            emailBody += '<p><strong>Username:</strong> ' + userOrgInfo.get('username') + '</p>';
            emailBody += '<p><strong>Company Name:</strong> ' + userOrgInfo.get('companyName') + '</p>';
            emailBody += '<p><strong>Organization Type:</strong> ' + userOrgInfo.get('orgType') + '</p>';
            emailBody += '<hr/>';
            emailBody += '<h2>Diagnostic Information</h2>';
            emailBody += diagnosticContent;
            emailBody += '</body></html>';

            email.setHtmlBody(emailBody);
            
            // Send email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Error sending diagnostic email: ' + e.getMessage());
        }
    }
 
}