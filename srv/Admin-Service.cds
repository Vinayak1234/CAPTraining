using { sap.ibso.captraining as my } from '../db/schema';
using { TF_GET_BOOKDETAILS } from '../db/cvschema';

service AdminService {

    @readonly
    entity BookDetails(AUTHOR_NAME:String) as SELECT FROM TF_GET_BOOKDETAILS(AUTHOR_NAME: :AUTHOR_NAME){*};

    entity Books as SELECT FROM my.Books{*};

    entity Authors as SELECT FROM my.Authors{*};
}