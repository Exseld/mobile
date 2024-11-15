# Application de Gestion de Classe

## Consignes

- Le travail est à réaliser individuellement.
- Ce projet comptera pour 20% de la note finale.
- La date limite de remise est le 24 mai 2024 à 21:00.
- Le projet doit être remis via un « commit » dans le projet Github Classroom. Aucune autre méthode de remise ne sera acceptée.
- Tout retard entraînera une pénalité de 10% par jour de retard jusqu’à un maximum de 5 jours. Passé ce délai, la note attribuée sera de zéro.

## Concept

Développer une application Flutter permettant à un enseignant de gérer la présence des étudiants dans une classe.

Cette application offrira à l'enseignant la possibilité de créer et de gérer des groupes d'étudiants, de marquer les présences et de gérer un calendrier scolaire partagé, mais modifiable seulement par les administrateurs.

### Rôles et permissions

L'application doit supporter plusieurs utilisateurs avec des rôles différenciés (enseignants, étudiants, administrateurs). Les rôles sont attribués à l'aide de la base de donnée. Seul un administrateur peut modifier le rôle d'un utilisateur.

Quelqu'un installant l'application doit être en mesure de créer un utilisateur. Après avoir créer son compte, cet utilisateur sera de type *étudiant*, qui est le rôle par défaut avec aucun privilège.

## Données et Utilisateurs

Les données suivantes devons être présentes dans l'application. Il est possible d'ajouter de l'information supplémentaire.

#### Profil de l'utilisateur

Contient le profil d'un utilisateur. 
- Matricule
- Nom
- Prénom
- Photo
- Courriel

Les données des utilisateurs sont accessibles sont les permissions suivantes : 
- L'utilisateur lui-même : Lecture et écriture
- Étudiants: Pas d'accès
- Enseignant : 
    - Lecture des profils étudiants
    - Pas d'accès aux profils administrateurs
- Administrateur : Lecture et écriture

>[!warning] Les photos pour le profil d'un étudiant doivent suivre les mêmes permissions

#### Classes

Identifie un groupe pour un cours
- Numéro du cours
- Numéro du groupe
- Enseignant
- Périodes de cours 
  - Jour de la semaine - heure de début - heure de fin
  - Un cours peut contenir plusieurs périodes
- Étudiants inscrits dans le cours

Permission
- Administrateur : lecture et écriture
- Enseignant du cours : lecture et écriture
- Autres enseignants : Pas d'accès
- Étudiants : Pas d'accès

#### Présences

Une table doit permettre de gérer les présences ou absences à un cours. Ici plusieurs formats sont possible donc la structure n'est pas fournie et devra être établie par le développeur.

Note: Les présences doivent être associés à un séquence de cours (1-30 pour cours donnée deux fois par semaine ou 1-15 pour un cours donné une fois par semaine.). Aussi un étudiant peut arriver en retard.

Permission
- Administrateur : Lecture et écriture
- Enseignant inscrit au cours : Lecture et écriture
- Enseignants : Pas d'accès
- Étudiants : Pas d'accès

## API

Le calendrier est disponible par API. Votre application doit charger cette API et ne doit pas conserver une liste statique du calendrier.  Cette API vous permettra d'afficher un calendrier et ainsi de faire l'association du jour versus le numéro d'un cours pour l'affichage des absences.  

- Méthodes supporté : GET
- URL : https://us-central1-cegep-al.cloudfunctions.net/calendrier
- Structure des données
  - Jour de l'année
    - Semaine de la session 1 à 15
      - `null` si le jour n'est pas une journée de classe : voir le champ `special`
    - Jour de la semaine (1 - Dimanche, 7 - Samedi)
    - Spécial
      - C - Congé
      - TP - Jour TP
      - A - Date limite d'abandon
      - EUF - Épreuve uniforme de Français
      - EC - Évaluation commune
      - PO - Évènement portes ouvertes

## Pages / Interfaces

Vous pouvez ajuster les détails de l'interface, mais les fonctionnalités décrites ici doivent s'y trouver. 

### Page de connexion

Permet à un utilisateur de s'identifier. Il doit être possible pour un utilisateur n'ayant pas de compte de se créer un compte par une option de création de profil. 

### Page de profil

Permet à un utilisateur d'ajuster les informations le concernant. Cette page doit contenir un formulaire permettant de modifier les informations contenues dans les données (profil de l'utilisateur).

### Page de gestion des profils

Les enseignants et les administrateurs ont accès à un champ de recherche permettant de voir/modifier le profil de n'importe quel utilisateur.
- Enseignant : lecture seulement
- Administrateur : lecture et écriture

Pour un administrateur, cette page doit aussi permettre de changer le rôle d'un utilisateur.

> [!note] Ici il est possible soit de créer une page différente, ou de réutiliser la page de profil avec des champs apparaissant dynamiquement selon le rôle de l'utilisateur.

