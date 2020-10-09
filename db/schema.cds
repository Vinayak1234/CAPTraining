namespace sap.ibso.captraining;


entity Books {
  key ID : Integer;
  title  : String(111);
  descr  : String(1111);
  author_ID : Integer;
  stock  : Integer;
  price  : Decimal(9,2);
  author : Association to Authors  on author.ID = author_ID;
}

entity Authors {
  key ID : Integer;
  name   : String(50);
  dateOfBirth  : Date;  
  placeOfBirth : String;  
  books  : Association to many Books on books.author_ID = ID;
}

// @cds.persistence.exists
// entity TF_GET_BOOKDETAILS (AUTHOR_NAME:String(50)){
//     key BOOK_ID : Integer;
//     TITLE :        String(111);
//     DESCR :        String(1111);
//     STOCK :        Integer;
//     PRICE :        Decimal(9,2);
//     AUTHOR_NAME:   String(50);
// }