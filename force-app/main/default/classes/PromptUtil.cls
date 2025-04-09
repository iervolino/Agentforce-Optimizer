public with sharing class PromptUtil {

   /**
     * @description Executes an Einstein GPT prompt template and returns only the generated text response
     * @param promptTemplate The template name to use for generation
     * @param inputParams A map of input parameters required for the template
     * @return The generated text response as a String
     * @throws AuraHandledException if the prompt execution fails or returns no generations
     */
    public static String runPrompt(
        String promptTemplate, 
        Map<String, ConnectApi.WrappedValue> inputParams
    ) {
        try {
            // Create and configure the prompt input
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = createPromptInput(inputParams);
            
            // Execute the prompt template and get the response
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation promptOutput = 
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(promptTemplate, promptInput);

            System.debug('### promptOutput ###: ' + promptOutput);

            // Check if we have any generations
            if (promptOutput == null || promptOutput.generations == null || promptOutput.generations.isEmpty()) {
                throw new AuraHandledException('No response generated from the prompt template: ' + promptTemplate);
            }

            // Extract and return just the text from the first generation
            ConnectApi.EinsteinLLMGenerationItemOutput responseItem = promptOutput.generations[0];
            return responseItem.text;
        } catch (Exception e) {
            System.debug('Error in runPrompt: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error executing prompt: ' + e.getMessage());
        }
    } 
    
    /**
     * @description Creates and configures a prompt input object with standard settings
     * @param inputParams The input parameters for the prompt
     * @return Configured EinsteinPromptTemplateGenerationsInput object
     */
    @TestVisible
    private static ConnectApi.EinsteinPromptTemplateGenerationsInput createPromptInput(
        Map<String, ConnectApi.WrappedValue> inputParams
    ) {
        ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        promptInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        promptInput.additionalConfig.applicationName = 'PromptBuilderPreview';
        promptInput.isPreview = false;
        promptInput.inputParams = inputParams;
        
        return promptInput;
    }


}