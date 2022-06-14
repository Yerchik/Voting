/**
* Used to handle Apex exceptions and notify the current user and admins via generated email message from a handled exception.
*
* @author  Dmytro Skakun
* @version 1.0
* @since   2022-03-22
*/
public inherited sharing class ExceptionUtility implements Queueable {
    private final String ADMIN_PROFILE_NAME = 'System Administrator';

    private Exception handledException;

    /**
    * Constructor with ability to pass a handled exception.
    * @param  handledException handled exception
    */
    public ExceptionUtility(Exception handledException) {
        this.handledException = handledException;
    }

    /**
    * Generates email message and notifies users.
    * @param  context Queueable context
    */
    public void execute(QueueableContext context) {
        if (this.handledException == null) {
            return;
        }

        notifyUsers(generateEmailMessage());
    }

    /**
    * Generates email message according to exception.
    * @return                  Generated email message
    */
    private String generateEmailMessage() {
        String emailMessage = '';

        if (this.handledException.getCause() != null) {
            emailMessage += Label.ExcUtil_Error_Cause.replace('{cause}', this.handledException.getCause().getMessage()) + '\n';
        }

        emailMessage += Label.ExcUtil_Error_Message.replace('{message}', this.handledException.getMessage()) + '\n';
        emailMessage += Label.ExcUtil_Stack_Trace.replace('{stackTrace}', this.handledException.getStackTraceString());

        return emailMessage;
    }

    /**
    * Sends email notification to users.
    */
    private void notifyUsers(String emailMessage) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        message.toAddresses = generateRecipients();
        message.subject = Label.ExcUtil_Email_Subject;
        message.plainTextBody = emailMessage;

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { message });
    }

    /**
    * Generates a list with current user's email and queries DB for admin's emails if Limits allow to do.
    * @return                  List of current user's email with admins' emails
    */
    private List<String> generateRecipients() {
        List<String> recipients = new List<String> { UserInfo.getUserEmail() };

        if (Limits.getLimitQueries() > Limits.getQueries()) {
            recipients.addAll(getAdminEmails());
        }

        return recipients;
    }

    /**
    * Queries DB for admin's emails.
    * @return                  Set of admins' emails
    */
    private Set<String> getAdminEmails() {
        Set<String> adminEmails = new Set<String>();

        for (User adminUser : [
            SELECT Email
            FROM User
            WHERE IsActive = TRUE
                AND Id != :UserInfo.getUserId()
                AND Profile.Name = :this.ADMIN_PROFILE_NAME
        ]) {
            adminEmails.add(adminUser.Email);
        }

        return adminEmails;
    }
}
