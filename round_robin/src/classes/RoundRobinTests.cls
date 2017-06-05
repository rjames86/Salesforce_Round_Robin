@isTest
private class RoundRobinTests {

	@isTest static void insertAccountTest() {
		Account acct = new Account(Name='Test account');
        insert acct;
	}

    @isTest static void integrationTest() {
        Account acct = new Account(Name='Test account');

        Datetime dt = Datetime.now();
        Long l = dt.getTime();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String LastName = 'Johnson';
        User myUser = new User(
            EmailEncodingKey='UTF-8',
            LastName= LastName,
            LanguageLocaleKey='en_US',
            Alias = LastName.abbreviate(8),
            Title='Engineer',
            Email= LastName + 'standarduser@testorg.com',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName= LastName + 'standarduserTestUser@testorg.com'
        );
        insert myUser;

        RoundRobinSettings.createRecord('Test', User.Title, 'Engineer', User.Title);

        RoundRobinService service = new RoundRobinService(new List<Account>{acct});
        service.assignRoundRobin();
    }
}
