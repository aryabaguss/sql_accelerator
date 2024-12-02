select id, first_name,last_name,email,phone from mahasiswa
where id_jurusan = 2;

select id, first_name,last_name,email,phone from mahasiswa
where id_jurusan = 2 and email like '%pd%';

select count(id) as total_mahasiswa from mahasiswa m;

select count(id) as total_dosen from dosen;

select id_jurusan,count(id) as total_dosen from dosen 
group by id_jurusan order by id_jurusan;

select id_jurusan,count(id_jurusan) as total_mahasiswa_per_jurusan ,
(select count(*) from mahasiswa) as total_mahasiswa from mahasiswa m
group by id_jurusan order by id_jurusan ;

select semester, sum(sks) as total_sks from mata_kuliah mk 
where id_jurusan = 2
group by semester order by semester ;

select nama as mata_kuliah_ganjil from mata_kuliah mk 
where id_jurusan  = 2 and semester % 2 = 1;

select count(distinct ruangan) as total_ruangan from mata_kuliah mk 
where semester  = 1 or semester  = 2;

select ruangan from mata_kuliah mk 
where semester = 1 or semester  = 2
group by ruangan 
having count(ruangan) > 1;

select id_mata_kuliah ,count(is_hadir) from attendance a 
where is_hadir = true
group by id_mata_kuliah
order by count(is_hadir) desc 
limit 20;

-- 11 --
select a.id_mata_kuliah,a.id_mahasiswa,
SUM(case when is_hadir = true then 1 else 0 end) as total_attendance,
SUM(case when is_hadir = true then 1 else 0 end) ::float / count(*) as attendance_level
from attendance a 
group by a.id_mata_kuliah ,a.id_mahasiswa
order by attendance_level desc
limit 10;

select id_mata_kuliah, 
id_mahasiswa, 
count(*) as total_attendance,
sum(is_hadir::int)::numeric / count(*) as attendance_rate
from attendance a 
group by 1,2
order by attendance_rate desc
limit 10;

-- 12 --
select id_mata_kuliah,
sum(case when is_hadir = false then 1 else 0 end) as total_absence,
(sum(case when is_hadir = false then 1 else 0 end) * 1.0 / count(*)) as absence_level
from attendance a
group by id_mata_kuliah 
having (sum(case when is_hadir = false then 1 else 0 end) * 1.0 / count(*)) > 0.5
order by absence_level desc;

-- 13 --
select week_kuliah, 
SUM(CASE WHEN is_hadir = true THEN 1 ELSE 0 END) as total_attendance,
SUM(case when is_hadir = true then 1 else 0 end) * 1.0 / count(*) as attendance_level
from attendance a
where id_mata_kuliah  = 10
group by week_kuliah 
order by week_kuliah asc;

-- 13 using CTE -- 
with temp as(
	select 
		id_mata_kuliah,
		sum(case when is_hadir = false then 1 else 0 end) as total_absence,
		(sum(case when is_hadir = false then 1 else 0 end) * 1.0 / count(*)) as absence_level
	from attendance a
	group by id_mata_kuliah 
	having (sum(case when is_hadir = false then 1 else 0 end) * 1.0 / count(*)) > 0.5
	order by absence_level desc limit 1
)
select week_kuliah, 
SUM(CASE WHEN is_hadir = true THEN 1 ELSE 0 END) as total_attendance,
SUM(case when is_hadir = true then 1 else 0 end) * 1.0 / count(*) as attendance_level
from attendance a
where id_mata_kuliah  = (select id_mata_kuliah from temp)
group by week_kuliah 
order by week_kuliah asc;

select nama,sum(sks) as sks from mata_kuliah mk 
group by nama
having sum(sks) > 3
order by sks,nama desc;

select min(nilai),max(nilai), avg(nilai) from nilai_v2

-- Session 2 --

-- 1 --
select m.id as id_mahasiswa, concat(m.first_name,' ',m.last_name), m.email,m.phone, j.jurusan 
from mahasiswa m 
join jurusan j  on j.id  = m.id_jurusan 
where j.jurusan  = 'Teknik Informatika';

