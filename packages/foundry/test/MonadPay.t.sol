// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MonadPay} from "../contracts/MonadPay.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Mock ERC20 for testing
contract MockERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    
    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        return true;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }
    
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
}

contract MonadPayTest is Test {
    MonadPay public monadPay;
    MockERC20 public usdc;
    
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);
    address public payer = address(0x4);
    
    function setUp() public {
        monadPay = new MonadPay();
        usdc = new MockERC20();
        
        // Mint some USDC to payer
        usdc.mint(payer, 1000e6); // 1000 USDC
    }
    
    function testCreateInvoiceSimple() public {
        MonadPay.Split[] memory splits = new MonadPay.Split[](1);
        splits[0] = MonadPay.Split({
            recipient: alice,
            basisPoints: 10000 // 100%
        });
        
        bytes32 invoiceId = monadPay.createInvoice(
            100e6, // 100 USDC
            address(usdc),
            "Test Invoice",
            splits
        );
        
        assertTrue(monadPay.invoiceExists(invoiceId));
    }
    
    function testCreateInvoiceWithSplits() public {
        MonadPay.Split[] memory splits = new MonadPay.Split[](3);
        splits[0] = MonadPay.Split({
            recipient: alice,
            basisPoints: 5000 // 50%
        });
        splits[1] = MonadPay.Split({
            recipient: bob,
            basisPoints: 3000 // 30%
        });
        splits[2] = MonadPay.Split({
            recipient: charlie,
            basisPoints: 2000 // 20%
        });
        
        bytes32 invoiceId = monadPay.createInvoice(
            100e6, // 100 USDC
            address(usdc),
            "Split Payment Test",
            splits
        );
        
        assertTrue(monadPay.invoiceExists(invoiceId));
    }
    
    function testPayInvoice() public {
        // Create invoice
        MonadPay.Split[] memory splits = new MonadPay.Split[](1);
        splits[0] = MonadPay.Split({
            recipient: alice,
            basisPoints: 10000 // 100%
        });
        
        bytes32 invoiceId = monadPay.createInvoice(
            100e6,
            address(usdc),
            "Payment Test",
            splits
        );
        
        // Payer approves and pays
        vm.startPrank(payer);
        usdc.approve(address(monadPay), 100e6);
        monadPay.payInvoice(invoiceId);
        vm.stopPrank();
        
        // Check that Alice received the payment
        assertEq(usdc.balanceOf(alice), 100e6);
        
        // Check that invoice is marked as paid
        (,,,,,bool paid,,,) = monadPay.getInvoice(invoiceId);
        assertTrue(paid);
    }
    
    function testPayInvoiceWithSplits() public {
        // Create invoice with splits
        MonadPay.Split[] memory splits = new MonadPay.Split[](3);
        splits[0] = MonadPay.Split({recipient: alice, basisPoints: 5000}); // 50%
        splits[1] = MonadPay.Split({recipient: bob, basisPoints: 3000});   // 30%
        splits[2] = MonadPay.Split({recipient: charlie, basisPoints: 2000}); // 20%
        
        bytes32 invoiceId = monadPay.createInvoice(
            100e6,
            address(usdc),
            "Split Payment",
            splits
        );
        
        // Payer approves and pays
        vm.startPrank(payer);
        usdc.approve(address(monadPay), 100e6);
        monadPay.payInvoice(invoiceId);
        vm.stopPrank();
        
        // Check that each recipient received correct amount
        assertEq(usdc.balanceOf(alice), 50e6);   // 50 USDC
        assertEq(usdc.balanceOf(bob), 30e6);     // 30 USDC
        assertEq(usdc.balanceOf(charlie), 20e6); // 20 USDC
    }
    
    function test_RevertWhen_CreateInvoiceWithInvalidSplits() public {
        // Splits that don't add up to 100%
        MonadPay.Split[] memory splits = new MonadPay.Split[](2);
        splits[0] = MonadPay.Split({recipient: alice, basisPoints: 5000});
        splits[1] = MonadPay.Split({recipient: bob, basisPoints: 4000}); // Total: 90%
        
        // This should revert
        vm.expectRevert("Splits must equal 100%");
        monadPay.createInvoice(
            100e6,
            address(usdc),
            "Invalid Splits",
            splits
        );
    }
    
    function test_RevertWhen_PayingInvoiceTwice() public {
        // Create and pay invoice
        MonadPay.Split[] memory splits = new MonadPay.Split[](1);
        splits[0] = MonadPay.Split({recipient: alice, basisPoints: 10000});
        
        bytes32 invoiceId = monadPay.createInvoice(
            100e6,
            address(usdc),
            "Double Pay Test",
            splits
        );
        
        vm.startPrank(payer);
        usdc.approve(address(monadPay), 200e6);
        monadPay.payInvoice(invoiceId);
        
        // Try to pay again - should revert
        vm.expectRevert("Invoice already paid");
        monadPay.payInvoice(invoiceId);
        vm.stopPrank();
    }
    
    function testGetInvoiceDetails() public {
        MonadPay.Split[] memory splits = new MonadPay.Split[](1);
        splits[0] = MonadPay.Split({recipient: alice, basisPoints: 10000});
        
        bytes32 invoiceId = monadPay.createInvoice(
            100e6,
            address(usdc),
            "Details Test",
            splits
        );
        
        (
            bytes32 id,
            address creator,
            uint256 amount,
            address token,
            string memory description,
            bool paid,
            uint256 createdAt,
            ,
        ) = monadPay.getInvoice(invoiceId);
        
        assertEq(id, invoiceId);
        assertEq(creator, address(this));
        assertEq(amount, 100e6);
        assertEq(token, address(usdc));
        assertEq(description, "Details Test");
        assertFalse(paid);
        assertTrue(createdAt > 0);
    }
}

