import { LightningElement, api, wire } from 'lwc';
import getCompleteAgentConfiguration from '@salesforce/apex/GenAiMetadataService.getCompleteAgentConfiguration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOGO from '@salesforce/resourceUrl/logo_agentforce_optimizer';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import AGENT_SELECTED_MC from '@salesforce/messageChannel/AgentSelected__c';

export default class agentConfigurationViewer extends LightningElement {
    agentId;
    configuration;
    error;
    isLoading = false;
    logoUrl = LOGO;
    subscription = null;
    allSectionsExpanded = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                AGENT_SELECTED_MC,
                (message) => this.handleAgentSelected(message)
            );
        }
    }

    unsubscribeToMessageChannel() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    handleAgentSelected(message) {
        try {
            if (!message || !message.agentId) {
                this.showToast('Error', 'No agent ID provided', 'error');
                return;
            }

            this.agentId = message.agentId;
            this.isLoading = true;
            this.configuration = undefined;
            this.error = undefined;
        } catch (error) {
            console.error('Error in handleAgentSelected:', error);
            this.showToast('Error', 'Failed to process agent selection', 'error');
        }
    }

    @wire(getCompleteAgentConfiguration, { agentId: '$agentId' })
    wiredConfiguration({ error, data }) {
        this.isLoading = false;
        
        if (error) {
            console.error('Error in wire adapter:', error);
            this.error = error;
            this.configuration = undefined;
            this.showToast('Error', 'Failed to load configuration: ' + (error.body?.message || error.message || 'Unknown error'), 'error');
            return;
        }

        if (!data) {
            console.warn('No data received from wire adapter');
            this.configuration = undefined;
            this.error = undefined;
            return;
        }

        try {
            this.configuration = data;
            this.error = undefined;
        } catch (error) {
            console.error('Error processing configuration data:', error);
            this.error = error;
            this.configuration = undefined;
            this.showToast('Error', 'Failed to process configuration data', 'error');
        }
    }

    get hasConfiguration() {
        return this.configuration && !this.error;
    }

    get showSplashScreen() {
        return !this.agentId;
    }

    get agentConfig() {
        return this.configuration?.agent || {};
    }

    get agentLabel() {
        return `Agent Configuration Viewer: ${this.agentConfig?.label || 'Agent Configuration'}`;
    }

    get topics() {
        return this.configuration?.topics || [];
    }

    get expandIconName() {
        return this.allSectionsExpanded ? 'utility:collapse_all' : 'utility:expand_all';
    }

    get expandButtonTitle() {
        return this.allSectionsExpanded ? 'Collapse All' : 'Expand All';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    handleExpandAll() {
        const accordion = this.template.querySelector('lightning-accordion');
        if (accordion) {
            if (this.allSectionsExpanded) {
                // Close all sections
                accordion.activeSectionName = [];
            } else {
                // Open all sections
                const sections = this.topics.map(topic => topic.name);
                accordion.activeSectionName = sections;
            }
            this.allSectionsExpanded = !this.allSectionsExpanded;
        }
    }
}