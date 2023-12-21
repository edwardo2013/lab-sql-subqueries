use sakila;
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
select * from film;
select * from inventory;
 select * from film where title='Hunchback Impossible';
 
select *
from (select title,f.film_id,count(*)
  from film as f
  join inventory as i
  on f.film_id=i.film_id group by f.film_id) as `title_count`
where `title_count`.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.

select * from film;
 select round((avg(length))) as 'avg' from film;

select 
   * 
   from film as f
   where f.length > (select round((avg(length))) as 'avg' from film);

-- 3, Use a subquery to display all actors who appear in the film "Alone Trip".
select * from actor;
select * from film where title = 'Alone Trip';
select * from film_actor;

SELECT actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id
IN (SELECT film_actor.actor_id
    FROM film_actor
    JOIN film ON film_actor.film_id = film.film_id
    WHERE film.title = 'Alone Trip');
 
 -- BONUS
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion.
-- Identify all movies categorized as family films.
    select * from category; -- category_id is 8
    select * from film;
    select * from film_category;
    
select 
	title
	from film join film_category 
	on film.film_id=film_category.film_id
	where category_id =
     (select category_id from category where name='family');
   
   select title
    from film
    where film_id in
	(select 
      film_category.film_id
      from film_category
      join category
      on category.category_id=film_category.category_id
      where name='Family');

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. T
-- to use joins, you will need to identify the relevant tables and their primary and foreign keys.
select * from country where country='Canada';
select * from city where country_id= (select country_id from country where country='Canada');
select * from address where city_id IN (select city_id from city where country_id = (select country_id from country where country='Canada') );
select first_name,last_name,email from customer where address_id IN (select address_id from address where city_id IN (select city_id from city where country_id = (select country_id from country where country='Canada') ) );
SELECT 
    CONCAT(first_name, ' ', last_name) AS name, email
FROM
    customer
WHERE
    address_id IN (SELECT 
            address_id
        FROM
            address
        WHERE
            city_id IN (SELECT 
                    city_id
                FROM
                    city
                WHERE
                    country_id = (SELECT 
                            country_id
                        FROM
                            country
                        WHERE
                            country = 'Canada')));
-- join version
SELECT 
    CONCAT(first_name, ' ', last_name) AS name, 
    email
FROM
    customer
    join address on address.address_id=customer.address_id
    join city on city.city_id=address.city_id
    join country on country.country_id=city.country_id
    where country.country = 'Canada';
    
-- Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
select 
   actor.actor_id,
   count(film_actor.film_id)
   from actor
  join film_actor
  on actor.actor_id=film_actor.actor_id
  group by actor_id 
  order by count(film_actor.film_id) desc
  LIMIT 1;

-- use max to get the max
	select
    max(movie_count)
    from
        (select 
		   actor.actor_id,
		   count(film_actor.film_id) as movie_count
		   from actor
		  join film_actor
		  on actor.actor_id=film_actor.actor_id
		  group by actor_id) as grouped_movie;
	
    
    
     select actor.actor_id,
     count(film_actor.film_id)
     from actor
			  join film_actor
			  on actor.actor_id=film_actor.actor_id
              group by actor_id having count(film_actor.film_id) =
		(select
		max(movie_count)
		from
			(select 
			   actor.actor_id,
			   count(film_actor.film_id) as movie_count
			   from actor
			  join film_actor
			  on actor.actor_id=film_actor.actor_id
			  group by actor_id) as grouped_movie);
              
              
	 select actor.actor_id,
     count(film_actor.film_id)
     from actor
			  join film_actor
			  on actor.actor_id=film_actor.actor_id
              group by actor_id having count(film_actor.film_id) =
		(select
		max(movie_count)
		from
			(select 
			   actor.actor_id,
			   count(film_actor.film_id) as movie_count
			   from actor
			  join film_actor
			  on actor.actor_id=film_actor.actor_id
			  group by actor_id) as grouped_movie);

-- Solution
SELECT title
FROM actor
JOIN film_actor ON actor.actor_id=film_actor.actor_id
JOIN film ON film.film_id=film_actor.film_id
WHERE actor.actor_id=(SELECT actor.actor_id
FROM actor 
JOIN film_actor ON actor.actor_id=film_actor.actor_id
GROUP BY actor_id
HAVING COUNT(film_actor.film_id) =(SELECT 
MAX(movies_count)
FROM
(SELECT actor.actor_id,COUNT(film_actor.film_id)AS movies_count
FROM actor 
JOIN film_actor ON actor.actor_id=film_actor.actor_id
GROUP BY actor_id)as grouped_movie));

-- Solution
SELECT title
FROM actor
JOIN film_actor ON actor.actor_id=film_actor.actor_id
JOIN film ON film.film_id=film_actor.film_id
WHERE actor.actor_id=(SELECT actor.actor_id
FROM actor 
JOIN film_actor ON actor.actor_id=film_actor.actor_id
GROUP BY actor_id
ORDER BY COUNT(film_actor.film_id) DESC
LIMIT 1);

-- Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., 
-- the customer who has made the largest sum of payments.
select customer_id, SUM(amount) from payment group by customer_id order by SUM(amount) desc limit 1;



	SELECT 
		customer_id, SUM(amount) as spent
	FROM
		payment
	GROUP BY customer_id
	having SUM(amount) =
		(select 
		MAX(spent)
		from
			(SELECT 
				customer_id, SUM(amount) as spent
			FROM
				payment
			GROUP BY customer_id) as grouped);

-- solution
    select 
      title
      from rental
      join inventory on inventory.inventory_id=rental.rental_id
      join film on film.film_id=inventory.film_id
      where customer_id =
      	(SELECT 
		customer_id
	FROM
		payment
	GROUP BY customer_id
	having SUM(amount) =
		(select 
		MAX(spent)
		from
			(SELECT 
				customer_id, SUM(amount) as spent
			FROM
				payment
			GROUP BY customer_id) as grouped) );
            
select 
      title,payment.amount
      from rental
      join inventory on inventory.inventory_id=rental.rental_id
      join film on film.film_id=inventory.film_id
      join payment on rental.rental_id=payment.payment_id
      where rental.customer_id =
      	(SELECT 
		customer_id
	FROM
		payment
	GROUP BY customer_id
	having SUM(amount) =
		(select 
		MAX(spent)
		from
			(SELECT 
				customer_id, SUM(amount) as spent
			FROM
				payment
			GROUP BY customer_id) as grouped) );
            
-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent 
-- by each client. You can use subqueries to accomplish this.

-- select custoemrs with total amount
select payment.customer_id, SUM(payment.amount)
 from payment
 group by customer_id;
 
 -- Do the avg
 select
   avg(total_amount)
   from
	 (select payment.customer_id, SUM(payment.amount) as total_amount
	 from payment
	 group by customer_id) as grouped;

-- now selectthe customers that have paid more than the avg
select payment.customer_id, SUM(payment.amount)
	 from payment
	 group by customer_id
     having SUM(payment.amount) >
		   (select
	        avg(total_amount)
		    from
			 (select payment.customer_id, SUM(payment.amount) as total_amount
			 from payment
			 group by customer_id) as grouped);