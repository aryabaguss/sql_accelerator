select * from messages m 

-- 1 --
select 
	m."content" ,
	count(*) as total_message
from messages m 
group by m."content" 
order by total_message desc 

-- 2 --
select 
	m."content" ,
	round(avg(length(m.content_messages)),2) as avg_len_message
from messages m 
group by m."content" 
order by avg_len_message desc 

-- 3 --
select 
	m.user_id_from ,
	u.email ,
	count(*) as total_sent
from messages m 
join users u on u.user_id = m.user_id_from 
group by m.user_id_from ,u.email 
order by total_sent desc, m.user_id_from asc 

-- 4 --
select 
	m.user_id_to ,
	u.email ,
	count(*) as total_sent
from messages m 
join users u on u.user_id = m.user_id_to 
group by m.user_id_to ,u.email 
order by total_sent desc, m.user_id_to asc 

-- 5 --
with sent as(
	select 
		m.user_id_from as user_id,
		u.email ,
		count(m.user_id_from) as total_sent,
		dense_rank() over(order by count(m.user_id_from) desc ) as rank_sent
	from messages m 
	join users u on u.user_id = m.user_id_from 
	group by 1,2
	order by total_sent desc, m.user_id_from asc 
),
receive as(
	select 
		s.*,
		count(*) as total_sent,
		dense_rank() over(order by count(m.user_id_to) desc ) as rank_receive
	from messages m 
	join sent s on s.user_id = m.user_id_to
	group by m.user_id_to ,s.user_id,s.email,s.total_sent,s.rank_sent
	order by  s.rank_sent asc, m.user_id_to asc 
)
select *
from receive

-- 6 --
select 
	least(m.user_id_from,m.user_id_to) as user_1 ,
	greatest(m.user_id_to,m.user_id_from) as user_2 ,
	count(*) as total
from messages m 
group by 1,2
having count(*) > 1
order by user_1,user_2

-- 7 --
select 
	(case when extract(hour from m.created_at) = 0 then 24 
	else extract(hour from m.created_at) 
	end) as hours,
	count(*) as total_message
from messages m 
group by hours
order by hours

-- 8 --
select * from users u 

select
	u."location",
	count(*) as total_user
from users u 
group by u."location" 
order by total_user desc , u."location" asc 

-- 9 --
select 
	(case when extract(hour from m.created_at) = 0 then 24 
	else extract(hour from m.created_at) 
	end) as hours,
	count(*) as total_message
from messages m 
where m.content = 'sticker'
group by hours
order by total_message desc 

-- 10 --
with day as(
	select 
		case 
	        when extract(dow from m.created_at) between 1 and 5 then 'Weekday'
	        when extract(dow from m.created_at) in (0, 6) then 'Weekend'
		    end as day_type,
		    count(*) as total_sticker_messages
	    from messages m
	    where m.content = 'sticker'
	    group by day_type
)
select 
	day_type,
	total_sticker_messages * 1.0 / (select count(*) from messages m ) as avg_message 
from day

--
with week as(
	select 
		extract(isodow from m.created_at) as day,
	    count(m.user_id_from) as total_user
	from messages m
	where m.content = 'sticker'
	group by day
	order by day 
)
select 
	(case when day between 1 and 5 then 'weekday' else 'weekend' end) as category,
	avg(total_user) as avg_message
from week
group by category
order by avg_message desc


-- 11 --
SELECT 
	m.message_id ,
	length(m.content_messages) as len_message,
	length(translate(m.content_messages,'abcdefghijklmnopqrstuvwxyz','0123456789abcdefghijklmnop')) as len_encrypt,
	m.content_messages ,
	translate(m.content_messages,'abcdefghijklmnopqrstuvwxyz','0123456789abcdefghijklmnop') as encrypt_message
FROM messages m
ORDER BY m.message_id

-- 12 --
select 
	m.message_id ,
	m."content" ,
	m.content_messages ,
	length(m.content_messages) as length
from messages m 
where m."content" = 'text'
group by 1,2,3
having length(m.content_messages) > 
	(select avg(length(m.content_messages)) as avgg
		from messages m 
		where m."content"  = 'text')
