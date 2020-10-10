package com.sap.cap.CAPTraining.handler;

import java.util.List;

import com.sap.cds.Result;
import com.sap.cds.ql.Select;
import com.sap.cds.services.ErrorStatuses;
import com.sap.cds.services.ServiceException;
import com.sap.cds.services.cds.CdsService;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.Before;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import cds.gen.sap.ibso.captraining.Books;
import cds.gen.sap.ibso.captraining.Books_;


@Component
@ServiceName("AdminService")
public class BookServiceHandler  implements EventHandler{

    private static final Logger LOG = LoggerFactory.getLogger(BookServiceHandler.class.getName());

    private PersistenceService persistenceService;

     @Autowired
	public BookServiceHandler(PersistenceService persistenceService) {
		this.persistenceService = persistenceService;

	}

    @Before(event = CdsService.EVENT_CREATE, entity = "AdminService.Books")
    public void validateBooks(List<Books> books) {
        LOG.info("Inside the validateBooks");

        for (Books bk : books) {
            Result result = this.persistenceService.run(Select.from(Books_.class).where(b -> b.ID().eq(bk.getId())));
            Long count = result.rowCount();
            if(count > 0){
                  throw new ServiceException(ErrorStatuses.NOT_ACCEPTABLE, "CAPJavaTraining.BookDetailsExists");
            }            
        }   
    }
}