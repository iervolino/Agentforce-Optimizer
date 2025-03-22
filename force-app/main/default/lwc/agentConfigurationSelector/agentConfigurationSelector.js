import { LightningElement, wire } from 'lwc';
import getAllAgents from '@salesforce/apex/GenAiMetadataService.getAllAgents';
import { publish, MessageContext } from 'lightning/messageService';
import AGENT_SELECTED_MC from '@salesforce/messageChannel/AgentSelected__c';

export default class AgentConfigurationSelector extends LightningElement {
    agents = [];
    selectedAgentId;
    error;
    label = 'Agent Configuration Selector';

    @wire(MessageContext)
    messageContext;

    @wire(getAllAgents)
    wiredAgents({ error, data }) {
        if (data) {
            this.agents = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.agents = [];
        }
    }

    handleAgentChange(event) {
        try {
            const selectedAgentId = event.target.value;
            console.log('Agent selected with ID:', selectedAgentId);
            
            if (!selectedAgentId) {
                console.log('No agent ID selected, returning early');
                return;
            }

            const selectedAgent = this.agents.find(agent => agent.id === selectedAgentId);
            console.log('Found selected agent:', selectedAgent);
            
            if (!selectedAgent) {
                console.log('No agent found for ID:', selectedAgentId);
                return;
            }

            // Publish the message using Lightning Message Service
            const message = {
                agentId: selectedAgent.id,
                agentName: selectedAgent.label
            };

            console.log('Publishing agent selected message:', message);
            publish(this.messageContext, AGENT_SELECTED_MC, message);
        } catch (error) {
            console.error('Error in handleAgentChange:', error);
        }
    }
}