order by 1
		
-- 13 -- later on
with sent as(
	select 
		to_char(m.created_at, 'YYYY-MM-DD') as date,
		u.user_id ,
		count(m.user_id_from) as total_sent
	from messages m 
	join users u on u.user_id = m.user_id_from 
	group by date,u.user_id 
	order by total_sent desc ,u.user_id 
),
receive as (
	select 
		to_char(m.created_at, 'YYYY-MM-DD') as date,
		u.user_id ,
		count(m.user_id_to) as total_rec
	from messages m 
	join users u on u.user_id = m.user_id_to
	group by date,u.user_id 
	order by total_rec desc ,u.user_id 
)
select distinct 
	s.date,
	s.user_id,
	s.total_sent,
	r.total_rec,
	(s.total_sent + r.total_rec) as total_engage
from sent s
join receive r on s.date = r.date and r.user_id = s.user_id
order by total_engage desc ,s.user_id

-- 14 --
select 
	m.message_id ,
	m."content" ,
	m.content_messages 
from messages m 
where m."content" = 'document' and
		(
		lower(m.content_messages) like '%aku%' or 
		lower(m.content_messages) like '%kamu%' or
		lower(m.content_messages) like '%dia%'
		)

with total as (
	select 
		count(*) as total_message
	from messages m 
	where m."content" = 'document' and
			(
			lower(m.content_messages) like '%aku%' or 
			lower(m.content_messages) like '%kamu%' or
			lower(m.content_messages) like '%dia%'
			)
)
select 
	t.total_message,
	(	select 
			count(*)
		from messages m 
		where m."content" = 'document') as total_doc,
	t.total_message * 1.0 / (select count(*) from messages m where m."content" = 'document') as rate
from total t

-- 15 --
select 
	split_part(email,'@',2) as domain ,
	count(u.user_id) as total
from users u 
--join messages m on m.user_id_from = u.user_id 
group by 1
order by total desc 

with email as(
	select  
		m."content" ,
		split_part(email,'@',2) as domain ,
		count(distinct u.email) as total_user,
		dense_rank() over(partition by m."content" order by count(*) desc) as rank
	from messages m 
	join users u on u.user_id = m.user_id_from 
	group by m."content" ,domain
	order by m.content,rank 
)
select *
from email e
where rank <= 3
order by e.content

select distinct u.email from messages m 
join users u on u.user_id = m.user_id_from 
where m."content" = 'document' and u.email like '%yahoo.com%'
order by email


-- Session 2 --

-- 1 --
select 
	m."content" ,
	count(*) as total_report
from messages_reports mr 
join messages m on m.message_id = mr.message_id 
group by 1
order by total_report desc 

-- 2 --
select * from messages_reports mr 

select * from users_reports ur 

with mess as (
	select 
		u.user_id ,
		count(mr.message_id) as from_message
	from messages m 
	left join users u on u.user_id = m.user_id_from 
	left join messages_reports mr on mr.message_id = m.message_id 
	--join users_reports ur on ur.message_id = m.message_id 
	group by 1
	order by from_message desc 
),
reportt as(
	select 
		u.user_id ,
		count(ur.message_id) as from_user
	from messages m 
	left join users u on u.user_id = m.user_id_from 
	left join users_reports ur on ur.message_id = m.message_id 
	group by 1
	order by from_user desc 
)
select 
	coalesce(m.user_id, r.user_id) AS user_id,
    coalesce(m.from_message, 0) AS from_message,
    coalesce(r.from_user, 0) AS from_user,
    (m.from_message + r.from_user) as total
from mess m
join reportt r on r.user_id = m.user_id
order by total desc ,from_message desc 

-- 3 --
with mess as (
	select 
		u.user_id ,
		count(mr.message_id) as from_message
	from messages m 
	left join users u on u.user_id = m.user_id_from 
	left join messages_reports mr on mr.message_id = m.message_id 
	--join users_reports ur on ur.message_id = m.message_id 
	group by 1
	order by from_message desc 
),
reportt as(
	select 
		u.user_id ,
		count(ur.message_id) as from_user
	from messages m 
	left join users u on u.user_id = m.user_id_from 
	left join users_reports ur on ur.message_id = m.message_id 
	group by 1
	order by from_user desc 
)
select 
	m.user_id,
	u.email ,
	u."location" ,
	m.from_message,
	r.from_user
