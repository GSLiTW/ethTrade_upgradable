Upgradeable USDC Exchange Contract

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract USDCExchange is Initializable, UUPSUpgradeable, OwnableUpgradeable, ChainlinkClient {
    IERC20 public usdcToken;
    uint256 public ethPrice;
    address public oracle;
    bytes32 public jobId;
    uint256 public fee;

    event Deposit(address indexed user, uint256 amount);
    event Swap(address indexed user, uint256 ethAmount, uint256 usdcAmount);

    function initialize(address _usdcToken, address _oracle, bytes32 _jobId, uint256 _fee) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        usdcToken = IERC20(_usdcToken);
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
        setChainlinkToken(0x514910771AF9Ca656af840dff83E8264EcF986CA);
    }

    function deposit() external payable {
        require(msg.value > 0, "Must deposit some ETH");
        emit Deposit(msg.sender, msg.value);
    }

    function swap() external {
        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "No ETH to swap");
        
        updateEthPrice();
        
        uint256 usdcAmount = (ethBalance * ethPrice) / 1e18;
        require(usdcToken.balanceOf(address(this)) >= usdcAmount, "Insufficient USDC balance");
        
        require(usdcToken.transfer(msg.sender, usdcAmount), "USDC transfer failed");
        
        emit Swap(msg.sender, ethBalance, usdcAmount);
    }

    function updateEthPrice() public {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        sendChainlinkRequest(req, fee);
    }

    function fulfill(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId) {
        ethPrice = _price;
    }

    function withdrawUSDC(uint256 amount) external onlyOwner {
        require(usdcToken.transfer(owner(), amount), "USDC transfer failed");
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}