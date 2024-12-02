// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;

import "./Stringify.sol";

enum BookStatus {
    active,
    outdated,
    archived
}

struct Book {
    string title;
    string author;
    uint256 publicationDate;
    uint256 expirationDate;
    BookStatus status;
    address primaryLibrarian;
    uint256 readCount;
}

struct BookIndex {
    uint256 index;
    bool exists;
}

error BookNotFound();
error UnauthorizedAccess();

contract Library is StringHelper {
    Book[] public books;
    mapping(string => BookIndex) private bookIndexes;
    mapping(string => address[]) private bookLibrarians;

    // MARK: - Private
    function _idFor(string calldata title, string calldata author) private view returns(string memory) {
        return this.append(title, author);
    }

    // MARK: - Public
    function createBook(string calldata title, string calldata author, uint256 expiryDate) public {
        Book memory newBook;

        newBook.title = title;
        newBook.author = author;
        newBook.expirationDate = block.timestamp + expiryDate * 1 seconds;
        newBook.primaryLibrarian = msg.sender;

        books.push(newBook);

        string memory id = _idFor(title, author);
        BookIndex memory bookIndex;
        bookIndex.index = books.length - 1;
        bookIndex.exists = true;

        bookIndexes[id] = bookIndex;
    }

    function checkStatus(string calldata title, string calldata author) public returns(bool outdated) {
        string memory id = _idFor(title, author);

        BookIndex memory bookIndex = bookIndexes[id];
        if (bookIndex.exists == false) { revert BookNotFound(); }

        Book storage book = books[bookIndex.index];

        book.readCount += 1;
        return block.timestamp > book.expirationDate;
    }

    function addAuthorizedLibrarianFor(string calldata title, string calldata author, address librarianAddress) public {
        string memory id = _idFor(title, author);

        BookIndex memory bookIndex = bookIndexes[id];
        if (bookIndex.exists == false) { revert BookNotFound(); }

        if (msg.sender != books[bookIndex.index].primaryLibrarian) { revert UnauthorizedAccess(); }

        bookLibrarians[id].push(librarianAddress);
    }

    function updateExpirationDateFor(string calldata title, string calldata author, uint256 addedPeriod) public {
        string memory id = _idFor(title, author);

        BookIndex memory bookIndex = bookIndexes[id];
        if (bookIndex.exists == false) { revert BookNotFound(); }

        Book storage book = books[bookIndex.index];

        if (msg.sender == book.primaryLibrarian) {
            book.expirationDate += addedPeriod * 1 days;
            return;
        }

        address[] memory authorizedLibrarians = bookLibrarians[id];

        for (uint256 i = 0; i < authorizedLibrarians.length; i++)  {
            if (msg.sender == authorizedLibrarians[i]) { 
                book.expirationDate += addedPeriod * 1 days;
                break;
            }
        }
    }

    function updateBookStatus(string calldata title, string calldata author, BookStatus status) public {
        string memory id = _idFor(title, author);

        BookIndex memory bookIndex = bookIndexes[id];
        if (bookIndex.exists == false) { revert BookNotFound(); }

        Book storage book = books[bookIndex.index];

        if (msg.sender != book.primaryLibrarian) { revert UnauthorizedAccess(); }
        book.status = status;
    }
}