from mess m
join reportt r on r.user_id = m.user_id
join users u on m.user_id = u.user_id 
where m.from_message = 0 and r.from_user = 0
order by m.user_id

-- 4 --
with mess as (
	select 
		u.user_id ,
		count(mr.message_id) as from_message
	from messages m 
	left join users u on u.user_id = m.user_id_from 
	left join messages_reports mr on mr.message_id = m.message_id 
	group by 1
	order by from_message desc 
),
reportt as(
	select 
		u.user_id ,
		count(ur.message_id) as from_user
	from messages m 
	left join users u on u.user_id = m.user_id_from 
	left join users_reports ur on ur.message_id = m.message_id 
	group by 1
	order by from_user desc 
),
locationn as(
	select 
		u."location" ,
	    m.from_message,
	    r.from_user
	from mess m
	join reportt r on r.user_id = m.user_id
	join users u on m.user_id = u.user_id 
	group by 1,2,3
	order by 1 
)
select  
	l.location,
	sum(distinct l.from_message) + sum(distinct l.from_user) as total
from locationn l
group by l.location
order by total desc 


-- 5 -- 
with temp1 as (
	select 
		extract(hour from mr.created_at) as hour,
		count(*) as total_mess
	from messages_reports mr 
	group by hour 
),
temp2 as(
	select 
		extract(hour from ur.created_at) as hour,
		count(*) as total_user
	from users_reports ur 
	group by hour 
)
select 
	a.hour,
	b.total_mess,
	a.total_user,
	(b.total_mess + a.total_user) as total_report
from temp2 a
join temp1 b on b.hour = a.hour
order by total_report desc 

-- 6 --
with temp1 as (
	select 
		to_char(mr.created_at,'Day') as day,
		count(*) as total_mess
	from messages_reports mr 
	group by day 
),
temp2 as(
	select 
		to_char(ur.created_at,'Day') as day,
		count(*) as total_user
	from users_reports ur 
	group by day 
)
select 
	a.day,
	b.total_mess,
	a.total_user,
	(b.total_mess + a.total_user) as total_report
from temp2 a
join temp1 b on b.day = a.day
order by total_report desc 

-- 7 --
with user_counts as(
	select 
		u.user_id ,
		count(*) as total
	from users_reports ur 
	join messages m on m.message_id = ur.message_id 
	join users u on u.user_id = m.user_id_from  
	group by 1
	having count(*) > 1
)
select 
	u.user_id ,
	m.message_id ,
	ur.reason_text ,
	to_char(ur.created_at,'YYYY-DD-MM') as date
from users_reports ur 
join messages m on m.message_id = ur.message_id 
join users u on u.user_id = m.user_id_from  
join user_counts uc on uc.user_id = u.user_id 
group by 1,2,3,ur.created_at 

-- 8 --
select * from messages_reports mr 

select * from messages m 

select 
	'Scam' as report_reason,
	count(mr.message_report_id) as total_report,
	count(distinct m.user_id_from) as total_user,
	round(avg(length(m.content_messages)),2) as avg_len_message
from messages_reports mr 
join messages m on m.message_id = mr.message_id 
where lower(mr.reason_text) like '%scam%'
union all 
select 
	'Abuse' as report_reason,
	count(mr.message_report_id) as total_report,
	count(distinct m.user_id_from) as total_user,
	round(avg(length(m.content_messages)),2) as avg_len_message
from messages_reports mr 
join messages m on m.message_id = mr.message_id 
where lower(mr.reason_text) like '%bully%'
union all 
select 
	'Something else' as report_reason,
	count(mr.message_report_id) as total_report,
	count(distinct m.user_id_from) as total_user,
	round(avg(length(m.content_messages)),2) as avg_len_message
from messages_reports mr 
join messages m on m.message_id = mr.message_id 
where lower(mr.reason_text) like '%violates%'
union all 
select 
	'Spam' as report_reason,
	count(mr.message_report_id) as total_report,
	count(distinct m.user_id_from) as total_user,
	round(avg(length(m.content_messages)),2) as avg_len_message
