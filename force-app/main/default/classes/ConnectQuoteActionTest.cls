/**
 * Tests for the Create Connect Quote action. A stand-in replaces the real Place Sales Transaction call.
 *
 * @author Jitendra Zaa
 */
@IsTest
private class ConnectQuoteActionTest {

    /** Counts its calls, inserts a real Quote on success, and can save the header and then fail. */
    private class MockPlacer implements QuotePlacer {
        Integer calls = 0;
        Boolean failAfterHeader = false;
        Id lastExistingQuoteId;

        public QuoteOutcome place(QuoteInput input, Id existingQuoteId) {
            calls++;
            lastExistingQuoteId = existingQuoteId;
            Id quoteId = existingQuoteId;
            if (quoteId == null) {
                Quote quote = new Quote(Name = input.quoteName, OpportunityId = input.opportunityId);
                insert quote;
                quoteId = quote.Id;
            }
            if (failAfterHeader) {
                failAfterHeader = false;
                return new QuoteOutcome(false, quoteId, 'T-' + calls, 'The line step failed.');
            }
            return new QuoteOutcome(true, quoteId, 'T-' + calls, null);
        }
    }

    private static Opportunity makeOpportunity() {
        Account account = new Account(Name = 'Swift Couriers');
        insert account;
        Opportunity opp = new Opportunity(
            Name = 'Swift Connect',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        return opp;
    }

    private static Id fakeId(Schema.SObjectType type, Integer n) {
        return Id.valueOf(type.getDescribe().getKeyPrefix() + String.valueOf(1000000 + n).leftPad(12, '0'));
    }

    private static ConnectQuoteAction.Input makeInput(Opportunity opp) {
        ConnectQuoteAction.Input input = new ConnectQuoteAction.Input();
        input.opportunityId = opp.Id;
        input.pricebook2Id = fakeId(Pricebook2.SObjectType, 1);
        input.product2Id = fakeId(Product2.SObjectType, 1);
        input.pricebookEntryId = fakeId(PricebookEntry.SObjectType, 1);
        input.unitPrice = 29;
        return input;
    }

    @IsTest
    static void oneClick_oneQuote() {
        Opportunity opp = makeOpportunity();
        MockPlacer mock = new MockPlacer();
        QuoteRequestService.placer = mock;

        List<ConnectQuoteAction.Output> outputs = ConnectQuoteAction.run(
            new List<ConnectQuoteAction.Input>{ makeInput(opp) }
        );

        Assert.areEqual(1, [SELECT COUNT() FROM Quote]);
        Quote_Request__c request = [SELECT Status__c, Quote__c FROM Quote_Request__c];
        Assert.areEqual('Completed', request.Status__c);
        Assert.isNotNull(request.Quote__c);
        Assert.areEqual(1, mock.calls);
        Assert.isTrue(outputs[0].created);
        Assert.areEqual(request.Quote__c, outputs[0].quoteId);
        Assert.areEqual(opp.Id + ':VC-SUB', outputs[0].correlationId);
    }

    @IsTest
    static void secondClick_sameQuote() {
        Opportunity opp = makeOpportunity();
        MockPlacer mock = new MockPlacer();
        QuoteRequestService.placer = mock;

        List<ConnectQuoteAction.Output> first = ConnectQuoteAction.run(
            new List<ConnectQuoteAction.Input>{ makeInput(opp) }
        );
        List<ConnectQuoteAction.Output> second = ConnectQuoteAction.run(
            new List<ConnectQuoteAction.Input>{ makeInput(opp) }
        );

        Assert.areEqual(1, [SELECT COUNT() FROM Quote]);
        Assert.isFalse(second[0].created);
        Assert.areEqual(first[0].quoteId, second[0].quoteId);
        Assert.areEqual(1, mock.calls);
    }

    @IsTest
    static void lineFailsAfterHeader_retryAddsLine() {
        Opportunity opp = makeOpportunity();
        MockPlacer mock = new MockPlacer();
        mock.failAfterHeader = true;
        QuoteRequestService.placer = mock;

        List<ConnectQuoteAction.Output> first = ConnectQuoteAction.run(
            new List<ConnectQuoteAction.Input>{ makeInput(opp) }
        );
        Quote_Request__c afterFailure = [SELECT Status__c, Quote__c, Attempts__c, Error_Message__c FROM Quote_Request__c];
        Assert.areEqual('Header Saved', afterFailure.Status__c);
        Assert.isNotNull(afterFailure.Quote__c);
        Assert.areEqual(1, afterFailure.Attempts__c);
        Assert.areEqual('The line step failed.', first[0].message);

        ConnectQuoteAction.run(new List<ConnectQuoteAction.Input>{ makeInput(opp) });

        Assert.areEqual(afterFailure.Quote__c, mock.lastExistingQuoteId);
        Assert.areEqual(1, [SELECT COUNT() FROM Quote]);
        Quote_Request__c afterRetry = [SELECT Status__c, Attempts__c FROM Quote_Request__c];
        Assert.areEqual('Completed', afterRetry.Status__c);
        Assert.areEqual(2, afterRetry.Attempts__c);
    }

    @IsTest
    static void placer_buildsGraphForNewQuoteAndForLineOnly() {
        Opportunity opp = makeOpportunity();
        QuoteInput input = new QuoteInput();
        input.opportunityId = opp.Id;
        input.pricebook2Id = fakeId(Pricebook2.SObjectType, 1);
        input.product2Id = fakeId(Product2.SObjectType, 1);
        input.pricebookEntryId = fakeId(PricebookEntry.SObjectType, 1);
        input.unitPrice = 29;
        input.startDate = Date.today();
        input.endDate = Date.today().addMonths(12).addDays(-1);
        input.quoteName = 'Velora Connect';

        Assert.isNotNull(PstQuotePlacer.buildGraph(input, null));
        Assert.isNotNull(PstQuotePlacer.buildGraph(input, fakeId(Quote.SObjectType, 1)));

        // The real call cannot succeed on made-up ids, but it must end in an outcome and never throw.
        QuoteOutcome outcome = new PstQuotePlacer().place(input, null);
        Assert.isNotNull(outcome);
    }

    @IsTest
    static void placer_turnsAResponseIntoAnOutcome() {
        Id quoteId = fakeId(Quote.SObjectType, 2);
        QuoteOutcome ok = PstQuotePlacer.toOutcome(true, String.valueOf(quoteId), 'T-1', null, null);
        Assert.isTrue(ok.isSuccess);
        Assert.areEqual(quoteId, ok.quoteId);
        Assert.areEqual('T-1', ok.trackerId);

        QuoteOutcome failed = PstQuotePlacer.toOutcome(false, null, null, new List<Object>{ 'No price' }, quoteId);
        Assert.isFalse(failed.isSuccess);
        Assert.areEqual(quoteId, failed.quoteId);
        Assert.areEqual('No price', failed.message);

        QuoteOutcome silent = PstQuotePlacer.toOutcome(false, null, null, null, null);
        Assert.isNotNull(silent.message);
    }
}
