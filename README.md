## CAP Services using java

#### Download the CAPTraining java project from git

<code>
  git clone https://github.com/Vinayak1234/CAPTraining.git 
  
  cd projects/CAPTraining
</code>

Or you can follow the below steps to create and run/deploy this hands-on exercise.

#### 1.  Create CAPTraining java project

1. To create CAPTraining project navigate to projects folder and execute the below maven command.

<code>
 mvn -B archetype:generate -DarchetypeArtifactId=cds-services-archetype -DarchetypeGroupId=com.sap.cds \
-DarchetypeVersion=1.3.0 -DcdsVersion=3.31.2 \
-DgroupId=com.sap.cap -DartifactId=CAPTraining -Dpackage=com.sap.cap.CAPTraining  

</code>

&nbsp;

This will initialize the application using the maven archetype `cds-services-archetype` and create your project as follows:

* The project is named `CAPTraining`.
* The `db` folder stores database-related artifacts.
* The `srv` folder stores your Java application.

&nbsp;

2. Create the schema.cds under CAPTraining>db  for creating entities.

 ```
  
  namespace sap.ibso.captraining;


  entity Books {
    key ID : Integer;
    title  : String(111);
    descr  : String(1111);
    author : Association to Authors;
    stock  : Integer;
    price  : Decimal(9,2);
  }

  entity Authors {
    key ID : Integer;
    name   : String(111);
    dateOfBirth  : Date;  
    placeOfBirth : String;  
    books  : Association to many Books on books.author = $self;
  }

```

3. Create Admin-Service.cds under CAPTraining>srv for creating admin services.

```
using { sap.ibso.captraining as my } from '../db/schema';

service AdminService {

    entity Books as projection on my.Books;

    entity Authors as projection on my.Authors;
}
```

4. Remove existing dependencies and add below mentioned dependencies to CAPTraining>srv>pom.xml.

```

	<dependencies>
	    <dependency>
		<groupId>com.sap.cds</groupId>
		<artifactId>cds-starter-spring-boot-odata</artifactId>
	    </dependency>

	    <dependency>
	       <groupId>com.sap.cds</groupId>
	       <artifactId>cds-feature-hana</artifactId>
	    </dependency>

	     <dependency>
		<groupId>org.xerial</groupId>
		<artifactId>sqlite-jdbc</artifactId>
	      </dependency>

	      <dependency>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-test</artifactId>
		<scope>test</scope>
	       </dependency>

	       <dependency>
		  <groupId>com.sap.cds</groupId>
		  <artifactId>cds-feature-cloudfoundry</artifactId>
		</dependency>
        
	</dependencies>
  
```


#### 2. Seup SQLITE for local development:

1. Install the sqlite

    `npm install --save-dev sqlite3`

2. Build cds objects

    `cds build/all`

3. Deploy the DB objects to local sqlite

    `cds deploy --to sqlite`

4. Start your application by running mvn spring-boot:run in the terminal and open it in a new tab.

    `mvn spring-boot:run`
    

#### 3. Setup hana and deploy the project to cf:

1. Execute the below command to add configuration for SAP HANA deployment

    `cds add hana`

2. Execute the below command to add an mta.yaml file out of CDS models and config. The file will be created under project root folder (CAPTraining/mta.yaml)

    `cds add mta`
    
3. Remove the production params from mta.yaml (CAPTraining/mta.yaml) file build-parameters since we will be deploying the mtar file to our dev or test instance.

    From:
    ```
    build-parameters:
      before-all:
       - builder: custom
         commands:
          - npm install --production
          - npx -p @sap/cds-dk cds build --production
    ```

    Change to:

    ```
    build-parameters:
      before-all:
       - builder: custom
         commands:
          - npm install
          - npx cds build
    ```

3. Build the project from terminal, that will generate mtar (CAPTraining_1.0.0.mtar) file under CAPTraining/mta_archives/CAPTraining_1.0.0.mtar

    `mbt build`

4. Deploy the project to CF:

    `cf deploy ./mta_archives/CAPTraining_1.0.0.mtar`
    
    On successful deploy the terminal console looks like this and copy the service url from console as highlighted below.
      
    	
	Staging application "CAPTraining-srv"...
	Application "CAPTraining-srv" staged
	Starting application "CAPTraining-srv"...
	Application "CAPTraining-srv" started and available at **2d77a5b8trial-dev-captraining-srv.cfapps.eu10.hana.ondemand.com**
	Skipping deletion of services, because the command line option "--delete-services" is not specified.
	Process finished.
	Use "cf dmol -i 0b8c38fb-0865-11eb-8372-eeee0a9e2566" to download the logs of the process.
 
    Copy the highlighted url to browser.
    
    https://2d77a5b8trial-dev-captraining-srv.cfapps.eu10.hana.ondemand.com/
    
    That will look like this with the list of services. Click on any service to fetch the details.
    
   ### Welcome to cds-services
   These are the paths currently served …

   ##### /odata/v4/AdminService / $metadata
     * Authors
     * Books

