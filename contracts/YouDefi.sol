//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YouDefi {
    struct Terms {
        address tokenAddress;
        address lender;
        address borrower;
        uint loanAmount;
        uint feeAmount;
        uint ethCollateralAmount;
        uint repayByTimestamp;
        string status;
    }

    uint public numOfLoans = 0;       // Total number of loans in the smart contract
    mapping (uint => Terms) public Loans; // Loan ID

    function getTimestamp() public view returns(uint){
        return block.timestamp;
    }

    function initiateLoan(address _tokenAddress, uint _loanAmt, uint _fee, uint _collateral, uint _timestamp) public {
        numOfLoans++;
        Loans[numOfLoans].lender = payable(msg.sender);
        Loans[numOfLoans].loanAmount = _loanAmt;
        Loans[numOfLoans].feeAmount = _fee;
        Loans[numOfLoans].ethCollateralAmount = _collateral;
        Loans[numOfLoans].repayByTimestamp = _timestamp;
        Loans[numOfLoans].tokenAddress =  _tokenAddress;
        Loans[numOfLoans].status = "Loan Created";
        IERC20(_tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _loanAmt
        );
    }

    function takeLoan(uint _LoanID) public payable {
        require(msg.value == Loans[_LoanID].ethCollateralAmount, "Invalid Collateral Amount");
        Loans[_LoanID].borrower = msg.sender;
        IERC20(Loans[_LoanID].tokenAddress).transfer(Loans[_LoanID].borrower, Loans[_LoanID].loanAmount);
        Loans[_LoanID].status = "Loan Borrowed";
    }

    function repay(uint _LoanID) public {
        require(msg.sender == Loans[_LoanID].borrower, "Only the borrower can repay the loan");
        IERC20(Loans[_LoanID].tokenAddress).transferFrom(Loans[_LoanID].borrower, Loans[_LoanID].lender, Loans[_LoanID].loanAmount + Loans[_LoanID].feeAmount);
        payable(msg.sender).transfer(Loans[_LoanID].ethCollateralAmount);
        Loans[_LoanID].status = "Loan Repaid";
    }

    function liquidate(uint _LoanID) public {
        require(msg.sender == Loans[_LoanID].lender, "Only the lender can liquidate the loan");
        require(block.timestamp >= Loans[_LoanID].repayByTimestamp, "Can not liquidate before the loan is due");
        payable(msg.sender).transfer(Loans[_LoanID].ethCollateralAmount);
        Loans[_LoanID].status = "Loan Defaulted";
    }
    
}

contract TokenCreator is ERC20 {
    constructor(uint initialSupply, string memory name, string memory abbr) ERC20(name, abbr) {
        _mint(msg.sender, initialSupply *10**18);
    }
}