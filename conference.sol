pragma solidity ^0.4.19;

contract Conference { 
    
    address public organizer;
    
    mapping (address => uint) public registrantsPaid; // Like a hash table
    
    uint public numRegistrants;  // Unsigned Integer
    uint public quota;
    
    // Event logs are the cheapest way of returning data from transactions
    event Deposit(address _from, uint _amount); 
    event Refund(address _to, uint _amount);
  
  
    // Modifiers can be thought of as a way to wrap a function with another function
    modifier onlyOrganizer() {
        require(msg.sender == organizer);
        _; // Executes wrapped function
    }

    // Constructors are run only once upon contract initialisation
    // Further calls to it will fail
    function Conference()
        public
    {
        organizer = msg.sender;
        quota = 500;
        numRegistrants = 0;
    }
  
    function buyTicket()
        payable   // Only functions marked payable can receive ether value
        public 
        returns (bool success)  // Return values have to be clearly defined
    {
        if (numRegistrants >= quota) {
            revert(); 
        }
        registrantsPaid[msg.sender] = msg.value; // Setting a value in the mapping
        numRegistrants += 1;
        Deposit(msg.sender, msg.value);
        return true;
    }
  
    function changeQuota(uint newquota) // uint parameter
        public 
        onlyOrganizer  // modifier
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

