using { sap.ibso.captraining as my } from '../db/schema';

service AdminService {

    entity Books as projection on my.Books;

    entity Authors as projection on my.Authors;

    //Postfix Projections
    entity AuthorsPostFix as SELECT from my.Authors {key ID, name, placeOfBirth, dateOfBirth};    
    
    //Smart * Selector
    entity BooksSmartSelector as SELECT from my.Books { *, author.name as author };

    // Path Expressions in from clauses
    entity BooksPathExpfrom as SELECT from my.Authors[name='Agatha Christie'].books { key ID, title , descr};

    // Path Expressions in select clauses
    entity BooksPathExpselect  as SELECT *, author.name from my.Books;

    // Path Expressions in Where clauses
    //     SELECT * from Books WHERE EXISTS (
    //    SELECT 1 from Authors WHERE Authors.ID = Books.author_ID
    //     AND Authors.name='Agatha Christie'
    //    );
    entity BooksPathExpwhere  as SELECT from my.Books where author.name='Agatha Christie';

    // Books and Authors left join
    entity BooksAuthorsJoin as SELECT from my.Books as books
    LEFT JOIN my.Authors author ON books.author_ID = author.ID {
        key books.ID, 
        books.title, 
        author.name
    };

    // With Infix Filters
    // SELECT books.title from Authors
    // LEFT JOIN Books books ON ( books.author_ID = Authors.ID )
    // AND ( books.descr = 'Mystery' )  
    // WHERE Authors.name='Agatha Christie';
    entity BooksInfixFilter as SELECT key ID, books[descr='Mystery'].title from my.Authors
                                WHERE name='Agatha Christie';

    // CDL-style Casts
    entity BooksCDLStyle as SELECT from my.Books { ID, price + 1 as additionalPrice : Decimal };

    //Excluding Clause
    entity BooksExcludeClause as SELECT from my.Books excluding { stock,price };


}
