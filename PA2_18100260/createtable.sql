CREATE TABLE Author (
    author_id   number,
    Name        varchar2(30),
    PRIMARY KEY (author_id)
);

CREATE TABLE Books (
    book_id     number,
    book_title  varchar2(50),
    author_id   number,
    year_of_publication number,
    edition     number,
    status      varchar2(20),
    PRIMARY KEY (book_id),
    FOREIGN KEY (author_id) REFERENCES Author,
    CONSTRAINT book_status CHECK (status='issued' OR status='not_issued')
);

CREATE TABLE Borrower (
    borrower_id number,
    name        varchar2(30),
    status      varchar2(20),
    PRIMARY KEY (borrower_id),
    CONSTRAINT borrower_status CHECK (status='student' OR status='faculty')
);

CREATE TABLE Issue (
    book_id     number,
    borrower_id number,
    issue_date  date,
    return_date date,
    PRIMARY KEY (book_id, borrower_id, issue_date),
    FOREIGN KEY (book_id) REFERENCES Books,
    FOREIGN KEY (borrower_id) REFERENCES Borrower
);

CREATE TABLE Pending_request (
    book_id     number,
    requester_id number,
    request_date date,
    issue_date  date,
    PRIMARY KEY (book_id, requester_id, request_date),
    FOREIGN KEY (book_id) REFERENCES Books,
    FOREIGN KEY (requester_id) REFERENCES Borrower(borrower_id)
);