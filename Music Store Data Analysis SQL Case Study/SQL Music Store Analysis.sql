--Easy Q:1 
select first_name,last_name, title from employee
order by levels desc limit 1
--Easy Q:2
select count(*) as c, billing_country from invoice
group by billing_country
order by c desc
limit 1
--Easy Q:3
select total from invoice order by total desc limit 3
--Easy Q:4
SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;
--Easy Q:5
SELECT customer.customer_id as c,customer.first_name, customer.last_name, SUM(total) as tt
FROM customer JOIN invoice 
ON Customer.Customer_Id=Invoice.Customer_Id 
GROUP BY c order by tt desc limit 1

--Moderate Q:1
select distinct customer.email, customer.first_name, customer.last_name
from customer 
join invoice on customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
where track_id in
(select track_id from track join genre on 
track.genre_id=genre.genre_id where genre.name='Rock')
order by email
--Moderate Q:2
select artist.artist_id,artist.name,count(artist.artist_id) as nos
from track
join album on track.album_id=album.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name LIKE 'Rock'
group by artist.artist_id
order by nos desc
limit 10
--Moderate Q:3
SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC
--Advance Q:1
with bestSellingArtist as
(select artist.artist_id, artist.name, 
sum(invoice_line.unit_price*invoice_line.quantity)
from artist
join album on album.artist_id=artist.artist_id
join track on track.album_id=album.album_id
join invoice_line on invoice_line.track_id=track.track_id
group by 1
order by 3 desc
limit 1)

select c.customer_id, c.first_name,c.last_name, SUM(il.unit_price*il.quantity)as amount_spent,bsa.name
from customer c
join invoice i on i.customer_id=c.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on il.track_id=t.track_id
join album a on t.album_id=a.album_id
join bestSellingArtist bsa on bsa.artist_id=a.artist_id
group by 1,2,3,5
order by 4 desc
--Advance Q:2
with popular_genre as(
select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() over(partition by customer.country order by count(invoice_line.quantity)desc) as RowNo
from invoice_line 
join invoice on invoice_line.invoice_id=invoice.invoice_id
join customer on customer.customer_id=invoice.customer_id
join track on track.track_id=invoice_line.track_id
join genre on track.genre_id=genre.genre_id
group by 2,3,4
order by 2 asc, 1 desc )

select * from popular_genre where rowno=1
--Advance Q:3
with Customer_with_country as
(select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total) desc) as rowno
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 4 asc,5 desc)
select * from Customer_with_country where RowNo <= 1