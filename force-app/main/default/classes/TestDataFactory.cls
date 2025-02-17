public class TestDataFactory {
    /* 
    * Encapsulates the User object.
    * Uses Builder pattern to simplify the creation of objects.
    */
    public class UserBuilder {
        private String alias = null;
        private String email = null;
        private String firstName = null;
        private String lastName = null;
        private String emailEncodingKey = null;
        private String languageLocaleKey = null;
        private String localeSidKey = null;
        private Id profileId = null;
        private String timeZoneSidKey = null;
        private String userName = null;
        private String slackbotChannelId = null;

        // Constructor
        public UserBuilder() {
        }

        // Setters
        public UserBuilder setAlias(String value) {
            this.alias = value;
            return this;
        }
        public UserBuilder setEmail(String value) {
            this.email = value;
            return this;
        }
        public UserBuilder setFirstName(String value) {
            this.firstName = value;
            return this;
        }
        public UserBuilder setLastName(String value) {
            this.lastName = value;
            return this;
        }
        public UserBuilder setEmailEncodingKey(String value) {
            this.emailEncodingKey = value;
            return this;
        }
        public UserBuilder setLanguageLocaleKey(String value) {
            this.languageLocaleKey = value;
            return this;
        }
        public UserBuilder setLocaleSidKey(String value) {
            this.localeSidKey = value;
            return this;
        }
        public UserBuilder setProfileId(Id value) {
            this.profileId = value;
            return this;
        }
        public UserBuilder setTimeZoneSidKey(String value) {
            this.timeZoneSidKey = value;
            return this;
        } 
        public UserBuilder setUserName(String value) {
            this.userName = value;
            return this;
        }
        public UserBuilder setSlackbotChannelId(String value){
            this.slackbotChannelId = value;
            return this;
        }

        /**
         * Returns an instance of User based on the parameters given above
         * @return User  - A User with the desired attributes
         */
        public User build() {
            User user = new User();
            user.Alias = this.alias;
            user.Email = this.email;
            user.FirstName = this.firstName;
            user.LastName = this.lastName;
            user.EmailEncodingKey = (this.emailEncodingKey == null) ? 'UTF-8' : this.emailEncodingKey;
            user.LanguageLocaleKey = (this.languageLocaleKey == null) ? 'en_US' : this.languageLocaleKey;
            user.LocaleSidKey = (this.localeSidKey == null) ? 'en_US' : this.localeSidKey;
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User']; 
            user.ProfileId = (this.profileId == null) ? p.Id : this.profileId;
            user.TimeZoneSidKey = (this.timeZoneSidKey == null) ? 'America/Los_Angeles': this.timeZoneSidKey;
            user.UserName = this.userName;
            user.Slackbot_Channel_ID__c = this.slackbotChannelId;
                       
            return user;
        }
    }

    /* 
    * Encapsulates the Case object.
    * Uses Builder pattern to simplify the creation of objects.
    */
    public class CaseBuilder {

        private String subject = null;
        private String status = null;
        private String priority = null;
        private Id ownerId = null;


        // Constructor
        public CaseBuilder() {
        }

        // Setters
        public CaseBuilder setSubject(String value) {
            this.subject = value;
            return this;
        }
        public CaseBuilder setStatus(String value) {
            this.status = value;
            return this;
        }
        public CaseBuilder setPriority(String value) {
            this.priority = value;
            return this;
        }
        public CaseBuilder setOwnerId(Id value) {
            this.ownerId = value;
            return this;
        }

        /**
         * Returns an instance of Case based on the parameters given above
         * @return Case  - A Case with the desired attributes
         */
        public Case build() {
            Case c = new Case();
            c.Subject = this.subject;
            c.Status = this.status;
            c.Priority = this.priority;
            c.OwnerId = this.ownerId;
                       
            return c;
        }
    }

    /* 
    * Encapsulates the CaseComment object.
    * Uses Builder pattern to simplify the creation of objects.
    */
    public class CaseCommentBuilder {

        private String commentBody = null;
        private Id parentId = null;


        // Constructor
        public CaseCommentBuilder() {
        }

        // Setters
        public CaseCommentBuilder setCommentBody(String value) {
            this.commentBody = value;
            return this;
        }
        public CaseCommentBuilder setParentId(Id value) {
            this.parentId = value;
            return this;
        }

        /**
         * Returns an instance of CaseComment based on the parameters given above
         * @return CaseComment  - A CaseComment with the desired attributes
         */
        public CaseComment build() {
            CaseComment cc = new CaseComment();
            cc.CommentBody = this.commentBody;
            cc.ParentId = this.parentId;
                       
            return cc;
        }
    }
}
