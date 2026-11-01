// Applies Velora's deal metrics rule to the Swift Couriers pilot quote and prints the result.
// Deploy DealMetrics first. Run: sf apex run --file scripts/anonymous/metrics-pilot.apex --target-org demo_cpq
// Expected: mrr=29.00 arr=348.00 tcv=48348.00
// @author Jitendra Zaa
Quote pilot = [SELECT Id FROM Quote WHERE Name = 'Swift Couriers Pilot Quote' LIMIT 1];
DealMetrics.Result result = DealMetrics.forQuote(pilot.Id);
System.debug('mrr=' + result.mrr + ' arr=' + result.arr + ' tcv=' + result.tcv);
