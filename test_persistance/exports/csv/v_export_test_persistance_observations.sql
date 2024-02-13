DROP VIEW IF EXISTS gn_monitoring.v_export_test_persistance_observations;
CREATE OR REPLACE VIEW gn_monitoring.v_export_test_persistance_observations as
select tm.module_code as protocole,
    tbs.base_site_code as idEolienne,
    tbs.id_base_site,
    tbv.id_base_visit,
    tobs.id_observation,
    tobs.cd_nom,
    ref_nomenclatures.get_nomenclature_label(
        (toc.data->>'id_nomenclature_presence_foret')::integer
    ) as PresForet,
    toc.data->>'date_depot_cadavre' as DateDepot,
    toc.data->>'date_derniere_pres_cad' as DateDernierePresence,
    toc.data->>'date_premiere_abs_cad' as DatePremiereAbsence,
    string_agg(
        distinct concat (UPPER(tr.nom_role), ' ', tr.prenom_role),
        ', '
        order by concat (UPPER(tr.nom_role), ' ', tr.prenom_role)
    ) as observers,
    string_agg(bo.nom_organisme, ','),
    tobs.comments as commentaireObs,
	array_to_string(
	array(
	select 
			case 
				when entity_id.entity_id = 'no_media' then null
			else concat('https://geonature.test01.natural-solutions.eu/geonature/api/media/attachments/',
			entity_id.entity_id)
		end
	from
		unnest(
        	array(
		select
			case
				when tmed3.media_path is null then '{no_media}'
				else tmed3.media_path
			end
	        )
        ) entity_id(entity_id)
	),
	', '
) as public_media_path_observations
from gn_monitoring.t_observations tobs
    join gn_monitoring.t_base_visits tbv on tbv.id_base_visit = tobs.id_base_visit
    join gn_monitoring.t_observation_complements toc on toc.id_observation = tobs.id_observation
    left join utilisateurs.t_roles tr on tr.id_role = tobs.id_digitiser
    join utilisateurs.bib_organismes bo on tr.id_organisme = bo.id_organisme
    left join gn_monitoring.t_base_sites tbs on tbs.id_base_site = tbv.id_base_site
    left join gn_monitoring.cor_type_site cts on tbs.id_base_site = cts.id_base_site
    left join gn_monitoring.cor_module_type cmt on cmt.id_type_site = cts.id_type_site
    left join gn_commons.t_modules tm on tm.id_module = cmt.id_module
    left join lateral (
	select 
		array_agg(
			concat(tmed.media_path,
		' (titre : ',
		tmed.title_fr,
		')')
		) as media_path,
		tmed.uuid_attached_row
	from
		gn_commons.t_medias tmed
	where
		tmed.uuid_attached_row is not null
	group by
		tmed.uuid_attached_row) tmed3 on
	tmed3.uuid_attached_row = tobs.uuid_observation
where tm.module_code::text = 'test_persistance'
group by tobs.id_observation,
    tm.module_code,
    tbs.id_base_site,
    tbv.id_base_visit,
    toc.data,
    tbs.base_site_code,
    tmed3.media_path