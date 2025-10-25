// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MonadPay is ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct Split {
        address recipient;
        uint256 basisPoints; // 10000 = 100%
    }

    struct Invoice {
        bytes32 id;
        address creator;
        uint256 amount;
        address token; // USDC address
        string description;
        Split[] splits;
        bool paid;
        uint256 createdAt;
        uint256 paidAt;
        address paidBy;
    }

    mapping(bytes32 => Invoice) public invoices;
    mapping(bytes32 => bool) public invoiceExists;

    event InvoiceCreated(
        bytes32 indexed invoiceId,
        address indexed creator,
        uint256 amount,
        address token,
        uint256 splitCount
    );

    event InvoicePaid(
        bytes32 indexed invoiceId,
        address indexed payer,
        uint256 amount,
        address token
    );

    event SplitDistributed(
        bytes32 indexed invoiceId,
        address indexed recipient,
        uint256 amount
    );

    function createInvoice(
        uint256 _amount,
        address _token,
        string memory _description,
        Split[] memory _splits
    ) external returns (bytes32) {
        require(_amount > 0, "Amount must be > 0");
        require(_token != address(0), "Invalid token");
        require(_splits.length > 0, "Must have at least 1 split");

        // Validate splits add up to 10000 (100%)
        uint256 totalBasisPoints = 0;
        for (uint256 i = 0; i < _splits.length; i++) {
            require(_splits[i].recipient != address(0), "Invalid recipient");
            require(_splits[i].basisPoints > 0, "Split must be > 0");
            totalBasisPoints += _splits[i].basisPoints;
        }
        require(totalBasisPoints == 10000, "Splits must equal 100%");

        bytes32 invoiceId = keccak256(
            abi.encodePacked(
                msg.sender,
                _amount,
                _token,
                _description,
                block.timestamp,
                block.number
            )
        );

        require(!invoiceExists[invoiceId], "Invoice already exists");

        Invoice storage invoice = invoices[invoiceId];
        invoice.id = invoiceId;
        invoice.creator = msg.sender;
        invoice.amount = _amount;
        invoice.token = _token;
        invoice.description = _description;
        invoice.paid = false;
        invoice.createdAt = block.timestamp;

        for (uint256 i = 0; i < _splits.length; i++) {
            invoice.splits.push(_splits[i]);
        }

        invoiceExists[invoiceId] = true;

        emit InvoiceCreated(
            invoiceId,
            msg.sender,
            _amount,
            _token,
            _splits.length
        );

        return invoiceId;
    }

    function payInvoice(bytes32 _invoiceId) external nonReentrant {
        require(invoiceExists[_invoiceId], "Invoice does not exist");
        Invoice storage invoice = invoices[_invoiceId];
        require(!invoice.paid, "Invoice already paid");

        IERC20 token = IERC20(invoice.token);

        // Transfer total amount from payer
        token.safeTransferFrom(msg.sender, address(this), invoice.amount);

        // Distribute to all recipients based on splits
        for (uint256 i = 0; i < invoice.splits.length; i++) {
            uint256 splitAmount = (invoice.amount * invoice.splits[i].basisPoints) / 10000;
            token.safeTransfer(invoice.splits[i].recipient, splitAmount);

            emit SplitDistributed(
                _invoiceId,
                invoice.splits[i].recipient,
                splitAmount
            );
        }

        invoice.paid = true;
        invoice.paidAt = block.timestamp;
        invoice.paidBy = msg.sender;

        emit InvoicePaid(_invoiceId, msg.sender, invoice.amount, invoice.token);
    }

    function getInvoice(bytes32 _invoiceId)
        external
        view
        returns (
            bytes32 id,
            address creator,
            uint256 amount,
            address token,
            string memory description,
            bool paid,
            uint256 createdAt,
            uint256 paidAt,
            address paidBy
        )
    {
        Invoice storage invoice = invoices[_invoiceId];
        return (
            invoice.id,
            invoice.creator,
            invoice.amount,
            invoice.token,
            invoice.description,
            invoice.paid,
            invoice.createdAt,
            invoice.paidAt,
            invoice.paidBy
        );
    }

    function getInvoiceSplits(bytes32 _invoiceId)
        external
        view
        returns (Split[] memory)
    {
        return invoices[_invoiceId].splits;
    }
}

