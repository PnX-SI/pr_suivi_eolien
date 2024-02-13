DROP VIEW IF EXISTS gn_monitoring.v_export_suivi_mortalite_site;
CREATE OR REPLACE VIEW gn_monitoring.v_export_suivi_mortalite_site as
SELECT 
tm.module_code as protocole,
tsg.sites_group_name AS lbParc,
tsg.sites_group_code AS idParc,
tsg.geom AS CoordParc,
st_x(st_centroid(tsg.geom)) AS longitude,
st_y(st_centroid(tsg.geom)) AS latitude,
tsg.altitude_min as "altitudeMinParc",
tsg.altitude_max as "altitudeMaxParc",
(rfg_i_com).commune_from_centroid AS communeParc,
(rfg_i_dep).dep_from_centroid AS departementParc,
ref_nomenclatures.get_nomenclature_label((cmt.id_type_site)::integer) AS type_site,
s.base_site_name AS nomEolienne,
s.base_site_code AS idEolienne,
s.geom AS CoordEol,
st_x(st_centroid(s.geom)) AS longitudeEol,
st_y(st_centroid(s.geom)) AS latitudeEol,
s.altitude_min as "altitudeMinEol",
s.altitude_max as "altitudeMaxEol",
a.jname->>'COM' AS commune,
a.jcode->>'DEP' AS code_departement,
a.jname->>'DEP' as departement,
concat(tr.nom_role, ' ', tr.prenom_role) as numerEol,
org.nom_organisme as organismeNumerEol,
ref_nomenclatures.get_nomenclature_label((tsc.data->>'id_nomenclature_contexte_saisie')::integer) AS ContSaisie,
ref_nomenclatures.get_nomenclature_label((tsc.data->>'id_nomenclature_type_lisiere')::integer) AS TypeLisiere,
tsc.data->>'modele_eolienne' AS ModEolienne,
tsc.data->>'longueur_pales' AS LongPales,
tsc.data->>'hauteur_eolienne' AS HautEolienne,
tsc.data->>'distance_lisiere' AS DistLisiereArb
from gn_monitoring.t_base_sites s
LEFT JOIN gn_monitoring.t_site_complements tsc ON s.id_base_site = tsc.id_base_site 
JOIN LATERAL ( SELECT d_1.id_base_site ,
        json_object_agg(d_1.type_code, d_1.o_name) AS jname,
        json_object_agg(d_1.type_code, d_1.o_code) AS jcode
       FROM ( SELECT sa.id_base_site ,
                ta.type_code,
                string_agg(DISTINCT a_1.area_name::text, ','::text) AS o_name,
                string_agg(DISTINCT a_1.area_code::text, ','::text) AS o_code
               FROM gn_monitoring.cor_site_area  sa
                 JOIN ref_geo.l_areas a_1 ON sa.id_area = a_1.id_area
                 JOIN ref_geo.bib_areas_types ta ON ta.id_type = a_1.id_type
              WHERE sa.id_base_site  = s.id_base_site
              GROUP BY sa.id_base_site , ta.type_code) d_1
      GROUP BY d_1.id_base_site) a ON true
left join utilisateurs.t_roles tr on tr.id_role = s.id_digitiser 
join utilisateurs.bib_organismes org on
	org.id_organisme = tr.id_organisme
left join gn_monitoring.cor_type_site cts on s.id_base_site = cts.id_base_site 
join gn_monitoring.t_sites_groups tsg on tsg.id_sites_group = tsc.id_sites_group 
join lateral (select area_name as commune_from_centroid from 
ref_geo.fct_get_area_intersection(st_centroid(tsg.geom)) rfg
join ref_geo.bib_areas_types bat 
on rfg.id_type = bat.id_type and bat.type_code = 'COM') rfg_i_com on true
join lateral (select area_name as dep_from_centroid from 
ref_geo.fct_get_area_intersection(st_centroid(tsg.geom)) rfg
join ref_geo.bib_areas_types bat 
on rfg.id_type = bat.id_type and bat.type_code = 'DEP') rfg_i_dep on true     
left join gn_monitoring.cor_module_type cmt on cmt.id_type_site = cts.id_type_site  
left join gn_commons.t_modules tm on tm.id_module = cmt.id_module
WHERE tm.module_code::text = 'suivi_mortalite'