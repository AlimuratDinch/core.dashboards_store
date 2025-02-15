{#
Dashboards Store - Helping students, one dashboard at a time.
Copyright (C) 2023  Sciance Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
#}
{{
    config(
        post_hook=[
            core_dashboards_store.create_clustered_index(
                "{{ this }}", ["fiche", "id_eco", "annee", "code_matiere"]
            ),
        ]
    )
}}

{% set max_etapes = var("interfaces")["gpi"]["max_etapes"] + 1 %}

select
    res_mat.fiche,
    res_mat.id_eco,
    res_mat.annee,
    res_mat.code_matiere,
    res_mat.groupe_matiere,
    res_mat.etat,
    res_mat.id_mat_ele,
    res_etape = case
        met1.seq_etape
        {% for i in range(1, max_etapes) %}
            when {{ i }} then res_mat.res_etape_{{ "%02d" % i }}
        {% endfor %}
    end,
    leg_etape = case
        met1.seq_etape
        {% for i in range(1, max_etapes) %}
            when {{ i }} then res_mat.leg_etape_{{ "%02d" % i }}
        {% endfor %}
    end,
    eval_res_etape = case
        met1.seq_etape
        {% for i in range(1, max_etapes) %}
            when {{ i }} then res_mat.eval_res_etape_{{ "%02d" % i }}
        {% endfor %}
    end,
    met1.etape,
    met1.date_fin,
    res_mat.is_reprise
from {{ ref("stg_res_bilan_mat") }} as res_mat
inner join
    {{ ref("i_gpm_t_modele_etape_etapes") }} as met1
    on met1.id_eco = res_mat.id_eco
    and met1.modele_etape = res_mat.modele_etape
    and met1.date_fin between res_mat.date_deb and res_mat.date_fin
