/**
 * What the quote placer needs to create one Velora Connect quote with one line.
 *
 * @author Jitendra Zaa
 */
public with sharing class QuoteInput {
    public Id opportunityId;
    public Id pricebook2Id;
    public Id product2Id;
    public Id pricebookEntryId;
    public Decimal unitPrice;
    public Date startDate;
    public Date endDate;
    public String quoteName;
}
