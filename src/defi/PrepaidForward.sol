// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../interfaces/IERC20.sol";

// Forward contract
// Agreement between two parties which forces the first party to buy from
// the second at a pre-determined price and date

// Prepaid forward contract - strike price is paid at the initiation

contract PrepaidForward {
    // long position - buyer
    // short position - seller
    // strike price - pre-determined price
    // maturity date - pre-determined date to execute the agreement

    // K - strike price
    // T - maturity date
    // S(t) - underlying asset price at time t

    // Payoff
    // Long  = S(T) - K
    // Short = K - S(T)

    // Theorem
    // Assume
    // - no arbitrage opportunity
    // - underlying asset doesn't pay dividends
    // - 0 cost to store underlying asset
    // Then strike price for forward contract entered at t0
    //    K = S(t0) / Z(t0, T)
    // where Z(t, T) = price of zero-coupon bond at time t with maturity T
    //       Z(T, T) = 1
    // For prepaid forward contract
    //    K = S(t0) / Z(t0, T) * Z(t0, T) = S(t0)

    event ForwardCreated(
        uint256 id, address indexed seller, uint256 quantity, uint256 strikePrice, uint256 maturityDate
    );
    event ForwardCanceled(uint256 id);
    event ForwardEntered(uint256 id, address indexed buyer);
    event ForwardSettled(uint256 id);

    // For example, WETH
    IERC20 public immutable underlyingAsset;
    // For example, USDC
    IERC20 public immutable payToken;

    enum Status {
        Open,
        Entered
    }

    struct Forward {
        address buyer;
        address seller;
        uint256 quantity;
        uint256 strikePrice;
        uint256 maturityDate;
        Status status;
    }

    uint256 private forwardId;
    mapping(uint256 => Forward) public forwards;

    constructor(IERC20 _underlying, IERC20 _pay) {
        underlyingAsset = _underlying;
        payToken = _pay;
    }

    function write(uint256 _quantity, uint256 _strikePrice, uint256 _maturityDate) external returns (uint256) {
        require(_maturityDate > block.timestamp, "maturity must be > now");

        uint256 id = forwardId + 1;
        forwardId = id;

        forwards[id] = Forward({
            buyer: address(0),
            seller: msg.sender,
            quantity: _quantity,
            strikePrice: _strikePrice,
            maturityDate: _maturityDate,
            status: Status.Open
        });

        emit ForwardCreated(id, msg.sender, _quantity, _strikePrice, _maturityDate);

        return id;
    }

    function cancel(uint256 _id) external {
        Forward storage forward = forwards[_id];

        // Also checks that forward exists
        require(msg.sender == forward.seller, "not authorized");
        require(forward.status == Status.Open, "not open");

        delete forwards[_id];

        emit ForwardCanceled(_id);
    }

    function enter(uint256 _id) external {
        Forward storage forward = forwards[_id];

        require(block.timestamp < forward.maturityDate, "expired");
        require(forward.status == Status.Open, "forward already entered");

        forward.status = Status.Entered;
        forward.buyer = msg.sender;

        underlyingAsset.transferFrom(forward.seller, address(this), forward.quantity);
        payToken.transferFrom(msg.sender, address(this), forward.strikePrice);

        emit ForwardEntered(_id, msg.sender);
    }

    function settle(uint256 _id) external {
        Forward memory forward = forwards[_id];

        require(msg.sender == forward.seller || msg.sender == forward.buyer, "not authorized");
        // Check forward is entered and not deleted
        require(forward.status == Status.Entered, "forward not entered");
        require(forward.maturityDate <= block.timestamp, "not expired");

        underlyingAsset.transfer(forward.buyer, forward.quantity);
        payToken.transfer(forward.seller, forward.strikePrice);

        delete forwards[_id];

        emit ForwardSettled(_id);
    }
}