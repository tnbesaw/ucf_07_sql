use sakila;


/* 1a. Display the first and last names of all actors from the table `actor`.*/
select a.first_name, a.last_name from actor a;


/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.*/
select upper(concat(a.first_name, ' ', a.last_name)) as "Actor Name" from actor a;


/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/
select a.actor_id, a.first_name, a.last_Name from actor a where upper(a.first_name) = 'JOE';


/* 2b. Find all actors whose last name contain the letters `GEN`:*/
select a.actor_id, a.first_name, a.last_Name from actor a where upper(a.last_name) LIKE '%GEN%';


/* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:*/
select a.actor_id, a.first_name, a.last_Name from actor a where upper(a.last_name) LIKE '%LI%' order by a.last_name, a.first_name;


/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:*/
select c.country_id, c.country from country c where c.country in ('Afghanistan', 'Bangladesh', 'China');


/* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).*/
alter table actor add description blob;


/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.*/
alter table actor drop column description;


/* 4a. List the last names of actors, as well as how many actors have that last name.*/
select a.last_name, count(1) cnt from actor a group by a.last_name order by a.last_name;


/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
select a.last_name, count(1) cnt from actor a group by a.last_name having cnt > 1 order by a.last_name;


/* 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.*/
update actor a set a.first_name = 'HARPO' where a.first_name = 'GROUCHO' and a.last_name = 'WILLIAMS';

    /*# confirm the update */
	select * from actor a where a.last_name = 'WILLIAMS';


/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
       In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.*/
update actor a set a.first_name = 'GROUCHO' where a.first_name = 'HARPO';

	/*# confirm the update */
	select * from actor a where a.first_name = 'HARPO';
	select * from actor a where a.first_name = 'GROUCHO';


/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?*/
SHOW CREATE TABLE address;

CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
  

/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:*/
select s.first_name, s.last_name, a.address
from   staff s
join   address a using (address_id);


/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.*/
select s.first_name, s.last_name, sum(p.amount) sum_payment
from   staff s
join   payment p using (staff_id)
where EXTRACT(YEAR_MONTH FROM payment_date) = '200505'
group by s.first_name, s.last_name;


/* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.*/
select f.title, count(fa.actor_id) cnt_actor
from   film f
inner join film_actor fa on f.film_id = fa.film_id
group by f.title
order by f.title;


/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?*/
select count(i.inventory_id) cnt_inventory
from   film f
inner join inventory i on f.film_id = i.film_id
where  f.title = 'Hunchback Impossible';


/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
  ![Total amount paid](Images/total_payment.png)*/
select c.first_name, c.last_name, sum(p.amount) as "Total Amount Paid"
from customer c
join  payment p on c.customer_id = p.customer_id
group by c.first_name, c.last_name
order by c.last_name, c.first_name;


/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
	    As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
	    Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.*/
select f.title 
from   film f
where  exists (select 1 from film xf where (xf.title like 'K%' or xf.title like 'Q%') and xf.film_id = f.film_id)
and    f.language_id = (select xl.language_id from language xl where xl.name = 'English')
order by f.title
;


/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.*/
select a.first_name, a.last_name
from   actor a
where  a.actor_id in
(
  select fa.actor_id
  from   film_actor fa
  where  fa.film_id in
    (
      select f.film_id
      from   film f
      where  f.title = 'Alone Trip'  
    )
);


/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
		Use joins to retrieve this information.*/
select c.customer_id, c.first_name, c.last_name, c.email
from   customer c
inner join address a  on a.address_id = c.address_id
inner join city    ci on ci.city_id = a.city_id
inner join country cn on cn.country_id = ci.country_id
where  cn.country = 'Canada';


/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.*/
select f.*
from   film f
where  f.film_id in
(
select fc.film_id
from   film_category fc
inner join category cat on fc.category_id = cat.category_id
where cat.name = 'Family'
);


/* 7e. Display the most frequently rented movies in descending order.*/
select f.title, count(1) cnt_rental
from   film f
inner join inventory i on i.film_id = f.film_id
inner join rental r on r.inventory_id = i.inventory_id
group by f.title
order by cnt_rental desc;


/* 7f. Write a query to display how much business, in dollars, each store brought in.*/
select s.store_id,
       sum(p.amount) AS 'total_sales'
from payment p
join rental r    on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join store s     on i.store_id = s.store_id
group by s.store_id
order by s.store_id;


/* 7g. Write a query to display for each store its store ID, city, and country.*/
select s.store_id, c.city, cy.country
from store s     
join address a   on s.address_id = a.address_id
join city c      on a.city_id = c.city_id
join country cy  on c.country_id = cy.country_id;


/* 7h. List the top five genres in gross revenue in descending order. 
        (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
select c.name,
       sum(p.amount) AS total_amount
from payment p
join rental r         on p.rental_id = r.rental_id
join inventory i      on r.inventory_id = i.inventory_id
join film_category fc on i.film_id = fc.film_id
join category c       on fc.category_id = c.category_id
group by c.name
order by total_amount desc
limit 5;


/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
        Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
create or replace view top_5_revenue_genres_vw as 
select c.name,
       sum(p.amount) AS total_amount
from payment p
join rental r         on p.rental_id = r.rental_id
join inventory i      on r.inventory_id = i.inventory_id
join film_category fc on i.film_id = fc.film_id
join category c       on fc.category_id = c.category_id
group by c.name
order by total_amount desc
limit 5;


/* 8b. How would you display the view that you created in 8a?*/
select * from top_5_revenue_genres_vw;


/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.*/
drop view top_5_revenue_genres_vw;
