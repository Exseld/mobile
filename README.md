Règles:

rules_version = '2';

service cloud.firestore {
    match /databases/{database}/documents {
        // Règles pour la collection Utilisateurs
            match /utilisateurs/{utilisateursId} {
                allow read, write: if request.auth != null && (
                 // L'utilisateur lui-même
                    utilisateursId == request.auth.uid ||
                    // Administrateur
                    get(/databases/$(database)/documents/utilisateurs/$(request.auth.uid)).data.role == "Administrateur" ||
                    get(/databases/$(database)/documents/utilisateurs/$(request.auth.uid)).data.role == "Enseignant"
                );
            }

        match /classes/{classesId} {
            allow read, write: if request.auth != null && (
            get(/databases/$(database)/documents/utilisateurs/$(request.auth.uid)).data.role == "Administrateur" ||
            get(/databases/$(database)/documents/utilisateurs/$(request.auth.uid)).data.role == "Enseignant"    
          );
        }
      
        // Règles pour la collection Présences
        match /presences/{sequenceId} {
          allow read, write: if request.auth != null && (
            // Administrateur
            get(/databases/$(database)/documents/utilisateurs/$(request.auth.uid)).data.role == "Administrateur" ||
            get(/databases/$(database)/documents/utilisateurs/$(request.auth.uid)).data.role == "Enseignant"
          );
        }
    }
}

Structure:
    classes:
     - enseignant (reference)
     - etudiants (array)
        - valeur (reference)
     - num_classe (string)
     - num_groupe (string)
     - periode (map)
        - heure_debut (string)
        - heure_fin (string)
        - jour_semaine (string)

    presences:
        - classe (reference)
        - date (timestamp)
        - etudiant (reference)
        - nb_heures (number)
        - statut (string)

    utilisateurs:
     - email (string)
     - matricule (string)
     - nom (string)
     - prenom (string)
     - role (string)

[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/cyQywG8J)
