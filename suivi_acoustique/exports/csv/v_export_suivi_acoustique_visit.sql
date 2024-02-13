DROP VIEW IF EXISTS gn_monitoring.v_export_suivi_acoustique_visit;
CREATE OR REPLACE VIEW gn_monitoring.v_export_suivi_acoustique_visit as
select tm.module_code as protocole,
    tbs.base_site_code as idEolienne,
    tbv.id_base_site,
    tbv.id_base_visit,
    tbv.visit_date_min as dateDebut,
    tbv.visit_date_max as dateFin,
    ref_nomenclatures.get_nomenclature_label(
        (tvc.data->>'id_nomenclature_type_etude')::integer
    ) as TypeEtude,
    ref_nomenclatures.get_nomenclature_label(
        (tvc.data->>'id_nomenclature_type_replicas')::integer
    ) as TypeReplicas,
    tvc.data->>'heure_debut_recherche' as HeureDebRecherche,
    tvc.data->>'heure_fin_recherche' as HeureFinRecherche,
    ref_nomenclatures.get_nomenclature_label(
        (tvc.data->>'id_nomenclature_presence_acoustique')::integer
    ) as PresAcoustique,
    tvc.data->>'hauteur' as hauteur,
    ref_nomenclatures.get_nomenclature_label(
        (tvc.data->>'id_nomenclature_type_hauteur')::integer
    ) as TypeHauteur,
    ref_nomenclatures.get_nomenclature_label(
        (tvc.data->>'id_nomenclature_position_nacelle')::integer
    ) as PosNacelle,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_evaluation_pluie_tranche'
        )::integer
    ) as EvalPluieTranche,
    tvc.data->>'pluie_tranche' as pluietranche,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'    "id_nomenclature_evaluation_vent_moy_tranche": {
'
        )::integer
    ) as EvalVentMoyTranche,

    tvc.data->>'vitesse_moy_tranche' as VitesseMoyTranche,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_evaluation_vitesse_eolienne'
        )::integer
    ) as EvalVitesseEol,
    tvc.data->>'vitesse_eolienne' as vitesseEol,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_methode_etude'
        )::integer
    ) as MethodeEtude,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_type_enregistrement'
        )::integer
    ) as TypeEnregistrement,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_type_identification'
        )::integer
    ) as TypeIdentification,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_methode_identification'
        )::integer
    ) as MethIdentification,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_logiciel_id_auto'
        )::integer
    ) as LogicielIdAuto,
    tvc.data->>'autre_logiciel_id_auto' as AutreLogicielIdAuto,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_type_canal'
        )::integer
    ) as TypeCanal,
    tvc.data->>'decoupage_fichier' as DecoupageFichier,
    tvc.data->>'duree_decoupage_fichier' as DureeDecoupageFichier,
    tvc.data->>'age_micro' as AgeMicro,
    tvc.data->>'freq_min' as FreqMin,
    tvc.data->>'freq_max' as FreqMax,
    tvc.data->>'trigger_used' as trigger,
    tvc.data->>'trigger_decibel' as TriggerDecibel,
    tvc.data->>'gain_used' as Gain,
    tvc.data->>'gain' as GainValue,
    tvc.data->>'intervalle_cris_max' as IntervalCrisMax,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_modele_materiel'
        )::integer
    ) as ModeleMateriel,
    tvc.data->>'modele_autre' as ModeleAutre,
    ref_nomenclatures.get_nomenclature_label(
        (
            tvc.data->>'id_nomenclature_type_duree'
        )::integer
    ) as TypeDuree,
    tvc.data->>'score' as score,
    string_agg(
        distinct concat (UPPER(tr.nom_role), ' ', tr.prenom_role),
        ', '
        order by concat (UPPER(tr.nom_role), ' ', tr.prenom_role)
    ) as observers_visit,
    string_agg(bo.nom_organisme, ','),
    tvc.data->>'observers_txt' as obsExterieurs_visit,
    tbv.id_dataset,
    td.dataset_name
from gn_monitoring.t_base_visits tbv
    join gn_monitoring.t_visit_complements tvc on tvc.id_base_visit = tbv.id_base_visit
    join gn_monitoring.cor_visit_observer cvo on cvo.id_base_visit = tbv.id_base_visit
    join utilisateurs.t_roles tr on tr.id_role = cvo.id_role
    join utilisateurs.bib_organismes bo on tr.id_organisme = bo.id_organisme
    left join gn_meta.t_datasets td on td.id_dataset = tbv.id_dataset
    left join gn_monitoring.t_base_sites tbs on tbs.id_base_site = tbv.id_base_site
    left join gn_monitoring.cor_type_site cts on tbs.id_base_site = cts.id_base_site
    left join gn_monitoring.cor_module_type cmt on cmt.id_type_site = cts.id_type_site
    left join gn_commons.t_modules tm on tm.id_module = cmt.id_module
where tm.module_code::text = :module_code
group by tbv.id_base_site,
    tm.module_code,
    tbv.id_base_visit,
    td.dataset_name,
    tvc.data,
    tbs.base_site_code