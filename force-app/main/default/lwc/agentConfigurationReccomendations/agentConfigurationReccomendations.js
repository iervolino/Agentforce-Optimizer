import { LightningElement, track, wire } from 'lwc';
import validateAgentforceConfigurations from '@salesforce/apex/GenAiMetadataService.validateAgentforceConfigurations';
import getCompleteAgentConfiguration from '@salesforce/apex/GenAiMetadataService.getCompleteAgentConfiguration';
import sendDiagnosticEmail from '@salesforce/apex/GenAiMetadataService.sendDiagnosticEmail';
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import AGENT_SELECTED_MC from '@salesforce/messageChannel/AgentSelected__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class AgentConfigurationReccomendations extends NavigationMixin(LightningElement) {
    @track isButtonGroupDisabled = true;
    @track isValidationCompleted = false;
    @track isShareModalOpen = false;
    @track shareModalData = null;
    @track splashScreenText = 'Agent configuration non selected';
    @track selectedAgentId;
    @track validationResults = [];
    @track isLoading = false;
    @track isSearchModalOpen = false;
    @track searchTerm = ''; 
    @track isOptimizeModalOpen = false;
    @track optimizeInstructions = '';
    @track isOptimizeButtonDisabled = true;
    @track isInfoModalOpen = false;
    @track isValidationComplete = false;
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
        if (!this.selectedAgentId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select an agent first',
                    variant: 'error'
                })
            );
            return;
        }

        this.isLoading = true;
        this.isValidationComplete = false;
        this.validationResults = [];

        try {
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
            this.isValidationComplete = true;
        } catch (error) {
            console.error('Error validating configurations:', error);
            this.validationResults = [{
                id: 0,
                name: 'Error',
                description: 'Failed to validate configurations. Please try again.',
                status: 'Error',
                statusClass: 'slds-text-color_error'
            }];
            this.isValidationComplete = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message || 'Failed to validate configurations',
                    variant: 'error'
                })
            );
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

    handleSearchInputChange(event) {
        this.searchTerm = event.target.value;
        // Add search logic here when needed
    }

    formatDiagnosticContent(completeConfig, validationResults) {
        if (!completeConfig || !validationResults) {
            return null;
        }

        const htmlContent = `
            <div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto;">
                <h1 style="color: #16325c; border-bottom: 2px solid #d8dde6; padding-bottom: 10px;">Agent Configuration</h1>
                <div style="background-color: #f3f3f3; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                    <p><strong>Name:</strong> ${completeConfig.agent?.name || 'N/A'}</p>
                    <p><strong>Label:</strong> ${completeConfig.agent?.label || 'N/A'}</p>
                    <p><strong>Description:</strong> ${completeConfig.agent?.description || 'N/A'}</p>
                    <p><strong>Capabilities:</strong> ${completeConfig.agent?.capabilities || 'N/A'}</p>
                    <p><strong>Language:</strong> ${completeConfig.agent?.language || 'N/A'}</p>
                    <p><strong>Planner Type:</strong> ${completeConfig.agent?.plannerType || 'N/A'}</p>
                </div>

                <h2 style="color: #16325c; border-bottom: 2px solid #d8dde6; padding-bottom: 10px;">Topics</h2>
                ${(completeConfig.topics || []).map(topic => `
                    <div style="background-color: #f3f3f3; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                        <h3 style="color: #16325c; margin-top: 0;">${topic.name || 'Unnamed Topic'}</h3>
                        <p><strong>Description:</strong> ${topic.description || 'N/A'}</p>
                        <p><strong>Scope:</strong> ${topic.scope || 'N/A'}</p>
                        
                        <div style="margin-top: 15px;">
                            <h4 style="color: #16325c; margin-bottom: 10px;">Instructions</h4>
                            <ul style="margin: 0; padding-left: 20px;">
                                ${(topic.instructions || []).map(instruction => 
                                    `<li>${instruction.description || 'N/A'}</li>`
                                ).join('')}
                            </ul>
                        </div>

                        <div style="margin-top: 15px;">
                            <h4 style="color: #16325c; margin-bottom: 10px;">Actions</h4>
                            <ul style="margin: 0; padding-left: 20px;">
                                ${(topic.actions || []).map(action => `
                                    <li>
                                        <strong>Function:</strong> ${action.function || 'N/A'}<br>
                                        <strong>Description:</strong> ${action.description || 'N/A'}<br>
                                    </li>
                                `).join('')}
                            </ul>
                        </div>
                    </div>
                `).join('')}

                <h2 style="color: #16325c; border-bottom: 2px solid #d8dde6; padding-bottom: 10px;">Validation Results</h2>
                <div style="background-color: #f3f3f3; padding: 15px; border-radius: 5px;">
                    ${validationResults.map(result => `
                        <div style="margin-bottom: 15px;">
                            ${result.description || 'No description available'}
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
        return htmlContent;
    }

    async handleExportDiagnostics() {
        try {
            if (!this.validationResults || this.validationResults.length === 0) {
                throw new Error('No validation results to export');
            }

            // Get complete agent configuration
            const completeConfig = await getCompleteAgentConfiguration({ agentId: this.selectedAgentId });
            if (!completeConfig.success) {
                throw new Error(completeConfig.error || 'Failed to retrieve agent configuration');
            }

            // Format the diagnostic content
            const diagnosticContent = this.formatDiagnosticContent(completeConfig, this.validationResults);
            
            // Copy to clipboard
            await navigator.clipboard.writeText(diagnosticContent);

            // Show success toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Diagnostic information has been copied to your clipboard',
                    variant: 'success'
                })
            );

        } catch (error) {
            console.error('Error exporting diagnostics:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message || 'Failed to export diagnostics',
                    variant: 'error'
                })
            );
        }
    }

    async handleShowInformationDisclosure() {
        try {
            const result = await this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__informationDisclosureModal'
                },
                state: {
                    c__label: 'Information Disclosure'
                }
            });
        } catch (error) {
            console.error('Error showing information disclosure modal:', error);
        }
    }

    handleShareDiagnostics() {
        this.isInfoModalOpen = true;
    }

    handleInfoModalClose() {
        this.isInfoModalOpen = false;
    }

    async handleInfoModalConfirm() {
        this.isInfoModalOpen = false;
        try {
            if (!this.validationResults || this.validationResults.length === 0) {
                throw new Error('No validation results to share');
            }

            if (!this.selectedAgentId) {
                throw new Error('No agent selected');
            }

            console.log('Getting complete agent configuration for agentId:', this.selectedAgentId);
            // Get complete agent configuration
            const completeConfig = await getCompleteAgentConfiguration({ agentId: this.selectedAgentId });
            console.log('Complete config result:', completeConfig);

            if (!completeConfig || !completeConfig.success) {
                throw new Error(completeConfig?.error || 'Failed to retrieve agent configuration');
            }

            // Format the diagnostic content
            const diagnosticContent = this.formatDiagnosticContent(completeConfig, this.validationResults);
            console.log('Formatted diagnostic content length:', diagnosticContent.length);
            
            if (!diagnosticContent) {
                throw new Error('Failed to format diagnostic content');
            }

            // Send the email
            console.log('Sending diagnostic email...');
            const emailResult = await sendDiagnosticEmail({ 
                agentId: this.selectedAgentId,
                diagnosticContent: diagnosticContent
            });
            console.log('Email result:', emailResult);

            if (emailResult) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Diagnostic information has been sent successfully',
                        variant: 'success'
                    })
                );
            } else {
                throw new Error('Failed to send diagnostic email');
            }
        } catch (error) {
            console.error('Error sharing diagnostics:', error);
            console.error('Error stack:', error.stack);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message || 'Failed to share diagnostics',
                    variant: 'error'
                })
            );
        }
    }

    get areDiagnosticButtonsDisabled() {
        return this.isLoading || !this.isValidationComplete;
    }

}