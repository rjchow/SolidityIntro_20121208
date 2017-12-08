pragma solidity ^0.4.19;

contract Conference { 
    address public organizer;
    mapping (address => uint) public registrantsPaid;
    uint public numRegistrants;
    uint public quota;
    
    // so you can log these events
    event Deposit(address _from, uint _amount); 
    event Refund(address _to, uint _amount);
  
    modifier onlyOrganizer() {
        require(msg.sender == organizer);
        _;
    }

    function Conference()
        public
    { // Constructor
        organizer = msg.sender;
        quota = 500;
        numRegistrants = 0;
    }
  
    function buyTicket()
        payable 
        public 
        returns (bool success) 
    {
        if (numRegistrants >= quota) {
            revert(); 
        } // see footnote
        registrantsPaid[msg.sender] = msg.value;
        numRegistrants++;
        Deposit(msg.sender, msg.value);
        return true;
    }
  
    function changeQuota(uint newquota) 
        public 
        onlyOrganizer 
    {
        quota = newquota;
    }
  
    function refundTicket(address recipient, uint amount)
        public 
        onlyOrganizer 
    {
        if (registrantsPaid[recipient] == amount) {
            if (this.balance >= amount) {
                registrantsPaid[recipient] = 0;
                numRegistrants -= 1;
                Refund(recipient, amount);
                recipient.transfer(amount);
            }
        }
    }
  
    function destroy()
      onlyOrganizer  
      public 
    { // so funds not locked in contract forever
        selfdestruct(organizer); // send funds to organizer
    }
}

