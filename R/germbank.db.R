setwd("C:\\Users\\user\\Desktop\\Project")
install.packages(RSQLite)
install.packages(DBI)


#============================================================
# Create BioVault.db with 3 Tables * Germplasm Management 
#============================================================

library(RSQLite)
library(DBI)

# Create a connection to the SQLite database
con <- dbConnect(RSQLite::SQLite(), "BioVault.db")

#===========================================================
# Create the Passport_data table
#===========================================================

dbExecute(con, "CREATE TABLE IF NOT EXISTS Passport_data (
  accession_id VARCHAR(50) PRIMARY KEY,
  genus VARCHAR(100),
  species VARCHAR(100),
  subtaxa VARCHAR(100),
  accession_name VARCHAR(255),
  biological_status VARCHAR(100),
  country_of_origin VARCHAR(100),
  location_of_collection VARCHAR(255),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  collecting_date DATE,
  collector_name VARCHAR(150),
  acquisition_date DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
   )
")

#===========================================================
#Inventory table
#===========================================================
dbExecute(con, "CREATE TABLE IF NOT EXISTS Inventory_data (
  inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
  accession_id VARCHAR(50),
  loc_id VARCHAR(50),
  harvest_date DATE,
  storage_date DATE,
  acquisition_date DATE,
  quantity_initial REAL DEFAULT 0,
  quantity_current REAL DEFAULT 0,
  '100 seed weight' REAL DEFAULT 0,     -- weight of 100 seeds in grams
  unit VARCHAR(50) DEFAULT 'g',         -- e.g., grams, kilograms, etc.
  germination_rate REAL DEFAULT 0,
  viability REAL DEFAULT 0,
  viability_loss_rate REAL DEFAULT 0,
  viability_test_date DATE,
  moisture_content REAL DEFAULT 0,      -- % (0-100)
  packaging_type VARCHAR(255),
  storage_location VARCHAR(255),
  storage_conditions VARCHAR(255),
  status VARCHAR(50) DEFAULT 'available', -- e.g., available, reserved, used, etc.
  purpose VARCHAR(255), -- e.g., research, breeding, distribution, etc.
  source VARCHAR(255), -- e.g., collected, donated, purchased, etc.
  regeneration_date DATE,
  remarks TEXT, -- additional notes or comments
  last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (accession_id) REFERENCES Passport_data(accession_id)
   )
")

#===========================================================
#Transactional Log Table
#===========================================================
dbExecute(con, "CREATE TABLE IF NOT EXISTS Transaction_log (
  transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
  accession_id VARCHAR(50), -- foreign key to Passport_data
  inventory_id INTEGER, --foreign key to Inventory_data
  transaction_type VARCHAR(50) NOT NULL, -- e.g., 'addition', 'removal', 'regeneration', 'viability_test', etc.
  transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  quantity REAL DEFAULT 0, -- quantity involved in the transaction
  unit VARCHAR(50) DEFAULT 'g', -- e.g., grams, kilograms, etc
  recipient_name VARCHAR(255), -- name of the person or organization receiving the seeds (for removals)
  recipient_information VARCHAR(255), -- contact information for the recipient
  purpose VARCHAR(255), -- reason for the transaction (e.g., research, breeding,)
  requested_by VARCHAR(255), -- name of the person requesting the transaction
  approved_by VARCHAR(255), -- name of the person approving the transaction
  remarks TEXT, -- additional notes or comments about the transaction
  last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(255), -- name of the person making the update
  
  FOREIGN KEY (accession_id) REFERENCES Passport_data(accession_id),
  FOREIGN KEY (inventory_id) REFERENCES Inventory_data(inventory_id)
  )
")



#===================================
#Insert Sample Data(FOR TESTING)
#===================================

#sample passport data
dbExecute(con, "
  INSERT OR IGNORE INTO Passport_data 
    (accession_id, genus, species, subtaxa, accession_name, biological_status, 
     country_of_origin, location_of_collection, latitude, longitude, 
     collecting_date, collector_name, acquisition_date)
  VALUES 
    ('GH-001', 'Manihot', 'esculenta', 'var. bitter', 'Local Red Cassava', 'Landrace', 
     'Ghana', 'Kumasi, Ashanti Region', 6.6667, -1.6167, '2023-05-15', 'Dr. Kwame Osei', '2024-01-10'),
    ('GH-002', 'Zea', 'mays', 'ssp. mays', 'Obatanpa Maize', 'Improved Variety', 
     'Ghana', 'Ejura, Ashanti', 7.3833, -1.3667, '2022-08-20', 'CSIR-CRI Team', '2023-03-05')
")
          dbExecute(con, "
  INSERT OR IGNORE INTO Passport_data 
    (accession_id, genus, species, subtaxa, accession_name, biological_status, 
     country_of_origin, location_of_collection, latitude, longitude, 
     collecting_date, collector_name, acquisition_date)
  VALUES 
    ('GH-001', 'Manihot', 'esculenta', 'var. bitter', 'Local Red Cassava', 'Landrace', 
     'Ghana', 'Kumasi, Ashanti Region', 6.6667, -1.6167, '2023-05-15', 'Dr. Kwame Osei', '2024-01-10'),
    ('GH-002', 'Zea', 'mays', 'ssp. mays', 'Obatanpa Maize', 'Improved Variety', 
     'Ghana', 'Ejura, Ashanti', 7.3833, -1.3667, '2022-08-20', 'CSIR-CRI Team', '2023-03-05')
