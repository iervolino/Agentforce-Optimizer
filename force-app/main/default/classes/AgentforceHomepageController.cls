/**
 * @description Controller class for the Agentforce Homepage component
 * This class provides methods to retrieve and display banner images for the Agentforce homepage
 * 
 * @author Francesco Iervolino
 * @date 2025-03-21
 */
public with sharing class AgentforceHomepageController {
    
    /**
     * @description Retrieves the URL for a specific Agentforce banner image
     * @param index The index number of the banner (0 for default banner, >0 for numbered banners)
     * @return String The URL of the banner image, or null if not found
     * 
     * @example
     * String bannerUrl = AgentforceHomepageController.getAgentforceBannerUrl(0);
     */
    @AuraEnabled(cacheable=true)
    public static String getAgentforceBannerUrl(Integer index) {
        String docName='agentforceHomepageBanner' + ((index>0)?index+'':'');
        return getBannerUrlFromName(docName);
    }

    /**
     * @description Retrieves the URL for a document based on its name
     * @param docName The name of the document to retrieve
     * @return String The URL of the document, or null if not found
     */
    private static String getBannerUrlFromName(String docName) {
        try {
           Document doc = [SELECT Id FROM Document where Name = :docName LIMIT 1];  
           System.debug('file URL: ' + '/servlet/servlet.ImageServer?id=' + doc.Id + '&oid=' + UserInfo.getOrganizationId() );
           return '/servlet/servlet.ImageServer?id=' + doc.Id + '&oid=' + UserInfo.getOrganizationId();
        } catch (Exception e) {
           // Handle exceptions and return null if the file is not found
           System.debug('Error retrieving file ID: ' + e.getMessage());
           return null;
        }
    }
}