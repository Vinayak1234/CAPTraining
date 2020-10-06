using { sap.ibso.captraining as my } from '../db/schema';

service AdminService {

    entity Authors as projection on my.Authors;
}