-- 2 --
select j.jurusan ,nama as mata_kuliah,count(distinct e.id_mahasiswa) as total_mahasiswa
from mata_kuliah m 
join jurusan j on j.id  = m.id_jurusan 
join enrollment e on e.id_mata_kuliah  = m.id 
group by e.id_mata_kuliah, e.id_jurusan ,j.jurusan ,m.nama
order by j.jurusan, total_mahasiswa desc;

select id_mahasiswa,e.id_jurusan ,j.jurusan ,id_mata_kuliah, mk.nama 
from enrollment e
join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
join jurusan j on j.id  = e.id_jurusan 
order by id_mahasiswa ,e.id_jurusan ,id_mata_kuliah 

-- 3 --
select j.jurusan, mk.nama, avg(nv.nilai) as ratarata_nilai from enrollment e
join nilai_v2 nv on nv.id_enrollment = e.id 
join jurusan j on j.id  = e.id_jurusan 
join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
group by j.jurusan , mk.nama 
order by j.jurusan, ratarata_nilai desc

-- 4 --
select j.jurusan , mk.nama  as mata_kuliah,semester,sks
from mata_kuliah mk 
join jurusan j ON j.id = mk.id_jurusan 
where j.jurusan  = 'Teknik Informatika'

-- 5 --
select distinct m.id as id_mahasiswa, concat(m.first_name,' ',m.last_name) as full_name, 
m.email , m.phone, j.jurusan , mk.nama 
from mahasiswa m 
join enrollment e on e.id_mahasiswa = m.id 
join jurusan j on j.id  = m.id_jurusan 
join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
where j.jurusan  = 'Teknik Informatika' and mk.nama  = 'Kecerdasan Buatan'

-- 6 --
select distinct j.jurusan, mk.nama , d.nama 
from dosen d 
join jurusan j on j.id  = d.id_jurusan 
join enrollment e on e.id_dosen  = d.id 
join mata_kuliah mk on e.id_mata_kuliah = mk.id 
where mk.nama  = 'Kecerdasan Buatan'

-- 7 --
select distinct m.id as id_mahasiswa, concat(m.first_name,' ',m.last_name) as full_name, 
j.jurusan , mk.nama ,nv.nilai 
from mahasiswa m 
join enrollment e on e.id_mahasiswa = m.id 
join jurusan j on j.id  = m.id_jurusan 
join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
join nilai_v2 nv on nv.id_enrollment = e.id 
where j.jurusan  = 'Teknik Informatika' and mk.nama  = 'Kecerdasan Buatan'
order by nv.nilai desc limit 10

-- 8 --
select distinct m.id as id_mahasiswa, concat(m.first_name,' ',m.last_name) as full_name, 
mk.nama as id_mata_kuliah ,nv.nilai 
from mahasiswa m 
join enrollment e on e.id_mahasiswa = m.id 
join jurusan j on j.id  = m.id_jurusan 
join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
join nilai_v2 nv on nv.id_enrollment = e.id 
where j.jurusan  = 'Teknik Informatika'
order by nv.nilai desc, mk.nama limit 7

-- 9 --
select mk.nama as mata_kuliah, 
concat(m.first_name,' ',m.last_name) as full_name,
count(is_hadir) as total_attendance,
SUM(case when is_hadir = true then 1 else 0 end) ::float / count(*) as attendance_level
from attendance a 
join mata_kuliah mk on mk.id  = a.id_mata_kuliah
join mahasiswa m on m.id  = a.id_mahasiswa 
where mk.nama  = 'Kecerdasan Buatan'
group by mk.nama, full_name
order by attendance_level desc

-- 10 --
select week_kuliah,
SUM(CASE WHEN is_hadir = true THEN 1 ELSE 0 END) as total_attendance,
lead(SUM(CASE WHEN is_hadir = true THEN 1 ELSE 0 END)) over() as total_attendance_week
from attendance a 
join mata_kuliah mk on mk.id  = a.id_mata_kuliah 
where mk.nama  = 'Kecerdasan Buatan'
group by week_kuliah 
order by week_kuliah 

