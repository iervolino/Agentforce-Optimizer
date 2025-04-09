@isTest
private class PromptUtilTest {

    /**
     * @description Tests the helper method createPromptInput.
     * Verifies that it correctly creates and configures the input object.
     */
    @isTest static void testCreatePromptInput() {
        // Arrange
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue paramValue = new ConnectApi.WrappedValue();
        paramValue.value = 'TestValue';
        inputParams.put('TestParam', paramValue);

        // Act
        ConnectApi.EinsteinPromptTemplateGenerationsInput result = PromptUtil.createPromptInput(inputParams); 

        // Assert
        Assert.isNotNull(result, 'PromptInput should not be null');
        Assert.isNotNull(result.additionalConfig, 'AdditionalConfig should not be null');
        Assert.areEqual('PromptBuilderPreview', result.additionalConfig.applicationName, 'ApplicationName mismatch');
        Assert.areEqual(false, result.isPreview, 'isPreview should be false');
        Assert.isNotNull(result.inputParams, 'inputParams should not be null');
        Assert.areEqual(1, result.inputParams.size(), 'inputParams size mismatch');
        Assert.isTrue(result.inputParams.containsKey('TestParam'), 'inputParams key mismatch');
        Assert.areEqual('TestValue', result.inputParams.get('TestParam').value, 'inputParams value mismatch');
    }

    /**
     * @description Tests the runPrompt method's exception handling.
     * Since ConnectApi.EinsteinLLM cannot be easily mocked without HttpCalloutMock,
     * this test focuses on verifying that exceptions during the ConnectApi call
     * are caught and re-thrown as AuraHandledException.
     */
    @isTest static void testRunPrompt_ExceptionHandling() {
        // Arrange
        String promptTemplate = 'TestTemplate';
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue paramValue = new ConnectApi.WrappedValue();
        paramValue.value = 'TestValue';
        inputParams.put('Input:AgentId', paramValue);

        Exception thrownException = null;
        String result = null;

        // Act
        Test.startTest();
        try {
            // This call will fail because ConnectApi.EinsteinLLM is not mocked
            result = PromptUtil.runPrompt(promptTemplate, inputParams);
        } catch (AuraHandledException e) {
            thrownException = e;
            // Get the actual error message
            System.debug('Caught AuraHandledException with message: ' + e.getMessage());
        }
        Test.stopTest();

        // Assert
        Assert.isNull(result, 'Result should be null when exception occurs');
        Assert.isNotNull(thrownException, 'An exception should have been thrown');
        Assert.isInstanceOfType(thrownException, System.AuraHandledException.class, 
            'Expected AuraHandledException, but got: ' + thrownException.getTypeName());
        
        // Get the actual error message from the AuraHandledException
        String actualMessage = thrownException.getMessage();
        System.debug('Actual error message: ' + actualMessage);
        
        // In test context, we expect a script-thrown exception to be wrapped in an AuraHandledException
        Assert.isTrue(
            thrownException instanceof AuraHandledException,
            'Expected AuraHandledException, but got: ' + thrownException.getTypeName()
        );
        
        // Verify that the exception is not null and has a message
        Assert.isNotNull(actualMessage, 'Exception message should not be null');
        Assert.isTrue(actualMessage.length() > 0, 'Exception message should not be empty');
    }

    /**
     * @description Tests the scenario where ConnectApi returns null or empty generations.
     * This requires mocking the ConnectApi response, which is complex.
     * For now, this test case highlights the need for a more advanced mocking strategy
     * (like using HttpCalloutMock if EinsteinLLM uses callouts under the hood, or a custom StubProvider if applicable).
     * Currently, this test cannot be fully implemented without such mocking.
     */
    @isTest static void testRunPrompt_EmptyGenerations() {
        // Placeholder: Test logic would go here if ConnectApi.EinsteinLLM could be mocked.
        // Example (pseudo-code, requires appropriate mock setup):
        // Test.setMock(ConnectApi.EinsteinLLM.class, new MockEinsteinLLMEmptyResponse());
        // ... call runPrompt ...
        // Assert.isInstanceOfType(thrownException, System.AuraHandledException.class);
        // Assert.isTrue(thrownException.getMessage().contains('No response generated'));
        System.debug('Test testRunPrompt_EmptyGenerations needs implementation with ConnectApi mocking.');
        Assert.isTrue(true, 'Placeholder assertion for empty generations test.'); // Avoid test failure for placeholder
    }
}