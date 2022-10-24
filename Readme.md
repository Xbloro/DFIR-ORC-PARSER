

# OrcPaser

Script bash permettant de :

- Dézipper récursivement une archive ORC dans une dir au choix
- Récupérer les éléments voulu et les placers dans une dir au choix

## Dépendances :

7z est requis pour l'extraction des éléments :

- 7za 

  ```bash
  sudo apt-get install p7zip*
  ```

## Configuration :

Le fichier de configuration est disponible dans le dossier.

```
configuration/config.txt
```

  Le fichier de configuration est un fichier texte de cette forme :

- "#" pour les commentaires ;
- ligne vide pour aérer ;
- nom du fichier à récupérer.

La récupération des fichiers se fait via l'outil "find", il est possible d'utiliser des "*" 

ex : 

```
*_Security.evtx
```

exemple de configuration :

```
#################  logs  #################
*_Security.evtx
*_Windows_PowerShell.evtx
*_Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx

```

la première ligne est ignorée car un commentaire, la dernière ligne également car vide.

Cette configuration va récupérer les fichiers :

```
- 0001000000000025_Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx
- 0001000000000025_Windows_PowerShell.evtx
- 0001000000000025_Security.evtx

```

# Exécution :

Le script prend 3 arguments :

- Le path "main" vers le dossier comportant les archives ORC;
- Le path vers le dossier ou seront décompressés les ORC, si il n'existe pas il sera créé ;
- Le path vers le dossier ou seront déposés les fichiers récupérés selon la configuration, si il n'existe pas il sera créé .

**Important** : Bien indiquer le full path en arguments et non un path relatif (on sait jamais).

**Important** : le path "main" (contenant les orcs) doit être un dossier maître ou toutes les archives seront déposées dedans, ex :

```
MAIN/
..........ORC-Desktop89076-23-12-02.7z
..........ORC-Desktop7876-23-12-02.7z
..........ORC-Desktop990236-23-12-02.7z
```

Le script classe les fichiers dans un dossier ayant pour nom l'archive ORC.

Important : Les dossier parent ne doivent contenir UNIQUEMENT les dossier à traiter ou être vide.

### Exemple :

```bash
bash OrcParser.sh /home/xbloro/Bureau/CanadianHusky/Archives/main/ /home/xbloro/Bureau/CanadianHusky/Archives/main/out outplaso/
```

arg1 : correspond au dossier ou sont stokés les archives ORC.
```
/home/xbloro/Bureau/CanadianHusky/Archives/main/
```

arg2 :  correspond au dossier ou seront extraites les archives ORC.

```
/home/xbloro/Bureau/CanadianHusky/Archives/main/out
```

arg3 : le dossier ou seront stokés les fichiers indiqués dans la configuration.


```
outplaso/
```

