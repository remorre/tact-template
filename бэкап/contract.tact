import "@stdlib/deploy";

contract TactApsl with Deployable {
    PaymentNum: Int as uint8;
    EndNum: Int as uint8;
    customerAmount: Int as coins;  
    dealerGuarantee: Int as coins; 
    owner: Address = address("UQCvpZAXC3sFrBY9yJ3rNXtEBvgF9mgwZLtlHIPwr4g_4-OR");
    dealer: Address = address("${dealer}");
    customer: Address = address("${customer}");

    init() {
        self.PaymentNum = 0;
        self.EndNum = 0;
        self.customerAmount = 0;  
        self.dealerGuarantee = 0; 
    }

    receive("Payment") {
        if (sender() == self.dealer) {
            self.PaymentNum = self.PaymentNum + 1;
            self.dealerGuarantee = myBalance() - self.customerAmount;
        } else if (sender() == self.customer) {
            self.PaymentNum = self.PaymentNum + 1;
            self.customerAmount = myBalance() - self.dealerGuarantee;
        } else {dump("Access denied")}}

    receive("End") {
        if (sender() == self.dealer) {
            self.EndNum = self.EndNum + 1;
        } else if (sender() == self.customer) {
            self.EndNum = self.EndNum + 1;
        } else {dump("Access denied")}

        if (self.EndNum == 2) {
            send(SendParameters{
            to: self.dealer,
            bounce: true,
            value: self.dealerGuarantee + (self.customerAmount - (self.customerAmount / 20)) - context().value,
            mode: SendRemainingValue + SendIgnoreErrors
            });

            send(SendParameters{
            to: self.owner,
            bounce: true,
            value: 0,
            mode: SendRemainingBalance + SendIgnoreErrors
            })
        }
    }
}
