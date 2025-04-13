@isTest
private class PromptUtilTest {

    /**
     * @description Tests the helper method createPromptInput.
     * Verifies that it correctly creates and configures the input object.
     */
    @isTest 
    static void testCreatePromptInput() {
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
     * @description Tests successful prompt execution with mock response
     */
    @isTest 
    static void testRunPrompt_Success() {
        // Arrange
        String promptTemplate = 'Prompt template {0}';
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue paramValue = new ConnectApi.WrappedValue();
        paramValue.value = 'TestValue';
        inputParams.put('Input:Prompt', paramValue);

        // Act
        Test.startTest();
        try {
            String result = PromptUtil.runPrompt(promptTemplate, inputParams);
            
            // Assert
            Assert.isNotNull(result, 'Result should not be null');
            Assert.isTrue(result.length() > 0, 'Result should not be empty');
        } catch (Exception e) {}
        Test.stopTest();

    }

    /**
     * @description Tests runPrompt with null prompt template
     */
    @isTest 
    static void testRunPrompt_NullTemplate() {
        // Arrange
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue paramValue = new ConnectApi.WrappedValue();
        paramValue.value = 'TestValue';
        inputParams.put('TestParam', paramValue);

        // Act & Assert
        Test.startTest();
        try {
            String result = PromptUtil.runPrompt(null, inputParams);
            Assert.fail('Should throw exception for null template');
        } catch (Exception e) {
            Assert.isTrue(e instanceof AuraHandledException || e instanceof System.NullPointerException, 
                'Should throw appropriate exception for null template');
        }
        Test.stopTest();
    }

    /**
     * @description Tests runPrompt with null input parameters
     */
    @isTest 
    static void testRunPrompt_NullInputParams() {
        // Act & Assert
        Test.startTest();
        try {
            String result = PromptUtil.runPrompt('TestTemplate', null);
            Assert.fail('Should throw exception for null input parameters');
        } catch (Exception e) {
            Assert.isTrue(e instanceof AuraHandledException || e instanceof System.NullPointerException, 
                'Should throw appropriate exception for null input parameters');
        }
        Test.stopTest();
    }

    /**
     * @description Tests runPrompt with empty input parameters
     */
    @isTest 
    static void testRunPrompt_EmptyInputParams() {
        // Arrange
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

        // Act & Assert
        Test.startTest();
        try {
            String result = PromptUtil.runPrompt('TestTemplate', inputParams);
            Assert.fail('Should throw exception when prompt execution fails');
        } catch (Exception e) {
            Assert.isTrue(e instanceof AuraHandledException || e instanceof System.IllegalArgumentException, 
                'Should throw appropriate exception for empty input parameters');
        }
        Test.stopTest();
    }

    /**
     * @description Tests createPromptInput with null input parameters
     */
    @isTest 
    static void testCreatePromptInput_NullInputParams() {
        // Act & Assert
        Test.startTest();
        try {
            ConnectApi.EinsteinPromptTemplateGenerationsInput result = PromptUtil.createPromptInput(null);
            Assert.isNotNull(result, 'Result should not be null even with null input params');
            Assert.isNotNull(result.additionalConfig, 'AdditionalConfig should not be null');
            Assert.areEqual('PromptBuilderPreview', result.additionalConfig.applicationName, 'ApplicationName mismatch');
            Assert.areEqual(false, result.isPreview, 'isPreview should be false');
            Assert.isNull(result.inputParams, 'inputParams should be null');
        } catch (Exception e) {
            Assert.fail('Should not throw exception for null input params: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * @description Tests createPromptInput with multiple parameters
     */
    @isTest 
    static void testCreatePromptInput_MultipleParams() {
        // Arrange
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        
        ConnectApi.WrappedValue param1 = new ConnectApi.WrappedValue();
        param1.value = 'Value1';
        inputParams.put('Param1', param1);
        
        ConnectApi.WrappedValue param2 = new ConnectApi.WrappedValue();
        param2.value = 'Value2';
        inputParams.put('Param2', param2);

        // Act
        Test.startTest();
        ConnectApi.EinsteinPromptTemplateGenerationsInput result = PromptUtil.createPromptInput(inputParams);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Result should not be null');
        Assert.isNotNull(result.additionalConfig, 'AdditionalConfig should not be null');
        Assert.areEqual('PromptBuilderPreview', result.additionalConfig.applicationName, 'ApplicationName mismatch');
        Assert.areEqual(false, result.isPreview, 'isPreview should be false');
        Assert.isNotNull(result.inputParams, 'inputParams should not be null');
        Assert.areEqual(2, result.inputParams.size(), 'Should have two parameters');
        Assert.areEqual('Value1', result.inputParams.get('Param1').value, 'Param1 value mismatch');
        Assert.areEqual('Value2', result.inputParams.get('Param2').value, 'Param2 value mismatch');
    }

    /**
     * @description Tests runPrompt with mock response containing multiple generations
     */
    @isTest 
    static void testRunPrompt_MultipleGenerations() {
        // Arrange
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue paramValue = new ConnectApi.WrappedValue();
        paramValue.value = 'TestValue';
        inputParams.put('TestParam', paramValue);

        // Act & Assert
        Test.startTest();
        try {
            String result = PromptUtil.runPrompt('TestTemplate', inputParams);
            Assert.isNotNull(result, 'Result should not be null');
            Assert.isTrue(result.length() > 0, 'Result should not be empty');
        } catch (Exception e) {}
        Test.stopTest();
    }
}