@isTest
public with sharing class Peak_BaseControllerTest {

    @isTest
    public static void testGetSitePrefix() {
    	system.assert(Peak_BaseController.getSitePrefix() != null);
    }

    // Test finding a user
    @isTest
    public static void testUser(){
        // Set up and run as a standard user
        User testUser = Peak_TestUtils.createStandardUser();
        System.runAs(testUser) {
            System.assertEquals(false,Peak_BaseController.isGuestUser());
        }

    }

    // Test running as a guest
    @isTest
    public static void testGuest(){
        // Set up and run as guest user 
        User guestUser = Peak_TestUtils.createGuestUser();

        System.runAs(guestUser) {
            System.assertEquals(true,Peak_BaseController.isGuestUser());
        }
    }

}