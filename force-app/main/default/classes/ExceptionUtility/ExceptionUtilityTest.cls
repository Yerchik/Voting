/**
* Used to test functionality of 'ExceptionUtility' class.
*
* @author  Dmytro Skakun
* @version 1.0
* @since   2022-03-22
*/
@IsTest
public class ExceptionUtilityTest {
    /**
    * Tests negative scenario of 'execute' method.
    */
    @IsTest
    static void execute_failTest() {
        Test.startTest();
        Id jobId = System.enqueueJob(new ExceptionUtility(null));

        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals('Completed', [SELECT Status FROM AsyncApexJob WHERE Id = :jobId].Status, 'Job should be finished');
        System.assertEquals(0, emailInvocations, 'Email should not be sent without provided exception');
    }

    /**
    * Tests positive scenario of 'execute' method.
    */
    @IsTest
    static void execute_successTest() {
        Id jobId;

        Test.startTest();
        try {
            insert new Account();
        } catch (Exception e) {
            jobId = System.enqueueJob(new ExceptionUtility(e));
        }

        Test.stopTest();

        System.assertEquals('Completed', [SELECT Status FROM AsyncApexJob WHERE Id = :jobId].Status, 'Job should be finished');
    }
}
