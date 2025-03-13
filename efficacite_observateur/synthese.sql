DROP VIEW IF EXISTS gn_monitoring.v_synthese_efficacite_observateur;
CREATE VIEW gn_monitoring.v_synthese_efficacite_observateur AS WITH source AS (
	SELECT id_source
	FROM gn_synthese.t_sources
	WHERE name_source = CONCAT('MONITORING_', UPPER(:module_code))
	LIMIT 1
), sites AS (
	SELECT id_base_site,
		geom AS the_geom_4326,
		ST_CENTROID(geom) AS the_geom_point,
		geom_local as geom_local
	FROM gn_monitoring.t_base_sites
),
visits AS (
	SELECT id_base_visit,
		uuid_base_visit,
		id_module,
		id_base_site,
		id_dataset,
		id_digitiser,
		visit_date_min AS date_min,
		COALESCE (visit_date_max, visit_date_min) AS date_max,
		comments,
		(
			case
				when visitecompl.data->'id_nomenclature_tech_collect_campanule'::text = 'null' then '314'
				else visitecompl.data->'id_nomenclature_tech_collect_campanule'::text
			end
		)::int as id_nomenclature_tech_collect_campanule,
		id_nomenclature_grp_typ
	FROM gn_monitoring.t_base_visits
		JOIN gn_monitoring.t_visit_complements visitecompl using(id_base_visit)
),
observers AS (
	SELECT array_agg(r.id_role) AS ids_observers,
		STRING_AGG(CONCAT(r.nom_role, ' ', prenom_role), ' ; ') AS observers,
		id_base_visit
	FROM gn_monitoring.cor_visit_observer cvo
		JOIN utilisateurs.t_roles r ON r.id_role = cvo.id_role
	GROUP BY id_base_visit
)
SELECT o.uuid_observation AS unique_id_sinp,
	v.uuid_base_visit AS unique_id_sinp_grp,
	source.id_source,
	o.id_observation AS entity_source_pk_value,
	v.id_dataset,
	ref_nomenclatures.get_id_nomenclature('NAT_OBJ_GEO', 'St') AS id_nomenclature_geo_object_nature,
	v.id_nomenclature_grp_typ,
	v.id_nomenclature_tech_collect_campanule,
	(
		case
			when obscompl.data->'presence_cadavre'::text = 'null' then '153'
			else obscompl.data->'presence_cadavre'::text
		end
	)::int as id_nomenclature_bio_condition,
	(
		case
			when obscompl.data->'technique_observation'::text = 'null' then '58'
			else obscompl.data->'technique_observation'::text
		end
	)::int AS id_nomenclature_obs_technique,
	(
		case
			when obscompl.data->'stade_de_vie'::text = 'null' then '1'
			else obscompl.data->'stade_de_vie'::text
		end
	)::int AS id_nomenclature_life_stage,
	(
		case
			when obscompl.data->'sexe'::text = 'null' then '168'
			else obscompl.data->'sexe'::text
		end
	)::int AS id_nomenclature_sex,
	(
		case
			when obscompl.data->'technique_observation'::text = '37' then ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND')
			else ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'NSP')
		end
	)::int AS id_nomenclature_obj_count,
	(
		case
			when obscompl.data->'technique_observation'::text = '37' then ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'Co')
			else ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'Es')
		end
	)::int AS id_nomenclature_type_count,
	(
		case
			when obscompl.data->'statut_observation'::text = 'null' then '85'
			else obscompl.data->'statut_observation'::text
		end
	)::int AS id_nomenclature_observation_status,
	(
		case
			when obscompl.data->'statut_source'::text = 'null' then '72'
			else obscompl.data->'statut_source'::text
		end
	)::int AS id_nomenclature_source_status,
	ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO', '1') AS id_nomenclature_info_geo_type,
	nullif(
		(
			(obscompl.data::json#>'{count_min}'::text [])::text
		),
		'null'
	)::integer AS count_min,
	nullif(
		(
			(obscompl.data::json#>'{count_max}'::text [])::text
		),
		'null'
	)::integer AS count_max,
	o.id_observation,
	o.cd_nom,
	t.nom_complet AS nom_cite,
	alt.altitude_min,
	alt.altitude_max,
	s.the_geom_4326,
	s.the_geom_point,
	s.geom_local as the_geom_local,
	v.date_min,
	v.date_max,
	obs.observers,
	v.id_digitiser,
	v.id_module,
	v.comments AS comment_context,
	o.comments AS comment_description,
	obs.ids_observers,
	v.id_base_site,
	v.id_base_visit
FROM gn_monitoring.t_observations o
	JOIN gn_monitoring.t_observation_complements obscompl on o.id_observation = obscompl.id_observation
	JOIN visits v ON v.id_base_visit = o.id_base_visit
	JOIN sites s ON s.id_base_site = v.id_base_site
	JOIN gn_commons.t_modules m ON m.id_module = v.id_module
	JOIN taxonomie.taxref t ON t.cd_nom = o.cd_nom
	JOIN source ON TRUE
	JOIN observers obs ON obs.id_base_visit = v.id_base_visit
	LEFT JOIN LATERAL ref_geo.fct_get_altitude_intersection(s.geom_local) alt (altitude_min, altitude_max) ON TRUE
WHERE m.module_code::text = :module_code;
SELECT *
FROM gn_monitoring.v_synthese_efficacite_observateur