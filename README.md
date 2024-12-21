> Cette installation permet de mettre en place un projet Moodle local en place. Celui-ci doit être déployé et exposé pour que les collaborateurs puissent le personnaliser via l'interface graphique.

# Déploiement

## Type d'installation

Pour la mise en place du projet, il faut choisir un type d'installation, il peut être cloné ou restauré.

### Moodle vierge

C'est une simple copie de projet moodle vierge, utilisant la version souhaitée.

### Restauration

On peut également restaurer le projet qui a été développé en cours. Celui ci a subit des création de cours, ajout de packs de textures, changements d'interface, modification des plugins...

Puisque notre VPS n'est pas à durée illimité, les données ont été extraites pour pouvoir restaurer le projet à l'identique. Les données incluent :

- `moodle/` : contient les fichiers sources, et notament le plugins et textures packs.
- `moodle_dump.sql` : contient un dump de la base de données
- `moodledata/`

## Execution

Saisir dans le .env :

- MOODLE_SOURCE : type d'installation souhaité ("cloned-moodle" ou "restored-version")
- DB_ADMIN_PASSWORD : Mot de passe pour admin (Moodle)
- DB_ROOT_PASSWORD : Mot de passe pour root (PhpMyAdmin)
- MOODLE_HOST : Adresse publique / nom de domaine
- `docker compose up -d --build`
- Ouvrir MOODLE_HOST dans le navigateur

# Architecture

Le dossier `moodledata/` et les données de la base de données sont persistées sur un volume pour les garder entre les executions.

Moodle se connecte à la BDD via l'utilisateur admin.

Les administrateurs se connectent à la BDD en externe par PhpMyAdmin via l'utilisateur root.

Les administrateurs se conenctent à Moodle via les utilisateurs créés sur Moodle en runtime.

# Déploiement sur la VM

> Historique des commandes executées pour déployer le Moodle sur la VM.

- Installation de Git : `apt install git-all`
- Installlation de Docker :
  - `apt-get update`
  - `apt-get install ca-certificates curl`
  - `sudo install -m 0755 -d /etc/apt/keyrings`
  - `sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc`
  - `sudo chmod a+r /etc/apt/keyrings/docker.asc`
  - ```shell
    echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
     | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```
- `git clone -b MOODLE_403_STABLE git://git.moodle.org/moodle.git`
- `dpkg -l | grep nginx : pas de nginx` et `dpkg -l | grep apache` : check qu'aucun serveur n'est installé
- `docker compose up -d --build`
  - => "Port already used"
  - `apt-get install lsof`
  - `lsof -i :80` : Retourne plusieurs 3 PID apache
  - `docker compose down` : Pour voir si apache est lancé par autre chose que docker
  - `lsof -i :80` : Retourne toujours 3 PID => apache est lancé en dehors du docker
  - `systemctl stop apache2`
  - `lsof -u :80` : Plus aucun PID !
  - `docker compose up -d --build` : OK !
  - `curl.exe -I http://212.83.155.143/` : NOK :\(
- Modification du host de apache
  - IP brute mise dans le ServerName (/etc/apache2/sites-enabled)
  - Modif avec nano (ajouté)
- Déploiement du port 80 d'apache interne à la VM
  - systemctl start apache2
  - `curl.exe -I http://212.83.155.143/` : serveur accessible !
- Tests pour comprendre pourquoi apache de docker fonctionne
  - Apache avec docker erreur 500
  - Recherche erreur
    - docker logs \<id> vide
    - /var/logs/apache2/error.log vide
    - Activation des logs PHP dans php.ini
    - `curl.exe -I http://212.83.155.143/` : 303 redirige vers localhost !
  - Port 80 fonctionne
- Trouver raison au status 303
  - Check différences de config (site-enabled/config, ports.conf, )
  - Moodle redirige ? L'empecher
    - Modification du wwwroot dans config.php => MOODLE FONCTIONNE !
- Initialisation Moodle
  - Procédure d'initialisation démarrée
  - SITE OK !
- Tentative de fonctionnement de SMTP
  - Ajout du service dans le docker compose
  - Mise en place des infos du SMTP DANS moodle
    - Erreur d'envoi lors de l'autoenregistrement / mdp oublié
    - Configuration des variables
    - Autoenregistrement ne génère plus d'erreur MAIS pas de mail reççu => SMTP ne fonctionen pas
    - tests du service SMTP sans moodle avec swaks dans le container => Erreur "IO::Socket::INET6: sock_info: Bad protocol 'tcp'"
