

# OrcPaser

Script bash permettant de :

- Dézipper récursivement une archive ORC dans une dir au choix
- Récupérer les éléments voulu et les placers dans une dir au choix

Le script n'est pas encore fini, il faut que j'ajoute les parseurs python et les grok logstash pour ingestion dans ELK


## Dépendances :

7z est requis pour l'extraction des éléments :

- 7za 

  ```bash
  sudo apt-get install p7zip*
  ```


# Exécution :

Le script prend 3 arguments :

- Le path vers l'archive ORC;
- Le path vers le dossier ou seront décompressés et traités les ORC, si il n'existe pas il sera créé ;
- Le nom du case.

**Important** : Bien indiquer le full path en arguments et non un path relatif (on sait jamais).


Le script classe les fichiers dans un dossier ayant pour nom l'archive ORC avec timestamp.



### Exemple :

```bash
bash OrcParser.sh /home/xbloro/Bureau/Archives/ORCpc1.7z/ /home/xbloro/Bureau/MonSUperCase/ MonSuperCaseName
```

arg1 : correspond au path de l'archive ORC.
```
/home/xbloro/Bureau/orcArchive.7z
```

arg2 :  correspond au dossier ou seront extraites les archives ORC.

```
/home/xbloro/Bureau/casename/
```

arg3 : le case name

```
casename
```

