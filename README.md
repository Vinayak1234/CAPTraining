## CAPTraining

<code>
  git clone https://github.com/Vinayak1234/CAPTraining.git 
  
  cd projects/CAPTraining
</code>

#### Create CAPTraining java project
<code>
 mvn -B archetype:generate -DarchetypeArtifactId=cds-services-archetype -DarchetypeGroupId=com.sap.cds \
-DarchetypeVersion=1.3.0 -DcdsVersion=3.31.2 \
-DgroupId=com.sap.cap -DartifactId=CAPTraining -Dpackage=com.sap.cap.CAPTraining  

</code>

#### Seup SQLITE for local development:

<code>
  npm install --save-dev sqlite3
</code>

Deploy the DB objects to local sqlite

<code>
  cds deploy --to sqlite
</code>


Start your application by running mvn spring-boot:run in the terminal and open it in a new tab.

<code>
   mvn spring-boot:run

 </code>