-- 11 --
select d.nama ,min(nv.nilai) as minimum ,
max(nv.nilai) as maximum,
avg(nv.nilai) as ratarata,
stddev(nv.nilai) as standardeviasi,
count(*) as total
from dosen d 
join enrollment e on e.id_dosen  = d.id 
join mata_kuliah mk on e.id_mata_kuliah = mk.id 
join nilai_v2 nv on nv.id_enrollment = e.id 
where mk.nama  = 'Kecerdasan Buatan'
group by d.nama

-- 12 --
select d.nama ,
count(*) as zero_given
from dosen d 
join enrollment e on e.id_dosen  = d.id 
join mata_kuliah mk on e.id_mata_kuliah = mk.id 
join nilai_v2 nv on nv.id_enrollment = e.id 
where mk.nama  = 'Kecerdasan Buatan' and nv.nilai  = 0
group by d.nama 

-- 13 --
with temp as(
	select distinct m.id as mahasiswa_id, j.jurusan,mk.nama as mata_kuliah
	from mahasiswa m
	join jurusan j  on j.id = m.id_jurusan 
	join enrollment e on e.id_mahasiswa = m.id 
	join mata_kuliah mk on mk.id = e.id_mata_kuliah 
	where mk.jadwal = 'Jum''at'
)
select t.jurusan, t.mata_kuliah, count(*) as total_students
from temp t
group by t.jurusan, t.mata_kuliah
order by t.jurusan

-- 14 --
select m.id as id_mahasiswa, concat(m.first_name,' ',m.last_name),
m.email,mk.nama as mata_kuliah ,mk.jadwal ,mk.ruangan 
from mahasiswa m 
join enrollment e on e.id_mahasiswa = m.id 
join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
where mk.jadwal = 'Senin' and mk.ruangan = 'Lantai 3'
order by mk.nama 

-- 15 --
select distinct d.nama as nama_dosen, mk.nama ,mk.jadwal ,mk.ruangan 
from dosen d 
join enrollment e on e.id_dosen = d.id 
join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
where mk.ruangan = 'Lantai 1' and  (mk.jadwal = 'Senin' or mk.jadwal = 'Kamis')
order by mk.jadwal desc


-- Session 3 --

-- 1 --
select m.id as id_mahasiswa,
concat(m.first_name,' ',m.last_name) as full_name,mk.nama , avg(nv.nilai) over(partition by m.id,mk.nama) as average
from mahasiswa m 
join enrollment e on e.id_mahasiswa = m.id 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
join nilai_v2 nv on nv.id_enrollment = e.id 
order by m.id

-- 2 --

select distinct m.id as id_mahasiswa,
		concat(m.first_name,' ',m.last_name) as full_name,j.jurusan, 
		max(nv.nilai) as nilai,
		row_number() over(partition by j.jurusan order by max(nv.nilai) desc) as rank
		from mahasiswa m 
		join enrollment e on e.id_mahasiswa = m.id 
		join jurusan j on j.id = e.id_jurusan 
		join nilai_v2 nv on nv.id_enrollment = e.id 
		group by m.id, j.jurusan

with ranked_students as (
	 select distinct m.id as id_mahasiswa,
		concat(m.first_name,' ',m.last_name) as full_name,j.jurusan, 
		max(nv.nilai) as nilai,
		row_number() over(partition by j.jurusan order by max(nv.nilai) desc) as rank
		from mahasiswa m 
		join enrollment e on e.id_mahasiswa = m.id 
		join jurusan j on j.id = e.id_jurusan 
		join nilai_v2 nv on nv.id_enrollment = e.id 
		group by m.id, j.jurusan
)
select *
from ranked_students
where rank = 3
order by jurusan, id_mahasiswa

-- 3 -- 
select a.id_mata_kuliah , mk.nama as mata_kuliah,
count(is_hadir) as total_data,
SUM(case when is_hadir = true then 1 else 0 end) as total_hadir,
round(SUM(case when is_hadir = true then 1 else 0 end) * 100.0 / count(*),2) as percentage_kehadiran
from mata_kuliah mk 
join attendance a on a.id_mata_kuliah = mk.id 
group by 1,2
order by 1