from messages_reports mr 
join messages m on m.message_id = mr.message_id 
where lower(mr.reason_text) like '%spam%'
union all 
select 
	'Doxxing' as report_reason,
	count(mr.message_report_id) as total_report,
	count(distinct m.user_id_from) as total_user,
	round(avg(length(m.content_messages)),2) as avg_len_message
from messages_reports mr 
join messages m on m.message_id = mr.message_id 
where lower(mr.reason_text) like '%doxx%'

-- 9 --
select 
	split_part(email,'@',2) as domain ,
	count(*) as total
from messages_reports mr 
join messages m on m.message_id = mr.message_id 
join users u on u.user_id = m.user_id_from 
group by domain 
order by total desc 
limit 5

-- 10 --
with total1 as (
	select 
		u."location" ,
		count(distinct mr.message_id) as total_report
	from users u
	left join messages m on m.user_id_from = u.user_id 
	left join messages_reports mr on mr.message_id = m.message_id 
	group by u."location" 
	--order by u."location" 
),
total2 as(
	select 
		u."location" ,
		count(distinct m.message_id) as total_message
	from users u
	left join messages m on m.user_id_from = u.user_id 
	group by u."location" 
	--order by u."location" 
)
select distinct 
	u."location" ,
	t.total_report,
	tt.total_message,
	round((t.total_report * 1.0 / tt.total_message * 1.0) * 100) as percentage_report
from users u 
join total1 t on t.location = u."location" 
join total2 tt on tt.location = u."location" 
order by u."location" asc 

-- 11 --
with ranks as(
	select 
		to_char(m.created_at, 'YYYY-MM-DD') as get_date,
		m."content" ,
		count(*) as qty_content,
		row_number() over(partition by to_char(m.created_at, 'YYYY-MM-DD') order by count(*) desc) as rank 
	from messages m 
	group by 1,2
	order by get_date
)
select 
	get_date,
	content,
	qty_content
from ranks r 
where r.rank = 1
limit 10

-- 12 --
with total as (
	select 
		m.user_id_from,
		u.email ,
		u."location" ,
		m.message_id 
	from users u
	join messages m on u.user_id = m.user_id_from 
	--left join messages_reports mr on mr.message_id = m.message_id 
	group by 1,2,3,4
	having count(m.message_id) <= 5
)
select 
	user_id_from,
	email,
	location,
	count(message_id) as total
from total t
group by 1,2,3
having count(message_id) <= 5
order by total desc , t.user_id_from 


-- 13 --
with rep1 as (
	select 
		m."content" ,
		count(*) as report_message
	from messages_reports mr 
	join messages m on m.message_id = mr.message_id 
	group by m."content" 
	order by report_message desc 
)
select 
	m."content" ,
	r.report_message,
	count(*) as report_user
from users_reports ur  
join messages m on m.message_id = ur.message_id 
join rep1 r on r.content = m."content" 
group by m."content" ,r.report_message
order by report_message desc 

-- 14 -- 
select 
	to_char(m.created_at,'YYYY-MM') as period_chat,
	u."location",
	m.*
from messages m 
join users u on u.user_id = m.user_id_from 
order by u."location",period_chat 

with ranked as (
	select 
		to_char(m.created_at,'YYYY-MM') as period_chat,
		u."location",
		m."content" ,
		count(*) as total,
		row_number() over(partition by u."location" order by count(*) desc) as rank
	from messages m 
	join users u on u.user_id = m.user_id_from 
	group by period_chat,u."location",m."content" 
	order by u."location",total desc 
)
select
	period_chat,
	location,
	content,
	total
from ranked
where rank = 1

-- 15 --
with finale as (
	select 
		to_char(m.created_at,'YYYY-MM-DD') as created,
		count(*) as total,
		lag(count(*)) over() as prev_total
	from messages m 
	group by created
	order by created
)
select 
	created,
	total,
	prev_total,
	round((total - prev_total)* 100.0 / total,2) as growth_percentage
from finale f
where prev_total is not null
order by created 
	
	
	
	
	
	
