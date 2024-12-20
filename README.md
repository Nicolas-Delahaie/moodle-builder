# Installation

Cette installation permet de mettre en place un projet Moodle local en place. Celui-ci doit être déployé et exposé pour que les collaborateurs puissent le personnaliser via l'interface graphique.

- `git clone -b MOODLE_403_STABLE git://git.moodle.org/moodle.git`
- Saisir dans le .env :
  - DB_ADMIN_PASSWORD : Mot de passe pour admin (Moodle)
  - DB_ROOT_PASSWORD : Mot de passe pour root (PhpMyAdmin)
  - MOODLE_HOST : Adresse publique / nom de domaine
- `docker compose up -d --build`
- Ouvrir http://localhost
- Suivre les étapes d'initialisation supplémentaires

# Architecture

Le dossier `moodle/` est copié dans l'image docker. S'il est modifié, il faudra re build le docker.

Le dossier `moodledata/` est quant à lui persisté sur un volume pour le garder entre les executions. En effet, il a fallu éviter de le mapper à partir de l'hôte car la synchronisation entrainait une énorme latence.

Moodle se connecte à la BDD via l'utilisateur admin.

Les administrateurs se connectent à la BDD en externe via PhpMyAdmin via l'utilisateur root.

Les administrateurs se conenctent à Moodle via les utilisateurs créés sur Moodle (prenoms de l'équipe).

# Déploiement sur la VM

## Installations

**Git :**

dpkg -l | grep git : pas de git
apt install git-all

**Docker :**

docker --version : non reconnu

apt-get update  
apt-get install ca-certificates curl  
sudo install -m 0755 -d /etc/apt/keyrings  
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc  
sudo chmod a+r /etc/apt/keyrings/docker.asc

```shell
echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
 | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

sudo apt-get update

## Lancement

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
