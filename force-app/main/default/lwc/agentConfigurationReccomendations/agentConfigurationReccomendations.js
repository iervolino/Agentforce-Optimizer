import { LightningElement, track, wire } from 'lwc';
import validateAgentforceConfigurations from '@salesforce/apex/GenAiMetadataService.validateAgentforceConfigurations';
import recommendAgentforceChanges from '@salesforce/apex/GenAiMetadataService.recommendAgentforceChanges';
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import AGENT_SELECTED_MC from '@salesforce/messageChannel/AgentSelected__c';

export default class AgentConfigurationReccomendations extends LightningElement {
    @track isButtonGroupDisabled = true;
    @track splashScreenText = 'Agent configuration non selected';
    @track selectedAgentId;
    @track validationResults = [];
    @track isLoading = false;
    @track isSearchModalOpen = false;
    @track searchTerm = '';
    @track isOptimizeModalOpen = false;
    @track optimizeInstructions = '';
    @track isOptimizeButtonDisabled = true;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        console.log('AgentConfigurationReccomendations component connected');
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        console.log('AgentConfigurationReccomendations component disconnected');
        this.unsubscribeFromMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                AGENT_SELECTED_MC,
                (message) => this.handleAgentSelected(message)
            );
            console.log('Subscribed to AgentSelected message channel');
        }
    }

    unsubscribeFromMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
        console.log('Unsubscribed from AgentSelected message channel');
    }

    handleAgentSelected(message) {
        console.log('Received agent selected message:', message);
        const { agentId, agentName } = message;
        this.selectedAgentId = agentId;
        this.isButtonGroupDisabled = false;
        this.splashScreenText = `Selected Agent: ${agentName}`;
        console.log('Updated component state:', {
            selectedAgentId: this.selectedAgentId,
            isButtonGroupDisabled: this.isButtonGroupDisabled,
            splashScreenText: this.splashScreenText
        });
    }

    async handleValidateConfigurations() {
        try {
            this.isLoading = true;
            const result = await validateAgentforceConfigurations({ agentId: this.selectedAgentId });
            console.log('Validation result:', result);
            
            // Handle single HTML result
            this.validationResults = [{
                id: 0,
                name: 'Configuration Validation',
                description: result,
                status: 'Complete',
                statusClass: 'slds-text-color_default'
            }];
        } catch (error) {
            console.error('Error validating configurations:', error);
            this.validationResults = [{
                id: 0,
                name: 'Error',
                description: 'Failed to validate configurations. Please try again.',
                status: 'Error',
                statusClass: 'slds-text-color_error'
            }];
        } finally {
            this.isLoading = false;
        }
    }

    getStatusClass(status) {
        switch (status?.toLowerCase()) {
            case 'success':
                return 'slds-text-color_success';
            case 'warning':
                return 'slds-text-color_warning';
            case 'error':
                return 'slds-text-color_error';
            default:
                return 'slds-text-color_default';
        }
    }

    handleOptimiseInstructions() {
        this.isOptimizeModalOpen = true;
        this.optimizeInstructions = '';
        this.isOptimizeButtonDisabled = true;
    }

    handleCloseOptimizeModal() {
        this.isOptimizeModalOpen = false;
        this.optimizeInstructions = '';
        this.isOptimizeButtonDisabled = true;
    }

    handleOptimizeInstructionsChange(event) {
        this.optimizeInstructions = event.target.value;
        this.isOptimizeButtonDisabled = !this.optimizeInstructions.trim();
    }

    async handleSubmitOptimizeInstructions() {
        try {
            this.isLoading = true;
            const result = await recommendAgentforceChanges({ 
                agentId: this.selectedAgentId, 
                userIntent: this.optimizeInstructions 
            });
            
            this.validationResults = [{
                id: 0,
                name: 'Optimization Recommendations',
                description: result,
                status: 'Success',
                statusClass: 'slds-text-color_success'
            }];
            
            this.handleCloseOptimizeModal();
        } catch (error) {
            console.error('Error submitting optimization instructions:', error);
            this.validationResults = [{
                id: 0,
                name: 'Error',
                description: 'Failed to submit optimization instructions. Please try again.',
                status: 'Error',
                statusClass: 'slds-text-color_error'
            }];
        } finally {
            this.isLoading = false;
        }
    }

    handleSearchClick() {
        this.isSearchModalOpen = true;
    }

    handleCloseModal() {
        this.isSearchModalOpen = false;
        this.searchTerm = '';
    }

    handleSearchInputChange(event) {
        this.searchTerm = event.target.value;
        // Add search logic here when needed
    }
}