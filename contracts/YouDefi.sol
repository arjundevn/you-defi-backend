//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { DAI } from "./Dai.sol";

contract YouDefi {
    struct Terms {
        address tokenAddress;
        address lender;
        address borrower;
        uint256 loanDaiAmount;
        uint feeDaiAmount;
        uint ethCollateralAmount;
        uint repayByTimestamp;
        string status;
    }

    Terms public terms;

    uint public numOfLoans = 0;       // Total number of loans in the smart contract
    mapping (uint => Terms) public Loans; // Loan ID

    enum LoanState {Created, Funded, Taken}
    LoanState public state;

    address payable public lender;
    address payable public borrower;
    IERC20 token;

    constructor(){
        // terms = _terms;
        // daiAddress = _daiAddress;
        // lender = payable(msg.sender);
        // state = LoanState.Created;
        // token = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138); 
    }

    modifier onlyInState(LoanState expectedState) {
        require(state == expectedState, "Not allowed in this state");
        _;
    }

    function fundLoan() public onlyInState(LoanState.Created) {
        state = LoanState.Funded;
        token.transferFrom(
            msg.sender,
            address(this),
            terms.loanDaiAmount
        );
    }

    function takeALoanAndAcceptLoanTerms() public payable onlyInState(LoanState.Funded){
        require(msg.value == terms.ethCollateralAmount, "Invalid Collateral Amount");
        borrower = payable(msg.sender);
        state = LoanState.Taken;
        token.transfer(borrower, terms.loanDaiAmount);
    }

    function repay() public onlyInState(LoanState.Taken) {
        require(msg.sender == borrower, "Only the borrower can repay the loan");
        token.transferFrom(borrower, lender, terms.loanDaiAmount + terms.feeDaiAmount);
        selfdestruct(borrower);
    }

    function liquidate() public onlyInState(LoanState.Taken) {
        require(msg.sender == lender, "Only the lender can liquidate the loan");
        require(block.timestamp >= terms.repayByTimestamp, "Can not liquidate before the loan is due");
        selfdestruct(lender);
    }

    function getTimestamp() public view returns(uint){
        return block.timestamp;
    }

    function NewinitiateLoan(address _tokenAddress, uint _loanAmt, uint _fee, uint _collateral, uint _timestamp) public {
        numOfLoans++;
        Loans[numOfLoans].lender = payable(msg.sender);
        Loans[numOfLoans].loanDaiAmount = _loanAmt;
        Loans[numOfLoans].feeDaiAmount = _fee;
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

    function NewtakeLoan(uint _LoanID) public payable {
        require(msg.value == Loans[_LoanID].ethCollateralAmount, "Invalid Collateral Amount");
        Loans[_LoanID].borrower = msg.sender;
        IERC20(Loans[_LoanID].tokenAddress).transfer(Loans[_LoanID].borrower, Loans[_LoanID].loanDaiAmount);
        Loans[_LoanID].status = "Loan Borrowed";
    }

    function NewRepay(uint _LoanID) public {
        require(msg.sender == Loans[_LoanID].borrower, "Only the borrower can repay the loan");
        IERC20(Loans[_LoanID].tokenAddress).transferFrom(Loans[_LoanID].borrower, Loans[_LoanID].lender, Loans[_LoanID].loanDaiAmount + Loans[_LoanID].feeDaiAmount);
        payable(msg.sender).transfer(Loans[_LoanID].ethCollateralAmount);
        Loans[_LoanID].status = "Loan Repaid";
    }

    function Newliquidate(uint _LoanID) public {
        require(msg.sender == Loans[_LoanID].lender, "Only the lender can liquidate the loan");
        require(block.timestamp >= Loans[_LoanID].repayByTimestamp, "Can not liquidate before the loan is due");
        payable(msg.sender).transfer(Loans[_LoanID].ethCollateralAmount);
        Loans[_LoanID].status = "Loan Defaulted";
    }
}