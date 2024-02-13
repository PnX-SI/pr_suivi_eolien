DROP VIEW IF EXISTS gn_monitoring.v_export_efficacite_observateur_visit;
CREATE OR REPLACE VIEW gn_monitoring.v_export_efficacite_observateur_visit as
select tm.module_code as protocole,
    tbs.base_site_code as idEolienne,
    ref_nomenclatures.get_nomenclature_label((tvc.data->>'id_type_donnee')::integer) as TypeDonnee,
    tbv.id_base_site,
    tbv.id_base_visit,
    tbv.visit_date_min as dateDebut,
    tbv.visit_date_max as dateFin,
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
    join gn_monitoring.t_observations tobs on tbv.id_base_visit = tobs.id_base_visit
    join gn_monitoring.cor_visit_observer cvo on cvo.id_base_visit = tbv.id_base_visit
    join utilisateurs.t_roles tr on tr.id_role = cvo.id_role
    join utilisateurs.bib_organismes bo on tr.id_organisme = bo.id_organisme
    left join gn_meta.t_datasets td on td.id_dataset = tbv.id_dataset
    left join gn_monitoring.t_base_sites tbs on tbs.id_base_site = tbv.id_base_site
    left join gn_monitoring.cor_type_site cts on tbs.id_base_site = cts.id_base_site
    left join gn_monitoring.cor_module_type cmt on cmt.id_type_site = cts.id_type_site
    left join gn_commons.t_modules tm on tm.id_module = cmt.id_module
where tm.module_code::text = 'efficacite_observateur'
group by tbv.id_base_site,
    tm.module_code,
    tbv.id_base_visit,
    td.dataset_name,
    tvc.data,
    tbs.base_site_code