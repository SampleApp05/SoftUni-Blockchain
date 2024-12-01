// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;

enum BookStatus {
    active,
    outdated,
    archived
}

struct Book {
    string title; // assuming this is unique
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

contract Library {
    Book[] private books;
    mapping(string => BookIndex) private bookIndexes;
    mapping(string => address[]) private bookLibrarians;

    // MARK: - Private
    function _idFor(Book calldata book) private pure returns(string memory) {
        return string(abi.encodePacked(book.title, book.author));
    }

    function _idFor(string calldata title, string calldata author) private pure returns(string memory) {
        return string(abi.encodePacked(title, author));
    }

    function addAuthorizedLibrarianFor(string calldata title, string calldata author, address librarianAddress) public {
        string memory id = _idFor(title, author);

        BookIndex memory bookIndex = bookIndexes[id];
        if (bookIndex.exists == false) { revert BookNotFound(); }

        if (msg.sender != books[bookIndex.index].primaryLibrarian) { revert UnauthorizedAccess(); }

        bookLibrarians[id].push(librarianAddress);
    }

    function updateBookStatus(string calldata title, string calldata author, BookStatus status) public {
        string memory id = _idFor(title, author);

        BookIndex memory bookIndex = bookIndexes[id];
        if (bookIndex.exists == false) { revert BookNotFound(); }

        Book storage book = books[bookIndex.index];

        if (msg.sender == book.primaryLibrarian) {
            book.status = status;
            return;
        }

        address[] memory authorizedLibrarians = bookLibrarians[id];

        for (uint256 i = 0; i < authorizedLibrarians.length; i++)  {
            if (msg.sender == authorizedLibrarians[i]) { 
                book.status = status;
                break;
            }
        }
    }
}