### Page de gestion de classe

Page permettant d'affecter des enseignants et étudiants à une classe. Ici il doit être possible d'accomplir les actions suivantes.
- Créer une classe (Administrateur seulement)
  - Un groupe doit avoir un numéro de cours et un numéro de groupe
- Ajouter jour/période à une classe
- Assigner un enseignant à une classe (Administrateur seulement)
- Assigner des étudiants à une classe

Rappel : les enseignants ont seulement accès à cette page pour les classes auxquelles ils sont assignés. 

### Page de gestion des présences

Page permettant d'afficher un cours pour une journée spécifique. Par défaut, l'application doit utiliser le jour courant lorsque la page est atteinte, mais l'utilisateur doit être en mesure de changer de cours ou de jour par la suite.

Une liste de noms et prénoms d'étudiants qui sont dans le cours doit apparaître. 

Cliquer sur un nom doit aller sur la page de profil de l'étudiant. La fonction back doit retourner l'utilisateur à la liste. Tel que mentionné plus haut, les permissions sur le profil sont : 
- Administrateur : Lecture et écriture
- Enseignant : Lecture seule

Faire un *swipe right* doit permettre de marquer l'étudiant absent, ou présent s'il a déjà été marqué absent précédemment.

Il doit être possible de filtrer rapidement cette vue pour afficher soit tous les étudiants, ou uniquement les présents ou absents.

Si l'enseignant a plusieurs groupes, un sélecteur doit permettre de changer le groupe. L'application doit utiliser le dernier groupe choisir pour l'affichage initial.

### Rapport d'absence

Page permettant à un enseignant de voir les absences totales pour une classe. Cette page affiche une liste des étudiants et leurs absences cumulées. Cliquer sur un étudiant doit conduire à une autre vue avec le détails des jours et le nombre d'heures d'absence pour cet étudiant.
### Calendrier

Il doit être possible d'afficher un calendrier avec les jours et le numéro de la semaine de cours. Les informations pour l'affichage du calendrier est fourni par l'API

Le calendrier doit indiquer
- Jour du mois
- Numéro de la semaine (1-15)
- Jours TP
- Jours Congé
- Jours modifiés, tel jours du lundi

## Fonctionnalités

### i18n / l10n

Vous devez supporter l'internationalisation, et ainsi l'interface doit supporter : Français et Anglais, basé sur les préférences de l'appareil de votre utilisateur.

### Navigation

Vous devez créer la navigation pour permettre l'accès au différentes pages. Plusieurs stratégies peuvent être utilisés (Drawer, Bottom ou Top navigation bar, Action dans le AppBar). Vous devez mettre en place une stratégie conviviale et gérer les scénarios où les permission de l'utilisateur limite les pages disponibles.

## Matériel à Remettre

### Documents et fichiers

- Code source via Github dans le répertoire dédié au projet final.
- Fichier README.md contenant :
    - Structure de la base de données utilisée.
    - Règles implémentées pour protéger votre base de données Firestore.
- Vidéo de 2-5 minutes démontrant le fonctionnement de l'application.
    - [Microsoft Stream](https://www.microsoft365.com/launch/stream) est un outil intéressant pour faire la vidéo; il vous permet de facilement enregistrer le contenu votre écran et votre voix, puis de partager un lien vers la vidéo résultante.

### Utilisateurs de tests

Vous devez créer les utilisateurs suivants pour permettre à votre enseignant de vérifier les fonctionnalités

Courriel : admin@acme.com
Mot de passe : admin456
Rôle : Administrateur

Courriel : enseignant1@acme.com
Mot de passe : 1ens456
Rôle : Enseignant

Courriel : enseignant2@acme.com
Mot de passe : 2ens456
Rôle : Enseignant

Vous devez créer au moins 3 groupes avec au minimum deux étudiants chaque. L'enseignant1 doit avoir deux groupes et l'enseignant2 un groupe.

## Grille d'évaluation (sur 100 pts)

| Pondération | Fonctionnalité/Aspect                              |
| ----------- | -------------------------------------------------- |
| 10          | Authentification et création de compte             |
| 5           | Page de profil                                     |
| 10          | Page de gestion des profils                        |
| 10          | Création et gestion des classes                    |
| 10          | Gestion des présences                              |
| 10          | Interface pour la gestion des classes et présences |
| 10          | Page de calendrier                                 |
| 10          | Qualité de l'interface utilisateur                 |
| 5           | Sécurité des données et gestion des accès          |
| 10          | Compatibilité linguistique (Anglais et Français)   |
| 10          | Documentation et clarté du code                    |

### Librairies et Outils

Utilisez les librairies standards de Flutter pour la réalisation de ce projet. Firebase devra être utiliser pour la base de données. Vous êtes encouragés à explorer et intégrer d'autres librairies si nécessaire pour améliorer la fonctionnalité ou l'interface de l'application.
