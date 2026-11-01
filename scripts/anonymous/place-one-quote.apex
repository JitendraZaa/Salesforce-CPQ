// Runs the Create Connect Quote action once for Swift Couriers - Fleet (the opportunity that has a price book), to see the real Place Sales Transaction call work
// before the flow is involved. Run: sf apex run --file scripts/anonymous/place-one-quote.apex
// This creates a real quote in the org. Run it only when you mean to.
// @author Jitendra Zaa
Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Name = 'Swift Couriers - Fleet' LIMIT 1];
Product2 product = [SELECT Id FROM Product2 WHERE ProductCode = 'VC-SUB' LIMIT 1];
PricebookEntry entry = [
    SELECT Id, UnitPrice
    FROM PricebookEntry
    WHERE Product2Id = :product.Id AND Pricebook2Id = :opp.Pricebook2Id AND IsActive = true
    LIMIT 1
];

ConnectQuoteAction.Input input = new ConnectQuoteAction.Input();
input.opportunityId = opp.Id;
input.pricebook2Id = opp.Pricebook2Id;
input.product2Id = product.Id;
input.pricebookEntryId = entry.Id;
input.unitPrice = entry.UnitPrice;

List<ConnectQuoteAction.Output> outputs = ConnectQuoteAction.run(new List<ConnectQuoteAction.Input>{ input });
System.debug('Quote: ' + outputs[0].quoteId + ' created: ' + outputs[0].created + ' message: ' + outputs[0].message);
System.debug([SELECT Status__c, Attempts__c, Tracker_Id__c, Error_Message__c FROM Quote_Request__c WHERE Request_Key__c = :outputs[0].correlationId]);
