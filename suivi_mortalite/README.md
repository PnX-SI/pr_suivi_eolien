# Protocole suivi mortalite

## Type de site

Le dossier type de site comprend les fichiers json des types de sites qui seront associés au module concerné .
Ainsi il faudra définir un nouveau type de site dans le module admin et ajouté ce fichier de configuration pour obtenir les champs liés au type de site créé dans "Admin".

## Config Observation

La configuraiton observation (`protocoles_suivi/suivi_mortalite/observation.json`) nécessite d'utiliser un id_nomenclature_pres_cadavre pour rendre conditionnel l'affichage de certains champs du formulaire.

Il est donc nécessaire de changer la valeur de comparaison de l' `id_nomenclature_pres_cadavre` . Pour cela il faut regarder dans la base de données et prendre la valeur de la colonne `id_nomenclature` de la table `ref_nomenclatures.t_nomenclatures` avec l' `id_type` associé au `mnemnoique` `PRES_CADAVRE`.
