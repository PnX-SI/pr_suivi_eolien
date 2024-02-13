DROP VIEW IF EXISTS gn_monitoring.v_export_suivi_:module_code_site;
CREATE OR REPLACE VIEW gn_monitoring.v_export_:module_code_site as
SELECT 
tm.module_code as protocole,
ref_nomenclatures.get_nomenclature_label((cmt.id_type_site)::integer) AS type_site,
s.base_site_name AS nomGite,
s.base_site_code AS idGite,
s.geom AS CoordGite,
st_x(st_centroid(s.geom)) AS longitudeGite,
st_y(st_centroid(s.geom)) AS latitudeGite,
s.altitude_min as "altitudeMinGite",
s.altitude_max as "altitudeMaxGite",
a.jname->>'COM' AS commune,
a.jcode->>'DEP' AS code_departement,
a.jname->>'DEP' as departement,
concat(tr.nom_role, ' ', tr.prenom_role) as numerGite,
org.nom_organisme as organismeNumerGite,
ref_nomenclatures.get_nomenclature_label((tsc.data->>'id_nomenclature_type_gite')::integer) AS TypeGite,
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
left join gn_monitoring.cor_module_type cmt on cmt.id_type_site = cts.id_type_site  
left join gn_commons.t_modules tm on tm.id_module = cmt.id_module
WHERE tm.module_code::text = :module_code