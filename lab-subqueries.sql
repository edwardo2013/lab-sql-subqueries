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
    