-- 4 --
select mk.id ,mk.nama,count(*) as jumlah_mahasiswa, dense_rank() over(order by count(*) desc) as rank 
from mahasiswa m 
join enrollment e on e.id_mahasiswa  = m.id 
join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
group by 1,2
order by rank

with ranked_total as (
	select mk.id ,mk.nama,count(*) as jumlah_mahasiswa, dense_rank() over(order by count(*) desc) as rank 
	from mahasiswa m 
	join enrollment e on e.id_mahasiswa  = m.id 
	join mata_kuliah mk on mk.id  = e.id_mata_kuliah 
	group by 1,2
)
select id,nama,jumlah_mahasiswa from ranked_total
where rank = 1
order by nama desc

-- 5 --
select e.id_dosen ,d.nama , mk.nama as mata_kuliah, round(avg(nv.nilai),2)
from dosen d 
join enrollment e ON e.id_dosen = d.id 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
join nilai_v2 nv on nv.id_enrollment = e.id 
group by 1,2,3
order by 1

-- 6 --
SELECT e.id_jurusan , j.jurusan , avg(n.nilai) , dense_rank () over(order by avg(n.nilai) desc) as rank
FROM nilai_v2 n
JOIN enrollment e on e.id = n.id_enrollment 
join jurusan j on j.id = e.id_jurusan 
group by 1,2

with ranked as (
	SELECT e.id_jurusan , j.jurusan , avg(n.nilai) as avg_nilai, dense_rank () over(order by avg(n.nilai) desc) as rank
	FROM nilai_v2 n
	JOIN enrollment e on e.id = n.id_enrollment 
	join jurusan j on j.id = e.id_jurusan 
	group by 1,2
)
select *
from ranked
where rank = 4

-- 7 --
select e.id_mata_kuliah , mk.nama  as mata_kuliah, d.nama as nama_dosen,
SUM(case when is_hadir = true then 1 else 0 end) as total_hadir,
--SUM(case when is_hadir = false then 1 else 0 end) as total_absen,
round(SUM(case when is_hadir = true then 1 else 0 end) * 100.0 / count(*),2) as percentage_kehadiran
from enrollment e 
join dosen d on d.id = e.id_dosen 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
join attendance a on a.id_mata_kuliah = e.id_mata_kuliah 
group by 1,2,3
having round(SUM(case when is_hadir = true then 1 else 0 end) * 100.0 / count(*),2) > 50
order by percentage_kehadiran desc,mk.nama asc 
limit 5


-- 8 --
select d.nama ,count(*)
from dosen d
join enrollment e ON e.id_dosen = d.id 
group by d.nama 
order by count(*) desc
limit 3

-- 9 --
select a.id_mata_kuliah ,mk.nama as mata_kuliah,a.week_kuliah,
SUM(case when is_hadir = true then 1 else 0 end) as mahasiswa_hadir
from attendance a 
join mata_kuliah mk on mk.id = a.id_mata_kuliah 
group by 1,2,3
order by 1,3

-- 10 --
select distinct e.id_dosen ,d.nama as nama_dosen, mk.sks ,mk.nama 
from dosen d 
join enrollment e on e.id_dosen = d.id 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
--group by 1,2
order by e.id_dosen ,mk.nama 

select e.id_dosen ,d.nama as nama_dosen, sum(distinct sks) as jumlah_sks, 
row_number() over(order by sum(distinct sks)desc, d.nama) as rank
from dosen d 
join enrollment e on e.id_dosen = d.id 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
group by e.id_dosen , nama_dosen
order by rank

with ranked as(
	select e.id_dosen ,d.nama as nama_dosen, sum(distinct sks) as jumlah_sks, 
	row_number() over(order by sum(distinct sks)desc, d.nama) as rank
	from dosen d 
	join enrollment e on e.id_dosen = d.id 
	join mata_kuliah mk on mk.id = e.id_mata_kuliah 
	group by e.id_dosen , nama_dosen
	order by rank
)
select * from ranked
where rank = 7





