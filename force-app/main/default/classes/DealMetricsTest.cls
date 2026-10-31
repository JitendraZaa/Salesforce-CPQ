/**
 * Tests for the Velora deal metrics rule. The fixtures are built in memory, so no org data is needed.
 *
 * @author Jitendra Zaa
 */
@IsTest
private class DealMetricsTest {

    @IsTest
    static void pilotFixture_returnsMrr29Arr348Tcv48348() {
        List<DealMetrics.Line> lines = new List<DealMetrics.Line>{
            new DealMetrics.Line('VV-100', false, 48000, 1, 0),
            new DealMetrics.Line('VC-SUB', true, 29, 1, 12)
        };
        DealMetrics.Result result = DealMetrics.calculate(lines);
        Assert.areEqual(29.00, result.mrr, 'MRR counts the Connect plan only');
        Assert.areEqual(348.00, result.arr, 'ARR is MRR times twelve');
        Assert.areEqual(48348.00, result.tcv, 'TCV counts every charge over the term');
    }

    @IsTest
    static void oneTimeOnly_hasNoRecurringRevenue() {
        List<DealMetrics.Line> lines = new List<DealMetrics.Line>{
            new DealMetrics.Line('VV-100', false, 48000, 1, 0)
        };
        DealMetrics.Result result = DealMetrics.calculate(lines);
        Assert.areEqual(0, result.mrr);
        Assert.areEqual(0, result.arr);
        Assert.areEqual(48000.00, result.tcv);
    }

    @IsTest
    static void rampCohort_100Connect36Months() {
        List<DealMetrics.Line> lines = new List<DealMetrics.Line>{
            new DealMetrics.Line('VC-SUB', true, 29, 100, 36)
        };
        DealMetrics.Result result = DealMetrics.calculate(lines);
        Assert.areEqual(2900.00, result.mrr);
        Assert.areEqual(34800.00, result.arr);
        Assert.areEqual(104400.00, result.tcv);
    }

    @IsTest
    static void forQuote_readsTheQuoteLines() {
        Product2 van = new Product2(Name = 'Volt Van', ProductCode = 'VV-100', IsActive = true);
        insert van;
        Id bookId = Test.getStandardPricebookId();
        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = bookId,
            Product2Id = van.Id,
            UnitPrice = 48000,
            IsActive = true
        );
        insert entry;
        Account account = new Account(Name = 'Swift Couriers');
        insert account;
        Opportunity opp = new Opportunity(
            Name = 'Pilot',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = bookId
        );
        insert opp;
        Quote quote = new Quote(Name = 'Pilot', OpportunityId = opp.Id, Pricebook2Id = bookId);
        insert quote;
        insert new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = entry.Id,
            Product2Id = van.Id,
            Quantity = 1,
            UnitPrice = 48000
        );

        DealMetrics.Result result = DealMetrics.forQuote(quote.Id);

        Assert.areEqual(0, result.mrr, 'A one-time line is not recurring');
        Assert.areEqual(48000.00, result.tcv);
    }

    @IsTest
    static void emptyList_returnsZeros() {
        DealMetrics.Result result = DealMetrics.calculate(null);
        Assert.areEqual(0, result.tcv);
    }
}
