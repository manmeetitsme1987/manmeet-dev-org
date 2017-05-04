public without sharing class SSOController {

    public Pagereference redirectActionToLambda(){
        String redirectUrl = 'http://kodakalarisdev.yourmoodle.com/login/index.php?un=salesforce_demo@demo.crm&pw=Password123&';
        PageReference pg = new Pagereference(redirectUrl);
        return pg;
    }
    
    public Pagereference redirectActionToPicturePark(){
        String redirectUrl = 'https://kodakalaris.picturepark.com/Site/Start?un=salesforce_demo@demo.crm&pw=Password123&';
        PageReference pg = new Pagereference(redirectUrl);
        return pg;
    }
}