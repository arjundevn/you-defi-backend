//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { DAI } from "./Dai.sol";

contract Loan {
    struct Terms {
        uint256 loanDaiAmount;
        uint feeDaiAmount;
        uint ethCollateralAmount;
        uint repayByTimestamp;
    }

    Terms public terms;

    enum LoanState {Created, Funded, Taken}
    LoanState public state;

    address payable public lender;
    address payable public borrower;
    IERC20 token;

    constructor(Terms memory _terms){
        terms = _terms;
        // daiAddress = _daiAddress;
        lender = payable(msg.sender);
        state = LoanState.Created;
        token = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138); 
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
}