CREATE DATABASE IF NOT EXISTS ecoride CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecoride;

CREATE TABLE utilisateur(
   id_utilisateur INT AUTO_INCREMENT,
   nom VARCHAR(100) NOT NULL,
   prenom VARCHAR(100) NOT NULL,
   email VARCHAR(150) NOT NULL UNIQUE,
   password VARCHAR(255) NOT NULL, 
   telephone VARCHAR(20),
   adresse TEXT,
   date_naissance DATE NOT NULL,
   photo VARCHAR(255),
   pseudo VARCHAR(50) UNIQUE,
   credit INT DEFAULT 20,  -- 20 crédits à l'inscription
   date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY(id_utilisateur),
   INDEX idx_email (email),
   INDEX idx_pseudo (pseudo)
);


CREATE TABLE role(
   id_role INT AUTO_INCREMENT,
   nom_role ENUM('chauffeur', 'passager', 'employe', 'administrateur') NOT NULL,
   description VARCHAR(255),
   PRIMARY KEY(id_role)
);

CREATE TABLE utilisateur_role(
   id_utilisateur INT,
   id_role INT,
   PRIMARY KEY(id_utilisateur, id_role),
   FOREIGN KEY(id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE,
   FOREIGN KEY(id_role) REFERENCES role(id_role) ON DELETE CASCADE
);

CREATE TABLE marque(
   id_marque INT AUTO_INCREMENT,
   libelle VARCHAR(100) NOT NULL UNIQUE,
   PRIMARY KEY(id_marque)
);

CREATE TABLE vehicule(
   id_vehicule INT AUTO_INCREMENT,
   modele VARCHAR(100) NOT NULL,
   immatriculation VARCHAR(15) NOT NULL UNIQUE,
   energie ENUM('essence', 'diesel', 'electrique', 'hybride') NOT NULL,
   couleur VARCHAR(50) NOT NULL,
   date_premiere_immatriculation DATE NOT NULL,
   nb_places INT NOT NULL CHECK (nb_places BETWEEN 1 AND 8),
   id_marque INT NOT NULL,
   id_utilisateur INT NOT NULL,
   PRIMARY KEY(id_vehicule),
   FOREIGN KEY(id_marque) REFERENCES marque(id_marque),
   FOREIGN KEY(id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE,
   INDEX idx_immatriculation (immatriculation)
);

CREATE TABLE preference(
   id_preference INT AUTO_INCREMENT,
   id_utilisateur INT NOT NULL,
   fumeur BOOLEAN DEFAULT FALSE,
   animal BOOLEAN DEFAULT FALSE,
   musique BOOLEAN DEFAULT TRUE,
   discussion BOOLEAN DEFAULT TRUE,
   autres_preferences TEXT,
   PRIMARY KEY(id_preference),
   FOREIGN KEY(id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE
);

CREATE TABLE covoiturage(
   id_covoiturage INT AUTO_INCREMENT,
   date_depart DATE NOT NULL,
   heure_depart TIME NOT NULL,
   lieu_depart VARCHAR(255) NOT NULL,
   ville_depart VARCHAR(100) NOT NULL,
   date_arrivee DATE NOT NULL,
   heure_arrivee TIME NOT NULL,
   lieu_arrivee VARCHAR(255) NOT NULL,
   ville_arrivee VARCHAR(100) NOT NULL,
   statut ENUM('planifie', 'en_cours', 'termine', 'annule') DEFAULT 'planifie',
   nb_places_total INT NOT NULL,
   nb_places_disponibles INT NOT NULL,
   prix_par_personne DECIMAL(10,2) NOT NULL,
   duree_estimee TIME,
   distance_km INT,
   commentaire TEXT,
   id_vehicule INT NOT NULL,
   id_conducteur INT NOT NULL,
   date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY(id_covoiturage),
   FOREIGN KEY(id_vehicule) REFERENCES vehicule(id_vehicule),
   FOREIGN KEY(id_conducteur) REFERENCES utilisateur(id_utilisateur),
   INDEX idx_date_depart (date_depart),
   INDEX idx_ville_depart (ville_depart),
   INDEX idx_ville_arrivee (ville_arrivee),
   INDEX idx_statut (statut),
   CHECK (nb_places_disponibles <= nb_places_total),
   CHECK (nb_places_disponibles >= 0)
);

CREATE TABLE participation(
   id_participation INT AUTO_INCREMENT,
   id_utilisateur INT NOT NULL,
   id_covoiturage INT NOT NULL,
   nb_places_reservees INT DEFAULT 1,
   statut ENUM('en_attente', 'confirme', 'annule', 'termine') DEFAULT 'en_attente',
   credit_utilise INT NOT NULL,
   date_participation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   date_confirmation TIMESTAMP NULL,
   commentaire_participant TEXT,
   PRIMARY KEY(id_participation),
   FOREIGN KEY(id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE,
   FOREIGN KEY(id_covoiturage) REFERENCES covoiturage(id_covoiturage) ON DELETE CASCADE,
   UNIQUE KEY unique_participation (id_utilisateur, id_covoiturage),
   INDEX idx_statut_participation (statut)
);

CREATE TABLE avis(
   id_avis INT AUTO_INCREMENT,
   commentaire TEXT,
   note TINYINT NOT NULL CHECK (note BETWEEN 1 AND 5),
   statut ENUM('en_attente', 'valide', 'rejete') DEFAULT 'en_attente',
   date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   date_validation TIMESTAMP NULL,
   id_evaluateur INT NOT NULL,
   id_evalue INT NOT NULL, 
   id_covoiturage INT NOT NULL, 
   id_validateur INT NULL,
   PRIMARY KEY(id_avis),
   FOREIGN KEY(id_evaluateur) REFERENCES utilisateur(id_utilisateur),
   FOREIGN KEY(id_evalue) REFERENCES utilisateur(id_utilisateur),
   FOREIGN KEY(id_covoiturage) REFERENCES covoiturage(id_covoiturage),
   FOREIGN KEY(id_validateur) REFERENCES utilisateur(id_utilisateur),
   UNIQUE KEY unique_avis (id_evaluateur, id_evalue, id_covoiturage),
   INDEX idx_evalue (id_evalue),
   INDEX idx_statut_avis (statut)
);