# Protocole suivi acoustique

## Type de site

Le dossier type de site comprend les fichiers json des types de sites qui seront associés au module concerné .
Ainsi il faudra définir un nouveau type de site dans le module admin et ajouté ce fichier de configuration pour obtenir les champs liés au type de site créé dans "Admin".

## A modifier une fois protocole installé

Dans le fichier `protocoles_suivi/suivi_acoustique/module.json` il faut remplacer la valeur associé aux champs du type `id_nomenclature_[mnemonique_type]_[value]` par leur valeur de `id_nomenclature` associée en base de données. Ces valeurs sont nécessaires pour rendre fonctionnel l'affichage conditionnel des champs du formulaire de visite.

Pour cela il faut regarder dans la base de données et prendre les valeurs de la colonne `id_nomenclature` de la table `ref_nomenclatures.t_nomenclatures` pour lequelles l' `id_type` est associé au `mnemnoique` concerné dans la table `ref_nomenclatures.bib_nomenclatures_types`

Pour ce faire il est possible de retrouver l'id_nomenclature de ces deux valeurs ci dessus avec la commande sql suivante :


```sql
SELECT tn.id_nomenclature, tn.mnemonique
FROM ref_nomenclatures.t_nomenclatures tn
JOIN ref_nomenclatures.bib_nomenclatures_types bnt
ON bnt.id_type = tn.id_type
where bnt.mnemonique in ('TYPE_ETUDE','PRESENCE_ACOUSTIQUE','TYPE_HAUTEUR','EVALUATION_PLUI_TRANCHE','EVALUATION_VENT_MOYEN_TRANCHE','EVALUATION_VITESSE_EOLIENNE','TYPE_ENREGISTREMENT', 'TYPE_IDENTIFICATION', 'METHODE_IDENTIFICATION','LOGICIEL_ID_AUTO','MODELE_MATERIEL')
```
