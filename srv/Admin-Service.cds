using { sap.ibso.captraining as my } from '../db/schema';
using { TF_GET_BOOKDETAILS,BooksInfo } from '../db/cvschema';

service AdminService {

    // Parameterized table function
    @readonly
    entity BookDetails(AUTHOR_NAME:String) as SELECT FROM TF_GET_BOOKDETAILS(AUTHOR_NAME: :AUTHOR_NAME){*};

    // Parameterized view
    entity BooksInfoView (BOOK_ID : Integer) as select from BooksInfo(BOOK_ID: :BOOK_ID) {*};

    entity Books as SELECT FROM my.Books{*};

    entity Authors as SELECT FROM my.Authors{*};
}