-- trophies count vs collectors count
select stat.trophies_count, count(distinct stat.collector_id) as collectors_count from 
(
	select c.id as collector_id, count(distinct t.object_version_id) as trophies_count
	from collectors c inner join trophies t on c.id = t.owner_id
	where c.id in ( 
		select owner_id 
		from trophies tr inner join map_object_versions mov 
			on tr.object_version_id = mov.id
		where mov.object_id in (
			select mo.id 
			from map_objects mo 
				inner join  map_object_object_tag moot on mo.id = moot.map_objects_id
				inner join tags t on t.id = moot.tags_id
			where t.name = 'Naked' and mo.is_visible
		)
	)
	group by c.id) stat
group by stat.trophies_count

-- number of collectors, who collected objects with specific tag
select count(distinct owner_id)
	from trophies tr inner join map_object_versions mov 
		on tr.object_version_id = mov.id
	where mov.object_id in (
		select mo.id 
		from map_objects mo 
			inner join  map_object_object_tag moot on mo.id = moot.map_objects_id
			inner join tags t on t.id = moot.tags_id
		where t.name = 'Naked' and mo.is_visible
)
