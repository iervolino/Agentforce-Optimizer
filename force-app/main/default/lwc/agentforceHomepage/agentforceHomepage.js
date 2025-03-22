import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getAgentforceBannerUrl from '@salesforce/apex/AgentforceHomepageController.getAgentforceBannerUrl';
// import getAgentforceBuilderUrl from '@salesforce/apex/AgentforceHomepageController.getAgentforceBuilderUrl';
import { labels } from './labels';

export default class AgentforceHomepage extends NavigationMixin(LightningElement) {

	/* Splash banner at the top of the page */
	heroBannerUrl;
	/* Banner associated with the launch card */
	launchBannerUrl;
	/* Banner associated with the practice (Trailhead) card */
	practiceBannerUrl;
	/* Banner associated with the learn (salesforce help) card */
	learnBannerUrl;

	labels = labels;
 
	@wire(getAgentforceBannerUrl,{ index: 0 })
	wiredFileUrl({ error, data }) {
		if (data) {
			this.heroBannerUrl = data;
		} else if (error) {
			console.error('Error retrieving file URL:', error);
		}
	}

	@wire(getAgentforceBannerUrl,{ index: 2 })
	wiredLaunchBannerUrl({ error, data }) {
		if (data) {
			this.launchBannerUrl = data;
		} else if (error) {
			console.error('Error retrieving smallBannerUrl1:', error);
		}
	}

	get launchBannerStyle() {
		return this.launchBannerUrl ? `background-image: url(${this.launchBannerUrl});` : '';
	}

	@wire(getAgentforceBannerUrl,{ index: 3 })
	wiredPracticeBannerUrl({ error, data }) {
		if (data) {
			this.practiceBannerUrl = data;
		} else if (error) {
			console.error('Error retrieving smallBannerUrl2:', error);
		}
	}

	get practiceBannerStyle() {
		return this.practiceBannerUrl ? `background-image: url(${this.practiceBannerUrl});` : '';
	}

	@wire(getAgentforceBannerUrl,{ index: 1 })
	wiredLearnBannerUrl({ error, data }) {
		if (data) {
			this.learnBannerUrl = data;
		} else if (error) {
			console.error('Error retrieving smallBannerUrl3:', error);
		}
	}

	get learnBannerStyle() {
		return this.learnBannerUrl ? `background-image: url(${this.learnBannerUrl});` : '';
	}


	/* @wire(getAgentforceBuilderUrl)
	wiredAgentUrl({ error, data }) {
		if (data) {
			this.agentUrl = data;
		} else if (error) {
			console.error('Error retrieving agent URL:', error);
		}
	} */

	view(event) {
		const viewType = event.currentTarget.dataset.type;
		let url;
		if (viewType === "url") {
			url = event.currentTarget.dataset.url;
		}
		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url
			}
		});
	}
}